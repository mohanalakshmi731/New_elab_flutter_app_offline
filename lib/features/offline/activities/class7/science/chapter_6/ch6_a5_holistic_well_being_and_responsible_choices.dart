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

/// Class 7 Science • Chapter 6 • Activity 5
/// Holistic Well-being and Responsible Choices.
///
/// Native Flutter port of `Cl7S-Ch06-A5-Holistic_Well_being_and_Responsible_Choices.html`.
/// Scenario 1: drag a balanced meal, then a junk-food meal, from the conveyor
/// belt onto the plate and watch the Energy, Bone Strength and Blood Health
/// meters. Scenario 2: say no to (or try) a peer's cigarette, then drag the
/// age timeline from 15 to 40 to see the lungs stay healthy or darken.
class Ch6A5HolisticWellBeingAndResponsibleChoicesPage extends StatefulWidget {
  const Ch6A5HolisticWellBeingAndResponsibleChoicesPage({super.key});

  @override
  State<Ch6A5HolisticWellBeingAndResponsibleChoicesPage> createState() =>
      _Ch6A5HolisticWellBeingAndResponsibleChoicesPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pickup 2356, buzz 2594.
enum _Sound implements LabTone {
  /// Generic button click.
  click('click.mp3'),

  /// Sidebar expand / collapse.
  toggle('toggle.mp3'),

  /// Correct action / right answer (HTML "success" / "chime" tones).
  correct('correct.mp3'),

  /// Wrong action / invalid move (HTML "error" tone).
  wrong('wrong.mp3'),

  /// Scenario completed / success popup.
  success('success.mp3'),

  /// Scenario changed.
  scenario('scenario.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('curtain.mp3'),

  /// A food item is picked up from the conveyor belt (HTML "pop").
  pickup('pickup.mp3'),

  /// A raspy cough while the damaged lungs age (HTML "cough").
  buzz('buzz.mp3');

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

/// Tailwind colours and Three.js material colours used by this lab.
abstract final class _Colors {
  // UI (Tailwind config: blue theme).
  static const Color blue = Color(0xFF3B82F6); // blue-500
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color emerald = Color(0xFF10B981); // emerald-500
  static const Color emerald100 = Color(0xFFD1FAE5);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald700 = Color(0xFF047857);
  static const Color green = Color(0xFF22C55E);
  static const Color red = Color(0xFFEF4444);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red400 = Color(0xFFF87171);
  static const Color red700 = Color(0xFFB91C1C);
  static const Color red800 = Color(0xFF991B1B);
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
  static const Color sky100 = Color(0xFFE0F2FE); // light scene background

  // Scene materials (Three.js hex values).
  static const Color skin = Color(0xFFE0AC69);
  static const Color shirtBlue = Color(0xFF3B82F6);
  static const Color shirtGreen = Color(0xFF10B981);
  static const Color pants = Color(0xFF1E293B);
  static const Color hair = Color(0xFF27272A);
  static const Color shoe = Color(0xFF111111);
  static const Color wood = Color(0xFF8B5A2B);
  static const Color plate = Color(0xFFF8FAFC);
  static const Color belt = Color(0xFF222222);
  static const Color steel = Color(0xFF94A3B8);
  static const Color stand = Color(0xFF475569);
  static const Color lungPink = Color(0xFFFCA5A5);
  static const Color lungMature = Color(0xFFDC5858);
  static const Color lungDark = Color(0xFF3F3F46);
  static const Color spot = Color(0xFF1C1917);
  static const Color smoke = Color(0xFF9CA3AF);
  static const Color spinach1 = Color(0xFF15803D);
  static const Color spinach2 = Color(0xFF166534);
  static const Color spinach3 = Color(0xFF22C55E);
  static const Color bowl = Color(0xFFE2E8F0);
  static const Color beans = Color(0xFF78350F);
  static const Color bun = Color(0xFFD97706);
  static const Color patty = Color(0xFF451A03);
  static const Color cheese = Color(0xFFFDE047);
  static const Color fry = Color(0xFFFEF08A);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables, blue accent): sidebar, canvas, popups, curtain, buttons.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate900,
    panel: Color(0xEB0F172A),
    border: Color(0x26FFFFFF),
    card: Color(0x991E293B),
    cardBorder: Color(0x80334155),
    canvasBg: _Colors.slate900,
    text: _Colors.slate200,
    textStrong: Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.blue,
    onAccent: Colors.white,
    primary: _Colors.blue600,
    onPrimary: Colors.white,
    success: _Colors.emerald,
    danger: _Colors.red,
    onDanger: Colors.white,
    info: _Colors.blue400,
    popupBg: _Colors.slate900,
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: _Colors.slate100,
    toastText: _Colors.slate900,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x661E40AF),
    curtainText: Colors.white,
    curtainMuted: Color(0xCC93C5FD),
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC000000),
    buttonIcon: Color(0xFFFFAB40),
    buttonBorder: Color(0xCCFF9800),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: Color(0xEB0F172A),
    labelText: _Colors.blue,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate100,
    panel: Color(0xF2FFFFFF),
    border: Color(0x26000000),
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.slate50,
    text: _Colors.slate800,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.blue600,
    onAccent: Colors.white,
    primary: _Colors.blue600,
    onPrimary: Colors.white,
    success: _Colors.emerald,
    danger: _Colors.red,
    onDanger: Colors.white,
    info: _Colors.blue,
    popupBg: Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: Colors.white,
    toastBg: _Colors.slate900,
    toastText: Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x661E40AF),
    curtainText: Colors.white,
    curtainMuted: Color(0xCC93C5FD),
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC000000),
    buttonIcon: Color(0xFFFFAB40),
    buttonBorder: Color(0xCCFF9800),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: Color(0xF2FFFFFF),
    labelText: _Colors.blue600,
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
    'app_title': 'Holistic Well-being and Responsible Choices',
    'app_subtitle': 'Class 7 • Adolescence: A Stage of Growth and Change',
    'scen_1_opt': "Scenario 1: The Meal Planner's Impact",
    'scen_2_opt': 'Scenario 2: The Timeline of Choice',
    'concept_exp': 'Observation Step',
    'observation': 'Result',
    'explanation': 'Explanation',
    'success': 'Discovery Complete!',
    'discovery_complete': 'Exploration Complete!',
    'select_next_sc_msg': 'Scenario 1 completed. Select the next from the sidebar!',
    'btn_conclude': 'Review Findings',
    'btn_eat': 'EAT MEAL',
    'btn_say_no': 'SAY NO',
    'btn_try_once': 'TRY ONCE',
    'lbl_energy': 'Energy',
    'lbl_bone': 'Bone\nStrength',
    'lbl_blood': 'Blood\nHealth',
    'lbl_deficiency': 'Deficiency',
    'lbl_iron_deficiency': 'Iron Deficiency',
    'lbl_age': 'Age',
    'lbl_current_age': 'Current Age:',
    'lbl_healthy_lungs': 'Healthy Lungs',
    'lbl_damaged_lungs': 'Lungs Damaged',
    'txt_addiction_quote': "Someone who is addicted today, might have started once with 'just one time'!",
    'lbl_student': 'Student',
    'lbl_meal': 'Meal Plate',
    'lbl_lungs': 'Lungs',
    'lbl_cough': '*cough*',
    'food_milk': 'Milk',
    'food_spinach': 'Spinach',
    'food_beans': 'Kidney Beans',
    'food_burger': 'Burger',
    'food_fries': 'Fries',
    'food_soda': 'Soda',
    'toast_drop_plate': 'Drop the food onto the plate!',
    'toast_say_no_first': "First make the healthy choice: click 'SAY NO'.",
    'toast_try_once_now': "This time, click 'TRY ONCE' to see the consequences.",
    'sum_balanced': 'Balanced Diet',
    'sum_balanced_eq': '= Sustained Energy & Growth',
    'sum_junk': 'Junk Food',
    'sum_junk_eq': '= Energy Crash & Deficiencies',
    'sum_vs': 'VS',
    'sum_path': 'The Path of Addiction',
    'sum_try_once': 'Try Once',
    'sum_repeated': 'Repeated Use',
    'sum_severe': 'Severe Damage',
    'summary_1':
        'A balanced diet, rich in proteins, vitamins, and minerals like calcium and iron, is crucial for growth, strength, and energy during adolescence. Junk food provides a short burst of energy but lacks the essential nutrients needed for healthy development.',
    'summary_2':
        "This simulation demonstrates that even a single decision to try a harmful substance can lead to a path of addiction and severe, long-term health damage. Saying 'NO' from the very first time is the most effective way to protect your future health and well-being.",
    'exp_1_1':
        'During adolescence, the body undergoes rapid physical growth. Foods like Milk (rich in Calcium), and Spinach/Beans (rich in Iron and Proteins) are essential building blocks that fulfill these increased nutritional demands.',
    'exp_1_2':
        'A balanced diet directly impacts holistic well-being. It provides sustained energy for daily activities, builds strong bones for structural support, and prevents conditions like anemia by maintaining optimal blood health.',
    'exp_1_3':
        'Junk foods might taste good and be easily available, but they are typically packed with excessive sugars, unhealthy fats, and empty calories, while severely lacking the vital nutrients required for a growing adolescent body.',
    'exp_1_4':
        'While junk food provides a rapid, short-lived burst of energy due to high sugar, it fails to sustain you. The lack of essential nutrients leads to a quick energy crash, fatigue, and potential long-term health issues like nutritional deficiencies.',
    'exp_2_1':
        "Adolescence often brings exposure to peer pressure. Having the confidence to firmly say 'NO' to addictive and harmful substances is a critical life skill for protecting your immediate and future well-being.",
    'exp_2_2':
        'By making the responsible choice to avoid smoking entirely, you protect your respiratory system from irreversible damage, ensuring healthy lung function and a higher quality of life as you age.',
    'exp_2_3':
        "Addiction frequently begins with the deceptive thought of 'just one time'. However, harmful substances like tobacco contain powerful toxins that begin inflicting cellular damage on your body from the very first use.",
    'exp_2_4':
        'What starts as a single try often leads to continuous, habitual use due to addiction. This causes severe, cumulative damage to the lung tissues, drastically increasing the risk of chronic respiratory diseases and reducing overall life expectancy.',
  },
  'hi': {
    'app_title': 'समग्र भलाई और जिम्मेदार विकल्प',
    'app_subtitle': 'कक्षा 7 • किशोरावस्था: वृद्धि और परिवर्तन की अवस्था',
    'scen_1_opt': 'परिदृश्य 1: भोजन योजनाकार का प्रभाव',
    'scen_2_opt': 'परिदृश्य 2: विकल्प की समयरेखा',
    'concept_exp': 'अवलोकन चरण',
    'observation': 'परिणाम',
    'explanation': 'स्पष्टीकरण',
    'success': 'खोज पूर्ण!',
    'discovery_complete': 'अन्वेषण पूर्ण!',
    'select_next_sc_msg': 'परिदृश्य 1 पूरा हुआ। साइडबार से अगला चुनें!',
    'btn_conclude': 'निष्कर्ष की समीक्षा करें',
    'btn_eat': 'भोजन करें',
    'btn_say_no': 'ना कहें',
    'btn_try_once': 'एक बार कोशिश करें',
    'lbl_energy': 'ऊर्जा',
    'lbl_bone': 'हड्डी की\nमजबूती',
    'lbl_blood': 'रक्त\nस्वास्थ्य',
    'lbl_deficiency': 'कमी',
    'lbl_iron_deficiency': 'आयरन की कमी',
    'lbl_age': 'आयु',
    'lbl_current_age': 'वर्तमान आयु:',
    'lbl_healthy_lungs': 'स्वस्थ फेफड़े',
    'lbl_damaged_lungs': 'क्षतिग्रस्त फेफड़े',
    'txt_addiction_quote': "आज जिसे लत है, उसने शायद 'बस एक बार' से शुरुआत की हो!",
    'lbl_student': 'छात्र',
    'lbl_meal': 'भोजन की थाली',
    'lbl_lungs': 'फेफड़े',
    'lbl_cough': '*खाँसी*',
    'food_milk': 'दूध',
    'food_spinach': 'पालक',
    'food_beans': 'राजमा',
    'food_burger': 'बर्गर',
    'food_fries': 'फ्राइज़',
    'food_soda': 'सोडा',
    'toast_drop_plate': 'भोजन को थाली पर छोड़ें!',
    'toast_say_no_first': "पहले स्वस्थ विकल्प चुनें: 'ना कहें' पर क्लिक करें।",
    'toast_try_once_now': "इस बार परिणाम देखने के लिए 'एक बार कोशिश करें' पर क्लिक करें।",
    'sum_balanced': 'संतुलित आहार',
    'sum_balanced_eq': '= निरंतर ऊर्जा और विकास',
    'sum_junk': 'जंक फूड',
    'sum_junk_eq': '= ऊर्जा में गिरावट और पोषण की कमी',
    'sum_vs': 'बनाम',
    'sum_path': 'लत का रास्ता',
    'sum_try_once': 'एक बार कोशिश',
    'sum_repeated': 'बार-बार उपयोग',
    'sum_severe': 'गंभीर क्षति',
    'summary_1':
        'किशोरावस्था के दौरान विकास, ताकत और ऊर्जा के लिए प्रोटीन, विटामिन और कैल्शियम तथा आयरन जैसे खनिजों से भरपूर संतुलित आहार महत्वपूर्ण है। जंक फूड ऊर्जा का एक छोटा विस्फोट प्रदान करता है लेकिन इसमें स्वस्थ विकास के लिए आवश्यक पोषक तत्वों की कमी होती है।',
    'summary_2':
        "यह सिमुलेशन दर्शाता है कि हानिकारक पदार्थ को आजमाने का एक भी निर्णय लत और गंभीर, दीर्घकालिक स्वास्थ्य क्षति की ओर ले जा सकता है। पहली बार से ही 'ना' कहना आपके भविष्य के स्वास्थ्य और भलाई की रक्षा करने का सबसे प्रभावी तरीका है।",
    'exp_1_1':
        'किशोरावस्था के दौरान, शरीर में तेजी से शारीरिक विकास होता है। दूध (कैल्शियम से भरपूर), और पालक/बीन्स (आयरन और प्रोटीन से भरपूर) जैसे खाद्य पदार्थ आवश्यक निर्माण खंड हैं जो इन बढ़ती पोषण संबंधी मांगों को पूरा करते हैं।',
    'exp_1_2':
        'संतुलित आहार आपके समग्र स्वास्थ्य को सीधे प्रभावित करता है। यह दैनिक गतिविधियों के लिए निरंतर ऊर्जा प्रदान करता है, संरचनात्मक समर्थन के लिए मजबूत हड्डियों का निर्माण करता है, और इष्टतम रक्त स्वास्थ्य बनाए रखकर एनीमिया जैसी स्थितियों को रोकता है।',
    'exp_1_3':
        'जंक फूड स्वादिष्ट हो सकते हैं और आसानी से उपलब्ध हो सकते हैं, लेकिन वे आमतौर पर अत्यधिक शर्करा, अस्वास्थ्यकर वसा और खाली कैलोरी से भरे होते हैं, जबकि बढ़ते किशोर शरीर के लिए आवश्यक महत्वपूर्ण पोषक तत्वों की भारी कमी होती है।',
    'exp_1_4':
        'उच्च शर्करा के कारण जंक फूड त्वरित, अल्पकालिक ऊर्जा प्रदान करता है, लेकिन यह आपको बनाए रखने में विफल रहता है। आवश्यक पोषक तत्वों की कमी से ऊर्जा में तेजी से गिरावट, थकान और पोषण संबंधी कमियों जैसी संभावित दीर्घकालिक स्वास्थ्य समस्याएं होती हैं।',
    'exp_2_1':
        "किशोरावस्था अक्सर साथियों के दबाव का जोखिम लाती है। नशे की लत और हानिकारक पदार्थों को दृढ़ता से 'ना' कहने का आत्मविश्वास होना आपकी तत्काल और भविष्य की भलाई की रक्षा के लिए एक महत्वपूर्ण जीवन कौशल है।",
    'exp_2_2':
        'धूम्रपान से पूरी तरह बचने का जिम्मेदार विकल्प चुनकर, आप अपने श्वसन तंत्र को अपरिवर्तनीय क्षति से बचाते हैं, स्वस्थ फेफड़ों की कार्यप्रणाली सुनिश्चित करते हैं और उम्र बढ़ने के साथ जीवन की बेहतर गुणवत्ता प्राप्त करते हैं।',
    'exp_2_3':
        "लत अक्सर 'सिर्फ एक बार' के भ्रामक विचार से शुरू होती है। हालांकि, तंबाकू जैसे हानिकारक पदार्थों में शक्तिशाली विषाक्त पदार्थ होते हैं जो पहले उपयोग से ही आपके शरीर पर कोशिकीय क्षति पहुंचाना शुरू कर देते हैं।",
    'exp_2_4':
        'जो एक बार की कोशिश से शुरू होता है, वह अक्सर लत के कारण निरंतर, आदतन उपयोग की ओर ले जाता है। इससे फेफड़ों के ऊतकों को गंभीर, संचयी क्षति होती है, जिससे पुरानी श्वसन बीमारियों का खतरा काफी बढ़ जाता है और जीवन प्रत्याशा कम हो जाती है।',
  },
};

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          "To visually demonstrate how different food choices directly impact an adolescent's energy levels, bone strength, and blood health.",
      steps: [
        LabStep(
          concept: 'Balanced Diet Selection',
          action:
              "Identify the healthy items—Milk, Spinach, and Kidney Beans—on the conveyor belt. Drag and drop them onto the avatar's plate to construct a balanced meal.",
          observation:
              'The items are successfully placed on the plate. Notice the health meters above the avatar are currently at a low 20% baseline.',
        ),
        LabStep(
          concept: 'Impact of Nutrition',
          action:
              "Click the blue 'EAT MEAL' button to simulate the avatar consuming the balanced diet you prepared.",
          observation:
              "The avatar's posture straightens, and they look highly energetic. The 'Bone Strength' and 'Blood Health' meters fill up significantly, while the 'Energy' meter reaches a full 100%.",
        ),
        LabStep(
          concept: 'Junk Food Selection',
          action:
              'The scene has reset. Now, locate the junk food items—Burger, Fries, and Soda—and drag them from the conveyor belt onto the plate to create an unbalanced meal.',
          observation:
              'The junk food items are placed on the plate. The health meters are reset to their low baseline state of 20%.',
        ),
        LabStep(
          concept: 'Consequences of Junk Food',
          action: "Click the 'EAT MEAL' button again to see the effects of consuming the junk food meal.",
          observation:
              "The 'Energy' meter briefly spikes to 100% but quickly crashes down. An 'Iron Deficiency' warning flashes, and the avatar slumps forward, looking visibly exhausted and sluggish.",
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To visualize the long-term consequences of choosing to try or refuse harmful substances, focusing on lung health.',
      steps: [
        LabStep(
          concept: 'Refusing Peer Pressure',
          action:
              "Observe the peer offering a cigarette. Click the green 'SAY NO' button to make a healthy, responsible choice.",
          observation:
              'The peer leaves the scene. The avatar successfully resists the negative peer pressure, and the internal lungs remain completely unaffected.',
        ),
        LabStep(
          concept: 'Long-term Health',
          action: "Click and drag the timeline slider at the bottom from 'Age 15' all the way up to 'Age 40'.",
          observation:
              "As the years pass on the timeline, the lungs remain completely bright pink and healthy. A 'Healthy Lungs' badge appears to confirm their optimal condition.",
        ),
        LabStep(
          concept: 'The First Step to Addiction',
          action:
              "The simulation has reset. This time, when the peer offers the cigarette, click the red 'TRY ONCE' button.",
          observation:
              'The avatar takes a puff, and a small cloud of smoke appears. Immediately, a tiny, dark grey spot forms on the previously healthy pink lungs.',
        ),
        LabStep(
          concept: 'Progressive Damage',
          action:
              "Drag the timeline slider from 'Age 15' to 'Age 40' once more to observe the long-term consequences of that single initial choice.",
          observation:
              "As age increases, the lungs rapidly darken into a sickly grey-black color. The dark patches multiply, grow, and merge, accompanied by harsh coughing sounds. A 'Lungs Damaged' warning flashes.",
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'यह प्रदर्शित करना कि भोजन के विभिन्न विकल्प किशोरों की ऊर्जा, हड्डियों की मजबूती और रक्त स्वास्थ्य को कैसे प्रभावित करते हैं।',
      steps: [
        LabStep(
          concept: 'संतुलित आहार का चयन',
          action:
              'कन्वेयर बेल्ट पर रखे स्वस्थ खाद्य पदार्थों—दूध, पालक, और राजमा—को पहचानें। संतुलित भोजन बनाने के लिए उन्हें खींचकर अवतार की थाली में रखें (ड्रैग एंड ड्रॉप)।',
          observation:
              'सामान सफलतापूर्वक थाली में रख दिए जाते हैं। ध्यान दें कि अवतार के ऊपर स्वास्थ्य मीटर अभी 20% के निचले स्तर पर हैं।',
        ),
        LabStep(
          concept: 'पोषण का प्रभाव',
          action:
              "आपके द्वारा तैयार किए गए संतुलित आहार को खाने का अनुकरण करने के लिए नीले 'भोजन करें' बटन पर क्लिक करें।",
          observation:
              "अवतार की मुद्रा सीधी हो जाती है और वे अत्यधिक ऊर्जावान दिखते हैं। 'हड्डी की मजबूती' और 'रक्त स्वास्थ्य' मीटर काफी भर जाते हैं, जबकि 'ऊर्जा' मीटर 100% तक पहुंच जाता है।",
        ),
        LabStep(
          concept: 'जंक फूड का चयन',
          action:
              'दृश्य रीसेट हो गया है। अब, जंक फूड आइटम—बर्गर, फ्राइज़, और सोडा—का पता लगाएं और असंतुलित भोजन बनाने के लिए उन्हें कन्वेयर बेल्ट से थाली में खींचें।',
          observation:
              'जंक फूड आइटम थाली में रखे गए हैं। स्वास्थ्य मीटर अपने 20% के निचले आधारभूत स्तर पर रीसेट हो गए हैं।',
        ),
        LabStep(
          concept: 'जंक फूड के परिणाम',
          action: "जंक फूड खाने के प्रभाव को देखने के लिए फिर से 'भोजन करें' बटन पर क्लिक करें।",
          observation:
              "'ऊर्जा' मीटर कुछ समय के लिए 100% तक बढ़ जाता है, लेकिन जल्दी ही नीचे गिर जाता है। 'आयरन की कमी' की चेतावनी दिखाई देती है, और अवतार आगे की ओर झुक जाता है, स्पष्ट रूप से थका हुआ और सुस्त दिखता है।",
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'हानिकारक पदार्थों को आजमाने या मना करने के दीर्घकालिक परिणामों की कल्पना करना, विशेष रूप से फेफड़ों के स्वास्थ्य पर ध्यान केंद्रित करना।',
      steps: [
        LabStep(
          concept: 'दबाव से इंकार',
          action:
              "सिगरेट पेश करने वाले सहपाठी को देखें। एक स्वस्थ, जिम्मेदार विकल्प चुनने के लिए हरे 'ना कहें' बटन पर क्लिक करें।",
          observation:
              'सहपाठी दृश्य से चला जाता है। अवतार नकारात्मक साथियों के दबाव का सफलतापूर्वक विरोध करता है, और आंतरिक फेफड़े पूरी तरह से अप्रभावित रहते हैं।',
        ),
        LabStep(
          concept: 'दीर्घकालिक स्वास्थ्य',
          action: "नीचे दिए गए समयरेखा स्लाइडर को 'आयु 15' से 'आयु 40' तक खींचें।",
          observation:
              "जैसे-जैसे समयरेखा पर वर्ष बीतते हैं, फेफड़े पूरी तरह से चमकीले गुलाबी और स्वस्थ रहते हैं। एक 'स्वस्थ फेफड़े' बैज उनकी इष्टतम स्थिति की पुष्टि करता है।",
        ),
        LabStep(
          concept: 'लत की ओर पहला कदम',
          action:
              "सिमुलेशन रीसेट हो गया है। इस बार, जब सहपाठी सिगरेट पेश करे, तो लाल 'एक बार कोशिश करें' बटन पर क्लिक करें।",
          observation:
              'अवतार कश लेता है, और धुएं का एक छोटा बादल दिखाई देता है। तुरंत, पहले से स्वस्थ गुलाबी फेफड़ों पर एक छोटा, गहरा भूरा धब्बा बन जाता है।',
        ),
        LabStep(
          concept: 'प्रगतिशील क्षति',
          action:
              "उस एक प्रारंभिक विकल्प के दीर्घकालिक परिणामों का निरीक्षण करने के लिए समयरेखा स्लाइडर को एक बार फिर 'आयु 15' से 'आयु 40' तक खींचें।",
          observation:
              "उम्र बढ़ने के साथ, फेफड़े तेजी से गहरे भूरे-काले रंग में बदल जाते हैं। काले धब्बे बढ़ते हैं और मिल जाते हैं, साथ में खांसने की तेज आवाजें आती हैं। 'फेफड़े क्षतिग्रस्त' चेतावनी दिखाई देती है।",
        ),
      ],
    ),
  ],
};

// ============================================================== STATE

const Size _design = Size(1000, 560);

/// Stand-in for the Three.js perspective camera at (0, eyeY, eyeZ) looking at
/// (0, targetY, 0): projects world points to design pixels (and back onto a
/// horizontal plane for dragging).
class _Cam {
  _Cam({
    required double eyeY,
    required double eyeZ,
    required double targetY,
    required this.f,
    required this.cx,
    required this.cy,
  })  : _ey = eyeY,
        _ez = eyeZ,
        _fy = (targetY - eyeY) / math.sqrt((targetY - eyeY) * (targetY - eyeY) + eyeZ * eyeZ),
        _fz = -eyeZ / math.sqrt((targetY - eyeY) * (targetY - eyeY) + eyeZ * eyeZ);

  final double _ey, _ez, _fy, _fz;

  /// Focal length and principal point in design pixels.
  final double f, cx, cy;

  /// Design position of a world point and the pixels per world unit there.
  ({Offset p, double k}) project(double x, double y, double z) {
    final dy = y - _ey, dz = z - _ez;
    final yc = dy * -_fz + dz * _fy;
    final zc = dy * _fy + dz * _fz;
    final k = f / zc;
    return (p: Offset(cx + x * k, cy - yc * k), k: k);
  }

  Offset point(double x, double y, double z) => project(x, y, z).p;

  /// World (x, z) where the view ray through design point [s] meets the
  /// horizontal plane y = [h] (the HTML drag plane), or null above the horizon.
  Offset? onPlane(Offset s, double h) {
    final u = (s.dx - cx) / f, v = (cy - s.dy) / f;
    final dy = v * -_fz + _fy;
    final dz = v * _fy + _fz;
    if (dy > -1e-4) return null;
    final t = (h - _ey) / dy;
    if (t <= 0) return null;
    return Offset(u * t, _ez + dz * t);
  }
}

/// Scenario 1 camera: the HTML camera (0, 3, 10) raised a little so the table
/// top, belt and plate read clearly in 2D. Scenario 2: the HTML camera.
final _Cam _cam1 = _Cam(eyeY: 4.2, eyeZ: 10, targetY: 1.4, f: 900, cx: 560, cy: 330);
final _Cam _cam2 = _Cam(eyeY: 3, eyeZ: 10, targetY: 1.5, f: 1100, cx: 434, cy: 315);

/// Conveyor belt centre x (HTML -3.5, nudged clear of the table edge).
const double _beltX = -3.7;
const double _beltTop = 1.65;
const Offset _plateXZ = Offset(0, 0.3);

/// Where the three dropped items settle on the plate (x, z offsets).
const List<Offset> _plateSlots = [Offset(-0.36, -0.08), Offset(0.36, -0.08), Offset(0, 0.3)];

enum _Food {
  milk('food_milk', 1.0),
  spinach('food_spinach', 0.62),
  beans('food_beans', 0.36),
  burger('food_burger', 0.54),
  fries('food_fries', 0.74),
  soda('food_soda', 0.64);

  const _Food(this.key, this.height);

  /// String key of the food's name.
  final String key;

  /// Height of the item in world units (for icons).
  final double height;

  bool get isJunk => index >= 3;
}

/// One draggable food item (HTML `createFood()` group).
class _FoodItem {
  _FoodItem(this.kind, this.home) : pos = home;

  final _Food kind;

  /// World (x, z) on the conveyor belt.
  final Offset home;
  Offset pos;
  bool visible = true;
  bool onPlate = false;

  Offset _from = Offset.zero, _to = Offset.zero;
  double _start = -1, _dur = 0.2;

  /// Slides to [to] over [dur] s (TWEEN Quadratic.Out).
  void slideTo(double now, Offset to, double dur) {
    _from = pos;
    _to = to;
    _start = now;
    _dur = dur;
  }

  void stop() => _start = -1;

  void update(double now) {
    if (_start < 0) return;
    final x = ((now - _start) / _dur).clamp(0.0, 1.0);
    pos = Offset.lerp(_from, _to, Curves.easeOutQuad.transform(x))!;
    if (x >= 1) _start = -1;
  }

  void reset({required bool show}) {
    pos = home;
    _start = -1;
    onPlate = false;
    visible = show;
  }
}

/// A dark tar spot on the lungs (HTML `Objects.s2.spots`), in lung-group
/// coordinates, with the age threshold where it starts to grow.
class _Spot {
  const _Spot(this.at, this.threshold, this.base);
  final Offset at;
  final double threshold;
  final double base;
}

/// A value tween driven by scene time (TWEEN.js stand-in).
class _Anim {
  double _from = 0, _to = 0, _start = -1, _dur = 1;

  void to(double now, double target, double dur) {
    _from = value(now);
    _to = target;
    _start = now;
    _dur = dur;
  }

  void jump(double v) {
    _from = _to = v;
    _start = -1;
  }

  double value(double now) {
    if (_start < 0) return _to;
    final x = ((now - _start) / _dur).clamp(0.0, 1.0);
    return _from + (_to - _from) * x;
  }
}

/// Mutable scene model read by the painters every frame.
class _Scene {
  _Scene()
      : foods = [
          for (var i = 0; i < 6; i++)
            _FoodItem(_Food.values[i], Offset(_beltX + (i % 3 - 1) * 1.0, -1)),
        ],
        spots = _makeSpots();

  int scenario = 0;
  int step = 1;
  double time = 0;

  // ---- Scenario 1: the meal planner.
  final List<_FoodItem> foods;
  int plated = 0;
  int? dragging;
  bool plateHot = false;
  bool junk = false;
  bool showEat = false;
  bool eating = false;
  double eatStart = -10;
  double energy = 20, bone = 20, blood = 20;
  bool ironWarning = false;
  final _Anim lean = _Anim();
  int mood = 0;
  bool energized = false;
  bool reviewReady = false;

  // ---- Scenario 2: the timeline of choice.
  String? choice;
  bool choicesVisible = true;
  bool timelineVisible = false;
  double age = 15;
  bool badge = false;
  bool peerVisible = true;
  double peerLeaveStart = -1;
  bool spot0 = false;
  double smokeStart = -1;
  double coughAt = -10;
  bool coughedThisSweep = false;
  bool quoteVisible = false;
  bool pendingAdvance = false;
  int mainMood = 0;
  final List<_Spot> spots;

  /// Confetti burst start (Review Findings).
  double confettiAt = -10;

  double get progress => (age - 15) / 25;

  void setMeters(double e, double b, double bl) {
    energy = e;
    bone = b;
    blood = bl;
  }

  static List<_Spot> _makeSpots() {
    final r = math.Random(11);
    return List.generate(40, (_) {
      final left = r.nextDouble() > 0.5;
      double dx, dy;
      do {
        dx = (r.nextDouble() - 0.5) * 0.55;
        dy = (r.nextDouble() - 0.5) * 0.9;
      } while (dx * dx / (0.27 * 0.27) + dy * dy / (0.45 * 0.45) > 1);
      return _Spot(Offset((left ? -0.42 : 0.42) + dx, 0.25 + dy), r.nextDouble() * 0.8 + 0.1, r.nextDouble() * 0.5 + 0.4);
    });
  }
}

/// Pan recogniser that only claims pointers that land on a food item, so the
/// canvas can still pan / zoom elsewhere when the camera is unlocked.
class _FoodPanRecognizer extends PanGestureRecognizer {
  _FoodPanRecognizer() : super(debugOwner: null);

  bool Function(Offset local) accepts = _never;

  static bool _never(Offset _) => false;

  @override
  bool isPointerAllowed(PointerEvent event) => accepts(event.localPosition) && super.isPointerAllowed(event);
}

class _Ch6A5HolisticWellBeingAndResponsibleChoicesPageState
    extends State<Ch6A5HolisticWellBeingAndResponsibleChoicesPage> with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final math.Random _rng = math.Random();

  late final Ticker _ticker;
  Offset _grabOffset = Offset.zero;

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
      _scene.time = elapsed.inMicroseconds / 1e6;
      for (final f in _scene.foods) {
        f.update(_scene.time);
      }
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

  /// HTML `resetScenarioState()`: step 1, meters at 20 %, healthy food on the
  /// belt, peer back with the cigarette, lungs pink, timeline hidden.
  void _resetScenario() {
    _lab.cancelPending();
    final sc = _scene
      ..step = 1
      ..dragging = null
      ..plateHot = false
      // Scenario 1.
      ..junk = false
      ..plated = 0
      ..showEat = false
      ..eating = false
      ..eatStart = -10
      ..ironWarning = false
      ..mood = 0
      ..energized = false
      ..reviewReady = false
      // Scenario 2.
      ..choice = null
      ..choicesVisible = true
      ..timelineVisible = false
      ..age = 15
      ..badge = false
      ..peerVisible = true
      ..peerLeaveStart = -1
      ..spot0 = false
      ..smokeStart = -1
      ..coughAt = -10
      ..coughedThisSweep = false
      ..quoteVisible = false
      ..pendingAdvance = false
      ..mainMood = 0
      ..confettiAt = -10;
    sc.setMeters(20, 20, 20);
    sc.lean.jump(0);
    for (final f in sc.foods) {
      f.reset(show: !f.kind.isJunk);
    }
    _lab.resetView(sound: false);
  }

  void _changeScenario(int index) {
    setState(() {
      _scene.scenario = index;
      _lab.hidePopup(sound: false);
      _resetScenario();
    });
  }

  void _fullReset() {
    setState(() {
      _scene.scenario = 0;
      _resetScenario();
    });
  }

  // ---- Scenario 1: drag and drop onto the plate.

  bool get _canDrag =>
      _lab.isLabActive &&
      _scene.scenario == 0 &&
      (_scene.step == 1 || _scene.step == 3) &&
      !_scene.eating;

  /// Index of the belt item under [local] (design px), front-most first.
  int? _hitFood(Offset local) {
    if (!_canDrag) return null;
    for (var i = _scene.foods.length - 1; i >= 0; i--) {
      final f = _scene.foods[i];
      if (!f.visible || f.onPlate || f.kind.isJunk != _scene.junk) continue;
      final pr = _cam1.project(f.pos.dx, _beltTop, f.pos.dy);
      final half = math.max(0.45 * pr.k, 30.0);
      final box = Rect.fromCenter(
        center: pr.p.translate(0, -0.4 * pr.k),
        width: half * 2,
        height: half * 2 + 0.25 * pr.k,
      );
      if (box.contains(local)) return i;
    }
    return null;
  }

  void _grab(Offset local) {
    final i = _hitFood(local);
    if (i == null) return;
    final f = _scene.foods[i]..stop();
    final w = _cam1.onPlane(local, _beltTop);
    _grabOffset = w == null ? Offset.zero : w - f.pos;
    _Audio.play(_Sound.pickup);
    setState(() => _scene.dragging = i);
  }

  void _dragTo(Offset local) {
    final i = _scene.dragging;
    if (i == null) return;
    final w = _cam1.onPlane(local, _beltTop);
    if (w == null) return;
    final p = w - _grabOffset;
    final f = _scene.foods[i]..pos = Offset(p.dx.clamp(-8.0, 7.0), p.dy.clamp(-4.0, 3.5));
    final hot = (f.pos - _plateXZ).distance < 1.0;
    if (hot != _scene.plateHot) setState(() => _scene.plateHot = hot);
  }

  /// HTML `handleUp`: within 1 unit of the plate the item settles on it;
  /// otherwise it slides back to the belt with the error tone.
  void _release() {
    final i = _scene.dragging;
    if (i == null) return;
    final sc = _scene;
    final f = sc.foods[i];
    setState(() {
      sc.dragging = null;
      sc.plateHot = false;
      if ((f.pos - _plateXZ).distance < 1.0) {
        _Audio.play(_Sound.correct);
        final jitter = Offset((_rng.nextDouble() - 0.5) * 0.08, (_rng.nextDouble() - 0.5) * 0.08);
        f
          ..onPlate = true
          ..slideTo(sc.time, _plateXZ + _plateSlots[sc.plated % 3] + jitter, 0.2);
        sc.plated++;
        if (sc.plated == 3) {
          sc.showEat = true;
          sc.step++;
        }
      } else {
        f.slideTo(sc.time, f.home, 0.3);
        _lab.showToast(_t('toast_drop_plate'), isError: true);
      }
    });
  }

  /// HTML `eatMeal()`: the plate empties, the head nods while eating and
  /// after 0.8 s the meters respond to the kind of meal.
  void _eatMeal() {
    final sc = _scene;
    if (!sc.showEat) return;
    setState(() {
      sc
        ..showEat = false
        ..eating = true
        ..eatStart = sc.time;
    });
    _lab.after(const Duration(milliseconds: 300), () {
      setState(() {
        for (final f in sc.foods) {
          if (f.onPlate) f.visible = false;
        }
      });
    });
    _lab.after(const Duration(milliseconds: 800), () {
      if (!sc.junk) {
        _Audio.play(_Sound.correct);
        setState(() {
          sc
            ..setMeters(100, 95, 100)
            ..mood = 1
            ..energized = true;
          sc.lean.to(sc.time, -0.1, 0.5);
        });
        _lab.after(const Duration(milliseconds: 3000), () {
          setState(() {
            sc.step++;
            _resetToJunkFood();
          });
        });
      } else {
        _Audio.play(_Sound.wrong);
        setState(() {
          sc
            ..setMeters(100, 20, 20)
            ..mood = 1;
        });
        _lab.after(const Duration(milliseconds: 1500), () {
          setState(() {
            sc
              ..setMeters(30, 20, 20)
              ..ironWarning = true
              ..mood = -1;
            sc.lean.to(sc.time, 0.3, 0.5);
          });
        });
        _lab.after(const Duration(milliseconds: 3000), () {
          _Audio.play(_Sound.correct);
          setState(() {
            sc
              ..eating = false
              ..reviewReady = true;
          });
        });
      }
    });
  }

  /// HTML `resetToJunkFood()`.
  void _resetToJunkFood() {
    final sc = _scene
      ..junk = true
      ..plated = 0
      ..eating = false
      ..mood = 0
      ..energized = false;
    sc.setMeters(20, 20, 20);
    sc.lean.jump(0);
    for (final f in sc.foods) {
      f.reset(show: f.kind.isJunk);
    }
  }

  // ---- Scenario 2: the choice and the timeline.

  /// HTML `makeChoice()`. The step asks for one of the two buttons; the other
  /// one explains what to do instead (the HTML would get stuck there).
  void _makeChoice(String choice) {
    final sc = _scene;
    if (!sc.choicesVisible) return;
    final expected = sc.step == 1 ? 'no' : 'yes';
    if (choice != expected) {
      _lab.showToast(_t(choice == 'yes' ? 'toast_say_no_first' : 'toast_try_once_now'), isError: true);
      return;
    }
    _Sound.click.play();
    setState(() {
      sc
        ..choicesVisible = false
        ..choice = choice
        ..coughedThisSweep = false;
      if (choice == 'no') {
        sc
          ..peerLeaveStart = sc.time
          ..mainMood = 1
          ..timelineVisible = true
          ..step += 1;
      } else {
        sc
          ..smokeStart = sc.time
          ..mainMood = 0
          ..quoteVisible = true
          ..spot0 = true;
      }
    });
    if (choice == 'no') {
      _lab.after(const Duration(milliseconds: 1000), () => setState(() => sc.peerVisible = false));
    } else {
      _lab.after(const Duration(milliseconds: 3000), () => setState(() => sc.quoteVisible = false));
      _lab.after(const Duration(milliseconds: 1500), () {
        setState(() {
          sc
            ..timelineVisible = true
            ..step += 1;
        });
      });
    }
  }

  /// HTML `updateTimeline()`.
  void _setAge(double value) {
    final sc = _scene;
    final age = value.roundToDouble();
    if (age == sc.age) return;
    setState(() {
      sc.age = age;
      final p = sc.progress;
      if (p > 0.8) sc.badge = true;
      if (sc.choice == 'yes' && p > 0.3) {
        // Random cough (HTML 5 % per step), and at least one per sweep.
        final forced = !sc.coughedThisSweep && p >= 0.5;
        if (forced || _rng.nextDouble() < 0.05) {
          _Audio.play(_Sound.buzz);
          sc
            ..coughAt = sc.time
            ..coughedThisSweep = true;
        }
      }
    });
    if (sc.progress >= 1 && !sc.pendingAdvance) {
      if (sc.choice == 'no' && sc.step == 2) {
        sc.pendingAdvance = true;
        _lab.after(const Duration(milliseconds: 2000), () {
          setState(() {
            _resetForTryOnce();
            sc.step++;
          });
        });
      } else if (sc.choice == 'yes' && sc.step == 4) {
        sc.pendingAdvance = true;
        _lab.after(const Duration(milliseconds: 1500), () {
          _Audio.play(_Sound.correct);
          setState(() => sc.reviewReady = true);
        });
      }
    }
  }

  /// HTML `resetS2ForTryOnce()`.
  void _resetForTryOnce() {
    _scene
      ..timelineVisible = false
      ..age = 15
      ..badge = false
      ..peerVisible = true
      ..peerLeaveStart = -1
      ..choicesVisible = true
      ..pendingAdvance = false
      ..mainMood = 0;
  }

  /// HTML `triggerConclusion()`: summary popup with the comparison visual
  /// and a confetti burst.
  void _reviewFindings() {
    final index = _scene.scenario;
    setState(() {
      _scene
        ..reviewReady = false
        ..confettiAt = _scene.time;
    });
    _lab.showScenarioConclusion(
      scenarioIndex: index,
      totalScenarios: 2,
      title: () => _t('success'),
      heading: () => _t('discovery_complete'),
      body: () => _t('summary_${index + 1}'),
      extra: () => index == 0 ? _mealSummary() : _addictionSummary(),
      delay: Duration.zero,
    );
  }

  List<LabAction> _actions() {
    final sc = _scene;
    if (sc.scenario == 0 && sc.showEat) {
      return [
        LabAction(
          label: _t('btn_eat'),
          icon: Icons.restaurant,
          color: _Colors.blue600,
          foreground: Colors.white,
          highlight: true,
          onTap: _eatMeal,
        ),
      ];
    }
    if (sc.scenario == 1 && sc.choicesVisible) {
      return [
        LabAction(
          label: _t('btn_say_no'),
          icon: Icons.thumb_up,
          color: _Colors.emerald,
          foreground: Colors.white,
          highlight: sc.step == 1,
          silent: true,
          onTap: () => _makeChoice('no'),
        ),
        LabAction(
          label: _t('btn_try_once'),
          icon: Icons.warning_amber_rounded,
          color: _Colors.red,
          foreground: Colors.white,
          highlight: sc.step == 3,
          silent: true,
          onTap: () => _makeChoice('yes'),
        ),
      ];
    }
    if (sc.reviewReady) {
      return [
        LabAction(
          label: _t('btn_conclude'),
          icon: Icons.check_circle,
          color: _Colors.indigo600,
          foreground: Colors.white,
          highlight: true,
          silent: true,
          onTap: _reviewFindings,
        ),
      ];
    }
    return const [];
  }

  // --------------------------------------------------------------- UI

  /// Scale of the stage on screen (BoxFit.contain in the canvas area).
  double _stageFit(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    var w = size.width;
    if (_lab.isSidebarOpen) {
      final lo = math.max(180.0, size.width * 0.2);
      final hi = math.max(lo, size.width * 0.5);
      w -= (size.width * _lab.sidebarFraction).clamp(lo, hi);
    }
    if (w <= 0 || size.height <= 0) return 1;
    return math.min(w / _design.width, size.height / _design.height);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final p = _Theme.of(_lab.isDark);
        final s = context.labScale;
        final sc = _scene;
        final data = _data;
        final inset = labOverlayInsets(context, _lab);
        final boost = (0.62 / _stageFit(context)).clamp(1.0, 1.6).toDouble();
        return LabShell(
          controller: _lab,
          icon: Icons.monitor_heart,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: sc.scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: sc.step,
          actions: _actions(),
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _insightCard(p, s),
          onReset: _fullReset,
          overlays: [
            if (sc.scenario == 0)
              Positioned(
                top: inset.top,
                left: inset.left,
                right: inset.right,
                child: Center(child: FittedBox(fit: BoxFit.scaleDown, child: _metersCard(p, s))),
              ),
            if (sc.scenario == 1 && sc.quoteVisible)
              Positioned(
                top: inset.top,
                left: inset.left,
                right: inset.right,
                child: Center(child: _quoteCard(s)),
              ),
            if (sc.scenario == 1 && sc.timelineVisible)
              Positioned(
                left: inset.left,
                right: inset.right,
                bottom: inset.bottom + (_lab.isSidebarOpen ? 60 * s : 0),
                child: Center(child: FittedBox(fit: BoxFit.scaleDown, child: _timelineCard(s))),
              ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _ConfettiPainter(scene: _scene, repaint: _frame)),
              ),
            ),
          ],
          stage: LabStage(
            designSize: _design,
            child: RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              gestures: {
                _FoodPanRecognizer: GestureRecognizerFactoryWithHandlers<_FoodPanRecognizer>(
                  _FoodPanRecognizer.new,
                  (r) => r
                    ..accepts = ((local) => _hitFood(local) != null)
                    ..dragStartBehavior = DragStartBehavior.down
                    ..gestureSettings = const DeviceGestureSettings(touchSlop: 4)
                    ..onStart = ((d) => _grab(d.localPosition))
                    ..onUpdate = ((d) => _dragTo(d.localPosition))
                    ..onEnd = ((_) => _release())
                    ..onCancel = _release,
                ),
              },
              child: CustomPaint(
                size: _design,
                painter: _ScenePainter(
                  scene: _scene,
                  repaint: _frame,
                  isDark: _lab.isDark,
                  showLabels: _lab.showLabels,
                  boost: boost,
                  labels: {
                    for (final k in const [
                      'lbl_student',
                      'lbl_meal',
                      'lbl_lungs',
                      'lbl_cough',
                      'food_milk',
                      'food_spinach',
                      'food_beans',
                      'food_burger',
                      'food_fries',
                      'food_soda',
                    ])
                      k: _t(k),
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Sidebar card with the current step's result and explanation (the
  /// expanded step of the HTML teacher board).
  Widget _insightCard(LabPalette p, double s) {
    final f = s * _lab.fontScale;
    final steps = _data.steps;
    final i = (_scene.step - 1).clamp(0, steps.length - 1);
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
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${_t('observation')}: ',
                  style: TextStyle(color: p.textStrong, fontWeight: FontWeight.w800),
                ),
                TextSpan(text: steps[i].observation),
              ],
            ),
            style: TextStyle(color: p.text, fontSize: 12 * f, height: 1.45, fontWeight: FontWeight.w500),
          ),
          Divider(color: p.cardBorder, height: 16 * s),
          Text(
            _t('explanation').toUpperCase(),
            style: TextStyle(
              color: p.accent,
              fontSize: 9.5 * f,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 4 * s),
          Text(
            _t('exp_${_scene.scenario + 1}_${i + 1}'),
            style: TextStyle(
              color: p.textMuted,
              fontSize: 11.5 * f,
              height: 1.45,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// HTML `#s1-meters-container`: Energy, Bone Strength and Blood Health
  /// bars (animated over 1 s) with the bouncing iron-deficiency warning.
  Widget _metersCard(LabPalette p, double s) {
    final sc = _scene;
    final dark = _lab.isDark;
    return Container(
      padding: EdgeInsets.fromLTRB(12 * s, 8 * s, 12 * s, 8 * s),
      decoration: BoxDecoration(
        color: (dark ? _Colors.slate900 : Colors.white).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: dark ? _Colors.slate700 : _Colors.slate300),
        boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 18, offset: Offset(0, 6))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _meter(p, s, _t('lbl_energy'), sc.energy, _Colors.blue, _Colors.blue),
          SizedBox(width: 14 * s),
          _meter(p, s, _t('lbl_bone'), sc.bone, _Colors.slate400, _Colors.slate500),
          SizedBox(width: 14 * s),
          Stack(
            clipBehavior: Clip.none,
            children: [
              _meter(p, s, _t('lbl_blood'), sc.blood, _Colors.red, _Colors.red),
              if (sc.ironWarning)
                Positioned(
                  right: -30 * s,
                  top: 26 * s,
                  child: _ironWarning(s),
                ),
            ],
          ),
          if (sc.ironWarning) SizedBox(width: 22 * s),
        ],
      ),
    );
  }

  Widget _meter(LabPalette p, double s, String label, double value, Color fill, Color valueColor) {
    final barH = 54 * s;
    return SizedBox(
      width: 50 * s,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: value),
        duration: const Duration(milliseconds: 1000),
        curve: const Cubic(0.4, 0, 0.2, 1),
        builder: (context, v, _) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${v.round()}%',
              style: TextStyle(color: valueColor, fontSize: 11 * s, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 2 * s),
            Container(
              width: 32 * s,
              height: barH,
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: const Color(0x4DC8C8C8),
                borderRadius: BorderRadius.circular(8 * s),
                border: Border.all(color: _Colors.blue.withValues(alpha: 0.5)),
              ),
              alignment: Alignment.bottomCenter,
              child: Container(
                height: (barH - 4) * (v / 100).clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6 * s),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [labShade(fill, 0.2), fill, labShade(fill, -0.2)],
                  ),
                ),
              ),
            ),
            SizedBox(height: 4 * s),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(color: p.text, fontSize: 9.5 * s, fontWeight: FontWeight.w700, height: 1.1),
            ),
          ],
        ),
      ),
    );
  }

  /// The HTML `#iron-warning` drop with "Deficiency" (animate-bounce).
  Widget _ironWarning(double s) {
    return Tooltip(
      message: _t('lbl_iron_deficiency'),
      child: ValueListenableBuilder<double>(
        valueListenable: _frame,
        builder: (context, t, child) {
          final ph = t % 1.0;
          final dy = -6 * s * (1 - math.sin(ph * math.pi));
          return Transform.translate(offset: Offset(0, dy), child: child);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(size: Size.square(24 * s), painter: const _DropPainter()),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3 * s),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _t('lbl_deficiency'),
                style: TextStyle(color: _Colors.red, fontSize: 8 * s, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// HTML `#s2-quote` (shown for 3 s after TRY ONCE).
  Widget _quoteCard(double s) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 10 * (1 - v)), child: child),
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: 360 * s),
        padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 10 * s),
        decoration: BoxDecoration(
          color: _Colors.slate900.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16 * s),
          border: Border.all(color: _Colors.slate700),
          boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 20)],
        ),
        child: Text(
          '"${_t('txt_addiction_quote')}"',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _Colors.slate200,
            fontSize: 13 * s,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            height: 1.35,
          ),
        ),
      ),
    );
  }

  /// HTML `#s2-timeline-container`: age slider 15 → 40 with the lung status
  /// badge above its right corner.
  Widget _timelineCard(double s) {
    final sc = _scene;
    final dark = _lab.isDark;
    final damaged = sc.choice == 'yes';
    final ageColor = dark ? _Colors.blue400 : _Colors.blue600;
    final muted = TextStyle(
      color: dark ? _Colors.slate400 : _Colors.slate600,
      fontSize: 11 * s,
      fontWeight: FontWeight.w700,
    );
    return SizedBox(
      width: 300 * s,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AnimatedScale(
            scale: sc.badge ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            alignment: Alignment.bottomRight,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 5 * s),
              decoration: BoxDecoration(
                color: damaged ? _Colors.red100 : _Colors.emerald100,
                borderRadius: BorderRadius.circular(10 * s),
                border: Border.all(color: damaged ? _Colors.red400 : _Colors.emerald400),
                boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 2))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    damaged ? Icons.warning_rounded : Icons.verified,
                    size: 13 * s,
                    color: damaged ? _Colors.red700 : _Colors.emerald700,
                  ),
                  SizedBox(width: 4 * s),
                  Text(
                    _t(damaged ? 'lbl_damaged_lungs' : 'lbl_healthy_lungs'),
                    style: TextStyle(
                      color: damaged ? _Colors.red700 : _Colors.emerald700,
                      fontSize: 11 * s,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 6 * s),
          Container(
            padding: EdgeInsets.fromLTRB(12 * s, 8 * s, 12 * s, 8 * s),
            decoration: BoxDecoration(
              color: (dark ? _Colors.slate900 : Colors.white).withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(16 * s),
              border: Border.all(color: dark ? _Colors.slate700 : _Colors.slate300),
              boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 18, offset: Offset(0, 6))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_t('lbl_age')} 15', style: muted),
                    Text('${_t('lbl_age')} 40', style: muted),
                  ],
                ),
                SizedBox(
                  height: 30 * s,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 6 * s,
                      activeTrackColor: _Colors.blue,
                      inactiveTrackColor: dark ? _Colors.slate700 : _Colors.slate300,
                      trackShape: const RoundedRectSliderTrackShape(),
                      thumbShape: _RingThumbShape(radius: 11 * s, ring: _Colors.blue),
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 16 * s),
                      overlayColor: _Colors.blue.withValues(alpha: 0.18),
                      tickMarkShape: SliderTickMarkShape.noTickMark,
                      showValueIndicator: ShowValueIndicator.never,
                    ),
                    child: Slider(
                      value: sc.age,
                      min: 15,
                      max: 40,
                      divisions: 25,
                      onChanged: _setAge,
                    ),
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '${_t('lbl_current_age')} '),
                      TextSpan(text: sc.age.round().toString()),
                    ],
                  ),
                  style: TextStyle(color: ageColor, fontSize: 13 * s, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Scenario 1 summary visual: Balanced Diet vs Junk Food cards.
  Widget _mealSummary() {
    final p = _Theme.of(_lab.isDark);
    final s = context.labScale;
    Widget card(String title, String eq, Color border, Color titleColor, List<_Food> foods) {
      return Expanded(
        child: Container(
          padding: EdgeInsets.all(10 * s),
          decoration: BoxDecoration(
            color: p.isDark ? _Colors.slate800 : _Colors.slate100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: 2),
          ),
          child: Column(
            children: [
              Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(color: titleColor, fontWeight: FontWeight.w900, fontSize: 11.5 * s, letterSpacing: 0.5),
              ),
              SizedBox(height: 8 * s),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final f in foods)
                    Container(
                      width: 34 * s,
                      height: 34 * s,
                      margin: EdgeInsets.symmetric(horizontal: 3 * s),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7 * s),
                        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 1))],
                      ),
                      child: CustomPaint(painter: _FoodIconPainter(f)),
                    ),
                ],
              ),
              SizedBox(height: 8 * s),
              Text(
                eq,
                textAlign: TextAlign.center,
                style: TextStyle(color: p.text, fontWeight: FontWeight.w700, fontSize: 10.5 * s, height: 1.3),
              ),
            ],
          ),
        ),
      );
    }

    final allDone = _lab.completedScenarios.length >= 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            card(_t('sum_balanced'), _t('sum_balanced_eq'), _Colors.emerald, _Colors.emerald400,
                const [_Food.milk, _Food.spinach, _Food.beans]),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6 * s),
              child: Text(
                _t('sum_vs'),
                style: TextStyle(color: p.textMuted, fontWeight: FontWeight.w900, fontSize: 12 * s),
              ),
            ),
            card(_t('sum_junk'), _t('sum_junk_eq'), _Colors.red, _Colors.red400,
                const [_Food.burger, _Food.fries, _Food.soda]),
          ],
        ),
        if (!allDone) ...[
          SizedBox(height: 10 * s),
          Container(
            padding: EdgeInsets.all(10 * s),
            decoration: BoxDecoration(
              color: _Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _Colors.blue.withValues(alpha: 0.25)),
            ),
            child: Text(
              _t('select_next_sc_msg'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.isDark ? _Colors.blue400 : _Colors.blue600,
                fontWeight: FontWeight.w700,
                fontSize: 12 * s,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Scenario 2 summary visual: "The Path of Addiction" timeline.
  Widget _addictionSummary() {
    final p = _Theme.of(_lab.isDark);
    final s = context.labScale;
    final bg = p.isDark ? _Colors.slate800 : _Colors.slate100;
    Widget node(String text, String label, Color fill, Color fg, {Color? border, bool glow = false, Color? labelColor}) {
      return Container(
        color: bg,
        padding: EdgeInsets.symmetric(horizontal: 4 * s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28 * s,
              height: 28 * s,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: fill,
                shape: BoxShape.circle,
                border: border == null ? null : Border.all(color: border, width: 2),
                boxShadow: glow ? [BoxShadow(color: _Colors.red.withValues(alpha: 0.5), blurRadius: 10)] : null,
              ),
              child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w900, fontSize: 11 * s)),
            ),
            SizedBox(height: 4 * s),
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: labelColor ?? p.textMuted,
                fontSize: 9 * s,
                fontWeight: labelColor == null ? FontWeight.w600 : FontWeight.w900,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(12 * s),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.isDark ? _Colors.slate700 : _Colors.slate300),
      ),
      child: Column(
        children: [
          Text(
            _t('sum_path').toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.isDark ? _Colors.blue400 : _Colors.blue600,
              fontWeight: FontWeight.w900,
              fontSize: 12 * s,
              letterSpacing: 0.6,
            ),
          ),
          SizedBox(height: 10 * s),
          Stack(
            children: [
              Positioned(
                left: 30 * s,
                right: 30 * s,
                top: 13 * s,
                child: Container(height: 3 * s, color: p.isDark ? _Colors.slate700 : _Colors.slate300),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(child: node('15', _t('sum_try_once'), _Colors.red, Colors.white, glow: true)),
                  Flexible(child: node('...', _t('sum_repeated'), _Colors.red800, Colors.white)),
                  Flexible(
                    child: node('40', _t('sum_severe'), _Colors.slate800, _Colors.red,
                        border: _Colors.red, labelColor: _Colors.red400),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10 * s),
          Text(
            '"${_t('txt_addiction_quote')}"',
            textAlign: TextAlign.center,
            style: TextStyle(color: p.textMuted, fontStyle: FontStyle.italic, fontSize: 11 * s, height: 1.35),
          ),
        ],
      ),
    );
  }
}

/// White ring thumb of the HTML `.timeline-slider` (white fill, 4 px blue
/// border, soft shadow).
class _RingThumbShape extends SliderComponentShape {
  const _RingThumbShape({required this.radius, required this.ring});

  final double radius;
  final Color ring;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.fromRadius(radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final r = radius * (1 + 0.2 * activationAnimation.value);
    canvas.drawCircle(
      center.translate(0, 2),
      r,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(center, r, Paint()..color = Colors.white);
    final w = r * 0.33;
    canvas.drawCircle(
      center,
      r - w / 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..color = ring,
    );
  }
}

// ============================================================ PAINTING

/// Room backdrop shared by both scenes: background colour, a soft pool of
/// light and the tiled 20 x 10 floor plane (extended sideways so the
/// letterbox area shows no edge).
void _paintRoom(Canvas canvas, Size size, _Cam cam, bool isDark) {
  final bleed = labBleed(size);
  final backY = cam.point(0, 0, -5).dy;
  canvas.drawRect(bleed, Paint()..color = isDark ? _Colors.slate900 : _Colors.sky100);
  canvas.drawRect(
    Rect.fromLTRB(bleed.left, bleed.top, bleed.right, backY),
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? const [Color(0xFF0B1120), Color(0xFF17233D)]
            : const [Color(0xFFF0F9FF), Color(0xFFD3EBFB)],
      ).createShader(Rect.fromLTRB(0, 0, size.width, backY)),
  );
  final glowC = Offset(size.width / 2, backY - 40);
  canvas.drawCircle(
    glowC,
    460,
    Paint()
      ..shader = RadialGradient(
        colors: [
          (isDark ? _Colors.blue : Colors.white).withValues(alpha: isDark ? 0.12 : 0.6),
          (isDark ? _Colors.blue : Colors.white).withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: glowC, radius: 460)),
  );
  final floor = Rect.fromLTRB(bleed.left, backY, bleed.right, bleed.bottom);
  canvas.drawRect(
    floor,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? const [Color(0xFF334155), Color(0xFF55657C)]
            : const [Color(0xFF94A3B8), Color(0xFFC6D0DC)],
      ).createShader(Rect.fromLTRB(0, backY, 0, size.height)),
  );
  canvas.save();
  canvas.clipRect(floor);
  final line = Paint()
    ..color = (isDark ? Colors.white : _Colors.slate600).withValues(alpha: isDark ? 0.06 : 0.12)
    ..strokeWidth = 1;
  for (var x = -40; x <= 40; x++) {
    canvas.drawLine(cam.point(x.toDouble(), 0, -5), cam.point(x.toDouble(), 0, 9), line);
  }
  for (var z = -5; z <= 9; z++) {
    canvas.drawLine(cam.point(-80, 0, z.toDouble()), cam.point(80, 0, z.toDouble()), line);
  }
  canvas.restore();
  canvas.drawRect(
    Rect.fromLTRB(bleed.left, backY, bleed.right, backY + 16),
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), Colors.transparent],
      ).createShader(Rect.fromLTRB(0, backY, 0, backY + 16)),
  );
}

/// Soft shadow of a rectangle (half sizes [hw] x [hd]) on the floor.
void _floorShadow(Canvas canvas, _Cam cam, double x, double z, double hw, double hd, double opacity) {
  final path = Path()
    ..addPolygon([
      cam.point(x - hw, 0, z - hd),
      cam.point(x + hw, 0, z - hd),
      cam.point(x + hw, 0, z + hd),
      cam.point(x - hw, 0, z + hd),
    ], true);
  final k = cam.project(x, 0, z).k;
  canvas.drawPath(
    path,
    Paint()
      ..color = Colors.black.withValues(alpha: opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 0.22 * k),
  );
}

/// Upright cylinder (table legs, stands) between heights [y0] and [y1].
void _vCylinder(Canvas canvas, _Cam cam, double x, double z, double y0, double y1, double r, Color color) {
  final b = cam.project(x, y0, z), t = cam.project(x, y1, z);
  final hb = r * b.k, ht = r * t.k;
  final path = Path()
    ..addPolygon([
      t.p.translate(-ht, 0),
      t.p.translate(ht, 0),
      b.p.translate(hb, 0),
      b.p.translate(-hb, 0),
    ], true);
  final rect = path.getBounds();
  canvas.drawPath(
    path,
    Paint()
      ..shader = LinearGradient(
        colors: [labShade(color, -0.35), labShade(color, 0.22), color, labShade(color, -0.45)],
        stops: const [0, 0.3, 0.6, 1],
      ).createShader(rect),
  );
  canvas.drawOval(
    Rect.fromCenter(center: b.p, width: hb * 2, height: hb * 0.6),
    Paint()..color = labShade(color, -0.35),
  );
}

/// Tapered capsule between [a] and [b] (arms, sleeves, bronchi).
void _limb(Canvas canvas, Offset a, Offset b, double w0, double w1, Color color) {
  final d = b - a;
  final len = d.distance;
  if (len < 0.01) {
    canvas.drawCircle(a, w0 / 2, Paint()..color = color);
    return;
  }
  final n = Offset(-d.dy, d.dx) / len;
  final mid = (a + b) / 2;
  final paint = Paint()
    ..shader = LinearGradient(
      colors: [labShade(color, 0.18), color, labShade(color, -0.32)],
      stops: const [0, 0.45, 1],
    ).createShader(Rect.fromPoints(mid + n * (w0 / 2), mid - n * (w0 / 2)));
  canvas.drawPath(
    Path()..addPolygon([a + n * (w0 / 2), b + n * (w1 / 2), b - n * (w1 / 2), a - n * (w0 / 2)], true),
    paint,
  );
  canvas.drawCircle(a, w0 / 2, paint);
  canvas.drawCircle(b, w1 / 2, paint);
}

/// Elbow position for a two-bone arm from shoulder [s] to hand [h] (lengths
/// [a], [b]); picks the lower of the two solutions (elbow pointing down).
Offset _elbow(Offset s, Offset h, double a, double b) {
  final v = h - s;
  final dist = v.distance.clamp(0.001, a + b - 1e-3);
  final dir = v / v.distance;
  final cosA = ((a * a + dist * dist - b * b) / (2 * a * dist)).clamp(-1.0, 1.0);
  final ang = math.acos(cosA);
  Offset rot(double t) => Offset(
        dir.dx * math.cos(t) - dir.dy * math.sin(t),
        dir.dx * math.sin(t) + dir.dy * math.cos(t),
      );
  final e1 = s + rot(ang) * a, e2 = s + rot(-ang) * a;
  // Local coordinates are y-up: the lower elbow has the smaller y.
  return e1.dy < e2.dy ? e1 : e2;
}

/// Cigarette from the filter end [a] to the lit end [b] (white paper, tan
/// filter, red tip as in the HTML meshes) with a glowing ember.
void _cigarette(Canvas canvas, Offset a, Offset b, double w, double ember) {
  final d = b - a;
  final len = d.distance;
  if (len < 1) return;
  final u = d / len;
  final n = Offset(-u.dy, u.dx) * (w / 2);
  Path seg(Offset p, Offset q) => Path()..addPolygon([p + n, q + n, q - n, p - n], true);
  canvas.drawPath(seg(a, b), Paint()..color = Colors.white);
  canvas.drawPath(seg(a, a + u * len * 0.28), Paint()..color = const Color(0xFFD9A066));
  canvas.drawPath(seg(b - u * w * 0.9, b), Paint()..color = _Colors.red);
  canvas.drawPath(
    seg(a, b),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = Colors.black.withValues(alpha: 0.25),
  );
  labGlow(canvas, b, w * (2 + 1.6 * ember), const Color(0xFFF97316), intensity: 0.55 + 0.45 * ember);
}

/// Faint smoke rising from a cigarette tip.
void _wisp(Canvas canvas, Offset tip, double u, double t) {
  for (var i = 0; i < 3; i++) {
    final ph = (t * 0.55 + i / 3) % 1.0;
    final c = tip + Offset(math.sin(ph * 7 + i) * 0.05 * u, -ph * 0.55 * u);
    canvas.drawCircle(
      c,
      (0.02 + ph * 0.06) * u,
      Paint()
        ..color = _Colors.smoke.withValues(alpha: 0.28 * (1 - ph))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 0.02 * u + 1),
    );
  }
}

/// Draws a food item standing on [base] (design px) with [k] px per world
/// unit: the Three.js `createFood()` meshes as 2.5D shapes.
void _paintFood(Canvas canvas, _Food kind, Offset base, double k) {
  Offset p(double x, double y) => Offset(base.dx + x * k, base.dy - y * k);
  switch (kind) {
    case _Food.milk:
      final front = Rect.fromPoints(p(-0.2, 0.8), p(0.2, 0));
      final depth = 0.16 * k;
      final d = Offset(math.cos(-0.6), math.sin(-0.6)) * depth;
      labBox3D(canvas, front, depth, _Colors.slate50);
      // Blue band with a milk drop.
      final band = Rect.fromLTRB(front.left, p(0, 0.52).dy, front.right, p(0, 0.3).dy);
      canvas.drawRect(band, Paint()..color = _Colors.blue);
      canvas.drawPath(
        Path()
          ..addPolygon([band.topRight, band.topRight + d, band.bottomRight + d, band.bottomRight], true),
        Paint()..color = labShade(_Colors.blue, -0.3),
      );
      final dc = band.center;
      final drop = Path()
        ..moveTo(dc.dx, dc.dy - 0.08 * k)
        ..quadraticBezierTo(dc.dx + 0.06 * k, dc.dy + 0.0, dc.dx + 0.045 * k, dc.dy + 0.045 * k)
        ..arcToPoint(Offset(dc.dx - 0.045 * k, dc.dy + 0.045 * k), radius: Radius.circular(0.05 * k))
        ..quadraticBezierTo(dc.dx - 0.06 * k, dc.dy, dc.dx, dc.dy - 0.08 * k)
        ..close();
      canvas.drawPath(drop, Paint()..color = Colors.white);
      // Gable top (the 4-sided cone).
      final apex = p(0, 1.0);
      canvas.drawPath(
        Path()..addPolygon([front.topRight, front.topRight + d, apex + d, apex], true),
        Paint()..color = labShade(_Colors.blue, -0.28),
      );
      canvas.drawPath(
        Path()..addPolygon([front.topLeft, apex, front.topRight], true),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [labShade(_Colors.blue, 0.2), _Colors.blue],
          ).createShader(Rect.fromPoints(front.topLeft, apex)),
      );
      canvas.drawLine(
        apex,
        apex + d,
        Paint()
          ..color = labShade(_Colors.blue, 0.35)
          ..strokeWidth = 0.035 * k
          ..strokeCap = StrokeCap.round,
      );
    case _Food.spinach:
      void leaf(double ang, double len, double w, Color c) {
        canvas.save();
        canvas.translate(p(0, 0.03).dx, p(0, 0.03).dy);
        canvas.rotate(ang);
        final path = Path()
          ..moveTo(0, 0)
          ..cubicTo(w * 0.9, -len * 0.25, w * 0.6, -len * 0.85, 0, -len)
          ..cubicTo(-w * 0.6, -len * 0.85, -w * 0.9, -len * 0.25, 0, 0)
          ..close();
        canvas.drawPath(
          path,
          Paint()
            ..shader = LinearGradient(
              colors: [labShade(c, 0.25), c, labShade(c, -0.3)],
            ).createShader(Rect.fromLTRB(-w, -len, w, 0)),
        );
        final rib = Paint()
          ..color = labShade(c, 0.45).withValues(alpha: 0.75)
          ..strokeWidth = 0.018 * k
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset.zero, Offset(0, -len * 0.88), rib);
        for (var i = 1; i <= 3; i++) {
          final y = -len * (0.25 + i * 0.17);
          canvas.drawLine(Offset(0, y), Offset(w * 0.4, y - len * 0.08), rib);
          canvas.drawLine(Offset(0, y), Offset(-w * 0.4, y - len * 0.08), rib);
        }
        canvas.restore();
      }
      leaf(0.05, 0.62 * k, 0.24 * k, _Colors.spinach3);
      leaf(0.55, 0.52 * k, 0.22 * k, _Colors.spinach1);
      leaf(-0.5, 0.56 * k, 0.24 * k, _Colors.spinach2);
    case _Food.beans:
      final rimC = p(0, 0.2);
      final rim = Rect.fromCenter(center: rimC, width: 0.62 * k, height: 0.16 * k);
      final bowl = Path()
        ..moveTo(rim.left, rimC.dy)
        ..arcTo(Rect.fromCenter(center: rimC, width: rim.width, height: 0.4 * k), math.pi, -math.pi, false)
        ..close();
      canvas.drawPath(
        bowl,
        Paint()
          ..shader = LinearGradient(
            colors: [labShade(_Colors.bowl, -0.2), _Colors.bowl, labShade(_Colors.bowl, -0.35)],
            stops: const [0, 0.4, 1],
          ).createShader(bowl.getBounds()),
      );
      canvas.drawOval(rim, Paint()..color = labShade(_Colors.bowl, -0.25));
      final heapPaint = Paint()..color = _Colors.beans;
      canvas.drawOval(Rect.fromCenter(center: rimC, width: rim.width * 0.9, height: rim.height * 0.8), heapPaint);
      canvas.drawArc(
        Rect.fromCenter(center: rimC.translate(0, 0.01 * k), width: rim.width * 0.9, height: 0.26 * k),
        math.pi,
        math.pi,
        true,
        heapPaint,
      );
      const beanSpots = [
        Offset(-0.17, 0.23), Offset(-0.06, 0.27), Offset(0.06, 0.26), Offset(0.17, 0.22), //
        Offset(-0.1, 0.19), Offset(0.02, 0.2), Offset(0.12, 0.18), Offset(-0.01, 0.3),
      ];
      for (var i = 0; i < beanSpots.length; i++) {
        final c = p(beanSpots[i].dx, beanSpots[i].dy);
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.rotate(i * 0.9);
        final r = Rect.fromCenter(center: Offset.zero, width: 0.1 * k, height: 0.06 * k);
        canvas.drawOval(r, Paint()..color = labShade(const Color(0xFF7F1D1D), i.isEven ? 0.05 : -0.1));
        canvas.drawOval(
          Rect.fromCenter(center: Offset(-0.015 * k, -0.012 * k), width: 0.04 * k, height: 0.018 * k),
          Paint()..color = Colors.white.withValues(alpha: 0.35),
        );
        canvas.restore();
      }
      canvas.drawArc(
        rim,
        0,
        math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.025 * k
          ..color = Colors.white.withValues(alpha: 0.9),
      );
    case _Food.burger:
      RRect layer(double y0, double y1, double hw, double r) =>
          RRect.fromRectAndRadius(Rect.fromPoints(p(-hw, y1), p(hw, y0)), Radius.circular(r * k));
      Paint shaded(Color c, Rect r) => Paint()
        ..shader = LinearGradient(
          colors: [labShade(c, 0.15), c, labShade(c, -0.3)],
          stops: const [0, 0.5, 1],
        ).createShader(r);
      final bottom = layer(0, 0.1, 0.3, 0.05);
      canvas.drawRRect(bottom, shaded(_Colors.bun, bottom.outerRect));
      final patty = layer(0.09, 0.2, 0.32, 0.05);
      canvas.drawRRect(patty, shaded(_Colors.patty, patty.outerRect));
      final cheese = Path()
        ..moveTo(p(-0.31, 0.23).dx, p(-0.31, 0.23).dy)
        ..lineTo(p(0.31, 0.23).dx, p(0.31, 0.23).dy)
        ..lineTo(p(0.31, 0.2).dx, p(0.31, 0.2).dy)
        ..lineTo(p(0.2, 0.2).dx, p(0.2, 0.2).dy)
        ..lineTo(p(0.14, 0.13).dx, p(0.14, 0.13).dy)
        ..lineTo(p(0.08, 0.2).dx, p(0.08, 0.2).dy)
        ..lineTo(p(-0.12, 0.2).dx, p(-0.12, 0.2).dy)
        ..lineTo(p(-0.18, 0.14).dx, p(-0.18, 0.14).dy)
        ..lineTo(p(-0.24, 0.2).dx, p(-0.24, 0.2).dy)
        ..lineTo(p(-0.31, 0.2).dx, p(-0.31, 0.2).dy)
        ..close();
      canvas.drawPath(cheese, Paint()..color = _Colors.cheese);
      final domeRect = Rect.fromCenter(center: p(0, 0.22), width: 0.62 * k, height: 0.6 * k);
      final dome = Path()
        ..moveTo(domeRect.left, domeRect.center.dy)
        ..arcTo(domeRect, math.pi, math.pi, false)
        ..close();
      canvas.drawPath(
        dome,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.35, -0.6),
            radius: 1.0,
            colors: [labShade(_Colors.bun, 0.35), _Colors.bun, labShade(_Colors.bun, -0.3)],
            stops: const [0, 0.5, 1],
          ).createShader(domeRect),
      );
      const seeds = [Offset(-0.14, 0.4), Offset(0.0, 0.46), Offset(0.13, 0.41), Offset(-0.06, 0.33), Offset(0.08, 0.34)];
      for (final sd in seeds) {
        canvas.drawOval(
          Rect.fromCenter(center: p(sd.dx, sd.dy), width: 0.045 * k, height: 0.028 * k),
          Paint()..color = const Color(0xFFFEF3C7),
        );
      }
    case _Food.fries:
      // Back wall of the carton.
      canvas.drawPath(
        Path()..addPolygon([p(-0.23, 0.5), p(0.23, 0.5), p(0.21, 0.58), p(-0.21, 0.58)], true),
        Paint()..color = labShade(_Colors.red, -0.35),
      );
      const sticks = [
        (-0.13, 0.7, -0.22), (-0.05, 0.76, -0.08), (0.03, 0.72, 0.04), (0.1, 0.74, 0.14), (0.16, 0.66, 0.26), //
      ];
      for (final (x, top, ang) in sticks) {
        canvas.save();
        final b0 = p(x, 0.3);
        canvas.translate(b0.dx, b0.dy);
        canvas.rotate(ang);
        final r = Rect.fromLTRB(-0.03 * k, -(top - 0.3) * k, 0.03 * k, 0);
        canvas.drawRect(
          r,
          Paint()
            ..shader = const LinearGradient(colors: [Color(0xFFFEF9C3), _Colors.fry, Color(0xFFEAB308)])
                .createShader(r),
        );
        canvas.restore();
      }
      final box = Path()
        ..moveTo(p(-0.18, 0).dx, p(-0.18, 0).dy)
        ..lineTo(p(0.18, 0).dx, p(0.18, 0).dy)
        ..lineTo(p(0.23, 0.5).dx, p(0.23, 0.5).dy)
        ..quadraticBezierTo(p(0, 0.38).dx, p(0, 0.38).dy, p(-0.23, 0.5).dx, p(-0.23, 0.5).dy)
        ..close();
      canvas.drawPath(
        box,
        Paint()
          ..shader = LinearGradient(
            colors: [labShade(_Colors.red, 0.15), _Colors.red, labShade(_Colors.red, -0.3)],
          ).createShader(box.getBounds()),
      );
      canvas.drawArc(
        Rect.fromCenter(center: p(0, 0.2), width: 0.16 * k, height: 0.12 * k),
        0.2,
        math.pi - 0.4,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.03 * k
          ..strokeCap = StrokeCap.round
          ..color = _Colors.cheese,
      );
    case _Food.soda:
      final body = Rect.fromPoints(p(-0.2, 0.6), p(0.2, 0));
      labCylinder(canvas, body, _Colors.red, tilt: 0.25);
      final wave = Path()..moveTo(body.left, p(0, 0.3).dy);
      for (var i = 0; i <= 12; i++) {
        final x = body.left + body.width * i / 12;
        wave.lineTo(x, p(0, 0.3).dy + math.sin(i / 12 * math.pi * 2) * 0.04 * k);
      }
      canvas.drawPath(
        wave,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.05 * k
          ..color = Colors.white.withValues(alpha: 0.9),
      );
      final top = Rect.fromCenter(center: body.topCenter, width: body.width * 0.86, height: body.width * 0.2);
      canvas.drawOval(top, Paint()..color = _Colors.slate300);
      canvas.drawOval(
        Rect.fromCenter(center: top.center.translate(0.04 * k, 0), width: 0.1 * k, height: 0.03 * k),
        Paint()..color = _Colors.slate500,
      );
      canvas.drawLine(
        p(-0.12, 0.55),
        p(-0.12, 0.05),
        Paint()
          ..strokeWidth = 0.035 * k
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: 0.35),
      );
  }
}

/// Small food icon for the summary cards.
class _FoodIconPainter extends CustomPainter {
  const _FoodIconPainter(this.kind);
  final _Food kind;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.height * 0.78 / kind.height;
    _paintFood(canvas, kind, Offset(size.width / 2, size.height * 0.9), math.min(k, size.width * 1.2));
  }

  @override
  bool shouldRepaint(covariant _FoodIconPainter old) => old.kind != kind;
}

/// The HTML iron-deficiency icon (red pin-shaped drop with a white bar).
class _DropPainter extends CustomPainter {
  const _DropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    canvas.scale(s);
    final path = Path()
      ..moveTo(12, 2)
      ..cubicTo(7.8, 2, 4, 6.3, 4, 11.2)
      ..cubicTo(4, 14.3, 5.2, 16.4, 7.5, 18.7)
      ..cubicTo(9.8, 21, 12, 23, 12, 23)
      ..cubicTo(12, 23, 14.2, 21, 16.5, 18.7)
      ..cubicTo(18.8, 16.4, 20, 14.3, 20, 11.2)
      ..cubicTo(20, 6.3, 16.2, 2, 12, 2)
      ..close();
    canvas.drawShadow(path, Colors.black, 2, false);
    canvas.drawPath(path, Paint()..color = _Colors.red);
    canvas.drawRect(const Rect.fromLTRB(8, 11, 16, 13), Paint()..color = _Colors.slate50);
  }

  @override
  bool shouldRepaint(covariant _DropPainter old) => false;
}

/// canvas-confetti burst (150 blue pieces from 30 % height, spread 70°).
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.scene, required Listenable repaint}) : super(repaint: repaint);

  final _Scene scene;

  static final List<(double, double, double, double, Color)> _bits = () {
    final r = math.Random(5);
    const colors = [_Colors.blue, _Colors.blue600, _Colors.blue400];
    return List.generate(150, (i) {
      final angle = (-90 + (r.nextDouble() - 0.5) * 70) * math.pi / 180;
      final speed = 45 * 0.5 + r.nextDouble() * 45;
      return (angle, speed, r.nextDouble() * 10, 5 + r.nextDouble() * 4, colors[i % 3]);
    });
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final t = scene.time - scene.confettiAt;
    if (t < 0 || t > 3.4) return;
    final n = t * 60; // animation ticks
    final scale = (size.shortestSide / 500).clamp(0.6, 1.5);
    final origin = Offset(size.width / 2, size.height * 0.3);
    final travel = (1 - math.pow(0.9, n).toDouble()) / 0.1;
    final alpha = (1 - n / 200).clamp(0.0, 1.0);
    for (final (angle, speed, wobble, w, color) in _bits) {
      final dist = speed * travel * scale;
      final c = origin +
          Offset(math.cos(angle) * dist + math.sin(wobble + n * 0.1) * 8 * scale,
              math.sin(angle) * dist + 3 * n * scale);
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(wobble + n * 0.12);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: w * scale, height: w * scale * (0.4 + 0.6 * math.cos(wobble + n * 0.2).abs())),
        Paint()..color = color.withValues(alpha: alpha),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => false;
}

/// Both scenes: the meal planner (table, conveyor belt, plate, student) and
/// the timeline of choice (student, peer, glass torso with lungs).
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.labels,
    required this.boost,
  }) : super(repaint: repaint);

  final _Scene scene;
  final bool isDark;
  final bool showLabels;
  final Map<String, String> labels;

  /// Canvas text scale so labels stay readable on small screens.
  final double boost;

  String _l(String key) => labels[key] ?? key;

  @override
  void paint(Canvas canvas, Size size) {
    if (scene.scenario == 0) {
      _paintMealScene(canvas, size);
    } else {
      _paintChoiceScene(canvas, size);
    }
  }

  // ------------------------------------------------------- scenario 1

  void _paintMealScene(Canvas canvas, Size size) {
    final cam = _cam1;
    final t = scene.time;
    _paintRoom(canvas, size, cam, isDark);
    _floorShadow(canvas, cam, -0.35, -0.3, 2.2, 1.45, 0.3);
    _floorShadow(canvas, cam, _beltX - 0.3, -1.3, 1.75, 0.75, 0.25);
    for (final x in const [-1.8, 1.8]) {
      _vCylinder(canvas, cam, x, -1, 0, 1.4, 0.1, _Colors.wood);
    }
    _paintConveyor(canvas, cam);
    for (var i = 0; i < scene.foods.length; i++) {
      final f = scene.foods[i];
      if (f.visible && !f.onPlate && scene.dragging != i) _paintFoodItem(canvas, f, t);
    }
    for (final x in const [-1.8, 1.8]) {
      _vCylinder(canvas, cam, x, 1, 0, 1.4, 0.1, _Colors.wood);
    }
    _paintTableTop(canvas, cam);
    _paintPlate(canvas, cam, t);
    final plated = [for (final f in scene.foods) if (f.visible && f.onPlate) f]
      ..sort((a, b) => a.pos.dy.compareTo(b.pos.dy));
    for (final f in plated) {
      _paintFoodItem(canvas, f, t);
    }

    // The student (HTML avatar, scale 1.2, turned -30° towards the table).
    final nodPhase = (t - scene.eatStart) / 0.2;
    var nod = 0.0;
    if (nodPhase >= 0 && nodPhase < 4) {
      final seg = nodPhase.floor();
      final frac = nodPhase - seg;
      nod = math.pi / 8 * (seg.isEven ? frac : 1 - frac);
    }
    _paintAvatar(
      canvas,
      cam,
      x: 3,
      z: 0,
      scale: 1.2,
      yaw: -math.pi / 6,
      shirt: _Colors.shirtBlue,
      lean: scene.lean.value(t),
      nod: nod,
      sway: math.sin(t * 2) * 0.05,
      mood: scene.mood,
      aura: scene.energized ? 1 : 0,
      t: t,
    );

    final d = scene.dragging;
    if (d != null) _paintFoodItem(canvas, scene.foods[d], t, lifted: true);

    if (showLabels) {
      final headTop = cam.point(3, 3.42, 0);
      _hotspot(canvas, Icons.person, _l('lbl_student'), headTop.translate(0, -6));
      final plateBack = cam.point(0, 1.65, -0.55);
      _hotspot(canvas, Icons.restaurant, _l('lbl_meal'), plateBack.translate(0, -4));
      for (var i = 0; i < scene.foods.length; i++) {
        final f = scene.foods[i];
        if (!f.visible || f.onPlate || scene.dragging == i) continue;
        final at = cam.point(f.pos.dx, 1.55, -0.4);
        labText(
          canvas,
          _l(f.kind.key),
          at.translate(0, 8),
          anchor: Alignment.topCenter,
          size: 11.5 * boost,
          weight: FontWeight.w700,
          color: isDark ? _Colors.slate100 : _Colors.slate800,
          background: isDark ? const Color(0xD90F172A) : const Color(0xE6FFFFFF),
          border: isDark ? _Colors.slate600 : _Colors.slate300,
          borderWidth: 1,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        );
      }
    }
  }

  void _paintConveyor(Canvas canvas, _Cam cam) {
    const x0 = _beltX - 1.6, x1 = _beltX + 1.6, z0 = -1.6, z1 = -0.4, yt = _beltTop, yb = 1.55;
    for (final z in const [-1.4, -0.6]) {
      for (final dx in const [-1.4, 1.4]) {
        _vCylinder(canvas, cam, _beltX + dx, z, 0, yb, 0.08, _Colors.stand);
      }
    }
    final side = Path()
      ..addPolygon([cam.point(x1, yt, z1), cam.point(x1, yt, z0), cam.point(x1, yb, z0), cam.point(x1, yb, z1)], true);
    canvas.drawPath(side, Paint()..color = labShade(_Colors.belt, 0.12));
    final top = Path()
      ..addPolygon([cam.point(x0, yt, z1), cam.point(x1, yt, z1), cam.point(x1, yt, z0), cam.point(x0, yt, z0)], true);
    canvas.drawPath(
      top,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A1A), Color(0xFF2E2E2E)],
        ).createShader(top.getBounds()),
    );
    final tread = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 1.2;
    for (var x = x0 + 0.2; x < x1 - 0.1; x += 0.2) {
      canvas.drawLine(cam.point(x, yt, z0), cam.point(x, yt, z1), tread);
    }
    final front = Path()
      ..addPolygon([cam.point(x0, yt, z1), cam.point(x1, yt, z1), cam.point(x1, yb, z1), cam.point(x0, yb, z1)], true);
    canvas.drawPath(front, Paint()..color = const Color(0xFF3A3F47));
    canvas.drawLine(
      cam.point(x0, yt, z1),
      cam.point(x1, yt, z1),
      Paint()
        ..color = _Colors.steel.withValues(alpha: 0.8)
        ..strokeWidth = 1.5,
    );
    for (final x in const [x0, x1]) {
      final back = cam.project(x, 1.6, -1.625), fr = cam.project(x, 1.6, -0.375);
      final w = 0.24 * (back.k + fr.k) / 2;
      canvas.drawLine(
        back.p,
        fr.p,
        Paint()
          ..strokeWidth = w
          ..strokeCap = StrokeCap.round
          ..color = labShade(_Colors.steel, -0.15),
      );
      canvas.drawLine(
        back.p.translate(0, -w * 0.25),
        fr.p.translate(0, -w * 0.25),
        Paint()
          ..strokeWidth = w * 0.3
          ..strokeCap = StrokeCap.round
          ..color = labShade(_Colors.steel, 0.35),
      );
      labSphere(canvas, fr.p, 0.12 * fr.k, _Colors.steel, highlight: 0.5, shade: 0.35);
      canvas.drawCircle(fr.p, 0.035 * fr.k, Paint()..color = _Colors.slate600);
    }
  }

  void _paintTableTop(Canvas canvas, _Cam cam) {
    const wood = _Colors.wood;
    final fl = cam.point(-2, 1.6, 1.25), fr = cam.point(2, 1.6, 1.25);
    final br = cam.point(2, 1.6, -1.25), bl = cam.point(-2, 1.6, -1.25);
    final fl2 = cam.point(-2, 1.4, 1.25), fr2 = cam.point(2, 1.4, 1.25);
    final top = Path()..addPolygon([fl, fr, br, bl], true);
    canvas.drawPath(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(wood, -0.1), labShade(wood, 0.14)],
        ).createShader(top.getBounds()),
    );
    canvas.save();
    canvas.clipPath(top);
    final grain = Paint()
      ..color = labShade(wood, -0.35).withValues(alpha: 0.35)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 9; i++) {
      final z = -1.25 + 2.5 * (i + 0.5) / 9;
      final path = Path();
      for (var j = 0; j <= 16; j++) {
        final x = -2 + 4 * j / 16;
        final pt = cam.point(x, 1.6, z + 0.035 * math.sin(x * 2.6 + i * 1.7));
        if (j == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      canvas.drawPath(path, grain);
    }
    canvas.restore();
    final front = Path()..addPolygon([fl, fr, fr2, fl2], true);
    canvas.drawPath(
      front,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(wood, -0.18), labShade(wood, -0.42)],
        ).createShader(front.getBounds()),
    );
    canvas.drawLine(
      fl,
      fr,
      Paint()
        ..color = labShade(wood, 0.35)
        ..strokeWidth = 1.5,
    );
  }

  void _paintPlate(Canvas canvas, _Cam cam, double t) {
    final c = cam.point(0, 1.645, 0.3);
    final rx = cam.point(0.8, 1.645, 0.3).dx - c.dx;
    final front = cam.point(0, 1.645, 1.1).dy, back = cam.point(0, 1.645, -0.5).dy;
    final rim = Rect.fromLTRB(c.dx - rx, back, c.dx + rx, front);
    final k = cam.project(0, 1.645, 0.3).k;
    canvas.drawOval(
      rim.shift(Offset(-0.06 * k, 0.07 * k)).inflate(2),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.28)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 0.05 * k),
    );
    canvas.drawOval(rim.shift(Offset(0, 0.05 * k)), Paint()..color = labShade(_Colors.plate, -0.28));
    canvas.drawOval(
      rim,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, _Colors.plate, labShade(_Colors.plate, -0.12)],
        ).createShader(rim),
    );
    final well = Rect.fromCenter(center: rim.center, width: rim.width * 0.68, height: rim.height * 0.68);
    canvas.drawOval(
      well,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(_Colors.plate, -0.14), labShade(_Colors.plate, -0.03)],
        ).createShader(well),
    );
    canvas.drawOval(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _Colors.slate400.withValues(alpha: 0.6),
    );
    if (scene.dragging != null) {
      final hot = scene.plateHot;
      final pulse = 0.5 + 0.5 * math.sin(t * 6);
      final color = hot ? _Colors.green : _Colors.blue;
      canvas.drawOval(
        rim.inflate(6 + 3 * pulse),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = hot ? 4 : 2.5
          ..color = color.withValues(alpha: hot ? 0.9 : 0.45 + 0.3 * pulse)
          ..maskFilter = hot ? const MaskFilter.blur(BlurStyle.solid, 4) : null,
      );
    }
  }

  void _paintFoodItem(Canvas canvas, _FoodItem f, double t, {bool lifted = false}) {
    final y = f.onPlate ? 1.67 : _beltTop;
    final pr = _cam1.project(f.pos.dx, y, f.pos.dy);
    var k = pr.k;
    if (f.onPlate && scene.eating) {
      final e = ((t - scene.eatStart) / 0.25).clamp(0.0, 1.0);
      k *= 1 - e;
      if (k < 1) return;
    }
    labGroundShadow(canvas, pr.p.translate(-0.05 * k, 0), 0.62 * k, 0.14 * k, opacity: lifted ? 0.4 : 0.3);
    if (lifted) {
      labGlow(canvas, pr.p.translate(0, -0.35 * k), 0.75 * k, _Colors.blue, intensity: 0.35);
    }
    _paintFood(canvas, f.kind, pr.p, k);
  }

  // ------------------------------------------------------- scenario 2

  void _paintChoiceScene(Canvas canvas, Size size) {
    final cam = _cam2;
    final t = scene.time;
    _paintRoom(canvas, size, cam, isDark);
    _floorShadow(canvas, cam, 2.8, -0.2, 0.9, 0.3, 0.16);

    // Peer (green shirt) offering the cigarette, or walking away.
    if (scene.peerVisible) {
      var x = -2.5, z = -1.0, opacity = 1.0;
      final leaving = scene.peerLeaveStart >= 0;
      if (leaving) {
        final p = ((t - scene.peerLeaveStart) / 1.0).clamp(0.0, 1.0);
        x = -2.5 + (-5 + 2.5) * p;
        z = -1 + (-3 + 1) * p;
        opacity = p < 0.6 ? 1 : 1 - (p - 0.6) / 0.4;
      }
      _paintAvatar(
        canvas,
        cam,
        x: x,
        z: z,
        scale: 1.1,
        yaw: leaving ? -0.7 : math.pi / 4,
        shirt: _Colors.shirtGreen,
        offering: !leaving,
        cigarette: true,
        opacity: opacity,
        t: t,
      );
    }

    // The student: smoking loop of the HTML `smokeAnim()`.
    var raise = 0.0;
    double? puff;
    if (scene.smokeStart >= 0) {
      final ph = (t - scene.smokeStart) % 4.3;
      if (ph < 1) {
        raise = Curves.easeInOutQuad.transform(ph);
      } else if (ph < 1.8) {
        raise = 1;
      } else if (ph < 2.8) {
        raise = 1 - Curves.easeInOutQuad.transform(ph - 1.8);
      }
      if (ph >= 1 && ph < 3) puff = (ph - 1) / 2;
    }
    final coughSince = t - scene.coughAt;
    final coughing = coughSince >= 0 && coughSince < 0.8;
    final damaged = scene.choice == 'yes' && scene.progress > 0.7;
    _paintAvatar(
      canvas,
      cam,
      x: 0,
      z: 0,
      scale: 1.1,
      yaw: 0,
      shirt: _Colors.shirtBlue,
      mood: damaged ? -1 : scene.mainMood,
      raise: scene.smokeStart >= 0 ? raise : -1,
      cigarette: scene.smokeStart >= 0,
      jolt: coughing ? math.sin(coughSince * 45) * (1 - coughSince / 0.8) : 0,
      t: t,
    );
    if (puff != null) _paintPuff(canvas, cam, puff);
    if (coughing) {
      final mouth = cam.point(0, 2.6, 0.4);
      labText(
        canvas,
        _l('lbl_cough'),
        mouth.translate(-70, -18 - coughSince * 30),
        size: 15 * boost,
        weight: FontWeight.w800,
        color: isDark ? _Colors.slate200 : _Colors.slate700,
        opacity: 1 - coughSince / 0.8,
      );
    }

    _paintTorsoModel(canvas, cam, t);

    if (showLabels) {
      _hotspot(canvas, Icons.person, _l('lbl_student'), cam.point(0, 3.12, 0).translate(0, -6));
      _hotspot(canvas, Icons.air, _l('lbl_lungs'), cam.point(3, 2.8, 0).translate(0, -6));
    }
  }

  /// One exhaled smoke puff (HTML smoke sphere tween, 2 s).
  void _paintPuff(Canvas canvas, _Cam cam, double p) {
    final pos = cam.project(0, 2.4 + 1.1 * p, 0.5 + 1.0 * p);
    final r = 0.1 * (0.5 + 2.0 * p) * pos.k * 1.7;
    final a = 0.8 * (1 - p);
    final paint = Paint()
      ..color = _Colors.smoke.withValues(alpha: a * 0.75)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.3 + 1);
    const lobes = [Offset(0, 0), Offset(-0.55, 0.2), Offset(0.5, 0.25), Offset(0.1, -0.45), Offset(-0.3, -0.3)];
    for (final o in lobes) {
      canvas.drawCircle(pos.p + o * r, r * 0.72, paint);
    }
  }

  /// The transparent torso shell with arms and the lungs inside (HTML
  /// `Objects.s2.torso`), with tar spots growing along the timeline.
  void _paintTorsoModel(Canvas canvas, _Cam cam, double t) {
    final pr = cam.project(3, 1.5, 0);
    final k = pr.k;
    final o = pr.p;
    Offset map(double x, double y) => Offset(o.dx + x * k, o.dy - y * k);
    Path toScreen(Path local) =>
        local.transform(Matrix4(k, 0, 0, 0, 0, -k, 0, 0, 0, 0, 1, 0, o.dx, o.dy, 0, 1).storage);

    final glass = isDark ? _Colors.slate400 : _Colors.slate500;
    final edge = isDark ? _Colors.slate300 : _Colors.slate600;
    final torso = toScreen(_torsoLocal);
    final back = torso.shift(Offset(-0.09 * k, -0.045 * k));
    canvas.drawPath(back, Paint()..color = glass.withValues(alpha: 0.08));
    canvas.drawPath(
      back,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeJoin = StrokeJoin.round
        ..color = edge.withValues(alpha: 0.22),
    );
    canvas.drawPath(
      torso,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [glass.withValues(alpha: 0.3), glass.withValues(alpha: 0.12), glass.withValues(alpha: 0.24)],
        ).createShader(torso.getBounds()),
    );

    // Lungs, windpipe and bronchi (gently breathing).
    final p = scene.progress;
    final lungColor = switch (scene.choice) {
      'no' => Color.lerp(_Colors.lungPink, _Colors.lungMature, p)!,
      'yes' => Color.lerp(_Colors.lungPink, _Colors.lungDark, p)!,
      _ => _Colors.lungPink,
    };
    final breathe = 1 + 0.015 * math.sin(t * 2.2);
    final lc = map(0, 0.25);
    canvas.save();
    canvas.translate(lc.dx, lc.dy);
    canvas.scale(breathe);
    canvas.translate(-lc.dx, -lc.dy);

    const pipe = _Colors.lungPink;
    for (final side in const [-1.0, 1.0]) {
      _limb(canvas, map(side * 0.003, 0.627), map(side * 0.357, 0.273), 0.08 * k, 0.08 * k, labShade(pipe, -0.05));
    }
    final tTop = map(0, 1.05), tBot = map(0, 0.55);
    final tw = 0.12 * k;
    final trachea = RRect.fromRectAndRadius(
      Rect.fromLTRB(tTop.dx - tw / 2, tTop.dy, tTop.dx + tw / 2, tBot.dy),
      Radius.circular(tw / 2),
    );
    canvas.drawRRect(
      trachea,
      Paint()
        ..shader = LinearGradient(colors: [labShade(pipe, 0.15), pipe, labShade(pipe, -0.3)])
            .createShader(trachea.outerRect),
    );
    final ring = Paint()
      ..color = labShade(pipe, -0.25)
      ..strokeWidth = 0.012 * k + 0.5;
    for (var y = 0.6; y < 1.02; y += 0.07) {
      final a = map(-0.055, y), b = map(0.055, y);
      canvas.drawLine(a, b, ring);
    }

    for (final side in const [-1.0, 1.0]) {
      final lung = toScreen(side < 0 ? _lungLeft : _lungRight);
      final b = lung.getBounds();
      canvas.drawPath(
        lung,
        Paint()
          ..shader = RadialGradient(
            center: Alignment(side < 0 ? 0.1 : -0.35, -0.45),
            radius: 1.05,
            colors: [
              labShade(lungColor, 0.28).withValues(alpha: 0.92),
              lungColor.withValues(alpha: 0.92),
              labShade(lungColor, -0.32).withValues(alpha: 0.92),
            ],
            stops: const [0, 0.55, 1],
          ).createShader(b),
      );
      canvas.save();
      canvas.clipPath(lung);
      // Lobe fissure.
      final fissure = Path()
        ..moveTo(map(side * 0.12, 0.5).dx, map(side * 0.12, 0.5).dy)
        ..quadraticBezierTo(
          map(side * 0.45, 0.3).dx,
          map(side * 0.45, 0.3).dy,
          map(side * 0.78, 0.0).dx,
          map(side * 0.78, 0.0).dy,
        );
      canvas.drawPath(
        fissure,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.015 * k + 0.5
          ..color = labShade(lungColor, -0.35).withValues(alpha: 0.55),
      );
      for (var i = 0; i < scene.spots.length; i++) {
        final sp = scene.spots[i];
        if ((sp.at.dx < 0) != (side < 0)) continue;
        final sc = _spotScale(i, sp);
        if (sc <= 0) continue;
        final r = 0.08 * sc * k;
        final c = map(sp.at.dx, sp.at.dy);
        canvas.drawCircle(
          c,
          r,
          Paint()
            ..shader = RadialGradient(
              colors: [
                _Colors.spot.withValues(alpha: 0.95),
                _Colors.spot.withValues(alpha: 0.8),
                _Colors.spot.withValues(alpha: 0),
              ],
              stops: const [0, 0.6, 1],
            ).createShader(Rect.fromCircle(center: c, radius: r)),
        );
      }
      canvas.restore();
      canvas.drawPath(
        lung,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = labShade(lungColor, -0.4).withValues(alpha: 0.7),
      );
    }
    // A pulsing ring calls out the very first spot after TRY ONCE.
    if (scene.spot0 && scene.smokeStart >= 0) {
      final since = t - scene.smokeStart;
      if (since < 4 && scene.progress == 0) {
        final c = map(scene.spots[0].at.dx, scene.spots[0].at.dy);
        final ph = (since * 1.5) % 1.0;
        canvas.drawCircle(
          c,
          (0.06 + 0.1 * ph) * k,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = _Colors.red.withValues(alpha: 0.9 * (1 - ph)),
        );
      }
    }
    canvas.restore();

    // Front of the glass shell.
    canvas.drawPath(
      torso,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..color = edge.withValues(alpha: 0.55),
    );
    canvas.drawPath(
      Path()
        ..moveTo(map(-0.6, 0.8).dx, map(-0.6, 0.8).dy)
        ..quadraticBezierTo(map(-0.66, -0.2).dx, map(-0.66, -0.2).dy, map(-0.6, -1.0).dx, map(-0.6, -1.0).dy),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.05 * k
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: isDark ? 0.14 : 0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 0.02 * k),
    );
  }

  /// HTML `updateTimeline()` spot growth.
  double _spotScale(int i, _Spot s) {
    if (scene.choice != 'yes') return 0;
    final p = scene.progress;
    var sc = 0.0;
    if (p >= s.threshold) sc = s.base * (p - s.threshold) / (1 - s.threshold) * 2;
    if (i == 0 && scene.spot0) sc = math.max(sc, 0.5);
    return sc;
  }

  // ------------------------------------------------------------ avatar

  /// The HTML `createAvatar()` figure seen from the front: [yaw] turns it
  /// (features and shoulders shift), [lean] tilts the upper body forward
  /// (slump) or back, [nod] tips the head, [raise] lifts the right arm to the
  /// mouth (smoking), [offering] holds the cigarette out to the side.
  void _paintAvatar(
    Canvas canvas,
    _Cam cam, {
    required double x,
    required double z,
    required double scale,
    required double yaw,
    required Color shirt,
    double lean = 0,
    double nod = 0,
    double sway = 0,
    int mood = 0,
    double raise = -1,
    bool cigarette = false,
    bool offering = false,
    double jolt = 0,
    double opacity = 1,
    double aura = 0,
    double t = 0,
  }) {
    if (opacity <= 0) return;
    final pr = cam.project(x, 0, z);
    final u = pr.k * scale;
    final foot = pr.p;
    final sinY = math.sin(yaw), cosY = math.cos(yaw);
    Offset pt(Offset l) => Offset(foot.dx + l.dx * u, foot.dy - l.dy * u);
    Offset lp(double lx, double ly) => Offset(foot.dx + lx * u, foot.dy - ly * u);

    final layered = opacity < 1;
    if (layered) {
      canvas.saveLayer(
        Rect.fromCenter(center: lp(0, 1.6), width: 5 * u, height: 4.5 * u),
        Paint()..color = Colors.black.withValues(alpha: opacity),
      );
    }

    if (aura > 0) {
      final pulse = 0.75 + 0.25 * math.sin(t * 3);
      labGlow(canvas, lp(0, 1.7), 1.7 * u, const Color(0xFF4ADE80), intensity: 0.4 * aura * pulse);
    }
    labGroundShadow(canvas, lp(-0.15, 0.02), 1.05 * u, 0.26 * u, opacity: 0.35);

    // Legs (long pants) and shoes.
    for (final side in const [-1.0, 1.0]) {
      final lx = side * 0.18 * cosY;
      final leg = Path()..addPolygon([lp(lx - 0.14, 0.95), lp(lx + 0.14, 0.95), lp(lx + 0.12, 0.12), lp(lx - 0.12, 0.12)], true);
      canvas.drawPath(leg, _cylPaint(_Colors.pants, leg.getBounds()));
      final toe = sinY * 0.1;
      final shoe = RRect.fromRectAndCorners(
        Rect.fromPoints(lp(lx - 0.12 + math.min(toe, 0), 0.17), lp(lx + 0.12 + math.max(toe, 0), 0)),
        topLeft: Radius.circular(0.08 * u),
        topRight: Radius.circular(0.08 * u),
        bottomLeft: Radius.circular(0.03 * u),
        bottomRight: Radius.circular(0.03 * u),
      );
      canvas.drawRRect(shoe, Paint()..color = _Colors.shoe);
      canvas.drawLine(
        lp(lx - 0.11 + math.min(toe, 0), 0.025),
        lp(lx + 0.11 + math.max(toe, 0), 0.025),
        Paint()
          ..strokeWidth = 0.03 * u
          ..color = _Colors.slate200.withValues(alpha: 0.85),
      );
    }
    // Hips.
    final hips = RRect.fromRectAndCorners(
      Rect.fromPoints(lp(-0.36, 1.22), lp(0.36, 0.8)),
      topLeft: Radius.circular(0.04 * u),
      topRight: Radius.circular(0.04 * u),
      bottomLeft: Radius.circular(0.14 * u),
      bottomRight: Radius.circular(0.14 * u),
    );
    canvas.drawRRect(hips, _cylPaint(_Colors.pants, hips.outerRect));

    // Upper body pivots at the waist.
    canvas.save();
    final pivot = lp(0, 1.2);
    canvas.translate(pivot.dx, pivot.dy);
    canvas.rotate(lean * sinY * 1.1 + jolt * 0.06);
    canvas.scale(1, lean > 0 ? 1 - 0.28 * lean * cosY.abs() : 1 - 0.12 * lean);
    canvas.translate(-pivot.dx, -pivot.dy);

    final farSide = sinY > 0.05 ? 1.0 : (sinY < -0.05 ? -1.0 : 0.0);
    Offset shoulder(double side) => Offset(side * 0.5 * cosY, 1.8);
    const mouth = Offset(0.02, 2.29);
    Offset hand(double side) {
      final s = shoulder(side);
      if (offering && side == 1) return s + const Offset(0.6, -0.22);
      if (raise >= 0 && side == 1) {
        final h0 = s + const Offset(0.07, -0.78);
        const hm = Offset(0.17, 2.25);
        final e = raise;
        return Offset.lerp(h0, hm, e)! + Offset(0.22 * math.sin(math.pi * e), 0);
      }
      return s + Offset(side * 0.07 + math.sin(t * 1.6 + side) * 0.008, -0.78);
    }

    void arm(double side) {
      final s = shoulder(side), h = hand(side);
      final e = _elbow(s, h, 0.42, 0.4);
      _limb(canvas, pt(s), pt(e), 0.19 * u, 0.16 * u, _Colors.skin);
      _limb(canvas, pt(e), pt(h), 0.16 * u, 0.13 * u, _Colors.skin);
      final dir = (e - s) / math.max((e - s).distance, 1e-3);
      _limb(canvas, pt(s - dir * 0.04), pt(s + dir * 0.3), 0.29 * u, 0.27 * u, shirt);
      final holds = cigarette && side == 1 && (offering || raise >= 0);
      if (holds) {
        Offset a, b;
        if (offering) {
          a = h + const Offset(-0.04, 0.0);
          b = a + const Offset(0.3, 0.07);
        } else {
          final r = Curves.easeInOut.transform(raise.clamp(0.0, 1.0));
          final restA = h + const Offset(-0.05, 0.03);
          final restB = restA + const Offset(0.28, -0.12);
          a = Offset.lerp(restA, mouth, r)!;
          b = Offset.lerp(restB, mouth + const Offset(0.31, 0.03), r)!;
        }
        final ember = raise >= 0.99 ? 1.0 : 0.0;
        _cigarette(canvas, pt(a), pt(b), 0.045 * u, ember);
        if (offering || raise < 0.5) _wisp(canvas, pt(b), u, t);
      }
      canvas.drawCircle(
        pt(h),
        0.088 * u,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.3, -0.4),
            colors: [labShade(_Colors.skin, 0.2), _Colors.skin, labShade(_Colors.skin, -0.3)],
          ).createShader(Rect.fromCircle(center: pt(h), radius: 0.088 * u)),
      );
    }

    final smokingArm = raise >= 0;
    for (final side in const [-1.0, 1.0]) {
      final behind = farSide == side || (farSide == 0 && !(smokingArm && side == 1));
      if (behind) arm(side);
    }

    // Shirt (torso cylinder) with collar and hem.
    final body = RRect.fromRectAndCorners(
      Rect.fromPoints(lp(-0.35, 2.03), lp(0.35, 0.9)),
      topLeft: Radius.circular(0.2 * u),
      topRight: Radius.circular(0.2 * u),
      bottomLeft: Radius.circular(0.05 * u),
      bottomRight: Radius.circular(0.05 * u),
    );
    canvas.drawRRect(body, _cylPaint(shirt, body.outerRect));
    final cx = sinY * 0.14 + sway * 0.35;
    canvas.drawLine(
      lp(-0.35, 0.98),
      lp(0.35, 0.98),
      Paint()
        ..color = labShade(shirt, -0.25)
        ..strokeWidth = 0.035 * u,
    );

    for (final side in const [-1.0, 1.0]) {
      final behind = farSide == side || (farSide == 0 && !(smokingArm && side == 1));
      final smoking = smokingArm && side == 1;
      if (!behind && !smoking) arm(side);
    }

    // Neck and head (the head tips forward when nodding / slumping).
    final drop = nod * 0.1 + math.max(0, lean) * 0.08;
    final hx = sway * 0.35 + (lean > 0 ? sinY * lean * 0.12 : 0);
    final hc = Offset(hx, 2.4 - drop);
    canvas.drawRect(Rect.fromPoints(lp(hx - 0.09, 2.12 - drop), lp(hx + 0.09, 1.95)), Paint()..color = labShade(_Colors.skin, -0.2));
    canvas.drawPath(
      Path()..addPolygon([lp(cx - 0.13, 2.01), lp(cx, 1.86), lp(cx + 0.13, 2.01)], true),
      Paint()..color = labShade(_Colors.skin, -0.12),
    );
    _paintHead(canvas, lp, u, hc, sinY, cosY, nod: nod, sway: sway, mood: mood, t: t);

    if (smokingArm) arm(1);
    canvas.restore();
    if (layered) canvas.restore();
  }

  Paint _cylPaint(Color c, Rect r) => Paint()
    ..shader = LinearGradient(
      colors: [labShade(c, -0.25), labShade(c, 0.2), c, labShade(c, -0.42)],
      stops: const [0, 0.3, 0.62, 1],
    ).createShader(r);

  void _paintHead(
    Canvas canvas,
    Offset Function(double, double) lp,
    double u,
    Offset hc,
    double sinY,
    double cosY, {
    required double nod,
    required double sway,
    required int mood,
    required double t,
  }) {
    final hairC = lp(hc.dx - sinY * 0.05, hc.dy + 0.05);
    final hairR = 0.375 * u;
    final faceC = lp(hc.dx, hc.dy);
    final faceR = 0.35 * u;
    canvas.drawCircle(hairC, hairR, Paint()..color = _Colors.hair);
    final earPaint = Paint()..color = labShade(_Colors.skin, -0.12);
    final frontal = sinY.abs() < 0.1;
    if (frontal) {
      for (final s in const [-1.0, 1.0]) {
        canvas.drawCircle(lp(hc.dx + s * 0.34, hc.dy - 0.01), 0.075 * u, earPaint);
      }
    }
    canvas.drawCircle(
      faceC,
      faceR,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.35),
          radius: 1.0,
          colors: [labShade(_Colors.skin, 0.2), _Colors.skin, labShade(_Colors.skin, -0.25)],
          stops: const [0, 0.55, 1],
        ).createShader(Rect.fromCircle(center: faceC, radius: faceR)),
    );
    if (!frontal) {
      canvas.drawCircle(lp(hc.dx - sinY.sign * 0.25, hc.dy - 0.02), 0.07 * u, earPaint);
    }
    // Hair cap with a fringe that falls lower towards the back of the head.
    final fringe = Path()
      ..moveTo(lp(hc.dx + 0.6, hc.dy + 1).dx, lp(hc.dx + 0.6, hc.dy + 1).dy)
      ..lineTo(lp(hc.dx - 0.6, hc.dy + 1).dx, lp(hc.dx - 0.6, hc.dy + 1).dy);
    for (var i = 0; i <= 24; i++) {
      final lx = -0.6 + 1.2 * i / 24;
      final ly = hc.dy + 0.14 - nod * 0.08 + lx * sinY * 0.55 + 0.025 * math.sin(lx * 30);
      final q = lp(hc.dx + lx, ly);
      fringe.lineTo(q.dx, q.dy);
    }
    fringe.close();
    final cap = Path.combine(
      PathOperation.intersect,
      Path()..addOval(Rect.fromCircle(center: hairC, radius: hairR)),
      fringe,
    );
    canvas.drawPath(
      cap,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [labShade(_Colors.hair, 0.22), _Colors.hair],
        ).createShader(Rect.fromCircle(center: hairC, radius: hairR)),
    );

    // Face: eyes, brows, mouth.
    final fx = hc.dx + sinY * 0.2 + sway * 0.35;
    final fy = hc.dy - nod * 0.22;
    final dark = Paint()..color = const Color(0xFF111111);
    final stroke = Paint()
      ..color = const Color(0xFF111111)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.028 * u
      ..strokeCap = StrokeCap.round;
    for (final s in const [-1.0, 1.0]) {
      final ec = lp(fx + s * 0.125 * cosY, fy + 0.05);
      if (mood < 0) {
        canvas.drawArc(Rect.fromCircle(center: ec, radius: 0.05 * u), 0, math.pi, true, dark);
        canvas.drawLine(ec.translate(-0.065 * u, 0), ec.translate(0.065 * u, 0), stroke);
      } else {
        canvas.drawOval(Rect.fromCenter(center: ec, width: 0.1 * u * (0.75 + 0.25 * cosY), height: 0.12 * u), dark);
        canvas.drawCircle(ec.translate(-0.015 * u, -0.022 * u), 0.018 * u, Paint()..color = Colors.white);
      }
      final bc = lp(fx + s * 0.13 * cosY, fy + 0.15);
      final tilt = mood < 0 ? s * 0.025 : 0.0;
      canvas.drawLine(
        bc.translate(-0.06 * u, tilt * u),
        bc.translate(0.06 * u, -tilt * u),
        stroke..color = labShade(_Colors.hair, 0.1),
      );
      stroke.color = const Color(0xFF111111);
    }
    final mc = lp(fx * 1.05, fy - 0.11);
    final mw = 0.13 * u;
    final mouthPath = Path()..moveTo(mc.dx - mw / 2, mc.dy);
    if (mood > 0) {
      mouthPath.quadraticBezierTo(mc.dx, mc.dy + 0.08 * u, mc.dx + mw / 2, mc.dy);
      for (final s in const [-1.0, 1.0]) {
        canvas.drawOval(
          Rect.fromCenter(center: lp(fx + s * 0.2, fy - 0.06), width: 0.1 * u, height: 0.06 * u),
          Paint()..color = const Color(0xFFF87171).withValues(alpha: 0.35),
        );
      }
    } else if (mood < 0) {
      mouthPath.quadraticBezierTo(mc.dx, mc.dy - 0.05 * u, mc.dx + mw / 2, mc.dy + 0.01 * u);
      // Sweat drop on the side of the head.
      final sd = lp(hc.dx - sinY.sign * 0.3 + (sinY == 0 ? 0.3 : 0), hc.dy + 0.12);
      canvas.drawPath(
        Path()
          ..moveTo(sd.dx, sd.dy - 0.09 * u)
          ..quadraticBezierTo(sd.dx + 0.05 * u, sd.dy, sd.dx, sd.dy + 0.03 * u)
          ..quadraticBezierTo(sd.dx - 0.05 * u, sd.dy, sd.dx, sd.dy - 0.09 * u),
        Paint()..color = _Colors.blue300.withValues(alpha: 0.9),
      );
    } else {
      mouthPath.lineTo(mc.dx + mw / 2, mc.dy);
    }
    canvas.drawPath(mouthPath, stroke);
  }

  // ------------------------------------------------------------ labels

  /// HTML `.hotspot-label`: glass pill with a blue border, icon and text,
  /// sitting just above [at].
  void _hotspot(Canvas canvas, IconData icon, String text, Offset at) {
    final size = 14 * boost;
    const blue = _Colors.blue;
    final fg = isDark ? blue : _Colors.blue600;
    final tp = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: String.fromCharCode(icon.codePoint),
            style: TextStyle(
              fontFamily: icon.fontFamily,
              package: icon.fontPackage,
              fontSize: size * 1.15,
              color: fg,
              height: 1.0,
            ),
          ),
          TextSpan(
            text: '  $text',
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.w800,
              color: fg,
              fontFamily: LabFont.active.family,
              fontFamilyFallback: LabFont.active.fallback,
              height: 1.2,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final w = tp.width + 20 * boost, h = tp.height + 8 * boost;
    final rect = Rect.fromLTWH(at.dx - w / 2, at.dy - h, w, h);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(8 * boost));
    canvas.drawRRect(
      rr.shift(const Offset(0, 3)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawRRect(rr, Paint()..color = isDark ? const Color(0xEB0F172A) : const Color(0xF2FFFFFF));
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = blue,
    );
    tp.paint(canvas, Offset(rect.left + 10 * boost, rect.top + 4 * boost));
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.isDark != isDark || old.showLabels != showLabels || old.boost != boost || !mapEquals(old.labels, labels);
}

/// HTML torso shell (ExtrudeGeometry shape, centred), y-up world units.
final Path _torsoLocal = (Path()
      ..moveTo(-0.75, -1.2)
      ..lineTo(-0.75, 0.1)
      ..lineTo(-0.85, 0.1)
      ..lineTo(-0.85, -0.6)
      ..cubicTo(-0.85, -0.8, -1.05, -0.8, -1.05, -0.6)
      ..lineTo(-1.05, 0.6)
      ..cubicTo(-1.05, 1.0, -0.5, 1.0, -0.25, 1.0)
      ..lineTo(-0.25, 1.3)
      ..lineTo(0.25, 1.3)
      ..lineTo(0.25, 1.0)
      ..cubicTo(0.5, 1.0, 1.05, 1.0, 1.05, 0.6)
      ..lineTo(1.05, -0.6)
      ..cubicTo(1.05, -0.8, 0.85, -0.8, 0.85, -0.6)
      ..lineTo(0.85, 0.1)
      ..lineTo(0.75, 0.1)
      ..lineTo(0.75, -1.2)
      ..close())
    .shift(const Offset(0, -0.05));

final Path _lungRight = _buildLung(1);
final Path _lungLeft = _buildLung(-1);

/// HTML lung shape (tall, tapering top, straight medial side), squashed to
/// 75 % height, centred and placed at (±0.42, 0.25) in the lungs group.
Path _buildLung(double s) {
  final p = Path()
    ..moveTo(0.1 * s, -0.6)
    ..cubicTo(0.2 * s, -0.7, 0.5 * s, -0.7, 0.65 * s, -0.5)
    ..cubicTo(0.8 * s, 0.0, 0.6 * s, 0.7, 0.35 * s, 1.0)
    ..cubicTo(0.2 * s, 1.1, 0.1 * s, 1.05, 0.1 * s, 0.9)
    ..cubicTo(0.0, 0.5, 0.0, -0.1, 0.1 * s, -0.6)
    ..close();
  final squashed = p.transform(Matrix4.diagonal3Values(1, 0.75, 1).storage);
  final b = squashed.getBounds();
  return squashed.shift(Offset(-b.center.dx + 0.42 * s, -b.center.dy + 0.25));
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
