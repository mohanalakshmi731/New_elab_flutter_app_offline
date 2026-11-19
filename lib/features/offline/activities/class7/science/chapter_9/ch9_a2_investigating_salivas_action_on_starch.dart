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

/// Class 7 Science • Chapter 9 • Activity 2
/// Investigating Saliva's Action on Starch.
///
/// Native Flutter port of `Cl7S-Ch9-A2-Investigating_Saliva_s_Action_on_Starch.html`.
/// Scenario 1 feeds a chapati to a virtual mouth and, while "Hold to Chew" is
/// pressed, salivary amylase breaks blue starch chains into pink sugar.
/// Scenario 2 runs the iodine test on boiled rice (A) and chewed rice (B).
class Ch9A2InvestigatingSalivasActionOnStarchPage extends StatefulWidget {
  const Ch9A2InvestigatingSalivasActionOnStarchPage({super.key});

  @override
  State<Ch9A2InvestigatingSalivasActionOnStarchPage> createState() =>
      _Ch9A2InvestigatingSalivasActionOnStarchPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pop 2357, drop 2364, pickup 2356,
/// splash 1311, magic 871.
enum _Sound implements LabTone {
  /// Generic button click.
  click('click.mp3'),

  /// Sidebar expand / collapse.
  toggle('toggle.mp3'),

  /// Correct action / right answer.
  correct('correct.mp3'),

  /// Wrong action / invalid move (HTML `playSound('error')`).
  wrong('wrong.mp3'),

  /// Scenario completed / success popup (HTML `playSound('success')`).
  success('success.mp3'),

  /// Scenario changed.
  scenario('scenario.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('curtain.mp3'),

  /// HTML `playSound('pop')`: chapati swallowed, chewing starts, a tool is
  /// applied to a test tube.
  pop('pop.mp3'),

  /// Iodine drops falling into a test tube.
  drop('drop.mp3'),

  /// A tray item or the chapati is picked up.
  pickup('pickup.mp3'),

  /// Water poured from the beaker.
  splash('splash.mp3'),

  /// Confetti burst at the end of a scenario.
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

/// Brand (`bio` / `med`) and Tailwind colours used by this lab.
abstract final class _Colors {
  static const Color emerald200 = Color(0xFFA7F3D0); // board text
  static const Color emerald300 = Color(0xFF6EE7B7); // curtain subtitle
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981); // bio.main
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald700 = Color(0xFF047857);
  static const Color blue = Color(0xFF3B82F6); // starch, acrylic rack
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue900 = Color(0xFF1E3A8A); // control magnifier
  static const Color indigo = Color(0xFF6366F1); // med.blue
  static const Color yellow = Color(0xFFEAB308); // amylase enzyme
  static const Color pink = Color(0xFFEC4899); // sugar
  static const Color pink400 = Color(0xFFF472B6);
  static const Color pink600 = Color(0xFFDB2777);
  static const Color orange400 = Color(0xFFFB923C);
  static const Color orange500 = Color(0xFFF97316);
  static const Color amber700 = Color(0xFFB45309); // iodine without starch
  static const Color amber800 = Color(0xFF92400E); // iodine drops
  static const Color violet900 = Color(0xFF4C1D95); // iodine in starch
  static const Color gray900 = Color(0xFF111827); // iodine + starch
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
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate900,
    panel: Color(0xEB0F172A),
    border: Color(0x26FFFFFF),
    card: Color(0xCC0F172A),
    cardBorder: _Colors.slate800,
    canvasBg: _Colors.slate900,
    text: _Colors.slate200,
    textStrong: Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.emerald500,
    onAccent: _Colors.slate950,
    primary: _Colors.emerald600,
    onPrimary: Colors.white,
    success: _Colors.emerald400,
    danger: Color(0xFFEF4444),
    onDanger: Colors.white,
    info: _Colors.blue,
    popupBg: _Colors.slate900,
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: _Colors.slate100,
    toastText: _Colors.slate900,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x5510B981),
    curtainText: Colors.white,
    curtainMuted: Color(0xCC6EE7B7),
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.emerald400,
    buttonBorder: Color(0xB310B981),
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
    canvasBg: _Colors.slate50,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.emerald500,
    onAccent: _Colors.slate950,
    primary: _Colors.emerald600,
    onPrimary: Colors.white,
    success: _Colors.emerald600,
    danger: Color(0xFFDC2626),
    onDanger: Colors.white,
    info: _Colors.blue,
    popupBg: _Colors.slate50,
    popupHeader: _Colors.slate100,
    dialogBg: Colors.white,
    toastBg: _Colors.slate900,
    toastText: Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x5510B981),
    curtainText: Colors.white,
    curtainMuted: Color(0xCC6EE7B7),
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.emerald400,
    buttonBorder: Color(0xB310B981),
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
    'app_title': "Investigating Saliva's Action on Starch",
    'app_subtitle': 'Class 7 • Life Processes in Animals',
    'scen_1_opt': 'Scenario 1: The Sweet Taste of Chewing',
    'scen_2_opt': 'Scenario 2: The Iodine Test: Starch Detective',
    'welcome_lab': 'Welcome to the Biology Lab.',
    // Setup board.
    'btn_setup': 'Setup Activity',
    'board_desc_1': 'Digestion starts in the mouth! See what enzymes do to complex food.',
    'board_desc_2': "Let's perform a chemical test to prove saliva's effect on starch.",
    // Scenario 1.
    'lbl_chapati': 'Chapati',
    'feed_me': 'Feed Me',
    'btn_chew': 'Hold to Chew',
    'lbl_sweetness': 'Sweetness',
    'drag_chapati': 'Drag the chapati into the mouth.',
    'lbl_inside_view': 'Inside View',
    'lbl_starch': 'Starch chain',
    'lbl_enzyme': 'Salivary amylase',
    'lbl_sugar': 'Sugar',
    // Scenario 2 tray.
    'lbl_tubes': 'Tubes',
    'lbl_rice': 'Boiled Rice',
    'lbl_chewed': 'Chewed Rice',
    'lbl_water': 'Water',
    'lbl_iodine': 'Iodine',
    'tip_tubes': 'Test Tubes',
    'tip_rice': 'Boiled Rice',
    'tip_chewed': 'Chew & Add Rice',
    'tip_water': 'Water',
    'tip_iodine': 'Iodine Dropper',
    // Scenario 2 feedback.
    'msg_place_tubes': 'Place the Test Tubes first.',
    'msg_add_rice': 'Add Boiled Rice to Tube A.',
    'msg_add_chewed': 'Add Chewed Rice to Tube B.',
    'msg_add_water': 'Add Water to both tubes.',
    'msg_iodine_a': 'Add Iodine to Tube A.',
    'msg_iodine_b': 'Add Iodine to Tube B.',
    'msg_invalid': 'Invalid action for this step.',
    'drop_tubes_here': 'Drop the test tubes here',
    'mag_a': 'Control: Iodine + Starch',
    'mag_b': 'Exp: Iodine + Digested Starch',
    'res_starch': 'Starch present',
    'res_no_starch': 'No starch',
    // Conclusion popup.
    'sc_complete': 'Scenario {n} Complete!',
    'observation_title': 'Key Takeaway',
    'sum_head_1': 'Digestion Begins!',
    'sum_body_1':
        'Saliva contains an enzyme called salivary amylase that breaks down complex carbohydrates (starch) into simpler sugars, which is why starchy foods taste sweeter after prolonged chewing.',
    'sum_head_2': 'Starch Digested!',
    'sum_body_2':
        'The Iodine test confirmed that the salivary amylase in the chewed rice (Tube B) successfully broke down the starch, resulting in a negative (no color change) test, unlike the unchewed control (Tube A).',
    's2_summary_msg':
        'Blue-black color proves starch is present. No color change means the saliva already digested the starch!',
    'not_sweet': 'Starch (not sweet)',
    'sweet': 'Sugar (sweet)',
    'res_a': 'Tube A (control): blue-black',
    'res_b': 'Tube B (chewed): brownish-yellow',
  },
  'hi': {
    'app_title': 'स्टार्च पर लार की क्रिया की जांच',
    'app_subtitle': 'कक्षा 7 • जंतुओं में जैव प्रक्रम',
    'scen_1_opt': 'परिदृश्य 1: चबाने का मीठा स्वाद',
    'scen_2_opt': 'परिदृश्य 2: आयोडीन परीक्षण: स्टार्च जासूस',
    'welcome_lab': 'जीव विज्ञान लैब में आपका स्वागत है।',
    'btn_setup': 'गतिविधि सेट करें',
    'board_desc_1': 'पाचन मुँह से शुरू होता है! देखें कि एंजाइम जटिल भोजन के साथ क्या करते हैं।',
    'board_desc_2': 'आइए स्टार्च पर लार के प्रभाव को सिद्ध करने के लिए एक रासायनिक परीक्षण करें।',
    'lbl_chapati': 'चपाती',
    'feed_me': 'मुझे खिलाओ',
    'btn_chew': 'चबाने के लिए दबाए रखें',
    'lbl_sweetness': 'मिठास',
    'drag_chapati': 'चपाती को खींचकर मुँह में छोड़ें।',
    'lbl_inside_view': 'अंदर का दृश्य',
    'lbl_starch': 'स्टार्च श्रृंखला',
    'lbl_enzyme': 'लार एमाइलेज',
    'lbl_sugar': 'शर्करा',
    'lbl_tubes': 'परखनलियाँ',
    'lbl_rice': 'उबले चावल',
    'lbl_chewed': 'चबाए चावल',
    'lbl_water': 'पानी',
    'lbl_iodine': 'आयोडीन',
    'tip_tubes': 'परखनलियाँ',
    'tip_rice': 'उबले चावल',
    'tip_chewed': 'चबाकर चावल डालें',
    'tip_water': 'पानी',
    'tip_iodine': 'आयोडीन ड्रॉपर',
    'msg_place_tubes': 'पहले परखनलियाँ रखें।',
    'msg_add_rice': 'परखनली A में उबले चावल डालें।',
    'msg_add_chewed': 'परखनली B में चबाए चावल डालें।',
    'msg_add_water': 'दोनों परखनलियों में पानी डालें।',
    'msg_iodine_a': 'परखनली A में आयोडीन डालें।',
    'msg_iodine_b': 'परखनली B में आयोडीन डालें।',
    'msg_invalid': 'इस चरण के लिए यह क्रिया मान्य नहीं है।',
    'drop_tubes_here': 'परखनलियाँ यहाँ छोड़ें',
    'mag_a': 'नियंत्रण: आयोडीन + स्टार्च',
    'mag_b': 'प्रयोग: आयोडीन + पचा हुआ स्टार्च',
    'res_starch': 'स्टार्च मौजूद',
    'res_no_starch': 'स्टार्च नहीं',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    'observation_title': 'मुख्य निष्कर्ष',
    'sum_head_1': 'पाचन शुरू!',
    'sum_body_1':
        'लार में लार एमाइलेज नामक एंजाइम होता है जो जटिल कार्बोहाइड्रेट (स्टार्च) को सरल शर्करा में तोड़ देता है। इसीलिए स्टार्च वाला भोजन देर तक चबाने पर मीठा लगने लगता है।',
    'sum_head_2': 'स्टार्च पच गया!',
    'sum_body_2':
        'आयोडीन परीक्षण ने पुष्टि की कि चबाए गए चावल (परखनली B) में लार एमाइलेज ने स्टार्च को सफलतापूर्वक तोड़ दिया, इसलिए परीक्षण नकारात्मक रहा (रंग नहीं बदला), जबकि बिना चबाए नियंत्रण (परखनली A) का रंग बदल गया।',
    's2_summary_msg':
        'नीला-काला रंग सिद्ध करता है कि स्टार्च मौजूद है। रंग न बदलने का अर्थ है कि लार ने स्टार्च को पहले ही पचा दिया है!',
    'not_sweet': 'स्टार्च (मीठा नहीं)',
    'sweet': 'शर्करा (मीठी)',
    'res_a': 'परखनली A (नियंत्रण): नीला-काला',
    'res_b': 'परखनली B (चबाए चावल): भूरा-पीला',
  },
};

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To visually understand how saliva begins to break down the starch in food into sugar, explaining the change in taste.',
      steps: [
        LabStep(
          concept: 'Food Entry',
          action: 'DRAG the piece of chapati from the plate and DROP it into the virtual mouth.',
          observation: "The chapati enters the mouth, and a magnified 'Inside View' window appears.",
        ),
        LabStep(
          concept: 'Mechanical & Chemical Action',
          action: "CLICK and HOLD the 'Chew' button for 30 seconds.",
          observation:
              "Animated teeth break the chapati, and yellow Pac-Man-like shapes (saliva enzymes) start 'eating' the blue starch chains.",
        ),
        LabStep(
          concept: 'Starch to Sugar Conversion',
          action: "Continue holding the 'Chew' button.",
          observation:
              "The blue starch chains are completely converted into small, pink hexagonal molecules representing sugar. A 'Sweetness Meter' rises.",
        ),
        LabStep(
          concept: 'Final State',
          action: "Release the 'Chew' button.",
          observation:
              "Saliva's enzymes broke down complex starch (not sweet) into simple sugar (sweet)! This is the first step of chemical digestion.",
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To use a chemical indicator (iodine) in a controlled experiment to prove that saliva digests starch.',
      steps: [
        LabStep(
          concept: 'Setup',
          action: 'DRAG the two test tubes from the shelf and DROP them into the rack.',
          observation: 'Two empty test tubes, labeled A and B, are placed securely in the rack.',
        ),
        LabStep(
          concept: 'Control Sample',
          action: 'DRAG the spoon of boiled rice and DROP it into Test Tube A.',
          observation: 'A spoonful of boiled rice (containing intact starch) is added to Test Tube A.',
        ),
        LabStep(
          concept: 'Experimental Sample',
          action: 'DRAG the chewed rice and DROP it into Test Tube B.',
          observation: 'A spoonful of chewed rice (mixed with saliva enzymes) is added to Test Tube B.',
        ),
        LabStep(
          concept: 'Prepare Solution',
          action: 'DRAG the beaker of water and TILT it over both test tubes.',
          observation: 'Both test tubes are now filled with a rice-water mixture.',
        ),
        LabStep(
          concept: 'Indicator Test (Control)',
          action: 'DRAG the iodine dropper over Test Tube A and CLICK to add 3 drops.',
          observation:
              'The solution in Test Tube A turns a dark blue-black color, proving starch is present.',
        ),
        LabStep(
          concept: 'Indicator Test (Experiment)',
          action: 'DRAG the iodine dropper over Test Tube B and CLICK to add 3 drops.',
          observation: 'The solution in Test Tube B remains a brownish-yellow color.',
        ),
        LabStep(
          concept: 'Conclusion',
          action: 'Compare the final colors.',
          observation:
              'Blue-black color proves starch is present. No color change means the saliva already digested the starch!',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'यह दृश्य रूप से समझना कि लार भोजन में मौजूद स्टार्च को शर्करा में तोड़ना कैसे शुरू करती है, जिससे स्वाद में आए बदलाव की व्याख्या होती है।',
      steps: [
        LabStep(
          concept: 'भोजन का प्रवेश',
          action: 'चपाती के टुकड़े को प्लेट से खींचें और आभासी मुँह में छोड़ें।',
          observation: "चपाती मुँह में जाती है और एक बड़ा किया हुआ 'अंदर का दृश्य' दिखाई देता है।",
        ),
        LabStep(
          concept: 'यांत्रिक और रासायनिक क्रिया',
          action: "'चबाने के लिए दबाए रखें' बटन को 30 सेकंड तक दबाए रखें।",
          observation:
              "दाँत चपाती को तोड़ते हैं, और पीले पैक-मैन जैसे आकार (लार के एंजाइम) नीली स्टार्च श्रृंखलाओं को 'खाने' लगते हैं।",
        ),
        LabStep(
          concept: 'स्टार्च से शर्करा में परिवर्तन',
          action: 'बटन को दबाए रखना जारी रखें।',
          observation:
              "नीली स्टार्च श्रृंखलाएँ पूरी तरह छोटे, गुलाबी षट्कोणीय अणुओं (शर्करा) में बदल जाती हैं। 'मिठास मीटर' ऊपर उठता है।",
        ),
        LabStep(
          concept: 'अंतिम अवस्था',
          action: 'बटन छोड़ दें।',
          observation:
              'लार के एंजाइमों ने जटिल स्टार्च (मीठा नहीं) को सरल शर्करा (मीठी) में तोड़ दिया! यह रासायनिक पाचन का पहला चरण है।',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'एक नियंत्रित प्रयोग में रासायनिक सूचक (आयोडीन) का उपयोग करके यह सिद्ध करना कि लार स्टार्च को पचाती है।',
      steps: [
        LabStep(
          concept: 'सेटअप',
          action: 'दोनों परखनलियों को शेल्फ से खींचकर स्टैंड (रैक) में छोड़ें।',
          observation: 'A और B लेबल वाली दो खाली परखनलियाँ रैक में मज़बूती से रखी जाती हैं।',
        ),
        LabStep(
          concept: 'नियंत्रण नमूना',
          action: 'उबले चावल की चम्मच को खींचकर परखनली A में छोड़ें।',
          observation: 'उबले चावल (जिनमें स्टार्च अपरिवर्तित है) की एक चम्मच परखनली A में डाली जाती है।',
        ),
        LabStep(
          concept: 'प्रायोगिक नमूना',
          action: 'चबाए हुए चावल को खींचकर परखनली B में छोड़ें।',
          observation: 'चबाए हुए चावल (लार के एंजाइमों से मिले हुए) की एक चम्मच परखनली B में डाली जाती है।',
        ),
        LabStep(
          concept: 'घोल तैयार करें',
          action: 'पानी के बीकर को खींचें और दोनों परखनलियों के ऊपर झुकाएँ।',
          observation: 'दोनों परखनलियाँ अब चावल और पानी के मिश्रण से भर गई हैं।',
        ),
        LabStep(
          concept: 'सूचक परीक्षण (नियंत्रण)',
          action: 'आयोडीन ड्रॉपर को परखनली A के ऊपर खींचें और 3 बूँदें डालें।',
          observation: 'परखनली A का घोल गहरे नीले-काले रंग का हो जाता है, जिससे सिद्ध होता है कि स्टार्च मौजूद है।',
        ),
        LabStep(
          concept: 'सूचक परीक्षण (प्रयोग)',
          action: 'आयोडीन ड्रॉपर को परखनली B के ऊपर खींचें और 3 बूँदें डालें।',
          observation: 'परखनली B का घोल भूरा-पीला ही रहता है।',
        ),
        LabStep(
          concept: 'निष्कर्ष',
          action: 'अंतिम रंगों की तुलना करें।',
          observation:
              'नीला-काला रंग सिद्ध करता है कि स्टार्च मौजूद है। रंग न बदलने का अर्थ है कि लार ने स्टार्च को पहले ही पचा दिया है!',
        ),
      ],
    ),
  ],
};

// ============================================================== STATE

const Size _design = Size(1000, 560);

// Scenario 1: microscopic "inside the mouth" view.
const Offset _microCenter = Offset(430, 282);
const Offset _mouthCenter = Offset(430, 318);
const double _mouthR = 100;
const Offset _plateCenter = Offset(790, 165);
const double _chapatiR = 46;

/// Chewing speed: HTML adds 1.5 % every 50 ms.
const double _chewRate = 30;

// Scenario 2: lab bench with the acrylic rack.
const double _rackX = 440;
const Offset _rackDepth = Offset(24, -16);
const List<double> _tubeX = [372, 532];
const double _tubeHalfW = 25;
const double _tubeTop = 150;
const double _tubeBottom = 396;
const double _liquidTop = 252;
const double _benchBack = 350;
const double _benchFront = 500;
const List<Offset> _lensCenter = [Offset(188, 182), Offset(708, 182)];
const double _lensR = 88;

/// HTML: tubes dropped anywhere in the middle 60 % of the view.
const Rect _rackZone = Rect.fromLTRB(200, 112, 800, 448);

/// Final iodine colours (HTML `addIodineDrop`).
const List<Color> _iodineColor = [_Colors.gray900, _Colors.amber700];

/// Tray item ids, in the HTML tray order.
const List<String> _toolIds = ['tubes', 'rice', 'chewed', 'water', 'iodine'];

double _clamp01(double v) => v.clamp(0.0, 1.0);
double _ease(double v) => Curves.easeInOutCubic.transform(_clamp01(v));

/// A rice grain (or chewed lump) resting at the bottom of a test tube.
class _Grain {
  const _Grain(this.dx, this.up, this.angle, this.size, this.delay);

  /// Offset from the tube axis and height above the tube bottom.
  final double dx;
  final double up;
  final double angle;
  final double size;

  /// Stagger while falling from the spoon (s).
  final double delay;
}

/// A drifting background particle (saliva bubble / chapati crumb).
class _Mote {
  const _Mote(this.pos, this.r, this.speed, this.phase, this.shape);
  final Offset pos;
  final double r;
  final double speed;
  final double phase;

  /// Irregular outline radii (crumbs).
  final List<double> shape;
}

/// One confetti piece (HTML `canvas-confetti` burst).
class _Confetti {
  const _Confetti(this.v, this.color, this.size, this.spin, this.flip, this.phase);
  final Offset v;
  final Color color;
  final double size;
  final double spin;
  final double flip;
  final double phase;
}

/// Mutable scene model read by the painters every frame.
class _Scene {
  _Scene() {
    final rnd = _rnd;
    for (var i = 0; i < 2; i++) {
      grains[i] = List.generate(30, (_) {
        final up = 5 + rnd.nextDouble() * 32;
        const r = 18.0;
        final dy = _tubeHalfW - up;
        final maxDx = up < _tubeHalfW ? math.sqrt(math.max(0.0, r * r - dy * dy)) : r;
        return _Grain(
          (rnd.nextDouble() * 2 - 1) * maxDx,
          up,
          rnd.nextDouble() * math.pi,
          i == 0 ? 1.0 : 4.6 + rnd.nextDouble() * 2.2,
          rnd.nextDouble() * 0.3,
        );
      });
    }
    for (var i = 0; i < 18; i++) {
      bubbles.add(_Mote(
        Offset(rnd.nextDouble() * 1000, rnd.nextDouble() * 640),
        4 + rnd.nextDouble() * 11,
        10 + rnd.nextDouble() * 22,
        rnd.nextDouble() * math.pi * 2,
        const [],
      ));
    }
    for (var i = 0; i < 14; i++) {
      crumbs.add(_Mote(
        Offset(60 + rnd.nextDouble() * 820, 90 + rnd.nextDouble() * 380),
        6 + rnd.nextDouble() * 9,
        0.2 + rnd.nextDouble() * 0.3,
        rnd.nextDouble() * math.pi * 2,
        List.generate(7, (_) => 0.65 + rnd.nextDouble() * 0.45),
      ));
    }
    for (var i = 0; i < 11; i++) {
      final a = rnd.nextDouble() * math.pi * 2;
      final d = math.sqrt(rnd.nextDouble()) * 0.72;
      chapatiSpots.add(Offset(math.cos(a) * d, math.sin(a) * d));
    }
  }

  final math.Random _rnd = math.Random(9);

  int scenario = 0;

  /// HTML `State.step`: 0 = setup board, then 1-based steps; one past the
  /// last step once the scenario is finished.
  int step = 0;
  double time = 0;
  bool done = false;

  // ---- Scenario 1
  bool fed = false;
  double fedT0 = 0;
  Offset chapati = _plateCenter;
  bool draggingChapati = false;
  bool overMouth = false;
  double progress = 0;
  bool chewing = false;
  bool chewDone = false;

  // ---- Scenario 2
  bool tubesPlaced = false;
  double tubesT0 = 0;
  final List<bool> rice = [false, false];
  final List<double> riceT0 = [0, 0];
  final List<bool> water = [false, false];
  final List<double> waterT0 = [0, 0];
  final List<bool> iodine = [false, false];
  final List<double> iodineT0 = [0, 0];
  int magnifier = -1;
  double magT0 = 0;
  final List<Offset> magHexes = [];

  /// Tray item being dragged and the target under the pointer
  /// (0 = tube A, 1 = tube B, 2 = rack area).
  String? dragTool;
  int? hover;

  /// When each tray item was enabled (bounce animation).
  final Map<String, double> enabledT0 = {};

  // ---- Shared
  final List<List<_Grain>> grains = [const [], const []];
  final List<_Mote> bubbles = [];
  final List<_Mote> crumbs = [];
  final List<Offset> chapatiSpots = [];
  final List<_Confetti> confetti = [];
  double confettiT0 = -1;

  /// HTML `initScenario3D()` + `resetS1UI()` / `resetS2UI()`.
  void build(int sc) {
    scenario = sc;
    step = 0;
    done = false;
    fed = false;
    chapati = _plateCenter;
    draggingChapati = false;
    overMouth = false;
    progress = 0;
    chewing = false;
    chewDone = false;
    tubesPlaced = false;
    for (var i = 0; i < 2; i++) {
      rice[i] = false;
      water[i] = false;
      iodine[i] = false;
    }
    magnifier = -1;
    dragTool = null;
    hover = null;
    enabledT0.clear();
    confetti.clear();
    confettiT0 = -1;
    magHexes
      ..clear()
      ..addAll(List.generate(8, (_) => Offset(20 + _rnd.nextDouble() * 60, 20 + _rnd.nextDouble() * 60)));
  }

  /// Fills a confetti burst (120 pieces, spread 100°).
  void startConfetti() {
    const colors = [_Colors.emerald500, _Colors.blue, Color(0xFFF59E0B), Colors.white];
    confetti.clear();
    for (var i = 0; i < 120; i++) {
      final a = -math.pi / 2 + (_rnd.nextDouble() * 2 - 1) * math.pi * 100 / 360;
      final v = 420 + _rnd.nextDouble() * 520;
      confetti.add(_Confetti(
        Offset(math.cos(a) * v, math.sin(a) * v),
        colors[i % colors.length],
        5 + _rnd.nextDouble() * 5,
        (_rnd.nextDouble() * 2 - 1) * 9,
        4 + _rnd.nextDouble() * 8,
        _rnd.nextDouble() * math.pi,
      ));
    }
    confettiT0 = time;
  }

  /// Liquid level (0..1) in tube [i] while the beaker pours.
  double fill(int i) => water[i] ? Curves.easeOutQuad.transform(_clamp01((time - waterT0[i] - 0.25) / 1.0)) : 0;

  /// Iodine colour change (0..1) in tube [i].
  double stain(int i) => iodine[i] ? _clamp01((time - iodineT0[i] - 0.45) / 1.5) : 0;
}

class _Ch9A2InvestigatingSalivasActionOnStarchPageState
    extends State<Ch9A2InvestigatingSalivasActionOnStarchPage> with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final GlobalKey _stageKey = GlobalKey();

  late final Ticker _ticker;
  Duration _last = Duration.zero;

  int get _scenario => _scene.scenario;
  int get _step => _scene.step;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_scenario];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _scene.build(0);
    _ticker = createTicker((elapsed) {
      final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.1);
      _last = elapsed;
      _scene.time = elapsed.inMicroseconds / 1e6;
      _tick(dt);
      _frame.value = _scene.time;
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

  /// Per-frame updates: chewing progress (HTML `setInterval`) and the
  /// chapati sliding back to its plate after a missed drop.
  void _tick(double dt) {
    final s = _scene;
    if (s.chewing) {
      s.progress = math.min(100.0, s.progress + _chewRate * dt);
      if (s.progress >= 100) _stopChewing();
    }
    if (!s.draggingChapati && !s.fed && s.chapati != _plateCenter) {
      final next = Offset.lerp(s.chapati, _plateCenter, math.min(1.0, dt * 12))!;
      s.chapati = (next - _plateCenter).distance < 0.5 ? _plateCenter : next;
    }
  }

  /// HTML `changeScenario()` / `resetScenarioState()`.
  void _rebuild(int scenario) {
    _lab.cancelPending();
    _scene.build(scenario);
  }

  void _changeScenario(int index) {
    setState(() {
      _lab.hidePopup(sound: false);
      _rebuild(index);
    });
    _lab.resetView(sound: false);
  }

  void _fullReset() => setState(() => _rebuild(0));

  /// HTML `startActivityFromBoard()`: hides the board, shows the chewing UI
  /// or the test-tube tray and moves to step 1.
  void _setup() {
    if (_step != 0) return;
    setState(() {
      _scene.step = 1;
      if (_scenario == 1) _scene.enabledT0['tubes'] = _scene.time;
    });
  }

  /// HTML `triggerConclusionState()`: last step, confetti, then the
  /// summary popup 2.5 s later.
  void _triggerConclusion() {
    if (!mounted || _scene.done) return;
    final sc = _scenario;
    setState(() {
      _scene
        ..step += 1
        ..done = true
        ..startConfetti();
    });
    _Audio.play(_Sound.magic);
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: 2,
      title: () => labFormat(_t('sc_complete'), {'n': sc + 1}),
      heading: () => '${_t('observation_title')}: ${_t('sum_head_${sc + 1}')}',
      body: () => _t('sum_body_${sc + 1}'),
      extra: () => _ConclusionExtra(scenario: sc, isDark: _lab.isDark, tr: _t),
      delay: const Duration(milliseconds: 2500),
    );
  }

  // ---- Scenario 1 -------------------------------------------------

  void _onPanStart(DragStartDetails d) {
    final s = _scene;
    if (!_lab.isLabActive || _scenario != 0 || _step != 1 || s.fed) return;
    if ((d.localPosition - s.chapati).distance > _chapatiR + 18) return;
    _Audio.play(_Sound.pickup);
    setState(() => s.draggingChapati = true);
  }

  void _onPanUpdate(DragUpdateDetails d) {
    final s = _scene;
    if (!s.draggingChapati) return;
    final p = d.localPosition;
    s
      ..chapati = Offset(p.dx.clamp(0.0, _design.width), p.dy.clamp(0.0, _design.height))
      ..overMouth = (s.chapati - _mouthCenter).distance < _mouthR;
  }

  void _onPanEnd() {
    final s = _scene;
    if (!s.draggingChapati) return;
    final inMouth = s.overMouth;
    setState(() {
      s
        ..draggingChapati = false
        ..overMouth = false;
    });
    if (inMouth) _feedChapati();
  }

  void _onStageTap(Offset pos) {
    final s = _scene;
    if (!_lab.isLabActive || _scenario != 0 || _step != 1 || s.fed) return;
    if ((pos - s.chapati).distance <= _chapatiR + 18) {
      _lab.showToast(_t('drag_chapati'), sound: false);
    }
  }

  /// HTML `applyS1Action()`: the chapati is swallowed and the camera zooms
  /// into the microscopic view.
  void _feedChapati() {
    _Audio.play(_Sound.pop);
    setState(() {
      _scene
        ..fed = true
        ..fedT0 = _scene.time
        ..chapati = _mouthCenter
        ..step = 2;
    });
  }

  /// HTML `startChewing()` (pointer down on "Hold to Chew").
  void _startChewing() {
    final s = _scene;
    if (_scenario != 0 || _step < 2 || _step > 3 || s.chewDone || s.chewing) return;
    _Audio.play(_Sound.pop);
    setState(() {
      s.chewing = true;
      if (s.step == 2) s.step = 3;
    });
  }

  /// HTML `stopChewing()` (pointer up / leave, or progress reached 100 %).
  void _stopChewing() {
    final s = _scene;
    if (!s.chewing) return;
    setState(() => s.chewing = false);
    if (s.progress >= 100 && s.step == 3) {
      setState(() => s.chewDone = true);
      _triggerConclusion();
    }
  }

  // ---- Scenario 2 -------------------------------------------------

  /// Which tray items can be used now (the HTML greys out the others).
  bool _toolEnabled(String id) {
    if (_scenario != 1) return false;
    return switch (id) {
      'tubes' => _step == 1 && !_scene.tubesPlaced,
      'rice' => _step == 2,
      'chewed' => _step == 3,
      'water' => _step == 4,
      'iodine' => _step == 5 || _step == 6,
      _ => false,
    };
  }

  /// HTML `startUiDrag()` guard messages, shown when a greyed-out item is
  /// touched.
  void _blockedTool() {
    final key = switch (_step) {
      1 => 'msg_place_tubes',
      2 => 'msg_add_rice',
      3 => 'msg_add_chewed',
      4 => 'msg_add_water',
      5 => 'msg_iodine_a',
      6 => 'msg_iodine_b',
      _ => null,
    };
    if (key != null) _lab.showToast(_t(key), isError: true);
  }

  /// The drop target under design point [p] for [tool]: 0 / 1 = tube A / B,
  /// 2 = the rack area (tubes only).
  int? _targetAt(String tool, Offset p) {
    if (tool == 'tubes') return _rackZone.contains(p) ? 2 : null;
    for (var i = 0; i < 2; i++) {
      if (Rect.fromLTRB(_tubeX[i] - 64, 100, _tubeX[i] + 64, 440).contains(p)) return i;
    }
    return null;
  }

  void _onToolDragStart(String id) {
    _Audio.play(_Sound.pickup);
    setState(() {
      _scene
        ..dragTool = id
        ..hover = null;
    });
  }

  void _onToolDragUpdate(Offset global) {
    final tool = _scene.dragTool;
    if (tool == null) return;
    final local = labGlobalToLocal(_stageKey, global);
    final hover = local == null ? null : _targetAt(tool, local);
    if (hover != _scene.hover) setState(() => _scene.hover = hover);
  }

  void _onToolDragEnd() {
    if (!mounted) return;
    setState(() {
      _scene
        ..dragTool = null
        ..hover = null;
    });
  }

  /// HTML drop handler: a tray item released over the scene.
  void _onToolDrop(String tool, Offset global) {
    final local = labGlobalToLocal(_stageKey, global);
    if (local == null) return;
    final target = _targetAt(tool, local);
    if (target != null) _applyTool(tool, target);
  }

  /// Tapping an enabled tray item uses it on its expected target (a
  /// shortcut for small screens; dragging works exactly like the HTML).
  void _tapTool(String tool) {
    final target = switch (tool) {
      'tubes' => 2,
      'rice' => 0,
      'chewed' => 1,
      'water' => _scene.water[0] ? 1 : 0,
      _ => _step == 5 ? 0 : 1,
    };
    _applyTool(tool, target);
  }

  /// HTML `applyS2Tool(target)`.
  void _applyTool(String tool, int target) {
    final s = _scene;
    final now = s.time;
    if (tool == 'tubes' && target == 2 && _step == 1) {
      _Audio.play(_Sound.pop);
      setState(() {
        s
          ..tubesPlaced = true
          ..tubesT0 = now
          ..step = 2;
        s.enabledT0['rice'] = now;
      });
    } else if (tool == 'rice' && target == 0 && _step == 2) {
      _Audio.play(_Sound.pop);
      setState(() {
        s.rice[0] = true;
        s.riceT0[0] = now;
        s.step = 3;
        s.enabledT0['chewed'] = now;
      });
    } else if (tool == 'chewed' && target == 1 && _step == 3) {
      _Audio.play(_Sound.pop);
      setState(() {
        s.rice[1] = true;
        s.riceT0[1] = now;
        s.step = 4;
        s.enabledT0['water'] = now;
      });
    } else if (tool == 'water' && _step == 4 && target < 2) {
      if (s.water[target]) return;
      _Audio.play(_Sound.pop);
      _lab.after(const Duration(milliseconds: 250), () => _Audio.play(_Sound.splash));
      setState(() {
        s.water[target] = true;
        s.waterT0[target] = now;
        if (s.water[0] && s.water[1]) {
          s.step = 5;
          s.enabledT0['iodine'] = now;
        }
      });
    } else if (tool == 'iodine' && target < 2 && (_step == 5 || _step == 6)) {
      final expected = _step == 5 ? 0 : 1;
      if (target != expected) {
        _lab.showToast(_t(expected == 0 ? 'msg_iodine_a' : 'msg_iodine_b'), isError: true);
        return;
      }
      _Audio.play(_Sound.pop);
      for (final ms in const [250, 550, 850]) {
        _lab.after(Duration(milliseconds: ms + 200), () => _Audio.play(_Sound.drop));
      }
      setState(() {
        s.iodine[target] = true;
        s.iodineT0[target] = now;
        s.magnifier = target;
        s.magT0 = now;
        s.step += 1;
      });
      // Step 7 ("compare the colours"), then the conclusion 4 s later.
      if (target == 1) _lab.after(const Duration(seconds: 4), _triggerConclusion);
    } else {
      _lab.showToast(_t('msg_invalid'), isError: true);
    }
  }

  // ---- Actions -----------------------------------------------------

  LabAction get _setupAction => LabAction(
        label: _t('btn_setup'),
        icon: Icons.play_circle_fill_rounded,
        color: _Colors.emerald600,
        foreground: Colors.white,
        highlight: true,
        onTap: _setup,
      );

  List<LabAction> _actions() => _step == 0 ? [_setupAction] : const [];

  // --------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final p = _Theme.of(_lab.isDark);
        final s = context.labScale;
        final data = _data;
        final inset = labOverlayInsets(context, _lab);
        final sc = _scenario;
        return LabShell(
          controller: _lab,
          icon: Icons.science,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: sc,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: math.max(1, _step),
          instruction: _step == 0 ? _t('board_desc_${sc + 1}') : (_step > data.steps.length ? '' : null),
          showHud: _step > 0,
          actions: _actions(),
          onEnterLab: () => _lab.showToast(_t('welcome_lab'), sound: false),
          onReset: _fullReset,
          overlays: [
            Positioned.fill(child: _dropTarget()),
            if (sc == 0 && _scene.fed) _chewControls(p, s, inset),
            if (sc == 1 && _step >= 1) _tray(p, s, inset),
            if (_step == 0) Positioned.fill(child: _board(s)),
          ],
          stage: LabStage(
            designSize: _design,
            child: GestureDetector(
              key: _stageKey,
              behavior: HitTestBehavior.opaque,
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: (_) => _onPanEnd(),
              onPanCancel: _onPanEnd,
              onTapUp: (d) => _onStageTap(d.localPosition),
              child: CustomPaint(
                size: _design,
                painter: sc == 0
                    ? _MicroPainter(
                        scene: _scene,
                        repaint: _frame,
                        isDark: _lab.isDark,
                        showLabels: _lab.showLabels,
                        tr: _t,
                      )
                    : _BenchPainter(
                        scene: _scene,
                        repaint: _frame,
                        isDark: _lab.isDark,
                        showLabels: _lab.showLabels,
                        tr: _t,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// The whole canvas accepts a tray item; the drop point is converted to
  /// scene coordinates and matched against the tubes / rack area.
  Widget _dropTarget() {
    return DragTarget<String>(
      onAcceptWithDetails: (d) => _onToolDrop(d.data, d.offset),
      builder: (context, candidates, rejected) => const IgnorePointer(child: SizedBox.expand()),
    );
  }

  /// HTML `#ui-setup-board`: objective, description and "Setup Activity".
  Widget _board(double s) {
    final sc = _scenario;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(440 * s, math.max(200.0, constraints.maxWidth - 90));
        return ColoredBox(
          color: _lab.isDark ? const Color(0xB3000000) : const Color(0x990F172A),
          child: Padding(
            padding: EdgeInsets.fromLTRB(14, 14, 62, 14 + MediaQuery.paddingOf(context).bottom),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: width,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(18 * s, 16 * s, 18 * s, 18 * s),
                    decoration: BoxDecoration(
                      color: _Colors.slate800,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: _Colors.emerald500.withValues(alpha: 0.5), width: 3),
                      boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 30, offset: Offset(0, 10))],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 54 * s,
                          height: 54 * s,
                          child: CustomPaint(
                            painter: sc == 0
                                ? const _ToothIconPainter(color: _Colors.emerald400)
                                : const _ToolIconPainter('tubes', isDark: true),
                          ),
                        ),
                        SizedBox(height: 10 * s),
                        Text(
                          _data.objective,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15 * s,
                            fontWeight: FontWeight.w800,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 8 * s),
                        Text(
                          _t('board_desc_${sc + 1}'),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _Colors.emerald200, fontSize: 12.5 * s, height: 1.4),
                        ),
                        SizedBox(height: 16 * s),
                        LabActionButton(action: _setupAction, scale: s, expand: false),
                      ],
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

  /// HTML `#s1-3d-ui`: the sweetness meter and the "Hold to Chew" button.
  Widget _chewControls(LabPalette p, double s, EdgeInsets inset) {
    final s1 = _scene;
    final pressed = s1.chewing;
    final meter = ValueListenableBuilder<double>(
      valueListenable: _frame,
      builder: (context, _, _) {
        final v = s1.progress / 100;
        return Container(
          width: 26 * s,
          height: 120 * s,
          padding: EdgeInsets.all(3 * s),
          decoration: BoxDecoration(
            color: _Colors.slate800.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: _Colors.slate600.withValues(alpha: 0.6), width: 2),
          ),
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: v.clamp(0.0, 1.0),
            widthFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [_Colors.pink600, _Colors.pink400],
                ),
                boxShadow: [
                  BoxShadow(color: _Colors.pink.withValues(alpha: 0.8), blurRadius: 12 * s),
                ],
              ),
            ),
          ),
        );
      },
    );

    final button = GestureDetector(
      // Keeps a press-and-hold from dragging the card around.
      onPanUpdate: (_) {},
      child: Listener(
        onPointerDown: (_) => _startChewing(),
        onPointerUp: (_) => _stopChewing(),
        onPointerCancel: (_) => _stopChewing(),
        child: AnimatedScale(
          scale: pressed ? 0.95 : 1,
          duration: const Duration(milliseconds: 120),
          child: Container(
            width: 104 * s,
            padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 10 * s),
            decoration: BoxDecoration(
              color: pressed ? _Colors.orange500 : _Colors.emerald600,
              borderRadius: BorderRadius.circular(26 * s),
              border: Border.all(
                color: (pressed ? _Colors.orange400 : _Colors.emerald400).withValues(alpha: 0.5),
                width: 4 * s,
              ),
              boxShadow: [
                BoxShadow(
                  color: (pressed ? _Colors.orange500 : _Colors.emerald500).withValues(alpha: 0.5),
                  blurRadius: 22 * s,
                  offset: Offset(0, 8 * s),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueListenableBuilder<double>(
                  valueListenable: _frame,
                  builder: (context, t, child) => Transform.translate(
                    offset: Offset(0, -(math.sin(t * math.pi * 2)).abs() * 5 * s),
                    child: child,
                  ),
                  child: SizedBox(
                    width: 28 * s,
                    height: 28 * s,
                    child: const CustomPaint(painter: _ToothIconPainter(color: Colors.white)),
                  ),
                ),
                SizedBox(height: 6 * s),
                Text(
                  _t('btn_chew'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12.5 * s,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Positioned(
      top: inset.top,
      bottom: inset.bottom,
      right: inset.right + 8,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LabGlassCard(
                palette: p,
                padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 10 * s),
                radius: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    meter,
                    SizedBox(height: 6 * s),
                    SizedBox(
                      width: 20 * s,
                      height: 20 * s,
                      child: const CustomPaint(painter: _CubeIconPainter()),
                    ),
                    SizedBox(height: 4 * s),
                    Text(
                      _t('lbl_sweetness').toUpperCase(),
                      style: TextStyle(
                        color: _Colors.pink400,
                        fontSize: 9 * s,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              if (!s1.chewDone) ...[SizedBox(height: 14 * s), button],
            ],
          ),
        ),
      ),
    );
  }

  /// HTML `#ui-s2-tray`: Tubes, Boiled Rice, Chewed Rice, Water, Iodine.
  Widget _tray(LabPalette p, double s, EdgeInsets inset) {
    final isDark = _lab.isDark;
    Widget box(String id, double size, {bool lifted = false}) => Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(size * 0.12),
          decoration: BoxDecoration(
            color: isDark ? _Colors.slate800 : Colors.white,
            borderRadius: BorderRadius.circular(size * 0.25),
            border: Border.all(
              color: lifted ? _Colors.emerald500 : (isDark ? _Colors.slate700 : _Colors.slate200),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: lifted ? 0.35 : 0.12),
                blurRadius: lifted ? 18 : 5,
                offset: Offset(0, lifted ? 10 : 3),
              ),
            ],
          ),
          child: CustomPaint(painter: _ToolIconPainter(id, isDark: isDark)),
        );

    Widget item(String id) {
      final enabled = _toolEnabled(id);
      final body = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<double>(
            valueListenable: _frame,
            builder: (context, t, child) {
              final t0 = _scene.enabledT0[id];
              final age = t0 == null ? 9.0 : t - t0;
              final dy = enabled && age < 1 ? -(math.sin(age * math.pi * 3)).abs() * 7 * s : 0.0;
              return Transform.translate(offset: Offset(0, dy), child: child);
            },
            child: box(id, 44 * s),
          ),
          SizedBox(height: 3 * s),
          SizedBox(
            width: 64 * s,
            child: Text(
              _t('lbl_$id').toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? _Colors.slate400 : _Colors.slate500,
                fontSize: 8.5 * s,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                height: 1.15,
              ),
            ),
          ),
        ],
      );
      return Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Tooltip(
          message: _t('tip_$id'),
          child: Draggable<String>(
            data: id,
            maxSimultaneousDrags: enabled ? 1 : 0,
            dragAnchorStrategy: pointerDragAnchorStrategy,
            feedback: Transform.translate(
              offset: Offset(-28 * s, -28 * s),
              child: Opacity(opacity: 0.92, child: box(id, 56 * s, lifted: true)),
            ),
            childWhenDragging: Opacity(opacity: 0.35, child: body),
            onDragStarted: () => _onToolDragStart(id),
            onDragUpdate: (d) => _onToolDragUpdate(d.globalPosition),
            onDragEnd: (_) => _onToolDragEnd(),
            child: GestureDetector(
              onTap: () => enabled ? _tapTool(id) : _blockedTool(),
              child: body,
            ),
          ),
        ),
      );
    }

    final ids = _toolIds.where((id) => id != 'tubes' || !_scene.tubesPlaced).toList();
    return Positioned(
      top: inset.top + 4,
      right: inset.right + 6,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(gestureSettings: const DeviceGestureSettings(touchSlop: 8)),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 9 * s),
          decoration: BoxDecoration(
            color: (isDark ? _Colors.slate900 : Colors.white).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20 * s),
            border: Border.all(color: isDark ? _Colors.slate700 : _Colors.slate200),
            boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 24, offset: Offset(0, 8))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < ids.length; i++) ...[
                if (i > 0) SizedBox(height: 7 * s),
                item(ids[i]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Extra content of the conclusion popup: starch → sugar (scenario 1) or
/// the two final test-tube colours (scenario 2).
class _ConclusionExtra extends StatelessWidget {
  const _ConclusionExtra({required this.scenario, required this.isDark, required this.tr});

  final int scenario;
  final bool isDark;
  final String Function(String) tr;

  @override
  Widget build(BuildContext context) {
    final p = _Theme.of(isDark);
    final s = context.labScale;
    Widget caption(String text, Color color) => Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: color, fontSize: 11.5 * s, fontWeight: FontWeight.w800, height: 1.3),
        );
    Widget column(Widget art, String text, Color color) => Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [art, SizedBox(height: 6 * s), caption(text, color)],
          ),
        );

    final Widget content;
    if (scenario == 0) {
      content = Row(
        children: [
          column(
            SizedBox(width: 96 * s, height: 40 * s, child: const CustomPaint(painter: _MiniMoleculePainter(sugar: false))),
            tr('not_sweet'),
            isDark ? _Colors.blue300 : _Colors.blue,
          ),
          Icon(Icons.arrow_forward_rounded, color: p.accent, size: 22 * s),
          column(
            SizedBox(width: 96 * s, height: 40 * s, child: const CustomPaint(painter: _MiniMoleculePainter(sugar: true))),
            tr('sweet'),
            isDark ? _Colors.pink400 : _Colors.pink600,
          ),
        ],
      );
    } else {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              column(
                SizedBox(width: 30 * s, height: 74 * s, child: CustomPaint(painter: _MiniTubePainter(0, isDark: isDark))),
                tr('res_a'),
                isDark ? _Colors.blue300 : _Colors.blue900,
              ),
              column(
                SizedBox(width: 30 * s, height: 74 * s, child: CustomPaint(painter: _MiniTubePainter(1, isDark: isDark))),
                tr('res_b'),
                isDark ? const Color(0xFFFBBF24) : _Colors.amber700,
              ),
            ],
          ),
          SizedBox(height: 8 * s),
          Text(
            tr('s2_summary_msg'),
            textAlign: TextAlign.center,
            style: TextStyle(color: p.textMuted, fontSize: 11 * s, fontWeight: FontWeight.w600, height: 1.35),
          ),
        ],
      );
    }
    return Container(
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.cardBorder),
      ),
      child: content,
    );
  }
}

// ============================================================ PAINTING

/// Confetti burst from the centre of the scene (HTML `confetti()`).
void _paintConfetti(Canvas canvas, _Scene s) {
  if (s.confettiT0 < 0) return;
  final dt = s.time - s.confettiT0;
  if (dt > 3.4 || dt < 0) return;
  const drag = 1.7;
  const gravity = 380.0;
  final f = (1 - math.exp(-drag * dt)) / drag;
  final alpha = 1 - _clamp01((dt - 2.4) / 1.0);
  for (final c in s.confetti) {
    final pos = Offset(500 + c.v.dx * f, 280 + c.v.dy * f + 0.5 * gravity * dt * dt);
    canvas
      ..save()
      ..translate(pos.dx, pos.dy)
      ..rotate(c.phase + c.spin * dt)
      ..scale(1, math.cos(c.phase + c.flip * dt));
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: c.size, height: c.size * 0.6),
      Paint()..color = c.color.withValues(alpha: alpha),
    );
    canvas.restore();
  }
}

/// Scenario 1: the microscopic view inside the mouth (HTML `buildS1Scene`):
/// three blue starch chains, three yellow amylase "Pac-Men" and the pink
/// sugar hexagons they produce, plus the mouth target and the chapati.
class _MicroPainter extends CustomPainter {
  _MicroPainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.tr,
  }) : super(repaint: repaint);

  final _Scene scene;
  final bool isDark;
  final bool showLabels;
  final String Function(String) tr;

  @override
  void paint(Canvas canvas, Size size) {
    final s = scene;
    final t = s.time;
    final zoom = s.fed ? _ease((t - s.fedT0) / 1.5) : 0.0;
    final k = 28 + (46 - 28) * zoom; // px per Three.js unit (camera z 20 -> 12)

    _background(canvas, size, t);
    if (s.fed) _crumbs(canvas, t, zoom);
    _molecules(canvas, k, t);
    if (s.fed) {
      _vignette(canvas, size);
      _teeth(canvas, size, t);
    }
    if (s.scenario == 0 && s.step == 1 && !s.fed) {
      _mouthTarget(canvas, t);
      _plate(canvas);
      if (!s.draggingChapati) _dragHint(canvas, t);
      _chapati(canvas, s.chapati, s.draggingChapati ? 1.1 : 1.0);
      labPill(
        canvas,
        tr('lbl_chapati').toUpperCase(),
        _plateCenter + const Offset(0, 84),
        size: 13,
        background: isDark ? const Color(0xCC1E293B) : const Color(0xE6FFFFFF),
        color: isDark ? _Colors.slate300 : _Colors.slate600,
        border: isDark ? _Colors.slate700 : _Colors.slate200,
      );
    }
    if (showLabels && s.fed) _labels(canvas, k);
    _paintConfetti(canvas, s);
  }

  void _background(Canvas canvas, Size size, double t) {
    final bleed = labBleed(size);
    canvas.drawRect(
      bleed,
      Paint()
        ..shader = RadialGradient(
          colors: isDark
              ? const [Color(0xFF1E293B), _Colors.slate900, _Colors.slate950]
              : const [Colors.white, Color(0xFFEFF3F8), _Colors.slate300],
          stops: const [0, 0.55, 1],
        ).createShader(Rect.fromCircle(center: _microCenter, radius: 720)),
    );
    // Saliva bubbles drifting upwards.
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final b in scene.bubbles) {
      final y = (b.pos.dy - t * b.speed) % 680 - 60;
      final x = b.pos.dx + math.sin(t * 0.6 + b.phase) * 12;
      final c = Offset(x, y);
      ring.color = (isDark ? Colors.white : _Colors.slate500).withValues(alpha: isDark ? 0.12 : 0.22);
      canvas.drawCircle(c, b.r, ring);
      canvas.drawCircle(
        c + Offset(-b.r * 0.35, -b.r * 0.35),
        b.r * 0.22,
        Paint()..color = Colors.white.withValues(alpha: isDark ? 0.18 : 0.6),
      );
    }
  }

  /// Chapati crumbs floating around after the drop; chewing shrinks them.
  void _crumbs(Canvas canvas, double t, double zoom) {
    final shrink = 1 - 0.8 * scene.progress / 100;
    for (final c in scene.crumbs) {
      final center = c.pos + Offset(math.sin(t * c.speed + c.phase) * 14, math.cos(t * c.speed * 0.8 + c.phase) * 10);
      final r = c.r * shrink * (0.6 + 0.4 * zoom);
      final path = Path();
      for (var i = 0; i < c.shape.length; i++) {
        final a = i / c.shape.length * math.pi * 2 + c.phase + t * 0.1;
        final p = center + Offset(math.cos(a), math.sin(a)) * r * c.shape[i];
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      path.close();
      canvas.drawPath(path, Paint()..color = const Color(0xFFD9A35B).withValues(alpha: 0.55 * zoom));
      canvas.drawCircle(center, r * 0.25, Paint()..color = const Color(0xFF8B5A2B).withValues(alpha: 0.4 * zoom));
    }
  }

  /// Starch chains, amylase enzymes and sugar hexagons for the current
  /// chewing progress (HTML `updateS1Animation(p)`).
  void _molecules(Canvas canvas, double k, double t) {
    final p = scene.progress;
    const c = _microCenter;
    for (var i = 0; i < 3; i++) {
      final rowY = c.dy - (i - 1) * 3.5 * k + math.sin(t * 0.9 + i * 1.7) * 3;
      double x1 = -2.5, x3 = 2.5, y2 = 0;
      var sphereScale = 1.0, hexScale = 0.0, spin = 0.0, enzX = -7.0;
      if (p < 30) {
        enzX = -7 + 5.75 * p / 30;
      } else if (p < 45) {
        final sub = (p - 30) / 15;
        enzX = -1.25 + 2.5 * sub;
        x1 = -2.5 - sub * 0.5;
      } else if (p < 80) {
        final conv = (p - 45) / 35;
        enzX = 1.25 + 2 * conv;
        sphereScale = 1 - conv;
        hexScale = conv;
        spin = conv * math.pi;
        x1 = -3 - conv;
        y2 = conv * 0.5;
        x3 = 2.5 + conv;
      } else {
        enzX = 3.25;
        sphereScale = 0;
        hexScale = 1;
        spin = math.pi + t * 0.8;
        x1 = -4;
        y2 = 0.5;
        x3 = 3.5;
      }
      final idle = p >= 80 ? 1.0 : 0.0;
      final pos = [
        Offset(c.dx + x1 * k, rowY + math.sin(t * 1.3 + i) * 0.15 * k * idle),
        Offset(c.dx, rowY - y2 * k + math.cos(t * 1.3 + i) * 0.15 * k * idle),
        Offset(c.dx + x3 * k, rowY + math.sin(t * 1.04 + i) * 0.15 * k * idle),
      ];

      // Bonds (hidden as the enzyme cuts them).
      if (p < 30) _bond(canvas, Offset(c.dx - 1.25 * k, rowY), k);
      if (p < 45) _bond(canvas, Offset(c.dx + 1.25 * k, rowY), k);
      // Glucose units of the starch chain.
      if (sphereScale > 0.01) {
        for (final q in pos) {
          _starch(canvas, q, 1.12 * k * sphereScale);
        }
      }
      // Sugar molecules.
      if (hexScale > 0.01) {
        for (var j = 0; j < 3; j++) {
          _hexagon(canvas, pos[j], 1.0 * k * hexScale, j == 1 ? 0 : spin * (j == 0 ? 1 : -1), j == 1 ? spin : 0);
        }
      }
      // Amylase enzyme.
      final enzAlpha = 1 - _clamp01((p - 74) / 6);
      if (enzAlpha > 0) {
        final chomp = scene.chewing
            ? 0.08 + 0.42 * (math.sin(t * 9 + i)).abs()
            : 0.34 + 0.05 * math.sin(t * 2 + i);
        _enzyme(canvas, Offset(c.dx + enzX * k, rowY), 1.4 * k, chomp, enzAlpha);
      }
    }
  }

  void _bond(Canvas canvas, Offset center, double k) {
    final r = Rect.fromCenter(center: center, width: 1.5 * k, height: 0.5 * k);
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, Radius.circular(r.height / 2)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, _Colors.slate300, _Colors.slate500],
        ).createShader(r),
    );
  }

  /// Glassy blue sphere (MeshPhysicalMaterial with transmission).
  void _starch(Canvas canvas, Offset c, double r) {
    labSphere(canvas, c, r, _Colors.blue, opacity: 0.86, highlight: 0.5, shade: 0.5);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = _Colors.blue300.withValues(alpha: 0.6),
    );
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(-r * 0.32, -r * 0.42), width: r * 0.62, height: r * 0.34),
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );
  }

  /// Pink hexagonal prism (CylinderGeometry with 6 segments).
  /// [squash] spins it about the vertical axis, [roll] in the image plane.
  void _hexagon(Canvas canvas, Offset c, double r, double squash, double roll) {
    final fx = 0.3 + 0.7 * math.cos(squash).abs();
    Path hex(Offset o) {
      final path = Path();
      for (var i = 0; i < 6; i++) {
        final a = roll + math.pi / 6 + i * math.pi / 3;
        final p = o + Offset(math.cos(a) * r * fx, math.sin(a) * r);
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      return path..close();
    }

    labGlow(canvas, c, r * 1.6, _Colors.pink, intensity: 0.25);
    final depth = Offset(r * 0.14, r * 0.14);
    canvas.drawPath(hex(c + depth), Paint()..color = const Color(0xFF9D174D));
    final front = hex(c);
    canvas.drawPath(
      front,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFBCFE8), _Colors.pink, Color(0xFFBE185D)],
          stops: [0, 0.45, 1],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.drawPath(
      front,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFFFCE7F3).withValues(alpha: 0.7),
    );
  }

  /// Yellow "Pac-Man" enzyme (a sphere with a missing wedge) facing the
  /// starch chain; [mouth] is the half-angle of its open mouth.
  void _enzyme(Canvas canvas, Offset c, double r, double mouth, double alpha) {
    final rect = Rect.fromCircle(center: c, radius: r);
    if (scene.chewing) labGlow(canvas, c, r * 1.7, _Colors.yellow, intensity: 0.35 * alpha);
    final body = Path()
      ..moveTo(c.dx, c.dy)
      ..arcTo(rect, mouth, math.pi * 2 - mouth * 2, false)
      ..close();
    canvas.drawPath(
      body,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.45),
          radius: 1.05,
          colors: [
            const Color(0xFFFEF08A).withValues(alpha: alpha),
            _Colors.yellow.withValues(alpha: alpha),
            const Color(0xFF854D0E).withValues(alpha: alpha),
          ],
          stops: const [0, 0.5, 1],
        ).createShader(rect),
    );
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF713F12).withValues(alpha: 0.5 * alpha),
    );
    // Clear-coat highlight and the eye.
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(-r * 0.38, -r * 0.48), width: r * 0.5, height: r * 0.26),
      Paint()..color = Colors.white.withValues(alpha: 0.55 * alpha),
    );
    final eye = c + Offset(r * 0.12, -r * 0.52);
    canvas.drawCircle(eye, r * 0.13, Paint()..color = Colors.black.withValues(alpha: alpha));
    canvas.drawCircle(eye + Offset(-r * 0.04, -r * 0.04), r * 0.04, Paint()..color = Colors.white.withValues(alpha: alpha));
  }

  void _vignette(Canvas canvas, Size size) {
    final zoom = _ease((scene.time - scene.fedT0) / 1.5);
    canvas.drawRect(
      labBleed(size),
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.transparent,
            (isDark ? Colors.black : const Color(0xFF831843)).withValues(alpha: (isDark ? 0.45 : 0.16) * zoom),
          ],
          stops: const [0.55, 1],
        ).createShader(Rect.fromCircle(center: _microCenter, radius: 600)),
    );
  }

  /// Gums and teeth framing the inside view; they chomp while chewing.
  void _teeth(Canvas canvas, Size size, double t) {
    final bleed = labBleed(size);
    final zoom = _ease((scene.time - scene.fedT0) / 1.5);
    final chomp = scene.chewing ? 14 * (0.5 - 0.5 * math.cos(t * 13)) : 0.0;
    final shift = (1 - zoom) * 70; // teeth slide in with the zoom
    final gum = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFBE185D), Color(0xFFF472B6)],
      ).createShader(const Rect.fromLTWH(0, -40, 1000, 70));
    final gumLow = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF472B6), Color(0xFFBE185D)],
      ).createShader(const Rect.fromLTWH(0, 530, 1000, 70));
    final top = 22 + chomp - shift;
    final low = 538 - chomp + shift;
    canvas.drawRect(Rect.fromLTRB(bleed.left, bleed.top, bleed.right, top), gum);
    canvas.drawRect(Rect.fromLTRB(bleed.left, low, bleed.right, bleed.bottom), gumLow);
    final toothFill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFFBEB), Color(0xFFF5F5F4), Color(0xFFE7E5E4)],
      ).createShader(Rect.fromLTRB(0, top - 4, 1000, top + 36));
    final toothLine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFFA8A29E);
    for (var x = -1500.0; x < 2500; x += 58) {
      final up = RRect.fromRectAndCorners(
        Rect.fromLTWH(x + 4, top - 4, 50, 36),
        bottomLeft: const Radius.circular(16),
        bottomRight: const Radius.circular(16),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );
      canvas.drawRRect(up, toothFill);
      canvas.drawRRect(up, toothLine);
      final down = RRect.fromRectAndCorners(
        Rect.fromLTWH(x + 33, low - 32, 50, 36),
        topLeft: const Radius.circular(16),
        topRight: const Radius.circular(16),
        bottomLeft: const Radius.circular(4),
        bottomRight: const Radius.circular(4),
      );
      canvas.drawRRect(down, toothFill);
      canvas.drawRRect(down, toothLine);
    }
  }

  /// HTML `#s1-mouth-target`: dashed "Feed Me" circle.
  void _mouthTarget(Canvas canvas, double t) {
    final hot = scene.overMouth;
    const c = _mouthCenter;
    final r = _mouthR * (hot ? 1.05 : 1.0);
    final green = isDark ? _Colors.emerald400 : _Colors.emerald600;
    if (hot) labGlow(canvas, c, r * 1.35, _Colors.emerald500, intensity: 0.45);
    canvas.drawCircle(c, r, Paint()..color = (isDark ? _Colors.slate900 : Colors.white).withValues(alpha: 0.62));
    canvas.drawCircle(c, r, Paint()..color = _Colors.emerald500.withValues(alpha: hot ? 0.18 : 0.06));
    labDashedPath(
      canvas,
      Path()..addOval(Rect.fromCircle(center: c, radius: r)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = _Colors.emerald500.withValues(alpha: hot ? 1 : 0.6),
      dash: 14,
      gap: 9,
      phase: t * 18,
    );
    // Phosphor "smiley-x-eyes" face.
    final face = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = green.withValues(alpha: 0.85);
    final fc = c + const Offset(0, -16);
    canvas.drawCircle(fc, 38, face);
    for (final ex in const [-14.0, 14.0]) {
      final e = fc + Offset(ex, -9);
      canvas.drawLine(e + const Offset(-6, -6), e + const Offset(6, 6), face..strokeWidth = 4);
      canvas.drawLine(e + const Offset(6, -6), e + const Offset(-6, 6), face);
    }
    final open = 0.7 + 0.3 * math.sin(t * 4).abs();
    canvas.drawOval(
      Rect.fromCenter(center: fc + const Offset(0, 14), width: 18, height: 12 * open),
      face..strokeWidth = 4,
    );
    labText(
      canvas,
      tr('feed_me').toUpperCase(),
      c + const Offset(0, 50),
      size: 16,
      weight: FontWeight.w800,
      color: green,
      letterSpacing: 2,
    );
  }

  void _plate(Canvas canvas) {
    labGroundShadow(canvas, _plateCenter + const Offset(0, 16), 150, 34, opacity: 0.35);
    final rect = Rect.fromCircle(center: _plateCenter, radius: 68);
    canvas.drawCircle(
      _plateCenter,
      68,
      Paint()
        ..shader = const RadialGradient(
          colors: [Colors.white, _Colors.slate100, _Colors.slate300],
          stops: [0, 0.7, 1],
        ).createShader(rect),
    );
    canvas.drawCircle(
      _plateCenter,
      52,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _Colors.slate300,
    );
  }

  void _dragHint(Canvas canvas, double t) {
    final a = 0.35 + 0.45 * (0.5 + 0.5 * math.sin(t * 3));
    labArrow(
      canvas,
      _plateCenter + const Offset(-74, 34),
      _mouthCenter + const Offset(_mouthR + 20, -46),
      color: _Colors.emerald500.withValues(alpha: a),
      width: 3,
      head: 14,
      dashed: true,
    );
  }

  /// Golden-brown chapati with charred spots.
  void _chapati(Canvas canvas, Offset c, double scale) {
    final r = _chapatiR * scale;
    labGroundShadow(canvas, c + Offset(0, r * 0.5), r * 2.1, r * 0.6, opacity: scene.draggingChapati ? 0.45 : 0.3);
    final rect = Rect.fromCircle(center: c, radius: r);
    final edge = Path();
    for (var i = 0; i <= 40; i++) {
      final a = i / 40 * math.pi * 2;
      final rr = r * (1 + 0.035 * math.sin(a * 7) + 0.02 * math.sin(a * 3 + 1));
      final p = c + Offset(math.cos(a), math.sin(a)) * rr;
      i == 0 ? edge.moveTo(p.dx, p.dy) : edge.lineTo(p.dx, p.dy);
    }
    edge.close();
    canvas.drawPath(
      edge,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFF8D79A), Color(0xFFE7B061), Color(0xFFB7782E)],
          stops: [0, 0.7, 1],
        ).createShader(rect),
    );
    for (var i = 0; i < scene.chapatiSpots.length; i++) {
      final spot = c + scene.chapatiSpots[i] * r;
      final big = i.isEven;
      canvas.drawOval(
        Rect.fromCenter(center: spot, width: r * (big ? 0.2 : 0.12), height: r * (big ? 0.14 : 0.09)),
        Paint()
          ..color = const Color(0xFF7C4A1E).withValues(alpha: big ? 0.55 : 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
      );
    }
    canvas.drawPath(
      edge,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF92400E).withValues(alpha: 0.5),
    );
  }

  void _labels(Canvas canvas, double k) {
    final s = scene;
    final zoom = _ease((s.time - s.fedT0) / 1.5);
    if (zoom < 0.6) return;
    final o = (zoom - 0.6) / 0.4;
    final p = s.progress;
    const c = _microCenter;
    labPill(canvas, tr('lbl_inside_view'), const Offset(110, 92), size: 13, opacity: o);
    final gapUp = Offset(c.dx, c.dy - 1.75 * k);
    final starchO = o * (1 - _clamp01((p - 55) / 7));
    if (starchO > 0) {
      labPill(canvas, tr('lbl_starch'), gapUp, size: 12.5, border: _Colors.blue, opacity: starchO);
    }
    final sugarO = o * _clamp01((p - 55) / 7);
    if (sugarO > 0) {
      labPill(canvas, tr('lbl_sugar'), gapUp, size: 12.5, border: _Colors.pink, opacity: sugarO);
    }
    if (p < 76) {
      double enzX;
      if (p < 30) {
        enzX = -7 + 5.75 * p / 30;
      } else if (p < 45) {
        enzX = -1.25 + 2.5 * (p - 30) / 15;
      } else {
        enzX = 1.25 + 2 * (p - 45) / 35;
      }
      labPill(
        canvas,
        tr('lbl_enzyme'),
        Offset(math.max(90.0, c.dx + enzX * k), c.dy + 1.75 * k),
        size: 12.5,
        border: _Colors.yellow,
        opacity: o,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MicroPainter old) =>
      old.isDark != isDark || old.showLabels != showLabels || old.tr != tr;
}

/// Scenario 2: the lab bench, acrylic rack and test tubes A / B (HTML
/// `buildS2Scene`), with the spoon / beaker / dropper animations and the
/// magnifier views.
class _BenchPainter extends CustomPainter {
  _BenchPainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.tr,
  }) : super(repaint: repaint);

  final _Scene scene;
  final bool isDark;
  final bool showLabels;
  final String Function(String) tr;

  Color get _glass => isDark ? const Color(0xFFDBEAFE) : _Colors.slate500;

  @override
  void paint(Canvas canvas, Size size) {
    final s = scene;
    final t = s.time;
    _room(canvas, size);
    _bench(canvas, size);
    if (s.step >= 1) _zoneChips(canvas);
    if (s.step == 1 && !s.tubesPlaced) _rackGhost(canvas, t);
    if (s.tubesPlaced) _rackAndTubes(canvas, t);
    _targets(canvas, t);
    for (var i = 0; i < 2; i++) {
      if (s.rice[i]) _spoon(canvas, i, t);
      if (s.water[i]) _beaker(canvas, i, t);
      if (s.iodine[i]) _dropper(canvas, i, t);
    }
    if (showLabels) _labels(canvas);
    if (s.magnifier >= 0) _magnifier(canvas, s.magnifier, t);
    _paintConfetti(canvas, s);
  }

  void _room(Canvas canvas, Size size) {
    final bleed = labBleed(size);
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, bleed.top, bleed.right, _benchBack + 2),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF0B1224), _Colors.slate900, Color(0xFF16213A)]
              : const [_Colors.slate50, Color(0xFFEEF2F7), _Colors.slate200],
        ).createShader(const Rect.fromLTWH(0, 0, 1000, _benchBack)),
    );
    // Wall panel seams.
    final seam = Paint()
      ..strokeWidth = 1
      ..color = (isDark ? Colors.white : _Colors.slate500).withValues(alpha: isDark ? 0.04 : 0.1);
    for (final y in const [118.0, 236.0]) {
      canvas.drawLine(Offset(bleed.left, y), Offset(bleed.right, y), seam);
    }
    // Blue point light near the tubes.
    if (scene.tubesPlaced) {
      labGlow(canvas, const Offset(_rackX + 12, 250), 260, _Colors.blue, intensity: isDark ? 0.22 : 0.12);
    }
  }

  void _bench(Canvas canvas, Size size) {
    final bleed = labBleed(size);
    final top = Rect.fromLTRB(bleed.left, _benchBack, bleed.right, _benchFront);
    canvas.drawRect(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark ? const [Color(0xFF26334A), _Colors.slate800] : const [_Colors.slate600, _Colors.slate700],
        ).createShader(const Rect.fromLTWH(0, _benchBack, 1000, _benchFront - _benchBack)),
    );
    // Soft reflection on the bench top.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(_rackX + 20, 430), width: 620, height: 90),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.05)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
    );
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, _benchFront, bleed.right, bleed.bottom),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark ? const [_Colors.slate900, _Colors.slate950] : const [_Colors.slate800, _Colors.slate900],
        ).createShader(const Rect.fromLTWH(0, _benchFront, 1000, 60)),
    );
    canvas.drawLine(
      Offset(bleed.left, _benchFront),
      Offset(bleed.right, _benchFront),
      Paint()
        ..strokeWidth = 2
        ..color = _Colors.slate500.withValues(alpha: 0.7),
    );
    canvas.drawLine(
      Offset(bleed.left, _benchBack),
      Offset(bleed.right, _benchBack),
      Paint()
        ..strokeWidth = 1.5
        ..color = (isDark ? _Colors.slate600 : _Colors.slate500).withValues(alpha: 0.6),
    );
  }

  /// HTML `#s2-dropzones` letters under the two tube positions.
  void _zoneChips(Canvas canvas) {
    for (var i = 0; i < 2; i++) {
      labText(
        canvas,
        i == 0 ? 'A' : 'B',
        Offset(_tubeX[i], 446),
        size: 22,
        weight: FontWeight.w900,
        color: Colors.white,
        background: _Colors.slate900.withValues(alpha: 0.55),
        radius: 8,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      );
    }
  }

  /// Dashed outline where the rack goes, until the tubes are placed.
  void _rackGhost(Canvas canvas, double t) {
    final active = scene.dragTool == 'tubes';
    final hot = active && scene.hover == 2;
    final rect = RRect.fromRectAndRadius(const Rect.fromLTRB(_rackX - 186, 136, _rackX + 200, 424), const Radius.circular(18));
    if (active) {
      canvas.drawRRect(rect, Paint()..color = _Colors.emerald500.withValues(alpha: hot ? 0.16 : 0.08));
    }
    labDashedPath(
      canvas,
      Path()..addRRect(rect),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = _Colors.emerald500.withValues(alpha: active ? 0.9 : 0.4),
      dash: 12,
      gap: 8,
      phase: t * 16,
    );
    labText(
      canvas,
      tr('drop_tubes_here'),
      const Offset(_rackX + 7, 280),
      size: 18,
      weight: FontWeight.w800,
      color: (isDark ? _Colors.emerald400 : _Colors.emerald700).withValues(alpha: active ? 1 : 0.7),
      maxWidth: 340,
    );
  }

  void _rackAndTubes(Canvas canvas, double t) {
    final s = scene;
    final appear = _clamp01((t - s.tubesT0) / 0.4);
    final drop = Curves.easeOutBack.transform(_clamp01((t - s.tubesT0) / 0.7));
    final dy = -150 * (1 - drop);
    const angle = -0.588; // atan2(-16, 24)
    final depth = _rackDepth.distance;
    final acrylic = _Colors.blue;
    final legPaint = Paint()..color = _Colors.blue300.withValues(alpha: 0.45 * appear);

    labGroundShadow(canvas, const Offset(_rackX + 14, 410), 420, 28, opacity: 0.4 * appear);
    // Back legs.
    for (final lx in const [-158.0, 158.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(_rackX + lx - 4 + _rackDepth.dx, 276 + _rackDepth.dy, _rackX + lx + 4 + _rackDepth.dx, 400 + _rackDepth.dy),
          const Radius.circular(4),
        ),
        legPaint,
      );
    }
    // Base plate.
    labBox3D(
      canvas,
      const Rect.fromLTRB(_rackX - 170, 400, _rackX + 170, 414),
      depth,
      acrylic,
      angle: angle,
      opacity: 0.55 * appear,
    );
    // Test tubes.
    for (var i = 0; i < 2; i++) {
      _tube(canvas, i, dy, t);
    }
    // Top plate (the tubes pass through its holes).
    labBox3D(
      canvas,
      const Rect.fromLTRB(_rackX - 170, 262, _rackX + 170, 276),
      depth,
      acrylic,
      angle: angle,
      opacity: 0.42 * appear,
    );
    for (var i = 0; i < 2; i++) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(_tubeX[i], 262 + _rackDepth.dy / 2), width: _tubeHalfW * 2 + 8, height: 9),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = _Colors.blue300.withValues(alpha: 0.7 * appear),
      );
    }
    // Front legs.
    for (final lx in const [-158.0, 158.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(_rackX + lx - 4, 276, _rackX + lx + 4, 400),
          const Radius.circular(4),
        ),
        Paint()..color = _Colors.blue300.withValues(alpha: 0.6 * appear),
      );
    }
  }

  Path _tubePath(Rect rect) {
    final r = rect.width / 2;
    return Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.left, rect.bottom - r)
      ..arcToPoint(Offset(rect.right, rect.bottom - r), radius: Radius.circular(r), clockwise: false)
      ..lineTo(rect.right, rect.top)
      ..close();
  }

  /// Liquid colour of tube [i] (rice water, then iodine).
  (Color, double) _liquid(int i) {
    final base = isDark ? _Colors.slate200 : _Colors.slate300;
    final st = scene.stain(i);
    final col = Color.lerp(base, _iodineColor[i], st)!;
    final alpha = 0.5 + ((i == 0 ? 0.95 : 0.85) - 0.5) * st;
    return (col, alpha);
  }

  void _tube(Canvas canvas, int i, double dy, double t) {
    final s = scene;
    final x = _tubeX[i];
    final rect = Rect.fromLTRB(x - _tubeHalfW, _tubeTop + dy, x + _tubeHalfW, _tubeBottom + dy);
    final inner = _tubePath(rect.deflate(2.5));
    final bottom = rect.bottom;

    canvas.drawPath(_tubePath(rect), Paint()..color = (isDark ? Colors.white : _Colors.slate400).withValues(alpha: 0.06));

    // Rice that already settled.
    if (s.rice[i]) {
      canvas.save();
      canvas.clipPath(inner);
      final age = t - s.riceT0[i];
      for (final g in s.grains[i]) {
        if (age < 0.45 + g.delay + 0.4) continue;
        _grain(canvas, i, Offset(x + g.dx, bottom - g.up), g);
      }
      canvas.restore();
    }

    // Liquid.
    final f = s.fill(i);
    if (f > 0) {
      final surface = bottom - f * (bottom - _liquidTop - dy);
      final (col, alpha) = _liquid(i);
      final lr = Rect.fromLTRB(rect.left, surface, rect.right, bottom);
      canvas.save();
      canvas.clipPath(inner);
      canvas.drawRect(
        lr,
        Paint()
          ..shader = LinearGradient(
            colors: [
              labShade(col, -0.3).withValues(alpha: alpha),
              labShade(col, 0.18).withValues(alpha: alpha),
              col.withValues(alpha: alpha),
              labShade(col, -0.35).withValues(alpha: alpha),
            ],
            stops: const [0, 0.3, 0.6, 1],
          ).createShader(lr),
      );
      // Iodine-starch complex reads blue-black, not grey.
      if (i == 0 && s.stain(0) > 0) {
        canvas.drawRect(
          lr,
          Paint()
            ..shader = RadialGradient(
              colors: [
                _Colors.blue900.withValues(alpha: 0.55 * s.stain(0)),
                _Colors.blue900.withValues(alpha: 0),
              ],
            ).createShader(lr),
        );
      }
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, surface), width: rect.width - 5, height: 7),
        Paint()..color = labShade(col, 0.35).withValues(alpha: math.min(1, alpha + 0.1)),
      );
      canvas.restore();
    }

    // Glass.
    labTestTube(canvas, rect, glass: _glass);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, rect.top), width: rect.width + 6, height: 8),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _glass.withValues(alpha: 0.8),
    );
    final hi = Rect.fromLTWH(rect.left + 6, rect.top + 12, 5, rect.height - 44);
    canvas.drawRRect(
      RRect.fromRectAndRadius(hi, const Radius.circular(3)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withValues(alpha: 0.5), Colors.white.withValues(alpha: 0.05)],
        ).createShader(hi),
    );
    canvas.drawLine(
      Offset(rect.right - 7, rect.top + 20),
      Offset(rect.right - 7, rect.bottom - 40),
      Paint()
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.18),
    );

    // Curved paper label with the tube letter.
    final label = Rect.fromLTRB(rect.left + 4, rect.top + 28, rect.right - 4, rect.top + 62);
    final rr = RRect.fromRectAndRadius(label, const Radius.circular(6));
    canvas.drawRRect(
      rr,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFE2E8F0), Colors.white, Colors.white, Color(0xFFCBD5E1)],
          stops: [0, 0.3, 0.7, 1],
        ).createShader(label),
    );
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = _Colors.blue,
    );
    labText(canvas, i == 0 ? 'A' : 'B', label.center, size: 22, weight: FontWeight.w900, color: _Colors.slate900);
  }

  /// A boiled rice grain (A) or a lump of chewed rice (B).
  void _grain(Canvas canvas, int i, Offset c, _Grain g) {
    if (i == 0) {
      canvas
        ..save()
        ..translate(c.dx, c.dy)
        ..rotate(g.angle);
      final r = Rect.fromCenter(center: Offset.zero, width: 5.5, height: 12);
      canvas.drawOval(r, Paint()..color = _Colors.slate50);
      canvas.drawOval(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = _Colors.slate400,
      );
      canvas.restore();
    } else {
      canvas.drawCircle(c, g.size, Paint()..color = const Color(0xFFFEF3C7));
      canvas.drawCircle(
        c,
        g.size,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0xFFD6D3D1),
      );
    }
  }

  /// HTML `addRiceToTube`: a spoon tips the rice into the tube.
  void _spoon(Canvas canvas, int i, double t) {
    final age = t - scene.riceT0[i];
    if (age > 1.35) return;
    final x = _tubeX[i];
    final alpha = _clamp01(age / 0.2) * (1 - _clamp01((age - 1.05) / 0.3));
    final tilt = -0.9 * _ease((age - 0.2) / 0.3);
    final bowl = Offset(x + 16, 116 - 20 * (1 - _clamp01(age / 0.25)));

    // Falling grains.
    for (final g in scene.grains[i]) {
      final u = _clamp01((age - 0.45 - g.delay) / 0.4);
      if (u <= 0 || u >= 1) continue;
      final from = bowl + Offset(-8 + g.dx * 0.2, 6);
      final to = Offset(x + g.dx, _tubeBottom - g.up);
      _grain(canvas, i, Offset(from.dx + (to.dx - from.dx) * u, from.dy + (to.dy - from.dy) * u * u), g);
    }

    canvas
      ..save()
      ..translate(bowl.dx, bowl.dy)
      ..rotate(tilt);
    final steel = Paint()
      ..shader = LinearGradient(
        colors: [
          _Colors.slate200.withValues(alpha: alpha),
          _Colors.slate400.withValues(alpha: alpha),
          _Colors.slate300.withValues(alpha: alpha),
        ],
      ).createShader(const Rect.fromLTWH(-24, -50, 110, 64));
    canvas.drawLine(
      const Offset(16, -4),
      const Offset(84, -46),
      Paint()
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..color = _Colors.slate400.withValues(alpha: alpha),
    );
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 44, height: 24), steel);
    // Heap still on the spoon.
    final left = 1 - _clamp01((age - 0.45) / 0.6);
    if (left > 0) {
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(0, -3), width: 34 * left + 4, height: 14 * left + 2),
        Paint()..color = (i == 0 ? Colors.white : const Color(0xFFFEF3C7)).withValues(alpha: alpha),
      );
    }
    canvas.restore();
  }

  /// HTML `fillWater`: a beaker tilts over the tube and pours.
  void _beaker(Canvas canvas, int i, double t) {
    final age = t - scene.waterT0[i];
    if (age > 1.6) return;
    final x = _tubeX[i];
    final alpha = _clamp01(age / 0.15) * (1 - _clamp01((age - 1.3) / 0.3));
    final tilt = -1.05 * (_ease(age / 0.3) - _ease((age - 1.15) / 0.25));
    final pivot = Offset(x + 62, 92);
    final rot = Offset(math.cos(tilt), math.sin(tilt));
    Offset local(Offset p) => pivot + Offset(p.dx * rot.dx - p.dy * rot.dy, p.dx * rot.dy + p.dy * rot.dx);

    // Stream into the tube.
    if (age > 0.25 && age < 1.2) {
      final spout = local(const Offset(-34, -36));
      final surface = _tubeBottom - scene.fill(i) * (_tubeBottom - _liquidTop) - 2;
      final path = Path()
        ..moveTo(spout.dx, spout.dy)
        ..quadraticBezierTo(x + 6, spout.dy + 8, x + 2, surface);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..color = _Colors.blue300.withValues(alpha: 0.7 * alpha),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white.withValues(alpha: 0.6 * alpha),
      );
    }

    canvas
      ..save()
      ..translate(pivot.dx, pivot.dy)
      ..rotate(tilt);
    canvas.saveLayer(const Rect.fromLTWH(-60, -60, 120, 120), Paint()..color = Colors.white.withValues(alpha: alpha));
    labBeaker(
      canvas,
      const Rect.fromLTWH(-30, -36, 60, 72),
      fill: 0.62 - 0.4 * _clamp01((age - 0.25) / 0.95),
      liquid: const Color(0xFF7DB8F7),
      glass: _glass,
    );
    canvas
      ..restore()
      ..restore();
  }

  /// HTML `addIodineDrop`: a dropper releases three drops.
  void _dropper(Canvas canvas, int i, double t) {
    final age = t - scene.iodineT0[i];
    if (age > 1.9) return;
    final x = _tubeX[i];
    final alpha = _clamp01(age / 0.2) * (1 - _clamp01((age - 1.5) / 0.35));
    final y0 = -26 * (1 - _clamp01(age / 0.25));
    const releases = [0.25, 0.55, 0.85];
    var squeeze = 0.0;
    for (final r in releases) {
      final u = (age - r + 0.15) / 0.15;
      if (u > 0 && u < 1) squeeze = math.max(squeeze, math.sin(u * math.pi));
    }
    final surface = _tubeBottom - scene.fill(i) * (_tubeBottom - _liquidTop);

    // Drops.
    for (final r in releases) {
      final u = (age - r) / 0.28;
      if (u <= 0 || u >= 1) continue;
      final y = 130 + (surface - 130) * u * u;
      final path = Path()
        ..moveTo(x, y - 7)
        ..quadraticBezierTo(x + 5, y, x, y + 4)
        ..quadraticBezierTo(x - 5, y, x, y - 7);
      canvas.drawPath(path, Paint()..color = _Colors.amber800);
    }
    // Ripples where the drops land.
    for (final r in releases) {
      final u = (age - r - 0.28) / 0.35;
      if (u <= 0 || u >= 1) continue;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, surface), width: 10 + 30 * u, height: 3 + 4 * u),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = _Colors.amber700.withValues(alpha: 1 - u),
      );
    }

    canvas.saveLayer(Rect.fromLTWH(x - 40, 0, 80, 160), Paint()..color = Colors.white.withValues(alpha: alpha));
    // Glass pipette with iodine.
    final body = RRect.fromRectAndRadius(Rect.fromLTRB(x - 6, 62 + y0, x + 6, 116 + y0), const Radius.circular(3));
    canvas.drawRRect(body, Paint()..color = _glass.withValues(alpha: 0.35));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(x - 4, 84 + y0, x + 4, 116 + y0), const Radius.circular(2)),
      Paint()..color = _Colors.amber800,
    );
    final tip = Path()
      ..moveTo(x - 6, 116 + y0)
      ..lineTo(x - 1.5, 128 + y0)
      ..lineTo(x + 1.5, 128 + y0)
      ..lineTo(x + 6, 116 + y0)
      ..close();
    canvas.drawPath(tip, Paint()..color = _Colors.amber800.withValues(alpha: 0.85));
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = _glass,
    );
    // Rubber bulb.
    final bulb = Rect.fromCenter(
      center: Offset(x, 50 + y0),
      width: 22 * (1 + 0.18 * squeeze),
      height: 28 * (1 - 0.15 * squeeze),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bulb, const Radius.circular(11)),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF7F1D1D), Color(0xFFDC2626), Color(0xFF7F1D1D)],
        ).createShader(bulb),
    );
    canvas.restore();
  }

  /// Emerald highlight on the valid drop targets while a tray item is
  /// dragged (HTML `.tube-target-active`).
  void _targets(Canvas canvas, double t) {
    final s = scene;
    final tool = s.dragTool;
    if (tool == null || tool == 'tubes' || !s.tubesPlaced) return;
    for (var i = 0; i < 2; i++) {
      final active = switch (tool) {
        'rice' => i == 0,
        'chewed' => i == 1,
        'water' => s.water[0] ? i == 1 : i == 0,
        'iodine' => s.step == 5 ? i == 0 : i == 1,
        _ => false,
      };
      if (!active) continue;
      final hot = s.hover == i;
      final rect = RRect.fromRectAndRadius(Rect.fromLTRB(_tubeX[i] - 44, 116, _tubeX[i] + 44, 426), const Radius.circular(16));
      final pulse = 0.5 + 0.5 * math.sin(t * 5);
      canvas.drawRRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..color = _Colors.emerald500.withValues(alpha: (hot ? 0.5 : 0.25) * (0.6 + 0.4 * pulse))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      canvas.drawRRect(rect, Paint()..color = _Colors.emerald500.withValues(alpha: hot ? 0.2 : 0.1));
      canvas.drawRRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = _Colors.emerald500.withValues(alpha: hot ? 1 : 0.75),
      );
    }
  }

  void _labels(Canvas canvas) {
    final s = scene;
    if (!s.tubesPlaced) return;
    for (var i = 0; i < 2; i++) {
      String? key;
      Color? border;
      if (s.stain(i) > 0.6) {
        key = i == 0 ? 'res_starch' : 'res_no_starch';
        border = i == 0 ? _Colors.blue : _Colors.amber700;
      } else if (s.rice[i]) {
        key = i == 0 ? 'lbl_rice' : 'lbl_chewed';
        border = _Colors.slate500;
      }
      if (key == null) continue;
      labPill(canvas, tr(key), Offset(_tubeX[i], 480), size: 12.5, border: border);
    }
  }

  /// HTML `showS2Magnifier()`: a magnified view of the tube contents.
  void _magnifier(Canvas canvas, int i, double t) {
    final age = t - scene.magT0;
    if (age > 3.8) return;
    final alpha = _clamp01(age / 0.25) * (1 - _clamp01((age - 3.5) / 0.3));
    if (alpha <= 0) return;
    final c = _lensCenter[i];
    const r = _lensR;
    final ring = i == 0 ? _Colors.blue900 : _Colors.amber700;
    final target = Offset(_tubeX[i], 330);
    final ang = (target - c).direction;

    // Zoom lines from the lens to the spot in the tube.
    final line = Paint()
      ..strokeWidth = 2
      ..color = (isDark ? Colors.white : _Colors.slate600).withValues(alpha: 0.45 * alpha);
    for (final sgn in const [1.0, -1.0]) {
      labDashedLine(
        canvas,
        c + Offset.fromDirection(ang + sgn * 0.75, r),
        target + Offset.fromDirection(ang + sgn * math.pi / 2, 24),
        line,
        dash: 6,
        gap: 5,
      );
    }
    canvas.drawCircle(
      target,
      24,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = ring.withValues(alpha: 0.9 * alpha),
    );

    canvas.saveLayer(Rect.fromCircle(center: c, radius: r + 30), Paint()..color = Colors.white.withValues(alpha: alpha));
    labGroundShadow(canvas, c + const Offset(0, 10), r * 2.1, r * 2.1, opacity: 0.35);
    canvas.drawCircle(c, r, Paint()..color = isDark ? const Color(0xF00F172A) : const Color(0xF5F8FAFC));
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r)));
    final k = 1.6 * r / 100; // SVG viewBox 100 -> lens
    Offset v(double x, double y) => c + Offset((x - 50) * k, (y - 50) * k);
    if (i == 0) {
      final strand = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8 * k
        ..strokeCap = StrokeCap.round
        ..color = _Colors.blue;
      final p1 = Path()
        ..moveTo(v(20, 50).dx, v(20, 50).dy)
        ..quadraticBezierTo(v(30, 20).dx, v(30, 20).dy, v(50, 50).dx, v(50, 50).dy)
        ..quadraticBezierTo(v(70, 80).dx, v(70, 80).dy, v(80, 50).dx, v(80, 50).dy);
      final p2 = Path()
        ..moveTo(v(20, 70).dx, v(20, 70).dy)
        ..quadraticBezierTo(v(40, 90).dx, v(40, 90).dy, v(60, 70).dx, v(60, 70).dy)
        ..quadraticBezierTo(v(80, 50).dx, v(80, 50).dy, v(90, 70).dx, v(90, 70).dy);
      canvas
        ..drawPath(p1, strand)
        ..drawPath(p2, strand);
      final pulse = 0.75 + 0.25 * math.cos(age * math.pi);
      for (final q in [v(45, 50), v(70, 70)]) {
        canvas.drawCircle(q, 10 * k, Paint()..color = _Colors.violet900.withValues(alpha: pulse));
        canvas.drawCircle(q + Offset(-3 * k, -3 * k), 3 * k, Paint()..color = Colors.white.withValues(alpha: 0.25 * pulse));
      }
    } else {
      for (final h in scene.magHexes) {
        final path = Path()
          ..moveTo(v(h.dx, h.dy - 8).dx, v(h.dx, h.dy - 8).dy)
          ..lineTo(v(h.dx + 7, h.dy - 4).dx, v(h.dx + 7, h.dy - 4).dy)
          ..lineTo(v(h.dx + 7, h.dy + 4).dx, v(h.dx + 7, h.dy + 4).dy)
          ..lineTo(v(h.dx, h.dy + 8).dx, v(h.dx, h.dy + 8).dy)
          ..lineTo(v(h.dx - 7, h.dy + 4).dx, v(h.dx - 7, h.dy + 4).dy)
          ..lineTo(v(h.dx - 7, h.dy - 4).dx, v(h.dx - 7, h.dy - 4).dy)
          ..close();
        canvas.drawPath(path, Paint()..color = _Colors.pink);
      }
      for (final (q, delay) in [(const Offset(30, 30), 0.0), (const Offset(70, 80), 0.2)]) {
        final bounce = -5 * (0.5 + 0.5 * math.cos((age - delay) * math.pi * 2));
        canvas.drawCircle(v(q.dx, q.dy + bounce), 10 * k, Paint()..color = _Colors.amber700);
      }
    }
    canvas.restore();
    // Lens rim and reflection.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = ring,
    );
    canvas.drawCircle(
      c,
      r - 6,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white.withValues(alpha: 0.3),
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r - 14),
      math.pi * 1.1,
      math.pi * 0.35,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.18),
    );
    labText(
      canvas,
      tr(i == 0 ? 'mag_a' : 'mag_b'),
      c + const Offset(0, -r),
      size: 12.5,
      weight: FontWeight.w800,
      color: Colors.white,
      background: _Colors.slate800.withValues(alpha: 0.92),
      border: ring,
      radius: 6,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BenchPainter old) =>
      old.isDark != isDark || old.showLabels != showLabels || old.tr != tr;
}

/// Phosphor-style molar ("ph-teeth") for the chew button and the board.
class _ToothIconPainter extends CustomPainter {
  const _ToothIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100, size.height / 100);
    final path = Path()
      ..moveTo(20, 32)
      ..cubicTo(20, 10, 40, 6, 50, 18)
      ..cubicTo(60, 6, 80, 10, 80, 32)
      ..cubicTo(80, 50, 74, 60, 72, 74)
      ..cubicTo(70, 92, 58, 94, 57, 78)
      ..cubicTo(56, 66, 44, 66, 43, 78)
      ..cubicTo(42, 94, 30, 92, 28, 74)
      ..cubicTo(26, 60, 20, 50, 20, 32)
      ..close();
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.25));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
    canvas.drawLine(
      const Offset(38, 30),
      const Offset(50, 36),
      Paint()
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _ToothIconPainter old) => old.color != color;
}

/// Pink sugar cube under the sweetness meter.
class _CubeIconPainter extends CustomPainter {
  const _CubeIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    labBox3D(canvas, Rect.fromLTWH(w * 0.08, w * 0.3, w * 0.62, w * 0.62), w * 0.3, _Colors.pink, stroke: true);
  }

  @override
  bool shouldRepaint(covariant _CubeIconPainter old) => false;
}

/// Tray item icons (test tubes, rice bowl, chewed rice, water beaker,
/// iodine dropper bottle), drawn in a 100 x 100 box.
class _ToolIconPainter extends CustomPainter {
  const _ToolIconPainter(this.id, {required this.isDark});

  final String id;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100, size.height / 100);
    final glass = isDark ? const Color(0xFFBFDBFE) : _Colors.slate500;
    switch (id) {
      case 'tubes':
        for (final (x, f, c) in [(24.0, 0.42, _Colors.indigo), (56.0, 0.58, const Color(0xFF818CF8))]) {
          final r = Rect.fromLTWH(x, 10, 20, 80);
          canvas.save();
          canvas.clipPath(Path()..addRRect(RRect.fromRectAndCorners(r, bottomLeft: const Radius.circular(10), bottomRight: const Radius.circular(10))));
          canvas.drawRect(Rect.fromLTRB(r.left, r.bottom - r.height * f, r.right, r.bottom), Paint()..color = c);
          canvas.restore();
          canvas.drawRRect(
            RRect.fromRectAndCorners(r, bottomLeft: const Radius.circular(10), bottomRight: const Radius.circular(10)),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4
              ..color = glass,
          );
          canvas.drawLine(
            Offset(x - 3, 10),
            Offset(x + 23, 10),
            Paint()
              ..strokeWidth = 5
              ..strokeCap = StrokeCap.round
              ..color = glass,
          );
        }
      case 'rice':
      case 'chewed':
        final chewed = id == 'chewed';
        // Spoon handle.
        canvas.drawLine(
          const Offset(58, 46),
          const Offset(90, 10),
          Paint()
            ..strokeWidth = 7
            ..strokeCap = StrokeCap.round
            ..color = _Colors.slate400,
        );
        // Rice heap.
        final heap = chewed ? const Color(0xFFFDE68A) : Colors.white;
        if (chewed) {
          canvas.drawOval(const Rect.fromLTWH(20, 30, 60, 30), Paint()..color = heap);
          canvas.drawOval(const Rect.fromLTWH(30, 26, 30, 18), Paint()..color = const Color(0xFFFEF3C7));
        } else {
          for (final (x, y) in [(30.0, 46.0), (40.0, 40.0), (50.0, 36.0), (60.0, 40.0), (70.0, 46.0), (45.0, 46.0), (56.0, 47.0)]) {
            canvas.save();
            canvas.translate(x, y);
            canvas.rotate((x - 50) / 40);
            canvas.drawOval(const Rect.fromLTWH(-5, -9, 10, 18), Paint()..color = heap);
            canvas.drawOval(
              const Rect.fromLTWH(-5, -9, 10, 18),
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.5
                ..color = _Colors.slate300,
            );
            canvas.restore();
          }
        }
        // Bowl.
        final bowl = Path()
          ..moveTo(10, 50)
          ..lineTo(90, 50)
          ..quadraticBezierTo(88, 88, 50, 90)
          ..quadraticBezierTo(12, 88, 10, 50)
          ..close();
        canvas.drawPath(
          bowl,
          Paint()
            ..shader = LinearGradient(
              colors: chewed
                  ? const [Color(0xFF14B8A6), Color(0xFF0F766E)]
                  : const [_Colors.emerald400, _Colors.emerald700],
            ).createShader(const Rect.fromLTWH(10, 50, 80, 40)),
        );
        canvas.drawLine(
          const Offset(8, 50),
          const Offset(92, 50),
          Paint()
            ..strokeWidth = 5
            ..strokeCap = StrokeCap.round
            ..color = chewed ? const Color(0xFF5EEAD4) : _Colors.emerald300,
        );
        if (chewed) {
          canvas.save();
          canvas.translate(62, 56);
          canvas.scale(0.3);
          const _ToothIconPainter(color: Colors.white).paint(canvas, const Size(100, 100));
          canvas.restore();
        }
      case 'water':
        labBeaker(canvas, const Rect.fromLTWH(22, 14, 56, 76), fill: 0.62, liquid: _Colors.blue, glass: glass);
      case 'iodine':
        // Dropper bulb + pipette.
        canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(41, 2, 18, 20), const Radius.circular(8)),
          Paint()..color = _Colors.slate800,
        );
        canvas.drawRect(const Rect.fromLTWH(46, 20, 8, 22), Paint()..color = glass.withValues(alpha: 0.8));
        // Brown glass bottle.
        final bottle = RRect.fromRectAndRadius(const Rect.fromLTWH(26, 40, 48, 54), const Radius.circular(10));
        canvas.drawRRect(
          bottle,
          Paint()
            ..shader = const LinearGradient(
              colors: [Color(0xFF78350F), _Colors.amber700, Color(0xFF78350F)],
            ).createShader(bottle.outerRect),
        );
        canvas.drawRect(const Rect.fromLTWH(36, 34, 28, 8), Paint()..color = _Colors.slate700);
        canvas.drawRect(const Rect.fromLTWH(30, 58, 40, 20), Paint()..color = Colors.white.withValues(alpha: 0.9));
        labText(canvas, 'I₂', const Offset(50, 68), size: 15, weight: FontWeight.w900, color: _Colors.indigo);
    }
  }

  @override
  bool shouldRepaint(covariant _ToolIconPainter old) => old.id != id || old.isDark != isDark;
}

/// Popup art: a starch chain (glucose units) or three sugar molecules.
class _MiniMoleculePainter extends CustomPainter {
  const _MiniMoleculePainter({required this.sugar});

  final bool sugar;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.height * 0.36;
    final cy = size.height / 2;
    for (var i = 0; i < 3; i++) {
      final c = Offset(size.width * (0.2 + 0.3 * i), cy + (sugar && i == 1 ? -r * 0.25 : 0));
      if (sugar) {
        final path = Path();
        for (var j = 0; j < 6; j++) {
          final a = math.pi / 6 + j * math.pi / 3;
          final p = c + Offset(math.cos(a), math.sin(a)) * r;
          j == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
        }
        path.close();
        canvas.drawPath(
          path,
          Paint()
            ..shader = const LinearGradient(
              colors: [Color(0xFFFBCFE8), _Colors.pink, Color(0xFFBE185D)],
            ).createShader(Rect.fromCircle(center: c, radius: r)),
        );
      } else {
        if (i < 2) {
          canvas.drawLine(
            c,
            Offset(size.width * (0.2 + 0.3 * (i + 1)), cy),
            Paint()
              ..strokeWidth = r * 0.45
              ..color = _Colors.slate300,
          );
        }
      }
    }
    if (!sugar) {
      for (var i = 0; i < 3; i++) {
        labSphere(canvas, Offset(size.width * (0.2 + 0.3 * i), cy), r, _Colors.blue, highlight: 0.5);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MiniMoleculePainter old) => old.sugar != sugar;
}

/// Popup art: final colour of test tube A (blue-black) or B (brown-yellow).
class _MiniTubePainter extends CustomPainter {
  const _MiniTubePainter(this.index, {required this.isDark});

  final int index;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(size.width * 0.15, 2, size.width * 0.7, size.height - 4);
    final colour = index == 0 ? const Color(0xFF172554) : _Colors.amber700;
    labTestTube(
      canvas,
      rect,
      fill: 0.62,
      liquid: colour,
      glass: isDark ? const Color(0xFFDBEAFE) : _Colors.slate500,
    );
    labText(
      canvas,
      index == 0 ? 'A' : 'B',
      Offset(rect.center.dx, rect.top + rect.height * 0.22),
      size: 13,
      weight: FontWeight.w900,
      color: isDark ? Colors.white : _Colors.slate900,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniTubePainter old) => old.index != index || old.isDark != isDark;
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
