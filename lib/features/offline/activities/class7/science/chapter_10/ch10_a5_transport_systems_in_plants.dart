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

/// Class 7 Science • Chapter 10 • Activity 5
/// Transport Systems in Plants.
///
/// Native Flutter port of `Cl7S-Ch10-A5-Transport_Systems_in_Plants.html`.
/// Two cut twigs stand in clear and red-inked water; a 24 hour time-lapse
/// sends the red up twig B's xylem, seen in a magnified stem cross-section.
/// Then glucose from a sunlit leaf travels down the phloem into a potato.
class Ch10A5TransportSystemsInPlantsPage extends StatefulWidget {
  const Ch10A5TransportSystemsInPlantsPage({super.key});

  @override
  State<Ch10A5TransportSystemsInPlantsPage> createState() => _Ch10A5TransportSystemsInPlantsPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pickup 2356, drop 2364, splash 1311,
/// whoosh 1492, magic 871.
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

  /// HTML `drag` tone: an item is picked up.
  pickup('pickup.mp3'),

  /// HTML `drop` tone: a twig lands in a tumbler, ink drops fall.
  drop('drop.mp3'),

  /// HTML `pour` noise: the jug pours water.
  splash('splash.mp3'),

  /// HTML `slice` tone: the scalpel cuts a stem.
  whoosh('whoosh.mp3'),

  /// HTML `magic` arpeggio: sun, magnifier, glucose, tuber.
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

/// CSS variables and Tailwind colours used by this lab.
abstract final class _Colors {
  // HTML --accent (dark / light theme).
  static const Color green500 = Color(0xFF22C55E);
  static const Color emerald500 = Color(0xFF10B981);

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

  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color blue = Color(0xFF3B82F6); // xylem
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue700 = Color(0xFF1D4ED8);

  static const Color red = Color(0xFFEF4444);
  static const Color red200 = Color(0xFFFECACA);
  static const Color red300 = Color(0xFFFCA5A5);
  static const Color red700 = Color(0xFFB91C1C);
  static const Color red900 = Color(0xFF7F1D1D);

  static const Color green50 = Color(0xFFF0FDF4);
  static const Color green100 = Color(0xFFDCFCE7);
  static const Color green200 = Color(0xFFBBF7D0);
  static const Color green300 = Color(0xFF86EFAC);
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green600 = Color(0xFF16A34A);
  static const Color green700 = Color(0xFF15803D);
  static const Color green800 = Color(0xFF166534);
  static const Color green900 = Color(0xFF14532D);
  static const Color emerald800 = Color(0xFF065F46);
  static const Color emerald900 = Color(0xFF064E3B);

  static const Color yellow100 = Color(0xFFFEF9C3);
  static const Color yellow200 = Color(0xFFFEF08A);
  static const Color yellow400 = Color(0xFFFACC15);
  static const Color yellow600 = Color(0xFFCA8A04);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);
  static const Color amber800 = Color(0xFF92400E);
  static const Color amber900 = Color(0xFF78350F);

  static const Color sky50 = Color(0xFFF0F9FF);
  static const Color sky100 = Color(0xFFE0F2FE);
  static const Color sky200 = Color(0xFFBAE6FD);

  // Scenario 2 soil (HTML #5c3a21 with a #3d2413 top edge).
  static const Color soil = Color(0xFF5C3A21);
  static const Color soilDark = Color(0xFF3D2413);
}

/// This lab's light and dark palettes (the HTML `:root` / `.light-theme`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate900,
    panel: Color(0xF71E293B),
    border: _Colors.slate700,
    card: Color(0xCC0F172A),
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.slate900,
    text: _Colors.slate200,
    textStrong: _Colors.slate50,
    textMuted: _Colors.slate400,
    accent: _Colors.green500,
    onAccent: _Colors.slate900,
    primary: _Colors.indigo600,
    onPrimary: Colors.white,
    success: _Colors.green500,
    danger: _Colors.red,
    onDanger: Colors.white,
    info: _Colors.blue,
    popupBg: _Colors.slate900,
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate800,
    toastBg: _Colors.slate100,
    toastText: _Colors.slate900,
    curtainBg: _Colors.slate950,
    curtainGlow: Color(0x4D22C55E),
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
    bg: _Colors.slate100,
    panel: Color(0xF7FFFFFF),
    border: _Colors.slate300,
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.slate100,
    text: _Colors.slate800,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.emerald500,
    onAccent: _Colors.slate900,
    primary: _Colors.indigo600,
    onPrimary: Colors.white,
    success: _Colors.green500,
    danger: _Colors.red,
    onDanger: Colors.white,
    info: _Colors.blue,
    popupBg: Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: Colors.white,
    toastBg: _Colors.slate900,
    toastText: Colors.white,
    curtainBg: _Colors.slate950,
    curtainGlow: Color(0x4D22C55E),
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
    'app_title': 'Transport Systems in Plants',
    'app_subtitle': 'Class 7 • Life Processes in Plants',
    'scen_1_opt': '1. The Upward Journey: Xylem',
    'scen_2_opt': '2. Food Delivery Network: Phloem',
    'sci_conclusion': 'Scientific Conclusion',
    'exp_out': 'Expected Outcome',
    // Conclusion panels (HTML s1_conclusion / s2_conclusion).
    's1_res_title': 'Xylem Transport Result',
    's1_res_p0': 'The red color traced the path of water.',
    's1_res_p1':
        'The red tint only appeared in specific tubes within the stem and moved strictly upwards into the leaves and flower petals.',
    's1_res_p2': 'The detailed cross-section proved that the **XYLEM** tissue is responsible for this upward conduction.',
    's1_res_conc': 'Conclusion: Water travels upwards through special tubes called XYLEM.',
    's2_res_title': 'Phloem Transport Result',
    's2_res_p0': 'The glowing glucose traced the path of food.',
    's2_res_p1':
        'Food created in the leaves moved downwards through a separate network of tubes, entirely distinct from the xylem.',
    's2_res_p2': 'When it reached the roots, it was stored in the potato tuber, causing growth.',
    's2_res_conc': 'Conclusion: Food travels from leaves to all parts via tubes called PHLOEM.',
    // HUD feedback (HTML hud.*).
    'h_startTumb': 'Drag jug to Tumbler A, then Tumbler B.',
    'h_tumbReady': 'Tumblers filled.',
    'h_addInk': 'Drag red ink to Tumbler B.',
    'h_inkAdded': 'Red ink added.',
    'h_prepTwigs': 'Drag scalpel to the red CUT zones at base of Twig A and B.',
    'h_twigsCut': 'Twigs cut obliquely.',
    'h_placeTwigs': 'Drag twigs into the tumblers.',
    'h_setupReady': 'Setup ready for observation.',
    'h_timePass': 'Time passing...',
    'h_sim24h': 'Simulating 24 hours...',
    'h_obsRed': 'Observe the red streaks.',
    'h_useMag': "Drag the magnifying glass to Twig B's stem.",
    'h_conc': 'Conclusion.',
    'h_clickSun': 'Click the sun to start photosynthesis.',
    'h_sunOn': 'Photosynthesis active.',
    'h_clickLeaf': 'Click the left leaf.',
    'h_foodMade': 'Glucose (food) produced.',
    'h_clickPhloem': 'Click the green phloem tube.',
    'h_phloemOn': 'Phloem active.',
    'h_dragFood': 'Drag the yellow food to the phloem.',
    'h_foodMoving': 'Food is traveling.',
    'h_clickPotato': 'Click the potato tuber for storage.',
    'h_potatoGrew': 'Tuber stored food and grew.',
    'btn_ff': 'Fast Forward 24 Hours',
    // Scene labels (HTML lbl.*).
    'tumbA': 'Tumbler A',
    'tumbB': 'Tumbler B',
    'jug': 'Water Jug',
    'ink': 'Red Ink',
    'twigA': 'Twig A',
    'twigB': 'Twig B',
    'scalpel': 'Scalpel',
    'mag': 'Magnifier',
    'sun': 'Sun',
    'leaf': 'Leaf',
    'glucose': 'Glucose',
    'tuber': 'Potato Tuber',
    'phloem': 'Phloem',
    'xylem': 'Xylem',
    'light': 'Light',
    'water': 'Water',
    'co2': 'CO2',
    // Strings that were hard-coded in the HTML scene.
    'click': 'CLICK',
    'produced': 'PRODUCED',
    'cut_a': 'CUT A',
    'cut_b': 'CUT B',
  },
  'hi': {
    'app_title': 'पौधों में परिवहन प्रणाली',
    'app_subtitle': 'कक्षा 7 • पौधों में जैव प्रक्रम',
    'scen_1_opt': '1. ऊपर की ओर यात्रा: जाइलम',
    'scen_2_opt': '2. भोजन वितरण नेटवर्क: फ्लोएम',
    'sci_conclusion': 'वैज्ञानिक निष्कर्ष',
    'exp_out': 'अपेक्षित परिणाम',
    's1_res_title': 'जाइलम परिवहन परिणाम',
    's1_res_p0': 'लाल रंग ने पानी के मार्ग का पता लगाया।',
    's1_res_p1':
        'लाल रंग केवल तने के भीतर विशेष नलिकाओं में दिखाई दिया और सीधे ऊपर की ओर पत्तियों और फूलों की पंखुड़ियों तक गया।',
    's1_res_p2': 'विस्तृत अनुप्रस्थ काट (क्रॉस-सेक्शन) ने सिद्ध किया कि **जाइलम** ऊतक ही इस ऊपर की ओर चालन के लिए उत्तरदायी है।',
    's1_res_conc': 'निष्कर्ष: पानी जाइलम नामक विशेष नलिकाओं के माध्यम से ऊपर की ओर जाता है।',
    's2_res_title': 'फ्लोएम परिवहन परिणाम',
    's2_res_p0': 'चमकते ग्लूकोज ने भोजन के मार्ग का पता लगाया।',
    's2_res_p1': 'पत्तियों में बना भोजन नलिकाओं के एक अलग नेटवर्क से नीचे की ओर गया, जो जाइलम से पूरी तरह अलग है।',
    's2_res_p2': 'जड़ों तक पहुँचकर भोजन आलू के कंद में जमा हो गया, जिससे कंद बढ़ गया।',
    's2_res_conc': 'निष्कर्ष: भोजन पत्तियों से फ्लोएम नामक नलिकाओं के माध्यम से सभी भागों तक जाता है।',
    'h_startTumb': 'जग को पहले टंबलर A पर, फिर टंबलर B पर खींचें।',
    'h_tumbReady': 'टंबलर भर गए।',
    'h_addInk': 'लाल स्याही को टंबलर B पर खींचें।',
    'h_inkAdded': 'लाल स्याही मिला दी गई।',
    'h_prepTwigs': 'स्केलपेल को टहनी A और B के आधार पर बने लाल कट ज़ोन पर खींचें।',
    'h_twigsCut': 'टहनियाँ तिरछी कट गईं।',
    'h_placeTwigs': 'टहनियों को टंबलर में खींचें।',
    'h_setupReady': 'अवलोकन के लिए सेटअप तैयार है।',
    'h_timePass': 'समय बीत रहा है...',
    'h_sim24h': '24 घंटे का अनुकरण...',
    'h_obsRed': 'लाल धारियों का निरीक्षण करें।',
    'h_useMag': 'आवर्धक कांच को टहनी B के तने पर खींचें।',
    'h_conc': 'निष्कर्ष।',
    'h_clickSun': 'प्रकाश संश्लेषण शुरू करने के लिए सूर्य पर क्लिक करें।',
    'h_sunOn': 'प्रकाश संश्लेषण सक्रिय।',
    'h_clickLeaf': 'बाईं पत्ती पर क्लिक करें।',
    'h_foodMade': 'ग्लूकोज (भोजन) बन गया।',
    'h_clickPhloem': 'हरी फ्लोएम नली पर क्लिक करें।',
    'h_phloemOn': 'फ्लोएम सक्रिय।',
    'h_dragFood': 'पीले भोजन को फ्लोएम में खींचें।',
    'h_foodMoving': 'भोजन यात्रा कर रहा है।',
    'h_clickPotato': 'भंडारण के लिए आलू के कंद पर क्लिक करें।',
    'h_potatoGrew': 'कंद ने भोजन संग्रहीत किया और बढ़ गया।',
    'btn_ff': '24 घंटे आगे बढ़ाएँ',
    'tumbA': 'टंबलर A',
    'tumbB': 'टंबलर B',
    'jug': 'पानी का जग',
    'ink': 'लाल स्याही',
    'twigA': 'टहनी A',
    'twigB': 'टहनी B',
    'scalpel': 'स्केलपेल',
    'mag': 'आवर्धक',
    'sun': 'सूर्य',
    'leaf': 'पत्ती',
    'glucose': 'ग्लूकोज',
    'tuber': 'आलू कंद',
    'phloem': 'फ्लोएम',
    'xylem': 'जाइलम',
    'light': 'प्रकाश',
    'water': 'पानी',
    'co2': 'CO2',
    'click': 'क्लिक करें',
    'produced': 'बन गया',
    'cut_a': 'कट A',
    'cut_b': 'कट B',
  },
};

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To demonstrate that water and dissolved minerals are transported upwards from the roots through the stem to all parts of the plant via the xylem tissue.',
      steps: [
        LabStep(
          concept: 'Preparation',
          action: 'DRAG the jug to Tumbler A, then Tumbler B to fill them one-third full with water.',
          observation: 'Two tumblers are on the table, partially filled with water.',
        ),
        LabStep(
          concept: 'Adding Tracer',
          action: 'DRAG the bottle of red ink and DROP it on Tumbler B to add a few drops.',
          observation: 'The water in Tumbler B turns a vibrant red color. Tumbler A remains clear.',
        ),
        LabStep(
          concept: 'Preparing Stems',
          action: 'DRAG the scalpel and DROP it on the massive red CUT zones at the base of Twig A and Twig B.',
          observation: 'The base of each stem shows a clean, angled cut for better absorption.',
        ),
        LabStep(
          concept: 'Placement',
          action:
              'DRAG the first twig into Tumbler A (clear water). DRAG the second twig into Tumbler B (red water).',
          observation: 'Each tumbler contains a plant twig.',
        ),
        LabStep(
          concept: 'Time Lapse',
          action: "CLICK the 'Fast Forward 24 Hours' button.",
          observation:
              'The plant in Tumbler B shows red streaks in the stem, leaves, and flowers. Plant A is unchanged.',
        ),
        LabStep(
          concept: 'Microscopic View',
          action: 'DRAG the magnifying glass over the stem of the plant from Tumbler B.',
          observation: 'A cross-section reveals only the xylem tubes are stained red.',
        ),
        LabStep(
          concept: 'Conclusion',
          action: 'Observe the summary panel.',
          observation: 'Confirmation that water travels upwards through the xylem.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To demonstrate that food (glucose) made in the leaves during photosynthesis is transported to all other parts of the plant for energy or storage via the phloem tissue.',
      steps: [
        LabStep(
          concept: 'Photosynthesis',
          action: 'A potato plant is shown. CLICK the pulsing Sun icon to begin photosynthesis.',
          observation: 'The sun shines brightly, sending light to the leaves.',
        ),
        LabStep(
          concept: 'Food Creation',
          action: 'CLICK on the large, green leaf on the left.',
          observation: 'The leaf reveals a 3D diagram showing glucose production.',
        ),
        LabStep(
          concept: 'Phloem Network',
          action: "The plant's vascular system is visible. CLICK the green phloem tube connected to the leaf.",
          observation: 'The phloem network activates and glows.',
        ),
        LabStep(
          concept: 'Loading Food',
          action: 'DRAG the glowing yellow glucose from the leaf into the green phloem tube.',
          observation: 'Food particles begin traveling down the stem.',
        ),
        LabStep(
          concept: 'Storage',
          action: 'CLICK on the potato tuber in the roots to direct the food there for storage.',
          observation: 'Food enters the tuber, causing it to swell and grow.',
        ),
        LabStep(
          concept: 'Conclusion',
          action: 'Observe the summary panel.',
          observation: 'Confirmation that phloem transports food to all plant parts.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'यह प्रदर्शित करना कि पानी और उसमें घुले खनिज जाइलम ऊतक के माध्यम से जड़ों से तने होते हुए पौधे के सभी भागों तक ऊपर की ओर पहुँचाए जाते हैं।',
      steps: [
        LabStep(
          concept: 'तैयारी',
          action: 'जग को पहले टंबलर A पर, फिर टंबलर B पर खींचें ताकि दोनों एक-तिहाई पानी से भर जाएँ।',
          observation: 'मेज़ पर दो टंबलर हैं, जिनमें कुछ पानी भरा है।',
        ),
        LabStep(
          concept: 'ट्रेसर मिलाना',
          action: 'लाल स्याही की बोतल को खींचें और कुछ बूँदें डालने के लिए उसे टंबलर B पर छोड़ें।',
          observation: 'टंबलर B का पानी चमकीला लाल हो जाता है। टंबलर A का पानी साफ़ रहता है।',
        ),
        LabStep(
          concept: 'तने तैयार करना',
          action: 'स्केलपेल को खींचें और टहनी A तथा टहनी B के आधार पर बने बड़े लाल कट ज़ोन पर छोड़ें।',
          observation: 'बेहतर अवशोषण के लिए हर तने के आधार पर एक साफ़, तिरछा कट दिखता है।',
        ),
        LabStep(
          concept: 'टहनियाँ रखना',
          action: 'पहली टहनी को टंबलर A (साफ़ पानी) में खींचें। दूसरी टहनी को टंबलर B (लाल पानी) में खींचें।',
          observation: 'हर टंबलर में एक टहनी रखी है।',
        ),
        LabStep(
          concept: 'टाइम लैप्स',
          action: "'24 घंटे आगे बढ़ाएँ' बटन पर क्लिक करें।",
          observation: 'टंबलर B वाले पौधे के तने, पत्तियों और फूलों में लाल धारियाँ दिखती हैं। पौधा A वैसा ही रहता है।',
        ),
        LabStep(
          concept: 'सूक्ष्म दृश्य',
          action: 'आवर्धक कांच को टंबलर B वाले पौधे के तने पर खींचें।',
          observation: 'अनुप्रस्थ काट से पता चलता है कि केवल जाइलम नलिकाएँ ही लाल रंगी हैं।',
        ),
        LabStep(
          concept: 'निष्कर्ष',
          action: 'सारांश पैनल देखें।',
          observation: 'पुष्टि कि पानी जाइलम के माध्यम से ऊपर की ओर जाता है।',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'यह प्रदर्शित करना कि प्रकाश संश्लेषण के दौरान पत्तियों में बना भोजन (ग्लूकोज) फ्लोएम ऊतक के माध्यम से ऊर्जा या भंडारण के लिए पौधे के अन्य सभी भागों तक पहुँचाया जाता है।',
      steps: [
        LabStep(
          concept: 'प्रकाश संश्लेषण',
          action: 'आलू का एक पौधा दिखाया गया है। प्रकाश संश्लेषण शुरू करने के लिए धड़कते हुए सूर्य आइकन पर क्लिक करें।',
          observation: 'सूर्य तेज़ चमकता है और पत्तियों तक प्रकाश भेजता है।',
        ),
        LabStep(
          concept: 'भोजन का निर्माण',
          action: 'बाईं ओर की बड़ी, हरी पत्ती पर क्लिक करें।',
          observation: 'पत्ती एक 3D आरेख दिखाती है जिसमें ग्लूकोज बनता दिखता है।',
        ),
        LabStep(
          concept: 'फ्लोएम नेटवर्क',
          action: 'पौधे का संवहन तंत्र दिख रहा है। पत्ती से जुड़ी हरी फ्लोएम नली पर क्लिक करें।',
          observation: 'फ्लोएम नेटवर्क सक्रिय होकर चमकने लगता है।',
        ),
        LabStep(
          concept: 'भोजन भरना',
          action: 'चमकते पीले ग्लूकोज को पत्ती से खींचकर हरी फ्लोएम नली में छोड़ें।',
          observation: 'भोजन के कण तने में नीचे की ओर जाने लगते हैं।',
        ),
        LabStep(
          concept: 'भंडारण',
          action: 'भोजन को भंडारण के लिए वहाँ भेजने हेतु जड़ों में लगे आलू के कंद पर क्लिक करें।',
          observation: 'भोजन कंद में पहुँचता है, जिससे वह फूलकर बड़ा हो जाता है।',
        ),
        LabStep(
          concept: 'निष्कर्ष',
          action: 'सारांश पैनल देखें।',
          observation: 'पुष्टि कि फ्लोएम पौधे के सभी भागों तक भोजन पहुँचाता है।',
        ),
      ],
    ),
  ],
};

// ============================================================== STATE

/// The HTML `#scene-content` box (900 x 600 px).
const Size _design = Size(900, 600);

// Scenario 1: lab bench, tumblers (glass 70 x 100 like the HTML SVG).
const double _benchY = 446;
const double _tumbAX = 200;
const double _tumbBX = 350;
const double _glassTop = 346;
const double _fillLevel = 0.4; // HTML `scaleY(0.4)`: "one-third full"

/// Bottom of a twig standing in a tumbler.
const double _twigInY = 440;

/// Jug spout / ink bottle mouth in their local coordinates (origin at the
/// bottom centre), used to aim the pour.
const Offset _jugSpout = Offset(-38, -117);
const Offset _inkMouth = Offset(0, -90);
const double _jugPourAngle = -0.7;
const double _inkPourAngle = -0.8;

// Scenario 2 (HTML master SVG, viewBox 900 x 600). The ground line is moved
// up to the stem base so roots and tuber sit underground.
const double _groundY = 400;
const Offset _sunC = Offset(155, 115);
const Offset _leafPivot = Offset(200, 240); // HTML origin-bottom-right
const Offset _potatoC = Offset(550, 480);
const Rect _phloemClick = Rect.fromLTWH(445, 320, 30, 60);
const Rect _leafCard = Rect.fromLTWH(80, 30, 350, 250);

// Magnified stem view (scenario 1, step 6).
const Offset _lensC = Offset(350, 314);
const Offset _zoomC = Offset(680, 250);
const double _zoomR = 118;

/// Draggable scene objects (the HTML `.draggable` elements).
enum _Item { jug, ink, scalpel, twigA, twigB, mag, food }

/// Where each item rests (box centre).
const Map<_Item, Offset> _home = {
  _Item.jug: Offset(510, 376),
  _Item.ink: Offset(490, 396),
  _Item.scalpel: Offset(700, 345),
  _Item.twigA: Offset(480, 305),
  _Item.twigB: Offset(605, 320),
  _Item.mag: Offset(460, 210),
  _Item.food: Offset(106, 215),
};

/// Box of each item (HTML element size), used to grab it and for the HTML
/// rect-overlap drop test.
const Map<_Item, Size> _box = {
  _Item.jug: Size(100, 140),
  _Item.ink: Size(56, 100),
  _Item.scalpel: Size(100, 40),
  _Item.twigA: Size(80, 170),
  _Item.twigB: Size(80, 170),
  _Item.mag: Size(120, 120),
  _Item.food: Size(40, 40),
};

/// A twig's stem base relative to its box centre.
const Offset _twigFoot = Offset(0, 80);

Offset _twigBase(bool a) => _home[a ? _Item.twigA : _Item.twigB]! + _twigFoot;

/// An HTML `.dropzone`.
class _Zone {
  const _Zone(this.id, this.rect, {this.oval = false});
  final String id;
  final Rect rect;
  final bool oval;
}

const Rect _zTumbA = Rect.fromLTWH(150, 290, 100, 160);
const Rect _zTumbB = Rect.fromLTWH(300, 290, 100, 160);
const Rect _zPlaceA = Rect.fromLTWH(140, 280, 120, 180);
const Rect _zPlaceB = Rect.fromLTWH(290, 280, 120, 180);
const Rect _zTwigB = Rect.fromLTWH(310, 250, 90, 200);
const Rect _zPhloem = Rect.fromLTWH(405, 280, 50, 80);

Rect _cutZone(bool a) => Rect.fromCenter(center: _twigBase(a), width: 100, height: 80);

Offset _rotate(Offset v, double a) {
  final c = math.cos(a), s = math.sin(a);
  return Offset(v.dx * c - v.dy * s, v.dx * s + v.dy * c);
}

double _ease(double v) => Curves.easeInOut.transform(v.clamp(0.0, 1.0));

/// Mutable scene model read by the painter every frame. Field names follow
/// the HTML `state.prog1` / `state.prog2`; `...At` fields hold the scene
/// time an animation started.
class _PlantScene {
  int scenario = 0;

  /// HTML `state.step` (0-based).
  int step = 0;
  double time = 0;
  double stepAt = 0;

  // Scenario 1.
  bool tA = false, tB = false, jugAnimating = false, inkDrop = false;
  bool cutA = false, cutB = false, inA = false, inB = false, sim = false, mag = false;
  String? pourZone;
  double pourAt = 0;
  Offset pourFrom = Offset.zero;
  double? fillAAt, fillBAt, inkAt, cutAt, cutAAt, cutBAt, placeAAt, placeBAt, simAt, magAt;
  Offset inkFrom = Offset.zero, cutFrom = Offset.zero, placeAFrom = Offset.zero, placeBFrom = Offset.zero;
  bool cutOnA = true;

  // Scenario 2.
  bool sun = false, leaf = false, phloem = false, foodMoving = false, potato = false;
  double? sunAt, vascAt, phloemAt, foodAt, potatoAt;

  // Dragging and snapping back.
  _Item? dragItem;
  Offset dragPos = Offset.zero, dragStart = Offset.zero, grabDelta = Offset.zero;
  _Item? snapItem;
  Offset snapFrom = Offset.zero;
  double snapAt = 0;

  /// HTML `loadScenario()`: fresh `prog1` / `prog2`.
  void resetProgress() {
    step = 0;
    stepAt = time;
    tA = tB = jugAnimating = inkDrop = cutA = cutB = inA = inB = sim = mag = false;
    pourZone = null;
    fillAAt = fillBAt = inkAt = cutAt = cutAAt = cutBAt = placeAAt = placeBAt = simAt = magAt = null;
    sun = leaf = phloem = foodMoving = potato = false;
    sunAt = vascAt = phloemAt = foodAt = potatoAt = null;
    dragItem = snapItem = null;
  }

  /// 0..1 progress of an animation that started at [at].
  double prog(double? at, double dur, {double delay = 0}) =>
      at == null ? 0 : ((time - at - delay) / dur).clamp(0.0, 1.0);

  bool get cutting => cutAt != null && time - cutAt! < 0.95;

  /// Current box centre of [item] (resting, dragged or snapping back).
  Offset posOf(_Item item) {
    final home = _home[item]!;
    if (dragItem == item) return dragPos;
    if (snapItem == item) {
      final k = Curves.easeOutCubic.transform(prog(snapAt, 0.3));
      if (k < 1) return Offset.lerp(snapFrom, home, k)!;
    }
    return home;
  }

  /// Items the user may pick up now (HTML `.draggable` without
  /// `.animating-locked`).
  List<_Item> draggables() {
    if (scenario == 1) return [if (step == 3 && phloem && !foodMoving) _Item.food];
    return switch (step) {
      0 => [if (!jugAnimating && !(tA && tB)) _Item.jug],
      1 => [if (inkAt == null) _Item.ink],
      2 => [if (!cutting && !(cutA && cutB)) _Item.scalpel],
      3 => [if (!inA) _Item.twigA, if (!inB) _Item.twigB],
      5 => [if (!mag) _Item.mag],
      _ => const [],
    };
  }

  /// Drop zones that accept [item] now (HTML `handleOrganicDrop`).
  List<_Zone> targetsFor(_Item item) {
    if (scenario == 1) {
      return [if (item == _Item.food && step == 3 && phloem && !foodMoving) const _Zone('phloem', _zPhloem, oval: true)];
    }
    return switch ((step, item)) {
      (0, _Item.jug) when !jugAnimating => [
          if (!tA) const _Zone('A', _zTumbA),
          if (!tB) const _Zone('B', _zTumbB),
        ],
      (1, _Item.ink) => [const _Zone('B', _zTumbB)],
      (2, _Item.scalpel) => [
          if (!cutA) _Zone('cutA', _cutZone(true), oval: true),
          if (!cutB) _Zone('cutB', _cutZone(false), oval: true),
        ],
      (3, _Item.twigA) when !inA => [const _Zone('A', _zPlaceA)],
      (3, _Item.twigB) when !inB => [const _Zone('B', _zPlaceB)],
      (5, _Item.mag) when !mag => [const _Zone('twigB', _zTwigB)],
      _ => const [],
    };
  }

  /// HTML drop test: the item's box overlaps a zone padded by 20 px. When
  /// several zones match, the nearest one wins.
  _Zone? dropZone(_Item item, Offset centre) {
    final size = _box[item]!;
    final r = Rect.fromCenter(center: centre, width: size.width, height: size.height);
    _Zone? best;
    var bestD = double.infinity;
    for (final z in targetsFor(item)) {
      if (!r.overlaps(z.rect.inflate(20))) continue;
      final d = (z.rect.center - centre).distance;
      if (d < bestD) {
        bestD = d;
        best = z;
      }
    }
    return best;
  }
}

/// One canvas-confetti particle (same physics as `confetti.browser.js`).
class _Fetti {
  _Fetti(math.Random r, double spread, this.color)
      : circle = r.nextBool(),
        wobble = r.nextDouble() * 10,
        wobbleSpeed = math.min(0.11, r.nextDouble() * 0.1 + 0.05),
        velocity = 45 * 0.5 + r.nextDouble() * 45,
        angle = -math.pi / 2 + (0.5 * spread - r.nextDouble() * spread),
        tilt = (r.nextDouble() * 0.5 + 0.25) * math.pi;

  final Color color;
  final bool circle;
  double x = 0, y = 0, wobble, wobbleSpeed, velocity, angle, tilt;
  double random = 2, tiltSin = 0, tiltCos = 0, wobbleX = 0, wobbleY = 0;
  int tick = 0;
  static const int ticks = 200;

  void update(math.Random r) {
    x += math.cos(angle) * velocity;
    y += math.sin(angle) * velocity + 3; // gravity 1 x 3
    velocity *= 0.9; // decay
    wobble += wobbleSpeed;
    wobbleX = x + 10 * math.cos(wobble);
    wobbleY = y + 10 * math.sin(wobble);
    tilt += 0.1;
    tiltSin = math.sin(tilt);
    tiltCos = math.cos(tilt);
    random = r.nextDouble() + 2;
    tick++;
  }
}

/// The HTML `confetti({...})` bursts, stepped at 60 fps by the ticker.
class _Confetti {
  final List<_Fetti> parts = [];
  final math.Random _rng = math.Random();
  double originY = 0.5;
  double _acc = 0;

  static const List<Color> colors = [
    Color(0xFF26CCFF),
    Color(0xFFA25AFD),
    Color(0xFFFF5E7E),
    Color(0xFF88FF5A),
    Color(0xFFFCFF42),
    Color(0xFFFFA62D),
    Color(0xFFFF36FF),
  ];

  void burst({required int count, required double spreadDeg, double originY = 0.5}) {
    this.originY = originY;
    final spread = spreadDeg * math.pi / 180;
    for (var i = 0; i < count; i++) {
      parts.add(_Fetti(_rng, spread, colors[i % colors.length]));
    }
  }

  void clear() {
    parts.clear();
    _acc = 0;
  }

  void advance(double dt) {
    if (parts.isEmpty) {
      _acc = 0;
      return;
    }
    _acc += dt.clamp(0.0, 0.25);
    while (_acc >= 1 / 60 && parts.isNotEmpty) {
      _acc -= 1 / 60;
      for (final p in parts) {
        p.update(_rng);
      }
      parts.removeWhere((p) => p.tick >= _Fetti.ticks);
    }
  }
}

/// Pan recognizer that only claims pointers landing on a draggable item, so
/// the canvas can still be panned elsewhere when the camera is unlocked.
class _ItemPanRecognizer extends PanGestureRecognizer {
  _ItemPanRecognizer() : super(debugOwner: null);

  bool Function(Offset local) accepts = _never;

  static bool _never(Offset _) => false;

  @override
  bool isPointerAllowed(PointerEvent event) => accepts(event.localPosition) && super.isPointerAllowed(event);
}

class _Ch10A5TransportSystemsInPlantsPageState extends State<Ch10A5TransportSystemsInPlantsPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _PlantScene _scene = _PlantScene();
  final _Confetti _confetti = _Confetti();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  late final Ticker _ticker;

  /// UI scale of the last build (used by popup builders).
  double _uiScale = 1;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_scene.scenario];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _ticker = createTicker((elapsed) {
      final t = elapsed.inMicroseconds / 1e6;
      final dt = t - _scene.time;
      _scene.time = t;
      _confetti.advance(dt);
      _frame.value = t;
    })..start();
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
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ logic

  /// HTML `loadScenario()`: cancels timers and rebuilds the scene.
  void _resetScene() {
    _lab.cancelPending();
    _scene.resetProgress();
    _confetti.clear();
    _lab.resetView(sound: false);
  }

  void _changeScenario(int index) {
    setState(() {
      _scene.scenario = index;
      _lab.hidePopup(sound: false);
      _resetScene();
    });
  }

  void _fullReset() {
    setState(() {
      _scene.scenario = 0;
      _resetScene();
    });
  }

  /// HTML `completeStep(n)`; the last step opens the conclusion.
  void _completeStep(int n) {
    if (!mounted) return;
    setState(() {
      _scene.step = n;
      _scene.stepAt = _scene.time;
      if (_scene.scenario == 1 && n == 2) _scene.vascAt = _scene.time;
    });
    if (n == _data.steps.length - 1) _finishScenario();
  }

  /// HTML: `showObservation(sN_conclusion)` + `confetti(...)` one second
  /// after the conclusion step renders.
  void _finishScenario() {
    final sc = _scene.scenario;
    _lab.after(const Duration(milliseconds: 1000), () {
      if (!mounted || _scene.scenario != sc) return;
      if (sc == 0) {
        _confetti.burst(count: 100, spreadDeg: 70, originY: 0.6);
      } else {
        _confetti.burst(count: 150, spreadDeg: 90);
      }
    });
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: 2,
      delay: const Duration(milliseconds: 1000),
      title: () => _t('sci_conclusion'),
      heading: () => _t('s${sc + 1}_res_title'),
      body: () => _t('s${sc + 1}_res_p0'),
      extra: () => _resultCard(sc),
    );
  }

  /// HUD hint for the current drag step (shown after a wrong drop).
  String _hint() {
    final sc = _scene;
    if (sc.scenario == 1) return sc.step == 3 ? _t('h_dragFood') : '';
    return switch (sc.step) {
      0 => _t('h_startTumb'),
      1 => _t('h_addInk'),
      2 => _t('h_prepTwigs'),
      3 => _t('h_placeTwigs'),
      5 => _t('h_useMag'),
      _ => '',
    };
  }

  // ------------------------------------------------------- dragging

  _Item? _hitItem(Offset p) {
    final items = _scene.draggables();
    for (final item in items.reversed) {
      final size = _box[item]!;
      final r = Rect.fromCenter(center: _scene.posOf(item), width: size.width, height: size.height);
      if (r.inflate(6).contains(p)) return item;
    }
    return null;
  }

  /// HTML pointerdown on a `.draggable`.
  void _grab(Offset p) {
    final sc = _scene;
    if (!_lab.isLabActive || sc.dragItem != null) return;
    final item = _hitItem(p);
    if (item == null) return;
    _Audio.play(_Sound.pickup);
    final pos = sc.posOf(item);
    setState(() {
      if (sc.snapItem == item) sc.snapItem = null;
      sc
        ..dragItem = item
        ..dragStart = pos
        ..dragPos = pos
        ..grabDelta = p - pos;
    });
  }

  void _dragTo(Offset p) {
    if (_scene.dragItem == null) return;
    _scene.dragPos = p - _scene.grabDelta;
  }

  /// HTML pointerup: drop on a zone or slide back to the start.
  void _release() {
    final sc = _scene;
    final item = sc.dragItem;
    if (item == null) return;
    final pos = sc.dragPos;
    final zone = sc.dropZone(item, pos);
    setState(() => sc.dragItem = null);
    if (zone == null) {
      setState(() {
        sc
          ..snapItem = item
          ..snapFrom = pos
          ..snapAt = sc.time;
      });
      if ((pos - sc.dragStart).distance > 12) _lab.showToast(_hint(), isError: true);
      return;
    }
    switch (item) {
      case _Item.jug:
        _pour(zone.id, pos);
      case _Item.ink:
        _addInk(pos);
      case _Item.scalpel:
        _cut(zone.id == 'cutA', pos);
      case _Item.twigA || _Item.twigB:
        _place(item == _Item.twigA, pos);
      case _Item.mag:
        _magnify();
      case _Item.food:
        _loadFood();
    }
  }

  /// Step 1: the jug tilts over a tumbler and pours (HTML jug drop).
  void _pour(String zone, Offset from) {
    final sc = _scene;
    final a = zone == 'A';
    setState(() {
      sc
        ..jugAnimating = true
        ..pourZone = zone
        ..pourAt = sc.time
        ..pourFrom = from;
      if (a) {
        sc.fillAAt = sc.time + 0.6;
      } else {
        sc.fillBAt = sc.time + 0.6;
      }
    });
    _lab.after(const Duration(milliseconds: 500), () => _Audio.play(_Sound.splash));
    _lab.after(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        if (a) {
          sc.tA = true;
        } else {
          sc.tB = true;
        }
      });
    });
    _lab.after(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      setState(() {
        sc
          ..jugAnimating = false
          ..pourZone = null;
      });
      if (sc.tA && sc.tB) {
        _lab.showToast(_t('h_tumbReady'));
        _lab.after(const Duration(milliseconds: 1000), () => _completeStep(1));
      }
    });
  }

  /// Step 2: red ink drops into Tumbler B.
  void _addInk(Offset from) {
    final sc = _scene;
    setState(() {
      sc
        ..inkAt = sc.time
        ..inkFrom = from;
    });
    _lab.after(const Duration(milliseconds: 400), () => _Audio.play(_Sound.drop));
    _lab.after(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() => sc.inkDrop = true);
      _lab.showToast(_t('h_inkAdded'));
      _lab.after(const Duration(milliseconds: 1500), () => _completeStep(2));
    });
  }

  /// Step 3: the scalpel swipes across a stem base (HTML `animate-swipe`).
  void _cut(bool a, Offset from) {
    final sc = _scene;
    _Audio.play(_Sound.whoosh);
    setState(() {
      sc
        ..cutAt = sc.time
        ..cutFrom = from
        ..cutOnA = a;
      if (a) {
        sc
          ..cutA = true
          ..cutAAt = sc.time;
      } else {
        sc
          ..cutB = true
          ..cutBAt = sc.time;
      }
    });
    _lab.after(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {});
      if (sc.cutA && sc.cutB) {
        _lab.after(const Duration(milliseconds: 1000), () {
          _lab.showToast(_t('h_twigsCut'));
          _completeStep(3);
        });
      }
    });
  }

  /// Step 4: a twig drops into its tumbler.
  void _place(bool a, Offset from) {
    final sc = _scene;
    _Audio.play(_Sound.drop);
    setState(() {
      if (a) {
        sc
          ..inA = true
          ..placeAAt = sc.time
          ..placeAFrom = from + _twigFoot;
      } else {
        sc
          ..inB = true
          ..placeBAt = sc.time
          ..placeBFrom = from + _twigFoot;
      }
    });
    if (sc.inA && sc.inB) {
      _lab.showToast(_t('h_setupReady'), sound: false);
      _lab.after(const Duration(milliseconds: 1000), () => _completeStep(4));
    }
  }

  /// Step 5: HTML `triggerSim1()` (24 hour time-lapse).
  void _triggerSim() {
    final sc = _scene;
    if (sc.sim) return;
    setState(() {
      sc
        ..sim = true
        ..simAt = sc.time;
    });
    _lab.showToast('${_t('h_timePass')} ${_t('h_sim24h')}', sound: false);
    _lab.after(const Duration(milliseconds: 3000), () {
      _completeStep(5);
      _lab.showToast(_t('h_obsRed'));
    });
  }

  /// Step 6: the magnifier reveals the stem cross-section.
  void _magnify() {
    final sc = _scene;
    _Audio.play(_Sound.magic);
    setState(() {
      sc
        ..mag = true
        ..magAt = sc.time;
    });
    _lab.showToast(_t('h_conc'), sound: false);
    _lab.after(const Duration(milliseconds: 3000), () => _completeStep(6));
  }

  /// Scenario 2, step 4: glucose enters the phloem.
  void _loadFood() {
    final sc = _scene;
    _Audio.play(_Sound.magic);
    setState(() {
      sc
        ..foodMoving = true
        ..foodAt = sc.time;
    });
    _lab.showToast(_t('h_foodMoving'), sound: false);
    _lab.after(const Duration(milliseconds: 1500), () => _completeStep(4));
  }

  // ---------------------------------------------------- scenario 2 clicks

  /// HTML `clickS2(tgt)` targets hit-tested in design coordinates.
  void _onTap(Offset p) {
    if (!_lab.isLabActive) return;
    final sc = _scene;
    if (sc.scenario == 1) {
      if (sc.step == 0 && !sc.sun && (p - _sunC).distance < 78) {
        _clickSun();
        return;
      }
      if (sc.step == 1 && !sc.leaf && const Rect.fromLTRB(40, 175, 212, 268).contains(p)) {
        _clickLeaf();
        return;
      }
      if (sc.step == 2 && !sc.phloem && _phloemClick.inflate(14).contains(p)) {
        _clickPhloem();
        return;
      }
      if (sc.step == 4 && !sc.potato && Rect.fromCenter(center: _potatoC, width: 116, height: 96).contains(p)) {
        _clickPotato();
        return;
      }
    }
    // A tap on a draggable item: remind the user to drag it.
    if (_hitItem(p) != null) {
      final hint = _hint();
      if (hint.isNotEmpty) _lab.showToast(hint, sound: false);
    }
  }

  void _clickSun() {
    final sc = _scene;
    _Audio.play(_Sound.magic);
    setState(() {
      sc
        ..sun = true
        ..sunAt = sc.time;
    });
    _lab.showToast(_t('h_sunOn'), sound: false);
    _lab.after(const Duration(milliseconds: 500), () => _completeStep(1));
  }

  void _clickLeaf() {
    _Audio.play(_Sound.click);
    setState(() => _scene.leaf = true);
    _lab.showToast(_t('h_foodMade'), sound: false);
    _completeStep(2);
  }

  void _clickPhloem() {
    final sc = _scene;
    _Audio.play(_Sound.click);
    setState(() {
      sc
        ..phloem = true
        ..phloemAt = sc.time;
    });
    _lab.showToast(_t('h_phloemOn'), sound: false);
    _completeStep(3);
  }

  void _clickPotato() {
    final sc = _scene;
    _Audio.play(_Sound.magic);
    setState(() {
      sc
        ..potato = true
        ..potatoAt = sc.time;
    });
    _lab.showToast(_t('h_potatoGrew'), sound: false);
    _lab.after(const Duration(milliseconds: 2000), () => _completeStep(5));
  }

  List<LabAction> _actions() {
    final sc = _scene;
    if (sc.scenario == 0 && sc.step == 4 && sc.inA && sc.inB && !sc.sim) {
      return [
        LabAction(
          label: _t('btn_ff'),
          icon: Icons.fast_forward_rounded,
          highlight: true,
          onTap: _triggerSim,
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
        final p = _Theme.of(_lab.isDark);
        final s = context.labScale;
        _uiScale = s;
        final data = _data;
        final sc = _scene;
        final shell = LabShell(
          controller: _lab,
          icon: Icons.park,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: sc.scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: sc.step + 1,
          actions: _actions(),
          sidebarExtraTitle: _t('exp_out'),
          sidebarExtra: _outcomeCard(p, s),
          onReset: _fullReset,
          stage: LabStage(
            designSize: _design,
            child: RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              gestures: {
                _ItemPanRecognizer: GestureRecognizerFactoryWithHandlers<_ItemPanRecognizer>(
                  _ItemPanRecognizer.new,
                  (r) => r
                    ..accepts = ((local) => _lab.isLabActive && _hitItem(local) != null)
                    ..dragStartBehavior = DragStartBehavior.down
                    ..gestureSettings = const DeviceGestureSettings(touchSlop: 4)
                    ..onStart = ((d) => _grab(d.localPosition))
                    ..onUpdate = ((d) => _dragTo(d.localPosition))
                    ..onEnd = ((_) => _release())
                    ..onCancel = _release,
                ),
                TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                  TapGestureRecognizer.new,
                  (r) => r.onTapUp = ((d) => _onTap(d.localPosition)),
                ),
              },
              child: CustomPaint(
                size: _design,
                painter: _ScenePainter(
                  scene: sc,
                  repaint: _frame,
                  isDark: _lab.isDark,
                  showLabels: _lab.showLabels,
                  lang: _lab.lang,
                  tr: _t,
                ),
              ),
            ),
          ),
        );
        // HTML canvas-confetti draws on a full-window canvas; it is kept above
        // the conclusion popup here so the burst stays visible on phones.
        return Stack(
          children: [
            shell,
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _ConfettiPainter(confetti: _confetti, repaint: _frame),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// The HTML accordion's "Expected Outcome" for the current step.
  Widget _outcomeCard(LabPalette p, double s) {
    final f = s * _lab.fontScale;
    final steps = _data.steps;
    final step = steps[_scene.step.clamp(0, steps.length - 1)];
    return Container(
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.visibility, size: 15 * f, color: p.isDark ? _Colors.blue400 : _Colors.blue),
          SizedBox(width: 8 * s),
          Expanded(
            child: Text(
              step.observation,
              style: TextStyle(color: p.text, fontSize: 12 * f, height: 1.45, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  /// HTML conclusion panel: two findings and the green conclusion box.
  Widget _resultCard(int scenario) {
    final p = _Theme.of(_lab.isDark);
    final s = _uiScale;
    final f = s * _lab.fontScale.clamp(0.9, 1.4);
    final n = scenario + 1;
    final green = p.isDark ? _Colors.green400 : _Colors.green700;
    final highlight = p.isDark ? _Colors.blue400 : _Colors.blue700;
    final base = TextStyle(color: p.text, fontSize: 12.5 * f, height: 1.5, fontWeight: FontWeight.w500);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(12 * s),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: p.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _rich(_t('s${n}_res_p1'), base, highlight),
              SizedBox(height: 8 * s),
              _rich(_t('s${n}_res_p2'), base, highlight),
            ],
          ),
        ),
        SizedBox(height: 10 * s),
        Container(
          padding: EdgeInsets.all(12 * s),
          decoration: BoxDecoration(
            color: _Colors.green500.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _Colors.green500.withValues(alpha: 0.3)),
          ),
          child: Text(
            _t('s${n}_res_conc'),
            textAlign: TextAlign.center,
            style: TextStyle(color: green, fontSize: 13 * f, height: 1.4, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  /// Text with `**bold**` parts in [highlight] (the HTML coloured spans).
  Widget _rich(String text, TextStyle base, Color highlight) {
    final parts = text.split('**');
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          for (var i = 0; i < parts.length; i++)
            TextSpan(
              text: parts[i],
              style: i.isOdd ? TextStyle(color: highlight, fontWeight: FontWeight.w800) : null,
            ),
        ],
      ),
    );
  }
}

// ============================================================ PAINTING

/// Paints the 900 x 600 HTML scene of the current scenario.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.tr,
  }) : super(repaint: repaint);

  final _PlantScene scene;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;
  final String Function(String key) tr;

  double get t => scene.time;

  // HTML SVGS.twig (viewBox 0 0 100 200, stem base at 50,190).
  static final Path _twigStem = Path()
    ..moveTo(50, 190)
    ..quadraticBezierTo(45, 100, 50, 20);
  static final List<Path> _twigLeaves = [
    Path()
      ..moveTo(50, 140)
      ..quadraticBezierTo(70, 130, 80, 100)
      ..quadraticBezierTo(50, 110, 50, 140)
      ..close(),
    Path()
      ..moveTo(50, 100)
      ..quadraticBezierTo(30, 90, 20, 60)
      ..quadraticBezierTo(50, 70, 50, 100)
      ..close(),
    Path()
      ..moveTo(50, 60)
      ..quadraticBezierTo(70, 50, 75, 20)
      ..quadraticBezierTo(55, 35, 50, 60)
      ..close(),
  ];
  static const List<double> _twigLeafY = [140, 100, 60];
  static const List<Offset> _twigLeafTip = [Offset(80, 100), Offset(20, 60), Offset(75, 20)];

  // HTML jug (local coordinates, origin at the bottom centre).
  static final Path _jugBody = Path()
    ..moveTo(-20, -120)
    ..lineTo(20, -120)
    ..lineTo(35, -10)
    ..arcToPoint(const Offset(25, 0), radius: const Radius.circular(10))
    ..lineTo(-25, 0)
    ..arcToPoint(const Offset(-35, -10), radius: const Radius.circular(10))
    ..close();

  // HTML phloem path `#phloem-main-path`.
  static final Path _phloemPath = Path()
    ..moveTo(200, 220)
    ..quadraticBezierTo(300, 280, 456, 300)
    ..lineTo(456, 400)
    ..quadraticBezierTo(470, 425, 550, 480);
  static final _phloemMetric = _phloemPath.computeMetrics().first;

  @override
  void paint(Canvas canvas, Size size) {
    if (scene.scenario == 0) {
      _paintXylemLab(canvas, size);
    } else {
      _paintPotatoPlant(canvas, size);
    }
  }

  // ------------------------------------------------------------ helpers

  Paint _stroke(Color c, double w, {StrokeCap cap = StrokeCap.round}) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = cap
    ..strokeJoin = StrokeJoin.round
    ..color = c;

  /// Runs [draw] with the layer faded to [alpha].
  void _faded(Canvas c, double alpha, VoidCallback draw) {
    if (alpha <= 0) return;
    if (alpha >= 1) {
      draw();
      return;
    }
    c.saveLayer(null, Paint()..color = Colors.black.withValues(alpha: alpha));
    draw();
    c.restore();
  }

  /// HTML `.label-text` chip (bg-panel, text-main, border).
  void _label(
    Canvas c,
    String text,
    Offset at, {
    Color? color,
    Color? bg,
    Color? border,
    Alignment anchor = Alignment.bottomCenter,
    double opacity = 1,
  }) {
    if (!showLabels) return;
    labText(
      c,
      text,
      at,
      size: 15,
      weight: FontWeight.w700,
      color: color ?? (isDark ? _Colors.slate50 : _Colors.slate900),
      background: bg ?? (isDark ? _Colors.slate800 : Colors.white),
      border: border ?? (isDark ? _Colors.slate700 : _Colors.slate300),
      borderWidth: 1,
      radius: 5,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      anchor: anchor,
      opacity: opacity,
    );
  }

  /// Tailwind `animate-pulse` opacity (1 -> 0.5 -> 1 every 2 s).
  double get _pulse => 0.75 + 0.25 * math.cos(t * math.pi);

  /// The pulsing "CLICK" / "PRODUCED" badges of the HTML scene.
  void _badge(
    Canvas c,
    String text,
    Offset at, {
    required Color bg,
    required Color fg,
    Color? border,
    Alignment anchor = Alignment.centerLeft,
    bool check = false,
  }) {
    final o = _pulse;
    final r = labText(
      c,
      text,
      at,
      size: 15,
      weight: FontWeight.w900,
      color: fg,
      background: bg,
      border: border,
      borderWidth: 2,
      padding: const EdgeInsets.fromLTRB(32, 6, 14, 6),
      anchor: anchor,
      opacity: o,
    );
    final ic = Offset(r.left + 18, r.center.dy);
    final p = _stroke(fg.withValues(alpha: o), 3);
    if (check) {
      c.drawPath(
        Path()
          ..moveTo(ic.dx - 6, ic.dy)
          ..lineTo(ic.dx - 2, ic.dy + 4)
          ..lineTo(ic.dx + 6, ic.dy - 5),
        p,
      );
    } else {
      c.drawLine(ic + const Offset(7, 0), ic - const Offset(7, 0), p);
      c.drawPath(
        Path()
          ..moveTo(ic.dx - 2, ic.dy - 5)
          ..lineTo(ic.dx - 7, ic.dy)
          ..lineTo(ic.dx - 2, ic.dy + 5),
        p,
      );
    }
  }

  /// HTML `.dropzone.dragover`: green fill, border and inner glow.
  void _zoneHighlight(Canvas c, _Zone z) {
    final r = z.rect;
    final fill = Paint()..color = _Colors.green500.withValues(alpha: 0.2);
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = _Colors.green500.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final border = _stroke(_Colors.green500, 4);
    if (z.oval) {
      c.drawOval(r, fill);
      c.drawOval(r.deflate(4), glow);
      c.drawOval(r, border);
    } else {
      final rr = RRect.fromRectAndRadius(r, const Radius.circular(12));
      c.drawRRect(rr, fill);
      c.drawRRect(rr.deflate(4), glow);
      c.drawRRect(rr, border);
    }
  }

  /// Soft shadow under an item being dragged (HTML `.is-dragging`).
  void _liftShadow(Canvas c, Offset centre, Size box) {
    c.drawOval(
      Rect.fromCenter(center: centre + Offset(0, box.height * 0.5 + 16), width: box.width * 0.9, height: 16),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  // ===================================================== SCENARIO 1

  void _paintXylemLab(Canvas c, Size size) {
    final sc = scene;
    final step = sc.step;
    _labRoom(c, size);
    if (step == 2 || step == 3) _trayGroup(c);
    _tumbler(c, true);
    _tumbler(c, false);
    _inkDrops(c);

    final drag = sc.dragItem;
    final hover = drag == null ? null : sc.dropZone(drag, sc.dragPos);
    if (hover != null) _zoneHighlight(c, hover);

    if (step == 0) _jugItem(c);
    if (step == 1) _inkItem(c);
    if (step == 2) _scalpelItem(c);
    if (step == 5 && !sc.mag && drag != _Item.mag) {
      final pos = sc.posOf(_Item.mag);
      _faded(c, sc.prog(sc.stepAt, 0.35), () {
        _drawMag(c, pos);
        _label(c, tr('mag'), pos + const Offset(0, -56), color: isDark ? _Colors.green400 : _Colors.green700);
      });
    }
    if (step == 4 && sc.simAt != null) _clock(c);
    if (sc.mag) _magnified(c);
    _draggedItem(c);
  }

  /// Lab wall and bench (HTML wall wash, table extension, apron and legs).
  void _labRoom(Canvas c, Size size) {
    final b = labBleed(size);
    c.drawRect(
      Rect.fromLTRB(b.left, b.top, b.right, 440),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF182133), Color(0xFF283245)]
              : const [_Colors.slate50, _Colors.slate200],
        ).createShader(const Rect.fromLTRB(0, 0, 900, 440)),
    );
    // Soft light pool behind the apparatus.
    c.drawCircle(
      const Offset(430, 330),
      420,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.white.withValues(alpha: isDark ? 0.07 : 0.5), Colors.white.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: const Offset(430, 330), radius: 420)),
    );
    // Bench top.
    c.drawRect(Rect.fromLTRB(b.left, 436, b.right, 452), Paint()..color = isDark ? _Colors.slate300 : _Colors.slate200);
    c.drawRect(Rect.fromLTRB(b.left, 436, b.right, 439), Paint()..color = _Colors.slate50);
    // Front apron (HTML table detail: #f1f5f9 with a 12 px #94a3b8 edge).
    c.drawRect(
      Rect.fromLTRB(b.left, 452, b.right, 492),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_Colors.slate100, _Colors.slate200],
        ).createShader(const Rect.fromLTRB(0, 452, 900, 492)),
    );
    c.drawRect(Rect.fromLTRB(b.left, 480, b.right, 492), Paint()..color = _Colors.slate400);
    // Under the bench.
    c.drawRect(
      Rect.fromLTRB(b.left, 492, b.right, b.bottom),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark ? const [Color(0xFF1E293B), Color(0xFF111827)] : const [_Colors.slate300, _Colors.slate400],
        ).createShader(const Rect.fromLTRB(0, 492, 900, 600)),
    );
    c.drawRect(
      Rect.fromLTRB(b.left, 492, b.right, 504),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.25), Colors.black.withValues(alpha: 0)],
        ).createShader(const Rect.fromLTRB(0, 492, 900, 504)),
    );
    for (final x in [120.0, 750.0]) {
      c.drawRect(Rect.fromLTRB(x, 492, x + 30, b.bottom), Paint()..color = _Colors.slate500);
      c.drawRect(Rect.fromLTRB(x, 492, x + 4, b.bottom), Paint()..color = _Colors.slate400);
    }
    // Tumbler letters on the apron (HTML label-text "A" / "B").
    if (showLabels) {
      for (final (x, l) in [(_tumbAX, 'A'), (_tumbBX, 'B')]) {
        labText(c, l, Offset(x, 466), size: 22, weight: FontWeight.w800, color: _Colors.slate500);
      }
    }
  }

  double _fillOf(bool a) => _fillLevel * _ease(scene.prog(a ? scene.fillAAt : scene.fillBAt, 0.9));

  /// 0..1 mix of the red ink in Tumbler B.
  double get _inkMix => scene.prog(scene.inkAt, 1.2, delay: 0.75);

  /// 0..1 rise of the red dye in twig B during the time-lapse.
  double get _redRise => scene.simAt == null ? 0 : scene.prog(scene.simAt, 2.6, delay: 0.2);

  double _waterTop(bool a) => _benchY - 3 - 97 * _fillOf(a);

  /// HTML `SVGS.tumbler`: glass, water and rim, with a twig standing in it.
  void _tumbler(Canvas c, bool a) {
    final sc = scene;
    final cx = a ? _tumbAX : _tumbBX;
    labGroundShadow(c, Offset(cx, _benchY + 1), 92, 10, opacity: 0.22);
    if (a ? sc.inA : sc.inB) {
      final k = Curves.easeOutCubic.transform(sc.prog(a ? sc.placeAAt : sc.placeBAt, 0.35));
      final from = a ? sc.placeAFrom : sc.placeBFrom;
      _drawTwig(
        c,
        Offset.lerp(from, Offset(cx, _twigInY), k)!,
        scale: 0.8 + 0.1 * k,
        cut: true,
        red: a ? 0 : _redRise,
      );
    }
    final glass = Rect.fromLTRB(cx - 35, _glassTop, cx + 35, _benchY);
    final fill = _fillOf(a);
    if (fill > 0) {
      final top = _waterTop(a);
      final water = Rect.fromLTRB(cx - 32, top, cx + 32, _benchY - 3);
      const clear = Color(0x6660A5FA); // rgba(96,165,250,0.4)
      const red = Color(0xCCEF4444); // rgba(239,68,68,0.8)
      final col = a ? clear : Color.lerp(clear, red, _inkMix)!;
      c.drawRRect(
        RRect.fromRectAndCorners(water, bottomLeft: const Radius.circular(3), bottomRight: const Radius.circular(3)),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [labShade(col, 0.12), labShade(col, -0.12)],
          ).createShader(water),
      );
      // Red clouds swirling while the ink mixes.
      final mix = _inkMix;
      if (!a && sc.inkAt != null && mix > 0 && mix < 1) {
        c.save();
        c.clipRect(water);
        for (var i = 0; i < 3; i++) {
          final ang = t * 1.6 + i * 2.1;
          final centre = Offset(cx + 16 * math.cos(ang), top + water.height * (0.35 + 0.2 * math.sin(ang + i)));
          final r = 10 + 30 * mix;
          c.drawCircle(
            centre,
            r,
            Paint()
              ..shader = RadialGradient(
                colors: [_Colors.red700.withValues(alpha: 0.7 * (1 - mix)), _Colors.red.withValues(alpha: 0)],
              ).createShader(Rect.fromCircle(center: centre, radius: r)),
          );
        }
        c.restore();
      }
      c.drawOval(
        Rect.fromCenter(center: Offset(cx, top), width: 64, height: 7),
        Paint()..color = labShade(col, 0.3).withValues(alpha: math.min(1, col.a + 0.15)),
      );
    }
    // Glass (HTML glassG gradient, #94a3b8 outline, #cbd5e1 rim).
    final rr = RRect.fromRectAndRadius(glass, const Radius.circular(5));
    c.drawRRect(
      rr,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.4),
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.5),
          ],
          stops: const [0, 0.2, 0.8, 1],
        ).createShader(glass),
    );
    c.drawLine(
      Offset(cx - 26, _glassTop + 14),
      Offset(cx - 26, _benchY - 12),
      _stroke(Colors.white.withValues(alpha: 0.45), 3),
    );
    c.drawRRect(rr, _stroke(_Colors.slate400, 3));
    c.drawOval(Rect.fromCenter(center: Offset(cx, _glassTop), width: 70, height: 16), _stroke(_Colors.slate300, 3));
  }

  /// Ink drops falling from the tilted bottle into Tumbler B, with ripples.
  void _inkDrops(Canvas c) {
    final sc = scene;
    if (sc.inkAt == null) return;
    final u = t - sc.inkAt!;
    final mouth = _inkPourOrigin() + _rotate(_inkMouth, _inkPourAngle);
    final surface = _waterTop(false);
    for (var i = 0; i < 3; i++) {
      final start = 0.4 + 0.25 * i;
      final f = (u - start) / 0.35;
      if (f >= 0 && f < 1) {
        final y = mouth.dy + 6 + (surface - mouth.dy - 6) * Curves.easeIn.transform(f);
        final p = Offset(mouth.dx, y);
        c.drawPath(
          Path()
            ..moveTo(p.dx, p.dy - 11)
            ..quadraticBezierTo(p.dx + 6, p.dy - 2, p.dx, p.dy + 5)
            ..quadraticBezierTo(p.dx - 6, p.dy - 2, p.dx, p.dy - 11)
            ..close(),
          Paint()..color = _Colors.red,
        );
      }
      final rip = (u - start - 0.35) / 0.45;
      if (rip >= 0 && rip < 1) {
        c.drawOval(
          Rect.fromCenter(center: Offset(mouth.dx, surface), width: 10 + 44 * rip, height: 3 + 7 * rip),
          _stroke(_Colors.red.withValues(alpha: 0.8 * (1 - rip)), 2),
        );
      }
    }
  }

  // ------------------------------------------------------- tray & twigs

  /// Steps 3-4: dissection tray with the two twigs and the CUT zones.
  void _trayGroup(Canvas c) {
    final sc = scene;
    final appear = sc.step == 2 ? sc.prog(sc.stepAt, 0.35) : 1.0;
    _faded(c, appear, () {
      // HTML SVGS.tray seen in perspective, resting on the bench.
      final outer = Path()
        ..moveTo(445, 226)
        ..lineTo(727, 226)
        ..lineTo(763, 442)
        ..lineTo(407, 442)
        ..close();
      final inner = Path()
        ..moveTo(457, 236)
        ..lineTo(715, 236)
        ..lineTo(747, 432)
        ..lineTo(423, 432)
        ..close();
      labGroundShadow(c, const Offset(585, 446), 380, 16, opacity: 0.25);
      c.drawRect(const Rect.fromLTRB(407, 442, 763, 450), Paint()..color = _Colors.slate400);
      c.drawPath(outer, Paint()..color = _Colors.slate300);
      c.drawPath(outer, _stroke(_Colors.slate400, 4));
      c.drawPath(
        inner,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_Colors.slate200, _Colors.slate50],
          ).createShader(const Rect.fromLTRB(423, 236, 747, 432)),
      );
      c.drawPath(inner, _stroke(_Colors.slate200, 2));

      if (sc.step == 2) {
        if (!sc.cutA) _cutMarker(c, true);
        if (!sc.cutB) _cutMarker(c, false);
      }
      // Twigs lying on the tray (tilted like the HTML), upright in step 4.
      final straight = sc.step == 3 ? Curves.easeOut.transform(sc.prog(sc.stepAt, 0.5)) : 0.0;
      for (final a in [true, false]) {
        final item = a ? _Item.twigA : _Item.twigB;
        if ((a ? sc.inA : sc.inB) || sc.dragItem == item) continue;
        final base = sc.posOf(item) + _twigFoot;
        final angle = (a ? -0.26 : 0.17) * (1 - straight);
        final cutAt = a ? sc.cutAAt : sc.cutBAt;
        final cut = cutAt != null && t - cutAt > 0.4;
        _drawTwig(c, base, angle: angle, cut: cut);
        final top = base + _rotate(const Offset(0, -168), angle);
        _label(c, tr(a ? 'twigA' : 'twigB'), top);
      }
    });
  }

  /// HTML `#cutZoneA/B`: dashed red oval with "CUT A/B".
  void _cutMarker(Canvas c, bool a) {
    final r = _cutZone(a);
    c.drawOval(r, Paint()..color = _Colors.red.withValues(alpha: 0.1));
    labDashedPath(
      c,
      Path()..addOval(r),
      _stroke(_Colors.red.withValues(alpha: 0.55), 4, cap: StrokeCap.butt),
      dash: 12,
      gap: 8,
      phase: t * 10,
    );
    labText(
      c,
      tr(a ? 'cut_a' : 'cut_b'),
      r.bottomCenter - const Offset(0, 14),
      size: 13,
      weight: FontWeight.w800,
      color: _Colors.red.withValues(alpha: 0.85),
    );
  }

  /// HTML `SVGS.twig`: stem, three leaves and a white flower. [red] (0..1)
  /// is the dye rising through the xylem during the time-lapse.
  void _drawTwig(Canvas c, Offset base, {double scale = 0.8, double angle = 0, bool cut = false, double red = 0}) {
    c.save();
    c.translate(base.dx, base.dy);
    if (angle != 0) c.rotate(angle);
    c.scale(scale);
    c.translate(-50, -190);

    final front = 190 - 175 * (red / 0.7).clamp(0.0, 1.0);
    final stemRed = ((red - 0.1) / 0.6).clamp(0.0, 1.0);

    // Stem, then the red dye creeping up its xylem.
    c.drawPath(_twigStem, _stroke(_Colors.green700, 6));
    if (red > 0) {
      c.save();
      c.clipRect(Rect.fromLTRB(0, front, 100, 200));
      if (stemRed > 0) c.drawPath(_twigStem, _stroke(_Colors.red700.withValues(alpha: stemRed), 6));
      final streak = _stroke(_Colors.red, 1.3);
      c.drawPath(_twigStem.shift(const Offset(-1.5, 0)), streak);
      c.drawPath(_twigStem.shift(const Offset(1.5, 0)), streak);
      c.restore();
    }

    // Leaves (pink-tinged once the dye reaches them).
    for (var i = 0; i < 3; i++) {
      final reach = (190 - _twigLeafY[i]) / 175 * 0.7;
      final k = red <= 0 ? 0.0 : ((red - reach) / 0.2).clamp(0.0, 1.0);
      final leaf = _twigLeaves[i];
      c.drawPath(leaf, Paint()..color = Color.lerp(_Colors.green400, _Colors.red300, k)!);
      final vein = Path()
        ..moveTo(50, _twigLeafY[i])
        ..lineTo(_twigLeafTip[i].dx, _twigLeafTip[i].dy);
      c.drawPath(vein, _stroke(Color.lerp(_Colors.green600, _Colors.red, k)!.withValues(alpha: 0.55), 1));
      c.drawPath(leaf, _stroke(Color.lerp(_Colors.green600, _Colors.red, k)!, 2));
    }

    // Flower: four petals round a yellow centre.
    final pk = ((red - 0.72) / 0.28).clamp(0.0, 1.0);
    final petal = Paint()..color = Color.lerp(Colors.white, _Colors.red200, pk)!;
    final petalEdge = _stroke(Color.lerp(_Colors.slate300, _Colors.red, pk)!, 1);
    for (final o in const [Offset(0, -10), Offset(10, 0), Offset(-10, 0), Offset(0, 10)]) {
      c.drawCircle(const Offset(50, 20) + o, 8, petal);
      c.drawCircle(const Offset(50, 20) + o, 8, petalEdge);
    }
    c.drawCircle(const Offset(50, 20), 5, Paint()..color = _Colors.yellow400);

    // Base: a square end, or the oblique cut.
    final baseCol = Color.lerp(_Colors.green900, _Colors.red900, stemRed)!;
    if (cut) {
      c.drawLine(const Offset(45, 185), const Offset(55, 195), _stroke(baseCol, 6, cap: StrokeCap.square));
      c.drawLine(const Offset(46.5, 187.5), const Offset(53.5, 194.5), _stroke(_Colors.green300, 1.6));
    } else {
      c.drawLine(const Offset(47, 190), const Offset(53, 190), _stroke(baseCol, 6, cap: StrokeCap.square));
    }
    c.restore();
  }

  // ------------------------------------------------------------- items

  /// Jug pose (bottom-centre origin and tilt) through the pour animation.
  (Offset, double) _jugPose() {
    final sc = scene;
    final home = _home[_Item.jug]! + const Offset(0, 70);
    final zone = sc.pourZone;
    if (zone == null) return (sc.posOf(_Item.jug) + const Offset(0, 70), 0);
    final cx = zone == 'A' ? _tumbAX : _tumbBX;
    final pour = Offset(cx + 4, 288) - _rotate(_jugSpout, _jugPourAngle);
    final from = sc.pourFrom + const Offset(0, 70);
    final u = t - sc.pourAt;
    if (u < 0.5) {
      final k = _ease(u / 0.5);
      return (Offset.lerp(from, pour, k)!, _jugPourAngle * k);
    }
    if (u < 1.5) return (pour, _jugPourAngle);
    final k = _ease((u - 1.5) / 0.5);
    return (Offset.lerp(pour, home, k)!, _jugPourAngle * (1 - k));
  }

  void _jugItem(Canvas c) {
    final sc = scene;
    if (sc.dragItem == _Item.jug) return;
    final (origin, angle) = _jugPose();
    if (sc.pourZone == null) labGroundShadow(c, origin + const Offset(0, 1), 80, 10, opacity: 0.22);
    // Water stream from the spout (HTML `animate-pour-water`).
    final u = t - sc.pourAt;
    if (sc.pourZone != null && u > 0.5 && u < 1.5) {
      final a = sc.pourZone == 'A';
      final spout = origin + _rotate(_jugSpout, angle);
      final bottom = _waterTop(a);
      final grow = Curves.easeIn.transform(((u - 0.5) / 0.22).clamp(0.0, 1.0));
      final cut = ((u - 1.3) / 0.2).clamp(0.0, 1.0);
      final y0 = spout.dy + (bottom - spout.dy) * cut;
      final y1 = spout.dy + (bottom - spout.dy) * grow;
      final stream = Rect.fromLTRB(spout.dx - 4, y0, spout.dx + 4, y1);
      c.drawRRect(
        RRect.fromRectAndRadius(stream, const Radius.circular(4)),
        Paint()
          ..shader = const LinearGradient(colors: [_Colors.blue300, _Colors.blue400, _Colors.blue300])
              .createShader(stream),
      );
      if (grow >= 1 && cut < 1) {
        for (var i = 0; i < 2; i++) {
          final ph = (t * 2.2 + i * 0.5) % 1;
          c.drawOval(
            Rect.fromCenter(center: Offset(spout.dx, bottom), width: 12 + 40 * ph, height: 3 + 6 * ph),
            _stroke(Colors.white.withValues(alpha: 0.7 * (1 - ph)), 1.6),
          );
        }
      }
    }
    _drawJug(c, origin, angle);
    if (sc.pourZone == null) _label(c, tr('jug'), origin + const Offset(0, -136));
  }

  /// HTML `SVGS.jug` (glass jug, blue water); handle opposite the spout.
  void _drawJug(Canvas c, Offset origin, double angle) {
    c.save();
    c.translate(origin.dx, origin.dy);
    c.rotate(angle);
    // Handle.
    c.drawPath(
      Path()
        ..moveTo(31, -86)
        ..cubicTo(58, -88, 60, -38, 30, -36),
      _stroke(_Colors.slate400, 8),
    );
    // Water stays level while the jug tilts.
    c.save();
    c.clipPath(_jugBody);
    c.rotate(-angle);
    final level = -75 + 7 * (angle.abs() / 0.7);
    c.drawRect(Rect.fromLTRB(-200, level, 200, 200), Paint()..color = _Colors.blue400.withValues(alpha: 0.5));
    c.drawRect(Rect.fromLTRB(-200, level, 200, level + 3), Paint()..color = _Colors.blue300.withValues(alpha: 0.8));
    c.restore();
    // Glass body (HTML jugG gradient).
    c.drawPath(
      _jugBody,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.6),
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.5),
          ],
        ).createShader(const Rect.fromLTRB(-35, -120, 35, 0)),
    );
    c.drawLine(const Offset(-14, -104), const Offset(-24, -16), _stroke(Colors.white.withValues(alpha: 0.55), 3));
    // Spout lip.
    final spout = Path()
      ..moveTo(-20, -120)
      ..cubicTo(-30, -130, -42, -122, -38, -114)
      ..lineTo(-21, -108)
      ..close();
    c.drawPath(spout, Paint()..color = Colors.white.withValues(alpha: 0.5));
    c.drawPath(spout, _stroke(_Colors.slate400, 3));
    c.drawPath(_jugBody, _stroke(_Colors.slate400, 3));
    c.restore();
  }

  Offset _inkPourOrigin() => Offset(_tumbBX + 2, 292) - _rotate(_inkMouth, _inkPourAngle);

  void _inkItem(Canvas c) {
    final sc = scene;
    if (sc.inkDrop || sc.dragItem == _Item.ink) return;
    var origin = sc.posOf(_Item.ink) + const Offset(0, 50);
    var angle = 0.0;
    var alpha = sc.prog(sc.stepAt, 0.35);
    if (sc.inkAt != null) {
      final u = t - sc.inkAt!;
      final k = _ease(u / 0.4);
      origin = Offset.lerp(sc.inkFrom + const Offset(0, 50), _inkPourOrigin(), k)!;
      angle = _inkPourAngle * k;
      alpha = 1 - ((u - 1.2) / 0.2).clamp(0.0, 1.0);
    } else {
      labGroundShadow(c, origin + const Offset(0, 1), 50, 8, opacity: 0.22 * alpha);
    }
    _faded(c, alpha, () {
      _drawInk(c, origin, angle);
      if (sc.inkAt == null) {
        _label(c, tr('ink'), origin + const Offset(0, -98), color: _Colors.red);
      }
    });
  }

  /// HTML `SVGS.inkBottle` (x1.5): bottle, red ink, dark dropper cap.
  void _drawInk(Canvas c, Offset origin, double angle) {
    c.save();
    c.translate(origin.dx, origin.dy);
    c.rotate(angle);
    c.scale(1.5);
    c.translate(-30, -70);
    const body = Rect.fromLTWH(15, 30, 30, 40);
    c.drawRRect(RRect.fromRectAndRadius(body, const Radius.circular(5)), Paint()..color = Colors.white.withValues(alpha: 0.85));
    c.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(18, 40, 24, 27), const Radius.circular(2)),
      Paint()..color = _Colors.red,
    );
    c.drawLine(const Offset(21, 44), const Offset(21, 62), _stroke(Colors.white.withValues(alpha: 0.5), 2));
    c.drawRRect(RRect.fromRectAndRadius(body, const Radius.circular(5)), _stroke(_Colors.slate400, 2));
    c.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(22, 10, 16, 20), const Radius.circular(3)),
      Paint()..color = _Colors.slate800,
    );
    c.drawLine(const Offset(22, 30), const Offset(38, 30), _stroke(_Colors.slate400, 4, cap: StrokeCap.butt));
    c.restore();
  }

  /// Scalpel position through the HTML swipe animation.
  Offset _scalpelPos() {
    final sc = scene;
    final home = sc.posOf(_Item.scalpel);
    if (!sc.cutting) return home;
    final base = _twigBase(sc.cutOnA);
    // Blade tip on the stem base, then the swipe-cut keyframes.
    final tip = _rotate(const Offset(-50, -1.2), -math.pi / 6);
    final start = base - tip + const Offset(18, -18);
    final u = t - sc.cutAt!;
    if (u < 0.15) return Offset.lerp(sc.cutFrom, start, _ease(u / 0.15))!;
    if (u < 0.65) return start + const Offset(-30, 30) * math.sin(math.pi * (u - 0.15) / 0.5);
    return Offset.lerp(start, _home[_Item.scalpel]!, _ease((u - 0.65) / 0.3))!;
  }

  void _scalpelItem(Canvas c) {
    final sc = scene;
    if (sc.dragItem == _Item.scalpel || (sc.cutA && sc.cutB && !sc.cutting)) return;
    final pos = _scalpelPos();
    _faded(c, sc.prog(sc.stepAt, 0.35), () {
      _drawScalpel(c, pos);
      if (!sc.cutting) _label(c, tr('scalpel'), pos + const Offset(0, -38));
    });
  }

  /// HTML `SVGS.scalpel` (x1.2), rotated -30 degrees.
  void _drawScalpel(Canvas c, Offset centre) {
    c.save();
    c.translate(centre.dx, centre.dy);
    c.rotate(-math.pi / 6);
    c.scale(1.2);
    c.translate(-50, -10);
    final handle = RRect.fromRectAndRadius(const Rect.fromLTRB(40, 5, 95, 15), const Radius.circular(3));
    c.drawRRect(handle, Paint()..color = _Colors.slate700);
    for (var x = 58.0; x <= 86; x += 7) {
      c.drawLine(Offset(x, 7), Offset(x, 13), _stroke(_Colors.slate600, 1.5));
    }
    c.drawRRect(handle, _stroke(_Colors.slate800, 2));
    final blade = Path()
      ..moveTo(40, 5)
      ..lineTo(10, 5)
      ..quadraticBezierTo(5, 15, 40, 15)
      ..close();
    c.drawPath(
      blade,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, _Colors.slate300, _Colors.slate400],
        ).createShader(const Rect.fromLTRB(5, 5, 40, 15)),
    );
    c.drawPath(blade, _stroke(_Colors.slate400, 1));
    c.restore();
  }

  /// HTML `SVGS.magGlass` (x1.2 in its 120 px box).
  void _drawMag(Canvas c, Offset centre, {double scale = 1}) {
    c.save();
    c.translate(centre.dx, centre.dy);
    c.scale(1.2 * scale);
    c.translate(-40, -40); // viewBox centre (50,50) minus the g translate(10,10)
    // Handle and collar.
    c.save();
    c.translate(53, 65);
    c.rotate(-math.pi / 4);
    final grip = RRect.fromRectAndRadius(const Rect.fromLTWH(-8, -20, 16, 40), const Radius.circular(6));
    c.drawRRect(grip, Paint()..color = _Colors.slate700);
    c.drawRRect(grip, _stroke(_Colors.slate800, 2));
    c.restore();
    c.save();
    c.translate(53, 46);
    c.rotate(-math.pi / 4);
    c.drawRect(const Rect.fromLTWH(-5, -6, 10, 12), Paint()..color = _Colors.slate400);
    c.restore();
    // Rim, lens and glare.
    c.drawCircle(const Offset(35, 35), 30, _stroke(_Colors.slate600, 8));
    c.drawCircle(const Offset(35, 35), 26, Paint()..color = Colors.white.withValues(alpha: 0.25));
    c.drawCircle(const Offset(35, 35), 26, _stroke(_Colors.slate400, 2));
    c.drawPath(
      Path()
        ..moveTo(18, 22)
        ..quadraticBezierTo(30, 10, 48, 20),
      _stroke(Colors.white.withValues(alpha: 0.8), 4),
    );
    c.restore();
  }

  /// HTML `triggerSim1()` clock shown during the 24 hour time-lapse.
  void _clock(Canvas c) {
    final u = t - scene.simAt!;
    final alpha = (u / 0.2).clamp(0.0, 1.0) * (1 - ((u - 2.75) / 0.25).clamp(0.0, 1.0));
    const o = Offset(450, 290);
    _faded(c, alpha, () {
      c.drawCircle(o, 96, Paint()..color = _Colors.slate900.withValues(alpha: 0.5));
      labGroundShadow(c, o + const Offset(0, 12), 150, 150, opacity: 0.25);
      c.drawCircle(o, 73.6, Paint()..color = _Colors.slate50);
      c.drawCircle(o, 73.6, _stroke(_Colors.slate800, 9.6));
      labDashedPath(c, Path()..addOval(Rect.fromCircle(center: o, radius: 64)), _stroke(_Colors.slate200, 3.2),
          dash: 6.4, gap: 9.6);
      for (var i = 0; i < 12; i++) {
        final d = _rotate(const Offset(0, -1), i * math.pi / 6);
        c.drawLine(o + d * 52, o + d * (i % 3 == 0 ? 42 : 47), _stroke(_Colors.slate500, i % 3 == 0 ? 3 : 1.6));
      }
      // Hour hand turns twice (24 h); the red hand races round.
      final hour = _rotate(const Offset(0, -34), u / 3 * 4 * math.pi);
      c.drawLine(o, o + hour, _stroke(_Colors.slate800, 6));
      final minute = _rotate(const Offset(0, -56), u / 3 * 24 * math.pi);
      c.drawLine(o, o + minute, _stroke(_Colors.red, 6.4));
      c.drawCircle(o, 8, Paint()..color = _Colors.slate800);
    });
  }

  /// Step 7: magnifier on twig B, light cone and the stem cross-section
  /// (HTML popup keyframes with 0 / 0.2 / 0.4 s delays).
  void _magnified(Canvas c) {
    final sc = scene;
    final k1 = Curves.easeOutBack.transform(sc.prog(sc.magAt, 0.5));
    final k2 = Curves.easeOut.transform(sc.prog(sc.magAt, 0.5, delay: 0.2));
    final k3 = Curves.easeOutBack.transform(sc.prog(sc.magAt, 0.5, delay: 0.4));

    if (k2 > 0) {
      final top = _zoomC + _rotate(const Offset(0, -_zoomR), -0.42);
      final bottom = _zoomC + _rotate(const Offset(0, _zoomR), 0.42);
      c.drawPath(
        Path()
          ..moveTo(_lensC.dx, _lensC.dy)
          ..lineTo(_lensC.dx + (top.dx - _lensC.dx) * k2, _lensC.dy + (top.dy - _lensC.dy) * k2)
          ..lineTo(_lensC.dx + (bottom.dx - _lensC.dx) * k2, _lensC.dy + (bottom.dy - _lensC.dy) * k2)
          ..close(),
        Paint()..color = _Colors.indigo500.withValues(alpha: 0.15),
      );
    }
    if (k1 > 0) {
      c.save();
      c.translate(_lensC.dx, _lensC.dy);
      c.scale(k1);
      c.translate(-_lensC.dx, -_lensC.dy);
      _drawMag(c, _lensC + const Offset(6, 6) * 0.85, scale: 0.85);
      c.restore();
    }
    if (k3 > 0) {
      c.save();
      c.translate(_zoomC.dx, _zoomC.dy);
      c.scale(k3);
      c.translate(-_zoomC.dx, -_zoomC.dy);
      c.drawCircle(
        _zoomC + const Offset(0, 14),
        _zoomR,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
      );
      c.drawCircle(_zoomC, _zoomR, Paint()..color = _Colors.green50);
      _crossSection(c, _zoomC, 90);
      c.drawCircle(_zoomC, _zoomR - 5, _stroke(_Colors.green800, 10));
      c.restore();
    }
    // Leader labels once the view has opened.
    final lk = sc.prog(sc.magAt, 0.4, delay: 0.9);
    if (lk > 0 && showLabels) {
      const k = 90 / 48;
      final xy = _zoomC + _rotate(const Offset(0, -17 * k), 210 * math.pi / 180);
      final ph = _zoomC + _rotate(const Offset(0, -23 * k), 150 * math.pi / 180);
      const xyAt = Offset(612, 396);
      const phAt = Offset(748, 396);
      final lead = _stroke((isDark ? Colors.white : _Colors.slate700).withValues(alpha: 0.8 * lk), 1.6);
      c.drawLine(xy, xyAt - const Offset(0, 11), lead);
      c.drawLine(ph, phAt - const Offset(0, 11), lead);
      final ring = _stroke(_Colors.slate800.withValues(alpha: lk), 1.6);
      c.drawCircle(xy, 8, ring);
      c.drawCircle(ph, 7, ring);
      _label(c, tr('xylem'), xyAt,
          anchor: Alignment.topCenter,
          color: _Colors.red700,
          bg: const Color(0xFFFEE2E2),
          border: _Colors.red300,
          opacity: lk);
      _label(c, tr('phloem'), phAt,
          anchor: Alignment.topCenter,
          color: _Colors.green700,
          bg: _Colors.green100,
          border: _Colors.green300,
          opacity: lk);
    }
  }

  /// HTML `SVGS.detailedCrossSection` (viewBox r = 48 drawn at radius [r]).
  /// Each vascular bundle has its xylem (stained red) towards the pith and
  /// its phloem (green) towards the outside, as in a real dicot stem.
  void _crossSection(Canvas c, Offset o, double r) {
    final k = r / 48;
    void ring(double rr, Color fill, Color edge, double w) {
      c.drawCircle(o, rr * k, Paint()..color = fill);
      c.drawCircle(o, rr * k, _stroke(edge, w * k));
    }

    ring(48, _Colors.green100, _Colors.green700, 1);
    ring(40, _Colors.green200, _Colors.green600, 0.5);
    ring(28, _Colors.green50, _Colors.green300, 0.5);
    ring(10, _Colors.slate200, _Colors.slate300, 0.5);
    for (var i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      final xy = o + _rotate(Offset(0, -17 * k), a);
      final ph = o + _rotate(Offset(0, -23 * k), a);
      labGlow(c, xy, 7 * k, _Colors.red, intensity: 0.5);
      c.drawCircle(xy, 3 * k, Paint()..color = _Colors.red);
      c.drawCircle(xy, 3 * k, _stroke(_Colors.red900, 0.5 * k));
      c.drawCircle(ph, 2.5 * k, Paint()..color = _Colors.green500);
      c.drawCircle(ph, 2.5 * k, _stroke(_Colors.green900, 0.5 * k));
    }
  }

  /// The item under the finger, lifted with a shadow (HTML `.is-dragging`).
  void _draggedItem(Canvas c) {
    final sc = scene;
    final item = sc.dragItem;
    if (item == null) return;
    final p = sc.dragPos;
    _liftShadow(c, p, _box[item]!);
    switch (item) {
      case _Item.jug:
        _drawJug(c, p + const Offset(0, 70), 0);
        _label(c, tr('jug'), p + const Offset(0, -66));
      case _Item.ink:
        _drawInk(c, p + const Offset(0, 50), 0);
        _label(c, tr('ink'), p + const Offset(0, -48), color: _Colors.red);
      case _Item.scalpel:
        _drawScalpel(c, p);
        _label(c, tr('scalpel'), p + const Offset(0, -38));
      case _Item.twigA || _Item.twigB:
        _drawTwig(c, p + _twigFoot, cut: true);
        _label(c, tr(item == _Item.twigA ? 'twigA' : 'twigB'), p + const Offset(0, -88));
      case _Item.mag:
        _drawMag(c, p);
        _label(c, tr('mag'), p + const Offset(0, -56), color: isDark ? _Colors.green400 : _Colors.green700);
      case _Item.food:
        _drawGlucose(c, p);
        _label(c, tr('glucose'), p + const Offset(0, -22), color: isDark ? _Colors.yellow400 : _Colors.yellow600);
    }
  }

  // ===================================================== SCENARIO 2

  void _paintPotatoPlant(Canvas c, Size size) {
    final sc = scene;
    _skyAndSoil(c, size);
    _sunBeams(c);
    _plantBody(c);
    _vascular(c);
    _glucoseFlow(c);
    _sun(c);
    if (sc.step == 2) {
      _leafCardView(c);
    } else {
      _bigLeaf(c);
    }
    _phloemUi(c);
    _potato(c);
    _draggedItem(c);
  }

  /// HTML sky gradient (warms when the sun is on) and soil.
  void _skyAndSoil(Canvas c, Size size) {
    final b = labBleed(size);
    final k = _ease(scene.prog(scene.sunAt, 1.0));
    final bg = isDark ? _Colors.slate900 : _Colors.slate100;
    final o = 0.9 + 0.1 * k; // HTML opacity-90 -> opacity-100
    final top = Color.lerp(bg, Color.lerp(_Colors.sky200, _Colors.yellow200, k), o)!;
    final bottom = Color.lerp(bg, Color.lerp(_Colors.sky100, _Colors.sky50, k), o)!;
    c.drawRect(
      Rect.fromLTRB(b.left, b.top, b.right, _groundY),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, top, bottom],
          stops: const [0, 0.05, 1],
        ).createShader(Rect.fromLTRB(0, b.top, 900, _groundY)),
    );
    c.drawRect(
      Rect.fromLTRB(b.left, _groundY, b.right, b.bottom),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF6B4428), _Colors.soil, Color(0xFF452A17)],
        ).createShader(const Rect.fromLTRB(0, _groundY, 900, 600)),
    );
    // Pebbles.
    final rng = math.Random(7);
    for (var i = 0; i < 70; i++) {
      final p = Offset(b.left + rng.nextDouble() * (b.width), _groundY + 18 + rng.nextDouble() * 240);
      c.drawOval(
        Rect.fromCenter(center: p, width: 4 + rng.nextDouble() * 7, height: 3 + rng.nextDouble() * 4),
        Paint()
          ..color = (rng.nextBool() ? const Color(0xFF7A5232) : _Colors.soilDark).withValues(alpha: 0.6),
      );
    }
    c.drawRect(Rect.fromLTRB(b.left, _groundY, b.right, _groundY + 10), Paint()..color = _Colors.soilDark);
    // Grass tufts along the ground line.
    final grass = _stroke(_Colors.green600, 2.4);
    for (var x = -300.0; x < 1200; x += 38) {
      if ((x - 450).abs() < 30) continue;
      final j = (x * 7.3) % 9;
      for (final d in const [-5.0, 0.0, 5.0]) {
        c.drawLine(Offset(x + d, _groundY + 1), Offset(x + d * 1.8 + (j - 4) * 0.4, _groundY - 9 - j), grass);
      }
    }
  }

  /// Light rays from the sun to the leaves once photosynthesis starts.
  void _sunBeams(Canvas c) {
    final sc = scene;
    if (!sc.sun) return;
    final k = sc.prog(sc.sunAt, 1.0);
    final p = _stroke(_Colors.yellow400.withValues(alpha: 0.6 * k), 4);
    for (final target in const [Offset(130, 222), Offset(290, 62), Offset(770, 128), Offset(450, 205)]) {
      final d = target - _sunC;
      final u = d / d.distance;
      labDashedPath(
        c,
        Path()
          ..moveTo(_sunC.dx + u.dx * 70, _sunC.dy + u.dy * 70)
          ..lineTo(target.dx - u.dx * 12, target.dy - u.dy * 12),
        p,
        dash: 14,
        gap: 10,
        phase: -t * 40,
      );
    }
  }

  /// HTML master SVG: roots, two-tone stems and the background leaves.
  void _plantBody(Canvas c) {
    final roots = _stroke(_Colors.amber900, 6);
    for (final path in [
      Path()
        ..moveTo(450, 400)
        ..quadraticBezierTo(400, 450, 350, 550),
      Path()
        ..moveTo(450, 400)
        ..quadraticBezierTo(500, 450, 550, 550),
      Path()
        ..moveTo(450, 400)
        ..lineTo(450, 550),
      Path()
        ..moveTo(420, 450)
        ..quadraticBezierTo(380, 500, 380, 550),
      Path()
        ..moveTo(480, 450)
        ..quadraticBezierTo(520, 500, 520, 550),
    ]) {
      c.drawPath(path, roots);
    }
    final stems = [
      (Path()
        ..moveTo(450, 400)
        ..lineTo(450, 150), 24.0, 16.0),
      (Path()
        ..moveTo(450, 300)
        ..quadraticBezierTo(300, 280, 200, 220), 12.0, 8.0),
      (Path()
        ..moveTo(450, 220)
        ..quadraticBezierTo(600, 200, 700, 150), 10.0, 6.0),
      (Path()
        ..moveTo(450, 150)
        ..quadraticBezierTo(400, 100, 350, 80), 8.0, 4.0),
    ];
    for (final (path, outer, _) in stems) {
      c.drawPath(path, _stroke(_Colors.green800, outer));
    }
    for (final (path, _, inner) in stems) {
      c.drawPath(path, _stroke(_Colors.green500, inner));
    }
    // Background leaves.
    final leafFill = Paint()..color = _Colors.green400;
    final leafEdge = _stroke(_Colors.green700, 2);
    final right = Path()
      ..moveTo(700, 150)
      ..quadraticBezierTo(750, 80, 850, 110)
      ..quadraticBezierTo(780, 180, 700, 150)
      ..close();
    final top = Path()
      ..moveTo(350, 80)
      ..quadraticBezierTo(280, 20, 220, 50)
      ..quadraticBezierTo(280, 120, 350, 80)
      ..close();
    for (final leaf in [right, top]) {
      c.drawPath(leaf, leafFill);
      c.drawPath(leaf, leafEdge);
    }
    final rib = _stroke(_Colors.green700, 1);
    c.drawPath(
      Path()
        ..moveTo(700, 150)
        ..quadraticBezierTo(775, 130, 850, 110),
      rib,
    );
    c.drawPath(
      Path()
        ..moveTo(350, 80)
        ..quadraticBezierTo(285, 50, 220, 50),
      rib,
    );
  }

  /// Blue xylem and green phloem tubes (visible from step 3).
  void _vascular(Canvas c) {
    final sc = scene;
    final o = sc.step >= 2 ? sc.prog(sc.vascAt, 1.0) : 0.0;
    if (o <= 0) return;
    final xylem = _Colors.blue.withValues(alpha: o);
    c.drawLine(const Offset(444, 400), const Offset(444, 150), _stroke(xylem, 6));
    c.drawPath(
      Path()
        ..moveTo(444, 300)
        ..quadraticBezierTo(300, 280, 200, 220),
      _stroke(xylem, 3),
    );
    c.drawPath(
      Path()
        ..moveTo(444, 220)
        ..quadraticBezierTo(600, 200, 700, 150),
      _stroke(xylem, 3),
    );
    final pk = sc.prog(sc.phloemAt, 1.0);
    if (pk > 0) {
      c.drawPath(
        _phloemPath,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round
          ..color = _Colors.green400.withValues(alpha: 0.7 * pk * o)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
    c.drawPath(_phloemPath, _stroke(Color.lerp(_Colors.emerald800, _Colors.green400, pk)!.withValues(alpha: o), 6));
  }

  /// HTML `animateMotion` glucose particles running down the phloem.
  void _glucoseFlow(Canvas c) {
    final sc = scene;
    if (sc.foodAt == null) return;
    final u = t - sc.foodAt!;
    final len = _phloemMetric.length;
    for (final begin in const [0.0, 1.25]) {
      if (u < begin) continue;
      final f = ((u - begin) / 2.5) % 1;
      final pos = _phloemMetric.getTangentForOffset(len * f)!.position;
      labGlow(c, pos, 28, _Colors.yellow400, intensity: 0.85);
      c.drawCircle(pos, 10, Paint()..color = _Colors.yellow400);
      c.drawCircle(pos, 10, _stroke(_Colors.yellow600, 1.5));
      c.drawCircle(pos - const Offset(3, 3), 3.5, Paint()..color = Colors.white.withValues(alpha: 0.75));
    }
  }

  /// HTML `SVGS.sun`: pulses before the click, spins and glows after.
  void _sun(Canvas c) {
    final sc = scene;
    final k = sc.prog(sc.sunAt, 1.0);
    final on = sc.sunAt != null;
    final since = on ? t - sc.sunAt! : 0.0;
    final scale = on ? 1 + 0.1 * math.sin(math.pi * (since % 20) / 20) : 1.0;
    final rot = on ? since * 2 * math.pi / 20 : 0.0;
    labGlow(c, _sunC, 80 + 70 * k, _Colors.yellow400, intensity: 0.45 + 0.45 * k);
    if (sc.step == 0 && !sc.sun) {
      final ph = (t * 0.8) % 1;
      c.drawCircle(_sunC, 62 + 26 * ph, _stroke(_Colors.yellow400.withValues(alpha: 0.7 * (1 - ph)), 4));
    }
    c.save();
    c.translate(_sunC.dx, _sunC.dy);
    c.rotate(rot);
    c.scale(scale);
    final ray = _stroke(_Colors.yellow400.withValues(alpha: on ? 0.8 + 0.2 * k : 1), 9);
    for (var i = 0; i < 8; i++) {
      final d = _rotate(const Offset(0, -1), i * math.pi / 4);
      c.drawLine(d * 45, d * 60, ray);
    }
    c.drawCircle(
      Offset.zero,
      37.5,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.3),
          colors: [_Colors.yellow100, _Colors.yellow400, _Colors.amber500],
          stops: [0, 0.55, 1],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: 37.5)),
    );
    c.restore();
    if (sc.step != 2) _label(c, tr('sun'), _sunC - const Offset(0, 68));
    if (sc.step == 0 && !sc.sun) {
      _badge(
        c,
        tr('click'),
        _sunC + const Offset(85, 0),
        bg: _Colors.amber400,
        fg: _Colors.amber900,
        border: _Colors.amber600,
      );
    }
  }

  /// HTML `SVGS.leaf` on the left branch (x1.5, x1.25 once clicked) with
  /// the glucose it made.
  void _bigLeaf(Canvas c) {
    final sc = scene;
    final grow = sc.leaf ? 1.25 : 1.0;
    final hint = sc.step == 1 && !sc.leaf;
    c.save();
    c.translate(_leafPivot.dx, _leafPivot.dy);
    c.scale(grow);
    c.translate(-_leafPivot.dx, -_leafPivot.dy);
    c.save();
    c.translate(50, 182.5);
    c.scale(1.5);
    final leaf = Path()
      ..moveTo(0, 25)
      ..cubicTo(40, 0, 80, 0, 100, 25)
      ..cubicTo(80, 50, 40, 50, 0, 25)
      ..close();
    if (hint) {
      c.drawPath(
        leaf,
        Paint()
          ..color = _Colors.green500.withValues(alpha: 0.6 * _pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }
    c.drawPath(
      leaf,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_Colors.green500, _Colors.green500.withValues(alpha: 0.8)],
        ).createShader(const Rect.fromLTRB(0, 0, 100, 50)),
    );
    c.drawPath(leaf, _stroke(_Colors.emerald900, 2 / 1.5));
    c.drawLine(const Offset(0, 25), const Offset(90, 25), _stroke(_Colors.emerald900.withValues(alpha: 0.4), 1.5 / 1.5));
    for (final x in const [25.0, 45.0, 65.0]) {
      c.drawLine(Offset(x + 10, 25), Offset(x, 12), _stroke(_Colors.emerald900.withValues(alpha: 0.25), 1));
      c.drawLine(Offset(x + 10, 25), Offset(x, 38), _stroke(_Colors.emerald900.withValues(alpha: 0.25), 1));
    }
    c.restore();
    c.restore();
    Offset scaled(Offset p) => _leafPivot + (p - _leafPivot) * grow;
    _label(c, tr('leaf'), scaled(const Offset(118, 262)), anchor: Alignment.topCenter);
    if (sc.leaf && sc.dragItem != _Item.food) {
      final pos = _home[_Item.food]!;
      _drawGlucose(c, pos);
      _label(c, tr('glucose'), pos + const Offset(0, -22), color: isDark ? _Colors.yellow400 : _Colors.yellow600);
    }
  }

  /// HTML `SVGS.glucose` in its 40 px box.
  void _drawGlucose(Canvas c, Offset p) {
    labGlow(c, p, 30, _Colors.yellow400, intensity: 0.6 + 0.3 * math.sin(t * 4));
    c.drawCircle(p, 16, Paint()..color = _Colors.yellow200);
    c.drawCircle(p, 16, _stroke(_Colors.yellow600, 4));
    c.drawCircle(p - const Offset(5, 5), 4, Paint()..color = Colors.white.withValues(alpha: 0.7));
  }

  /// Step 3: the leaf card with the HTML `SVGS.leafCrossSection`.
  void _leafCardView(Canvas c) {
    final panel = isDark ? _Colors.slate800 : Colors.white;
    final border = isDark ? _Colors.slate700 : _Colors.slate300;
    final rr = RRect.fromRectAndRadius(_leafCard, const Radius.circular(16));
    c.drawRRect(
      rr.shift(const Offset(0, 6)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
    );
    c.drawRRect(rr, Paint()..color = panel);
    c.drawRRect(rr.deflate(2), _stroke(border, 4));

    c.save();
    c.translate(115, 50);
    c.scale(1.4);
    final leaf = Path()
      ..moveTo(10, 75)
      ..quadraticBezierTo(80, -20, 190, 75)
      ..quadraticBezierTo(80, 170, 10, 75)
      ..close();
    c.drawPath(leaf, Paint()..color = _Colors.green400);
    c.drawPath(leaf, _stroke(_Colors.green800, 3));
    c.drawLine(const Offset(10, 75), const Offset(190, 75), _stroke(_Colors.green800, 2));
    // Cut-away block of leaf cells.
    final block = Path()
      ..moveTo(70, 40)
      ..lineTo(130, 40)
      ..lineTo(110, 90)
      ..lineTo(50, 90)
      ..close();
    c.drawPath(block, Paint()..color = _Colors.green900);
    c.drawPath(block, _stroke(_Colors.emerald900, 2));
    for (var row = 0; row < 2; row++) {
      final y = 45.0 + row * 22;
      final left = 70 - 0.4 * (y - 40) + 4;
      for (var i = 0; i < 3; i++) {
        final x = left + i * 18;
        final cell = Path()
          ..moveTo(x, y)
          ..lineTo(x + 14, y)
          ..lineTo(x + 14 - 6, y + 15)
          ..lineTo(x - 6, y + 15)
          ..close();
        c.drawPath(cell, Paint()..color = _Colors.green500);
        c.drawPath(cell, _stroke(_Colors.green900, 1.5));
        c.drawCircle(Offset(x + 4, y + 7.5), 1.6, Paint()..color = _Colors.green800);
      }
    }
    // Inputs: light, water, CO2.
    final lightCol = isDark ? _Colors.yellow400 : _Colors.yellow600;
    final co2Col = isDark ? _Colors.slate400 : _Colors.slate600;
    labArrow(c, const Offset(80, 10), const Offset(100, 40), color: lightCol, width: 4, head: 10);
    labArrow(c, const Offset(30, 40), const Offset(60, 55), color: _Colors.blue, width: 4, head: 10);
    labArrow(c, const Offset(30, 110), const Offset(60, 85), color: _Colors.slate500, width: 4, head: 10);
    labText(c, tr('light'), const Offset(50, 23), size: 12, weight: FontWeight.w800, color: lightCol, anchor: Alignment.bottomLeft);
    labText(c, tr('water'), const Offset(5, 38), size: 12, weight: FontWeight.w800, color: _Colors.blue, anchor: Alignment.bottomLeft);
    final co2 = tr('co2');
    final r = labText(c, co2.substring(0, co2.length - 1), const Offset(5, 128),
        size: 12, weight: FontWeight.w800, color: co2Col, anchor: Alignment.bottomLeft);
    labText(c, co2.substring(co2.length - 1), Offset(r.right + 0.5, r.bottom + 2),
        size: 8.5, weight: FontWeight.w800, color: co2Col, anchor: Alignment.bottomLeft);
    // Output: glucose.
    labDashedLine(c, const Offset(120, 75), const Offset(152, 75), _stroke(_Colors.yellow400, 4, cap: StrokeCap.butt),
        dash: 4, gap: 4, phase: -t * 12);
    labArrow(c, const Offset(150, 75), const Offset(160, 75), color: _Colors.yellow400, width: 4, head: 10);
    for (final o in const [Offset(170, 75), Offset(180, 75), Offset(175, 85)]) {
      labGlow(c, o, 9, _Colors.yellow400, intensity: 0.5 + 0.4 * math.sin(t * 4 + o.dx));
      c.drawCircle(o, 4, Paint()..color = _Colors.yellow200);
      c.drawCircle(o, 4, _stroke(_Colors.yellow600, 1));
    }
    labText(c, tr('glucose'), const Offset(150, 108), size: 12, weight: FontWeight.w800, color: lightCol, anchor: Alignment.bottomLeft);
    c.restore();

    _badge(
      c,
      tr('produced'),
      const Offset(390, 240),
      bg: _Colors.amber100,
      fg: _Colors.amber600,
      anchor: Alignment.bottomRight,
      check: true,
    );
  }

  /// HTML phloem click zone: pulse, Xylem / Phloem labels, CLICK badge and
  /// the dashed drop zone for the glucose.
  void _phloemUi(Canvas c) {
    final sc = scene;
    if (sc.step < 2) return;
    final o = sc.prog(sc.vascAt, 1.0);
    if (sc.step == 2 && !sc.phloem) {
      c.drawRRect(
        RRect.fromRectAndRadius(_phloemClick.inflate(4), const Radius.circular(20)),
        Paint()..color = _Colors.green500.withValues(alpha: 0.35 * _pulse),
      );
    }
    _label(c, tr('xylem'), Offset(_phloemClick.left - 8, _phloemClick.bottom - 4),
        anchor: Alignment.centerRight,
        color: _Colors.blue700,
        bg: _Colors.blue100,
        border: _Colors.blue300,
        opacity: o);
    if (sc.phloem) {
      _label(c, tr('phloem'), Offset(_phloemClick.right + 8, _phloemClick.bottom - 4),
          anchor: Alignment.centerLeft,
          color: _Colors.green700,
          bg: _Colors.green100,
          border: _Colors.green300,
          opacity: sc.prog(sc.phloemAt, 0.5));
    }
    if (sc.phloem && sc.step == 3) {
      c.drawOval(_zPhloem, Paint()..color = _Colors.green500.withValues(alpha: 0.2));
      labDashedPath(c, Path()..addOval(_zPhloem), _stroke(_Colors.green500, 4, cap: StrokeCap.butt),
          dash: 10, gap: 7, phase: t * 10);
    }
    if (sc.step == 2 && !sc.phloem) {
      _badge(
        c,
        tr('click'),
        Offset(_phloemClick.right + 16, _phloemClick.center.dy),
        bg: _Colors.green400,
        fg: _Colors.green900,
        border: _Colors.green600,
      );
    }
  }

  /// HTML potato tuber: pulses at step 5, swells x1.3 with a glow.
  void _potato(Canvas c) {
    final sc = scene;
    final k = _ease(sc.prog(sc.potatoAt, 1.0));
    final scale = 1 + 0.3 * k;
    if (k > 0) labGlow(c, _potatoC, 90 * scale, _Colors.yellow400, intensity: k);
    if (sc.step == 4 && !sc.potato) {
      c.drawOval(
        Rect.fromCenter(center: _potatoC, width: 110, height: 90),
        Paint()
          ..color = _Colors.yellow400.withValues(alpha: 0.5 * _pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }
    final r = Rect.fromCenter(center: _potatoC, width: 90 * scale, height: 70 * scale);
    c.drawOval(
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.4),
          colors: [_Colors.amber500, _Colors.amber600, _Colors.amber700],
          stops: [0, 0.55, 1],
        ).createShader(r),
    );
    c.drawOval(r, _stroke(_Colors.amber800, 3));
    for (final (o, rr) in const [(Offset(-20, -10), 2.0), (Offset(20, 10), 3.0), (Offset(-10, 20), 2.0)]) {
      c.drawCircle(_potatoC + o * scale, rr * scale, Paint()..color = _Colors.amber900);
    }
    _label(c, tr('tuber'), _potatoC - Offset(0, 35 * scale + 6));
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.isDark != isDark || old.showLabels != showLabels || old.lang != lang;
}

/// Paints the canvas-confetti bursts over the canvas.
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.confetti, required Listenable repaint}) : super(repaint: repaint);

  final _Confetti confetti;

  @override
  void paint(Canvas canvas, Size size) {
    if (confetti.parts.isEmpty) return;
    // canvas-confetti works in window pixels; scale its motion to the canvas.
    final k = (size.shortestSide / 640).clamp(0.45, 1.25);
    final origin = Offset(size.width * 0.5, size.height * confetti.originY);
    Offset at(double x, double y) => origin + Offset(x, y) * k;
    for (final p in confetti.parts) {
      final paint = Paint()..color = p.color.withValues(alpha: (1 - p.tick / _Fetti.ticks).clamp(0.0, 1.0));
      final x1 = p.x + p.random * p.tiltCos;
      final y1 = p.y + p.random * p.tiltSin;
      final x2 = p.wobbleX + p.random * p.tiltCos;
      final y2 = p.wobbleY + p.random * p.tiltSin;
      if (p.circle) {
        canvas.save();
        final c = at(p.x, p.y);
        canvas.translate(c.dx, c.dy);
        canvas.rotate(math.pi / 10 * p.wobble);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: math.max(1, (x2 - x1).abs() * 0.6 * 2 * k),
            height: math.max(1, (y2 - y1).abs() * 0.6 * 2 * k),
          ),
          paint,
        );
        canvas.restore();
      } else {
        final a = at(p.x, p.y), b = at(p.wobbleX, y1), c = at(x2, y2), d = at(x1, p.wobbleY);
        canvas.drawPath(
          Path()
            ..moveTo(a.dx, a.dy)
            ..lineTo(b.dx, b.dy)
            ..lineTo(c.dx, c.dy)
            ..lineTo(d.dx, d.dy)
            ..close(),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => false;
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
