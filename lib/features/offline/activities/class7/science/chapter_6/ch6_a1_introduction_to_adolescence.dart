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

/// Class 7 Science • Chapter 6 • Activity 1
/// Introduction to Adolescence.
///
/// Native Flutter port of `Cl7S-Ch06-A1-Introduction_to_Adolescence.html`.
/// Scenario 1: tap the cousins Venkatesh and Devyani to hear their chat, then
/// drag the signs they notice (height, voice, moustache) into "Signs of
/// Adolescence". Scenario 2: drag Grade 5 and Grade 8 avatars onto the
/// comparison stands, tap the glowing hotspots to fill the observation jar
/// and sort every change into boys / girls / common columns.
class Ch6A1IntroductionToAdolescencePage extends StatefulWidget {
  const Ch6A1IntroductionToAdolescencePage({super.key});

  @override
  State<Ch6A1IntroductionToAdolescencePage> createState() => _Ch6A1IntroductionToAdolescencePageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pop 2357, drop 2364, pickup 2356, buzz 2594,
/// magic 871, whoosh 1492.
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

  /// Character tapped / hotspot found (HTML `pop`).
  pop('pop.mp3'),

  /// Icon lands in the observation jar.
  drop('drop.mp3'),

  /// An icon is picked up from a tray.
  pickup('pickup.mp3'),

  /// Devyani hears Venkatesh's voice crack (HTML `voice_crack`).
  buzz('buzz.mp3'),

  /// Findings ready to review (HTML `chime`).
  magic('magic.mp3'),

  /// The observation jar tips over (Categorize).
  whoosh('whoosh.mp3');

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
      await player.play(AssetSource('audio/class7/${sound.file}'), volume: volume, mode: PlayerMode.lowLatency);
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

/// Brand, Tailwind and Three.js material colours used by this lab.
abstract final class _Colors {
  static const Color zslYellow = Color(0xFFEAB308); // zsl.yellow
  static const Color violet300 = Color(0xFFC4B5FD);
  static const Color violet400 = Color(0xFFA78BFA);
  static const Color violet500 = Color(0xFF8B5CF6);
  static const Color violet600 = Color(0xFF7C3AED);
  static const Color violet700 = Color(0xFF6D28D9);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue700 = Color(0xFF1D4ED8);
  static const Color blue800 = Color(0xFF1E40AF);
  static const Color pink50 = Color(0xFFFDF2F8);
  static const Color pink200 = Color(0xFFFBCFE8);
  static const Color pink300 = Color(0xFFF9A8D4);
  static const Color pink400 = Color(0xFFF472B6);
  static const Color pink500 = Color(0xFFEC4899);
  static const Color pink600 = Color(0xFFDB2777);
  static const Color pink700 = Color(0xFFBE185D);
  static const Color pink800 = Color(0xFF9D174D);
  static const Color purple300 = Color(0xFFD8B4FE);
  static const Color purple400 = Color(0xFFC084FC);
  static const Color purple500 = Color(0xFFA855F7);
  static const Color purple700 = Color(0xFF7E22CE);
  static const Color red400 = Color(0xFFF87171);
  static const Color red500 = Color(0xFFEF4444);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color sky400 = Color(0xFF38BDF8); // hotspot spheres
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

  // Three.js materials (HTML `Mats`).
  static const Color skin = Color(0xFFE0AC69);
  static const Color shirtBoy = blue500;
  static const Color shirtGirl = pink500;
  static const Color pants = slate800;
  static const Color hair = Color(0xFF4A2C11);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
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
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate900,
    primary: _Colors.violet600,
    onPrimary: Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: Colors.white,
    info: _Colors.violet400,
    popupBg: _Colors.slate900,
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate800,
    toastBg: _Colors.slate100,
    toastText: _Colors.slate900,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x665B21B6), // violet-800/40
    curtainText: Colors.white,
    curtainMuted: Color(0xCCC4B5FD), // violet-300/80
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
    panel: Color(0xF2FFFFFF),
    border: Color(0x26000000),
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: Color(0xFFE0F2FE),
    text: _Colors.slate800,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate900,
    primary: _Colors.violet600,
    onPrimary: Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: Colors.white,
    info: _Colors.violet600,
    popupBg: Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: Colors.white,
    toastBg: _Colors.slate900,
    toastText: Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x665B21B6),
    curtainText: Colors.white,
    curtainMuted: Color(0xCCC4B5FD),
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
const _font = LabFont(family: null, fallback: null, size: 15, minSize: 12, maxSize: 24);

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
    'app_title': 'Introduction to Adolescence',
    'app_subtitle': 'Class 7 • Adolescence: A Stage of Growth and Change',
    'scen_1_opt': "Scenario 1: The Cousins' Conversation",
    'scen_2_opt': 'Scenario 2: Grade 5 to Grade 8 Comparison',
    'success': 'Discovery Complete!',
    'discovery_complete': 'Exploration Complete!',
    'btn_conclude': 'Review Findings',
    'summary_1':
        'These observable changes in height, voice, and facial hair are common signs that mark the beginning of adolescence, a period of growth between childhood and adulthood.',
    'summary_2':
        'During adolescence, boys and girls experience both common changes (like height gain and pimples) and specific secondary sexual changes. It reinforces that these variations in timing and appearance are normal signs of the body preparing for adulthood.',
    // Scenario 1: the cousins' conversation.
    'conversation': 'Conversation',
    'name_venkatesh': 'Venkatesh',
    'name_devyani': 'Devyani',
    's1_bubble1': 'You have become so tall, Devyani!',
    's1_bubble2': 'Your voice has also changed!',
    's1_bubble3': 'Venkatesh, you have a thin moustache now!!',
    'drag_icons_here': 'Drag observed signs here',
    'signs_of_adolescence': 'Signs of Adolescence',
    'signs_zone': 'Signs of\nAdolescence',
    // Signs of change (tray chips, hotspot labels, jar icons).
    'lbl_height': 'Increased Height',
    'lbl_voice': 'Voice Change',
    'lbl_moustache': 'Moustache',
    'lbl_shoulders': 'Broader Shoulders',
    'lbl_adams': "Adam's Apple",
    'lbl_pimples': 'Pimples',
    'lbl_breasts': 'Development of Breasts',
    'sum_voice': 'Voice',
    'sum_facial_hair': 'Facial Hair',
    // Scenario 2: Grade 5 to Grade 8.
    'grade5': 'Grade 5',
    'grade8': 'Grade 8',
    'observation_jar': 'Observation Jar',
    'reset_girls': 'Reset for Girls',
    'btn_categorize': 'Categorize',
    'categorize_changes': 'Categorize the Changes',
    'only_boys': 'Observed only in boys',
    'only_girls': 'Observed only in girls',
    'common_both': 'Common in boys & girls',
    // Status and feedback added for the native port.
    'hud_girls': 'DRAG the "Grade 5 Girl" avatar to the left stand and the "Grade 8 Girl" avatar to the right stand.',
    'hud_summarize': "The lab will now summarize the learning. Click 'Review Findings'.",
    'wrong_stand': 'Not this stand! Grade 5 goes on the left stand and Grade 8 on the right.',
    'place_g5_first': 'First place the Grade 5 Boy on the left stand.',
    'wrong_column': 'Not this column. Is this change seen only in boys, only in girls, or in both?',
  },
  'hi': {
    'app_title': 'किशोरावस्था का परिचय',
    'app_subtitle': 'कक्षा 7 • किशोरावस्था: वृद्धि और परिवर्तन की अवस्था',
    'scen_1_opt': 'परिदृश्य 1: चचेरे भाई-बहनों की बातचीत',
    'scen_2_opt': 'परिदृश्य 2: कक्षा 5 से कक्षा 8 की तुलना',
    'success': 'खोज पूर्ण!',
    'discovery_complete': 'अन्वेषण पूर्ण!',
    'btn_conclude': 'निष्कर्ष की समीक्षा करें',
    'summary_1':
        'लंबाई, आवाज़ और चेहरे के बालों में ये दिखाई देने वाले परिवर्तन सामान्य संकेत हैं जो किशोरावस्था की शुरुआत को दर्शाते हैं, जो बचपन और वयस्कता के बीच वृद्धि की अवधि है।',
    'summary_2':
        'किशोरावस्था के दौरान लड़के और लड़कियाँ दोनों सामान्य परिवर्तन (जैसे लंबाई बढ़ना और मुंहासे) और विशिष्ट द्वितीयक लैंगिक परिवर्तन अनुभव करते हैं। समय और रूप में ये भिन्नताएँ वयस्कता की तैयारी कर रहे शरीर के बिल्कुल सामान्य संकेत हैं।',
    'conversation': 'बातचीत',
    'name_venkatesh': 'वेंकटेश',
    'name_devyani': 'देवयानी',
    's1_bubble1': 'देवयानी, तुम इतनी लंबी हो गई हो!',
    's1_bubble2': 'तुम्हारी आवाज़ भी बदल गई है!',
    's1_bubble3': 'वेंकटेश, अब तुम्हारी हल्की मूंछें आ गई हैं!!',
    'drag_icons_here': 'देखे गए संकेतों को यहाँ खींचें',
    'signs_of_adolescence': 'किशोरावस्था के संकेत',
    'signs_zone': 'किशोरावस्था\nके संकेत',
    'lbl_height': 'लंबाई में वृद्धि',
    'lbl_voice': 'आवाज़ में बदलाव',
    'lbl_moustache': 'मूंछें',
    'lbl_shoulders': 'चौड़े कंधे',
    'lbl_adams': 'एडम्स एप्पल',
    'lbl_pimples': 'मुंहासे',
    'lbl_breasts': 'स्तनों का विकास',
    'sum_voice': 'आवाज़',
    'sum_facial_hair': 'चेहरे के बाल',
    'grade5': 'कक्षा 5',
    'grade8': 'कक्षा 8',
    'observation_jar': 'अवलोकन जार',
    'reset_girls': 'लड़कियों के लिए रीसेट करें',
    'btn_categorize': 'वर्गीकृत करें',
    'categorize_changes': 'परिवर्तनों को वर्गीकृत करें',
    'only_boys': 'केवल लड़कों में देखा गया',
    'only_girls': 'केवल लड़कियों में देखा गया',
    'common_both': 'लड़कों और लड़कियों दोनों में आम',
    'hud_girls': '"कक्षा 5 की लड़की" अवतार को बाएँ स्टैंड पर और "कक्षा 8 की लड़की" अवतार को दाएँ स्टैंड पर खींचें।',
    'hud_summarize': "प्रयोगशाला अब सीखी गई बातों का सारांश देगी। 'निष्कर्ष की समीक्षा करें' पर क्लिक करें।",
    'wrong_stand': 'यह स्टैंड नहीं! कक्षा 5 बाएँ स्टैंड पर और कक्षा 8 दाएँ स्टैंड पर जाएगा।',
    'place_g5_first': 'पहले कक्षा 5 के लड़के को बाएँ स्टैंड पर रखें।',
    'wrong_column': 'यह कॉलम नहीं। क्या यह परिवर्तन केवल लड़कों में, केवल लड़कियों में, या दोनों में दिखता है?',
  },
};

/// Mission objective and steps per scenario. Each step's action is the
/// HTML "Current Task" HUD text for that step.
const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To identify the initial, observable signs of adolescence as depicted in the conversation between Venkatesh and Devyani.',
      steps: [
        LabStep(
          concept: 'Physical Growth',
          action:
              'The scene shows two characters, an older boy (Venkatesh) and a younger girl (Devyani). CLICK on Venkatesh to hear what he says.',
          observation: "Venkatesh remarks on Devyani's height. An upward arrow indicates an increase in height.",
        ),
        LabStep(
          concept: 'Voice Change',
          action: 'Now, CLICK on Devyani to hear her response.',
          observation: "Devyani notices Venkatesh's voice change. A soundwave pulses over his throat.",
        ),
        LabStep(
          concept: 'Facial Hair',
          action: 'Devyani has more to say. CLICK on her again.',
          observation: 'Devyani points out a moustache. A faint moustache appears on Venkatesh.',
        ),
        LabStep(
          concept: 'Identifying Signs',
          action:
              'A summary panel appears. DRAG the icons for the changes you observed (Height, Voice, Moustache) into the box labeled "Signs of Adolescence".',
          observation: "Icons are successfully categorized as 'Signs of Adolescence'.",
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To visually compare students from different grades and identify common physical changes during adolescence, as prompted by Activity 6.1.',
      steps: [
        LabStep(
          concept: 'Baseline Comparison',
          action:
              'You see two groups of student avatars: "Grade 5" and "Grade 8". DRAG a "Grade 5 Boy" avatar to the left comparison stand.',
          observation: 'The younger boy acts as a baseline before puberty.',
        ),
        LabStep(
          concept: 'Visible Growth',
          action: 'Now, DRAG a "Grade 8 Boy" avatar to the right comparison stand to see the changes.',
          observation: 'The older boy is noticeably taller and broader.',
        ),
        LabStep(
          concept: 'Male Changes',
          action:
              'Several areas on the Grade 8 Boy are now glowing. CLICK on each glowing hotspot to identify a change.',
          observation: "Identified: Increased Height, Broader Shoulders, Adam's Apple, Pimples.",
        ),
        LabStep(
          concept: 'Shifting Focus',
          action:
              "Well done! Now let's observe the changes in girls. CLICK the 'Reset for Girls' button and repeat the process with the girl avatars.",
          observation: 'Stands are cleared, and girl avatars are placed for comparison.',
        ),
        LabStep(
          concept: 'Female Changes',
          action: 'CLICK on the glowing hotspots on the Grade 8 Girl to identify the changes.',
          observation: 'Identified: Increased Height, Development of Breasts, Pimples.',
        ),
        LabStep(
          concept: 'Categorization setup',
          action: "The Observation Jar is now full. Let's categorize the changes. CLICK 'Categorize'.",
          observation: 'Icons spill out, ready to be sorted.',
        ),
        LabStep(
          concept: 'Sorting the changes',
          action: 'DRAG each icon from the jar into the correct category in the table.',
          observation: 'Changes are correctly mapped to boys, girls, or both.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'वेंकटेश और देवयानी के बीच बातचीत में दर्शाए गए किशोरावस्था के शुरुआती, दिखाई देने वाले संकेतों को पहचानना।',
      steps: [
        LabStep(
          concept: 'शारीरिक विकास',
          action:
              'दृश्य में दो पात्र हैं, एक बड़ा लड़का (वेंकटेश) और एक छोटी लड़की (देवयानी)। वेंकटेश पर क्लिक करके सुनें कि वह क्या कहता है।',
          observation: 'वेंकटेश देवयानी की लंबाई पर टिप्पणी करता है। ऊपर की ओर तीर लंबाई में वृद्धि दर्शाता है।',
        ),
        LabStep(
          concept: 'आवाज़ में बदलाव',
          action: 'अब देवयानी की प्रतिक्रिया सुनने के लिए उस पर क्लिक करें।',
          observation: 'देवयानी वेंकटेश की आवाज़ में बदलाव पर ध्यान देती है। उसके गले पर ध्वनि तरंग दिखाई देती है।',
        ),
        LabStep(
          concept: 'चेहरे के बाल',
          action: 'देवयानी को कुछ और कहना है। उस पर फिर से क्लिक करें।',
          observation: 'देवयानी मूंछों की ओर इशारा करती है। वेंकटेश पर हल्की मूंछें दिखाई देती हैं।',
        ),
        LabStep(
          concept: 'संकेतों की पहचान',
          action:
              'एक सारांश पैनल दिखाई देता है। देखे गए परिवर्तनों (लंबाई, आवाज़, मूंछें) के आइकन को "किशोरावस्था के संकेत" वाले बॉक्स में खींचें।',
          observation: "आइकन सफलतापूर्वक 'किशोरावस्था के संकेत' के रूप में वर्गीकृत हो गए हैं।",
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'गतिविधि 6.1 के अनुसार, अलग-अलग कक्षाओं के छात्रों की दृश्य तुलना करके किशोरावस्था के दौरान होने वाले सामान्य शारीरिक परिवर्तनों को पहचानना।',
      steps: [
        LabStep(
          concept: 'आधार रेखा तुलना',
          action:
              'आपको छात्र अवतारों के दो समूह दिखते हैं: "कक्षा 5" और "कक्षा 8"। "कक्षा 5 के लड़के" अवतार को बाएँ तुलना स्टैंड पर खींचें।',
          observation: 'छोटा लड़का यौवन से पहले की आधार रेखा का काम करता है।',
        ),
        LabStep(
          concept: 'दिखाई देने वाली वृद्धि',
          action: 'अब परिवर्तन देखने के लिए "कक्षा 8 के लड़के" अवतार को दाएँ तुलना स्टैंड पर खींचें।',
          observation: 'बड़ा लड़का स्पष्ट रूप से अधिक लंबा और चौड़ा है।',
        ),
        LabStep(
          concept: 'लड़कों में परिवर्तन',
          action: 'कक्षा 8 के लड़के पर कई जगहें चमक रही हैं। परिवर्तन पहचानने के लिए हर चमकते हॉटस्पॉट पर क्लिक करें।',
          observation: 'पहचाने गए: लंबाई में वृद्धि, चौड़े कंधे, एडम्स एप्पल, मुंहासे।',
        ),
        LabStep(
          concept: 'ध्यान बदलना',
          action:
              "बहुत बढ़िया! अब लड़कियों में परिवर्तन देखते हैं। 'लड़कियों के लिए रीसेट करें' बटन पर क्लिक करें और लड़की अवतारों के साथ यही प्रक्रिया दोहराएँ।",
          observation: 'स्टैंड खाली हो जाते हैं और तुलना के लिए लड़की अवतार रखे जाते हैं।',
        ),
        LabStep(
          concept: 'लड़कियों में परिवर्तन',
          action: 'परिवर्तनों को पहचानने के लिए कक्षा 8 की लड़की पर चमकते हॉटस्पॉट पर क्लिक करें।',
          observation: 'पहचाने गए: लंबाई में वृद्धि, स्तनों का विकास, मुंहासे।',
        ),
        LabStep(
          concept: 'वर्गीकरण की तैयारी',
          action: "अवलोकन जार भर गया है! परिवर्तनों को क्रमबद्ध करने के लिए 'वर्गीकृत करें' पर क्लिक करें।",
          observation: 'आइकन बाहर गिरते हैं और छाँटने के लिए तैयार हैं।',
        ),
        LabStep(
          concept: 'परिवर्तनों को छाँटना',
          action: 'जार से हर आइकन को टेबल के सही कॉलम में खींचें।',
          observation: 'परिवर्तन लड़कों, लड़कियों या दोनों के लिए सही ढंग से छाँटे गए हैं।',
        ),
      ],
    ),
  ],
};

// ============================================================== STATE

const Size _design = Size(1000, 560);

/// The HTML perspective camera (eye at (0, 5, 12) looking at (0, 2, 0)),
/// projecting world units to design px. [center] is the design point the
/// camera looks at and [focal] the focal length in design px.
class _Cam {
  const _Cam(this.center, this.focal);

  final Offset center;
  final double focal;

  static const double _eyeY = 5;
  static const double _eyeZ = 12;
  // Unit view direction (0, -3, -12) / |(0, -3, -12)|.
  static const double _fy = -0.24253562503633297;
  static const double _fz = -0.9701425001453319;

  /// Design point of world (x, y, z) and the local scale (px per unit).
  ({Offset p, double k}) project(double x, double y, double z) {
    final dy = y - _eyeY;
    final dz = z - _eyeZ;
    final yc = -dy * _fz + dz * _fy;
    final zc = dy * _fy + dz * _fz;
    final k = focal / zc;
    return (p: Offset(center.dx + x * k, center.dy - yc * k), k: k);
  }

  Offset point(double x, double y, double z) => project(x, y, z).p;

  /// Where the ray under design point [s] meets the plane y = [h] (the HTML
  /// invisible drag plane).
  ({double x, double z})? planeHit(Offset s, double h) {
    final xn = (s.dx - center.dx) / focal;
    final yn = -(s.dy - center.dy) / focal;
    final dy = _fy - yn * _fz;
    final dz = _fz + yn * _fy;
    if (dy > -1e-4) return null;
    final t = (h - _eyeY) / dy;
    return (x: t * xn, z: _eyeZ + t * dz);
  }
}

/// Scenario 1 framing (characters left of centre, chat on the right) and
/// scenario 2 framing (stands in the middle, lineups on both sides).
const _Cam _cam1 = _Cam(Offset(300, 290), 1150);
const _Cam _cam2 = _Cam(Offset(500, 290), 900);

/// The physical changes the lab names (HTML `SVGs` + label keys).
enum _Sign { height, voice, moustache, shoulders, adams, pimples, breasts }

String _signKey(_Sign s) => switch (s) {
  _Sign.height => 'lbl_height',
  _Sign.voice => 'lbl_voice',
  _Sign.moustache => 'lbl_moustache',
  _Sign.shoulders => 'lbl_shoulders',
  _Sign.adams => 'lbl_adams',
  _Sign.pimples => 'lbl_pimples',
  _Sign.breasts => 'lbl_breasts',
};

Color _signColor(_Sign s) => switch (s) {
  _Sign.height => _Colors.blue500,
  _Sign.pimples => _Colors.red500,
  _Sign.breasts => _Colors.pink500,
  _ => _Colors.indigo500,
};

/// Columns of the categorisation table (HTML `data-accept`).
enum _Col { boys, girls, common }

/// The column a change belongs to (HTML drop rules).
_Col _colOf(_Sign s) => switch (s) {
  _Sign.shoulders || _Sign.adams => _Col.boys,
  _Sign.breasts => _Col.girls,
  _ => _Col.common,
};

enum _Side { up, leftUp, rightUp, rightDown }

/// A hotspot on a Grade 8 avatar, in the avatar's local units (HTML
/// `createHotspot` positions), plus where its label sits.
class _SpotDef {
  const _SpotDef(this.id, this.sign, this.x, this.y, this.side);

  final String id;
  final _Sign sign;
  final double x;
  final double y;
  final _Side side;
}

const List<_SpotDef> _boySpots = [
  _SpotDef('height', _Sign.height, 0, 3.2, _Side.up),
  _SpotDef('shoulders', _Sign.shoulders, -0.6, 1.8, _Side.leftUp),
  _SpotDef('adams', _Sign.adams, 0, 1.99, _Side.rightDown),
  _SpotDef('pimples', _Sign.pimples, 0.22, 2.36, _Side.rightUp),
];

const List<_SpotDef> _girlSpots = [
  _SpotDef('height_g', _Sign.height, 0, 3.2, _Side.up),
  _SpotDef('breasts', _Sign.breasts, 0, 1.6, _Side.rightDown),
  _SpotDef('pimples_g', _Sign.pimples, 0.22, 2.36, _Side.rightUp),
];

/// A draggable comparison avatar (HTML `Objects.s2.avatars`).
class _Avatar {
  _Avatar(
    this.id, {
    required this.girl,
    required this.grade8,
    required this.scale,
    required this.homeX,
    required this.homeZ,
  }) : x = homeX,
       z = homeZ;

  final String id;
  final bool girl;
  final bool grade8;
  final double scale;
  final double homeX;
  final double homeZ;

  double x;
  double y = 0;
  double z;
  bool visible = true;
  bool placed = false;

  /// Return tween to the home spot after a wrong drop (HTML 300 ms TWEEN).
  double? backT0;
  double backX = 0, backY = 0, backZ = 0;

  void goHome() {
    x = homeX;
    y = 0;
    z = homeZ;
    placed = false;
    backT0 = null;
  }
}

class _Spot {
  _Spot(this.def, this.avatar);

  final _SpotDef def;
  final _Avatar avatar;
  double? foundAt;
}

/// A change icon collected in the observation jar.
class _JarItem {
  const _JarItem(this.id, this.sign);

  final String id;
  final _Sign sign;
}

class _Msg {
  const _Msg(this.venkatesh, this.key);

  final bool venkatesh;
  final String key;
}

/// Mutable scene model read by the painter every frame.
class _TeenScene {
  int scenario = 0;
  int step = 1;
  double time = 0;

  // Scenario 1 (HTML State.s1 + Objects.s1).
  double venkTalk = -1; // talking until (scene time)
  double devTalk = -1;
  double? arrowT0;
  double? waveT0;
  double? stacheT0;
  double? fadeT0; // arrow / wave / moustache shrink away
  final List<_Msg> chat = [];
  bool s1Panel = false;
  final List<_Sign> s1Zone = [];

  // Scenario 2 (HTML State.s2 + Objects.s2).
  bool girls = false;
  final Map<String, _Avatar> avatars = {
    'g5b': _Avatar('g5b', girl: false, grade8: false, scale: 0.85, homeX: -5.5, homeZ: -1.5),
    'g8b': _Avatar('g8b', girl: false, grade8: true, scale: 1.25, homeX: 5.5, homeZ: -1.5),
    'g5g': _Avatar('g5g', girl: true, grade8: false, scale: 0.9, homeX: -5.5, homeZ: -1.5),
    'g8g': _Avatar('g8g', girl: true, grade8: true, scale: 1.15, homeX: 5.5, homeZ: -1.5),
  };
  int hoverStand = -1;
  final List<_Spot> spots = [];
  final List<_JarItem> jar = [];
  bool jarVisible = false;
  bool tableVisible = false;
  final List<_JarItem> spilled = [];
  final Map<_Col, List<_JarItem>> sorted = {for (final c in _Col.values) c: <_JarItem>[]};

  bool conclusionReady = false;

  _Avatar get g5 => avatars[girls ? 'g5g' : 'g5b']!;
  _Avatar get g8 => avatars[girls ? 'g8g' : 'g8b']!;

  /// HTML `resetScenarioState()` for both scenarios.
  void reset() {
    step = 1;
    venkTalk = -1;
    devTalk = -1;
    arrowT0 = null;
    waveT0 = null;
    stacheT0 = null;
    fadeT0 = null;
    chat.clear();
    s1Panel = false;
    s1Zone.clear();
    girls = false;
    for (final a in avatars.values) {
      a
        ..goHome()
        ..visible = !a.girl;
    }
    hoverStand = -1;
    spots.clear();
    jar.clear();
    jarVisible = false;
    tableVisible = false;
    spilled.clear();
    for (final list in sorted.values) {
      list.clear();
    }
    conclusionReady = false;
  }

  /// Per-frame updates that are not tied to setState (return tweens).
  void tick() {
    for (final a in avatars.values) {
      final t0 = a.backT0;
      if (t0 == null) continue;
      final v = Curves.easeOut.transform(((time - t0) / 0.3).clamp(0.0, 1.0));
      a
        ..x = a.backX + (a.homeX - a.backX) * v
        ..y = a.backY * (1 - v)
        ..z = a.backZ + (a.homeZ - a.backZ) * v;
      if (v >= 1) a.backT0 = null;
    }
  }
}

/// Drags avatars only when the pointer goes down on one, so pinch / pan of
/// the canvas keeps working everywhere else.
class _ItemPanRecognizer extends PanGestureRecognizer {
  _ItemPanRecognizer() : super(debugOwner: null);

  bool Function(Offset local) accepts = _never;

  static bool _never(Offset _) => false;

  @override
  bool isPointerAllowed(PointerEvent event) => accepts(event.localPosition) && super.isPointerAllowed(event);
}

class _Ch6A1IntroductionToAdolescencePageState extends State<Ch6A1IntroductionToAdolescencePage>
    with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _TeenScene _scene = _TeenScene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final ScrollController _chatScroll = ScrollController();

  late final Ticker _ticker;
  late final AnimationController _jarTip = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  // Avatar drag (HTML dragObj / dragOffset on the y = 0.5 plane).
  _Avatar? _dragAvatar;
  double _dragDx = 0, _dragDz = 0;

  /// Chat panel opened / closed by the user (null: automatic).
  bool? _chatOpen;

  /// Drop-zone flashes (HTML `.success` / `.error` for 500 ms).
  final Map<String, ({bool ok, int serial})> _flash = {};
  int _flashSerial = 0;

  double? _confettiT0;
  List<_Confetto> _confetti = const [];

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_scene.scenario];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _ticker = createTicker((elapsed) {
      _scene
        ..time = elapsed.inMicroseconds / 1e6
        ..tick();
      _frame.value = _scene.time;
    })..start();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ticker.dispose();
    _jarTip.dispose();
    _chatScroll.dispose();
    _frame.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ logic

  /// HTML `resetScenarioState()`: clears chat, trays, jar, table and puts
  /// every avatar back.
  void _rebuildScene() {
    _lab.cancelPending();
    _jarTip
      ..stop()
      ..value = 0;
    _dragAvatar = null;
    _chatOpen = null;
    _flash.clear();
    _confettiT0 = null;
    _scene.reset();
    _lab.resetView(sound: false);
  }

  void _changeScenario(int index) {
    setState(() {
      _scene.scenario = index;
      _lab.hidePopup(sound: false);
      _rebuildScene();
    });
  }

  void _fullReset() {
    setState(() {
      _scene.scenario = 0;
      _rebuildScene();
    });
  }

  void _flashZone(String id, bool ok) {
    final serial = ++_flashSerial;
    _flash[id] = (ok: ok, serial: serial);
    _lab.after(const Duration(milliseconds: 500), () {
      if (!mounted || _flash[id]?.serial != serial) return;
      setState(() => _flash.remove(id));
    });
  }

  /// HTML `triggerConclusionState()`: shows "Review Findings" with a chime.
  void _conclusionReady() {
    _Audio.play(_Sound.magic);
    setState(() {
      _scene
        ..conclusionReady = true
        ..step += 1;
    });
  }

  /// HTML `triggerConclusion()`: confetti and the summary popup.
  void _showConclusion() {
    final idx = _scene.scenario;
    setState(() {
      _confettiT0 = _scene.time;
      _confetti = _Confetto.burst(150);
    });
    _lab.showScenarioConclusion(
      scenarioIndex: idx,
      totalScenarios: 2,
      title: () => _t('success'),
      heading: () => _t('discovery_complete'),
      body: () => _t('summary_${idx + 1}'),
      extra: () => idx == 0 ? _summaryS1() : _summaryS2(),
    );
  }

  // ------------------------------------------------- scenario 1 logic

  /// HTML `handleS1Click(id)`.
  void _handleS1Click(bool venkatesh) {
    final sc = _scene;
    final t = sc.time;
    if (sc.step == 1 && venkatesh) {
      _Audio.play(_Sound.pop);
      setState(() {
        sc.chat.add(const _Msg(true, 's1_bubble1'));
        sc
          ..venkTalk = t + 2.5
          ..devTalk = -1
          ..arrowT0 = t
          ..step += 1;
      });
      _scrollChat();
    } else if (sc.step == 2 && !venkatesh) {
      _Audio.play(_Sound.buzz);
      setState(() {
        sc.chat.add(const _Msg(false, 's1_bubble2'));
        sc
          ..devTalk = t + 2.5
          ..venkTalk = -1
          ..waveT0 = t
          ..step += 1;
      });
      _scrollChat();
    } else if (sc.step == 3 && !venkatesh) {
      _Audio.play(_Sound.pop);
      setState(() {
        sc.chat.add(const _Msg(false, 's1_bubble3'));
        sc
          ..devTalk = t + 2.5
          ..venkTalk = -1
          ..stacheT0 = t
          ..step += 1;
      });
      _scrollChat();
      _lab.after(const Duration(milliseconds: 1500), _showS1Panel);
    }
  }

  /// HTML `showS1DragUI()`: the drag panel slides in and the 3D cues shrink.
  void _showS1Panel() {
    if (!mounted || _scene.scenario != 0) return;
    setState(() {
      _scene
        ..s1Panel = true
        ..fadeT0 = _scene.time;
    });
  }

  void _scrollChat() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_chatScroll.hasClients) return;
      _chatScroll.animateTo(
        _chatScroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  /// A sign dropped on "Signs of Adolescence" (always correct in the HTML).
  void _dropS1(_Sign sign) {
    final sc = _scene;
    if (sc.scenario != 0 || sc.s1Zone.contains(sign)) return;
    _Audio.play(_Sound.correct);
    setState(() {
      sc.s1Zone.add(sign);
      _flashZone('s1', true);
    });
    if (sc.s1Zone.length == 3) {
      _lab.after(const Duration(milliseconds: 1500), () {
        if (!mounted || sc.scenario != 0) return;
        setState(() => sc.s1Panel = false);
        _conclusionReady();
      });
    }
  }

  /// The character under a design point (HTML invisible hit cylinders).
  bool? _hitCharacter(Offset p) {
    for (final (venk, x, scale) in const [(true, -2.0, 1.2), (false, 2.0, 0.9)]) {
      final pr = _cam1.project(x, 0, 0);
      final u = pr.k * scale;
      final r = Rect.fromLTRB(pr.p.dx - 0.8 * u, pr.p.dy - 3.2 * u, pr.p.dx + 0.8 * u, pr.p.dy + 0.3 * u);
      if (r.contains(p)) return venk;
    }
    return null;
  }

  // ------------------------------------------------- scenario 2 logic

  /// HTML pointerdown rules: boys at steps 1-2, girls at step 4.
  bool _canDrag(_Avatar a) {
    final sc = _scene;
    if (!a.visible || a.placed || a.backT0 != null) return false;
    if (!sc.girls) return sc.step == 1 || sc.step == 2;
    return sc.step == 4;
  }

  _Avatar? _hitAvatar(Offset p) {
    _Avatar? best;
    for (final a in _scene.avatars.values) {
      if (!_canDrag(a)) continue;
      final pr = _cam2.project(a.x, a.y, a.z);
      final u = pr.k * a.scale;
      final r = Rect.fromLTRB(pr.p.dx - 0.62 * u, pr.p.dy - 3.0 * u, pr.p.dx + 0.62 * u, pr.p.dy + 0.2 * u);
      if (r.contains(p) && (best == null || a.z > best.z)) best = a;
    }
    return best;
  }

  void _grab(Offset p) {
    final a = _hitAvatar(p);
    final hit = _cam2.planeHit(p, 0.5);
    if (a == null || hit == null) return;
    _dragAvatar = a;
    _dragDx = hit.x - a.x;
    _dragDz = hit.z - a.z;
  }

  void _dragTo(Offset p) {
    final a = _dragAvatar;
    final hit = _cam2.planeHit(p, 0.5);
    if (a == null || hit == null) return;
    a
      ..x = (hit.x - _dragDx).clamp(-9.0, 9.0)
      ..z = (hit.z - _dragDz).clamp(-4.5, 4.5)
      ..y = 1;
    _scene.hoverStand = _standUnder(a);
  }

  /// Stand within reach of [a] (HTML distance < 1.5 with the avatar lifted).
  int _standUnder(_Avatar a) {
    for (var i = 0; i < 2; i++) {
      final dx = a.x - (i == 0 ? -2 : 2);
      if (math.sqrt(dx * dx + a.z * a.z) < 1.2) return i;
    }
    return -1;
  }

  /// HTML pointerup: snap onto the right stand or tween back home.
  void _release() {
    final a = _dragAvatar;
    if (a == null) return;
    _dragAvatar = null;
    final sc = _scene;
    final stand = _standUnder(a);
    sc.hoverStand = -1;
    final is5 = a.id.startsWith('g5');
    final rightStand = stand == (is5 ? 0 : 1);
    final ok =
        stand >= 0 &&
        (sc.girls
            ? sc.step == 4 && rightStand
            : ((sc.step == 1 && a.id == 'g5b') || (sc.step == 2 && a.id == 'g8b')) && rightStand);
    if (!ok) {
      a
        ..backX = a.x
        ..backY = a.y
        ..backZ = a.z
        ..backT0 = sc.time;
      if (stand >= 0 && !rightStand) {
        _lab.showToast(_t('wrong_stand'), isError: true);
      } else if (stand >= 0) {
        _lab.showToast(_t('place_g5_first'), isError: true);
      } else {
        _Audio.play(_Sound.wrong);
      }
      setState(() {});
      return;
    }
    _Audio.play(_Sound.correct);
    setState(() {
      a
        ..x = stand == 0 ? -2 : 2
        ..y = 0.2
        ..z = 0
        ..placed = true;
      if (!sc.girls) {
        sc.step++;
        if (sc.step == 3) _spawnSpots();
      } else if (sc.g5.placed && sc.g8.placed) {
        sc.step++;
        _spawnSpots();
      }
    });
  }

  /// HTML `spawnS2Hotspots(mode)`: glowing spots on the Grade 8 avatar.
  void _spawnSpots() {
    final sc = _scene;
    sc.spots
      ..clear()
      ..addAll([for (final d in sc.girls ? _girlSpots : _boySpots) _Spot(d, sc.g8)]);
    sc.jarVisible = true;
  }

  /// Design-space centre of a hotspot.
  Offset _spotCenter(_Spot s) {
    final a = s.avatar;
    final pr = _cam2.project(a.x, a.y, a.z);
    final u = pr.k * a.scale;
    return pr.p + Offset(s.def.x * u, -s.def.y * u);
  }

  _Spot? _hitSpot(Offset p) {
    _Spot? best;
    var bestD = double.infinity;
    for (final s in _scene.spots) {
      if (s.foundAt != null) continue;
      final pr = _cam2.project(s.avatar.x, s.avatar.y, s.avatar.z);
      final d = (_spotCenter(s) - p).distance;
      if (d < 0.4 * pr.k * s.avatar.scale && d < bestD) {
        best = s;
        bestD = d;
      }
    }
    return best;
  }

  /// HTML `handleS2Hotspot()` + `spawnIconInJar()`.
  void _handleSpot(_Spot s) {
    final sc = _scene;
    _Audio.play(_Sound.pop);
    setState(() {
      s.foundAt = sc.time;
      sc.jar.add(_JarItem(s.def.id, s.def.sign));
    });
    _lab.after(const Duration(milliseconds: 250), () => _Audio.play(_Sound.drop));
    if (sc.spots.every((e) => e.foundAt != null)) {
      // Boys: "Reset for Girls" appears. Girls: "Categorize" appears.
      _lab.after(const Duration(milliseconds: 1500), () {
        if (!mounted || sc.scenario != 1) return;
        setState(() => sc.step++);
      });
    }
  }

  /// HTML `handleS2Reset()`: clear the stands and bring in the girls.
  void _resetForGirls() {
    final sc = _scene;
    if (sc.girls) return;
    setState(() {
      sc.avatars['g5b']!.visible = false;
      sc.avatars['g8b']!.visible = false;
      for (final id in const ['g5g', 'g8g']) {
        sc.avatars[id]!
          ..goHome()
          ..visible = true;
      }
      sc
        ..girls = true
        ..jarVisible = false;
      sc.spots.clear();
    });
  }

  /// HTML `handleS2Categorize()`: the jar tips over and the table opens.
  void _categorize() {
    final sc = _scene;
    if (sc.tableVisible) return;
    _jarTip.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      setState(() => sc.jarVisible = false);
      _jarTip.value = 0;
    });
    setState(() {
      sc
        ..tableVisible = true
        ..step += 1;
      sc.spilled
        ..clear()
        ..addAll(sc.jar);
    });
  }

  void _dropTable(_JarItem item, _Col col) {
    final sc = _scene;
    if (!sc.spilled.contains(item)) return;
    if (_colOf(item.sign) != col) {
      setState(() => _flashZone(col.name, false));
      _lab.showToast(_t('wrong_column'), isError: true);
      return;
    }
    _Audio.play(_Sound.correct);
    setState(() {
      sc.spilled.remove(item);
      sc.sorted[col]!.add(item);
      _flashZone(col.name, true);
    });
    if (sc.spilled.isEmpty) {
      _lab.after(const Duration(seconds: 1), () {
        if (mounted && sc.scenario == 1 && !sc.conclusionReady) _conclusionReady();
      });
    }
  }

  // ------------------------------------------------------ gestures

  void _onTapUp(TapUpDetails d) {
    if (!_lab.isLabActive) return;
    final p = d.localPosition;
    if (_scene.scenario == 0) {
      final who = _hitCharacter(p);
      if (who != null) _handleS1Click(who);
    } else {
      final spot = _hitSpot(p);
      if (spot != null) _handleSpot(spot);
    }
  }

  List<LabAction> _actions() {
    final sc = _scene;
    if (sc.conclusionReady) {
      return [
        LabAction(
          label: _t('btn_conclude'),
          icon: Icons.check_circle,
          color: _Colors.violet600,
          foreground: Colors.white,
          highlight: true,
          silent: true, // the popup plays the success tone
          onTap: _showConclusion,
        ),
      ];
    }
    if (sc.scenario == 1 && sc.step == 4 && !sc.girls) {
      return [
        LabAction(
          label: _t('reset_girls'),
          icon: Icons.sync,
          color: _Colors.slate700,
          foreground: Colors.white,
          highlight: true,
          onTap: _resetForGirls,
        ),
      ];
    }
    if (sc.scenario == 1 && sc.step == 6 && !sc.tableVisible) {
      return [
        LabAction(
          label: _t('btn_categorize'),
          icon: Icons.format_list_bulleted,
          color: _Colors.violet600,
          foreground: Colors.white,
          highlight: true,
          sound: _Sound.whoosh,
          onTap: _categorize,
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
        final data = _data;
        final sc = _scene;
        final inset = labOverlayInsets(context, _lab);
        final done = sc.step > data.steps.length;
        final stageScale = math.min(
          _canvasWidth(context) / _design.width,
          MediaQuery.sizeOf(context).height / _design.height,
        );
        final instruction = done
            ? _t('hud_summarize')
            : (sc.scenario == 1 && sc.step == 4 && sc.girls ? _t('hud_girls') : null);
        return LabShell(
          controller: _lab,
          icon: Icons.groups_rounded,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: sc.scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: sc.step,
          instruction: instruction,
          actions: _actions(),
          onReset: _fullReset,
          overlays: _overlays(context, p, s, inset),
          stage: LabStage(
            designSize: _design,
            child: RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              gestures: {
                _ItemPanRecognizer: GestureRecognizerFactoryWithHandlers<_ItemPanRecognizer>(
                  _ItemPanRecognizer.new,
                  (r) => r
                    ..accepts = ((local) => _lab.isLabActive && _scene.scenario == 1 && _hitAvatar(local) != null)
                    ..dragStartBehavior = DragStartBehavior.down
                    ..gestureSettings = const DeviceGestureSettings(touchSlop: 4)
                    ..onStart = ((d) => _grab(d.localPosition))
                    ..onUpdate = ((d) => _dragTo(d.localPosition))
                    ..onEnd = ((_) => _release())
                    ..onCancel = _release,
                ),
                TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                  TapGestureRecognizer.new,
                  (r) => r.onTapUp = _onTapUp,
                ),
              },
              child: CustomPaint(
                size: _design,
                painter: _ScenePainter(
                  scene: _scene,
                  repaint: _frame,
                  isDark: _lab.isDark,
                  showLabels: _lab.showLabels,
                  lang: _lab.lang.code,
                  tr: _t,
                  labelPx: (11.5 / stageScale).clamp(15.0, 26.0),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Width of the canvas area (screen minus the open sidebar).
  double _canvasWidth(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (!_lab.isSidebarOpen) return w;
    final min = math.max(180.0, w * 0.2);
    final max = math.max(min, w * 0.5);
    return w - (w * _lab.sidebarFraction).clamp(min, max);
  }

  /// Overlay slots keep fixed indices (so dragged cards keep their offsets);
  /// an empty slot is a non-interactive fill.
  List<Widget> _overlays(BuildContext context, LabPalette p, double s, EdgeInsets inset) {
    const empty = Positioned.fill(child: SizedBox.shrink());
    final sc = _scene;
    final avail = _canvasWidth(context) - inset.left - inset.right;
    final chatW = math.min((avail * 0.36).clamp(150 * s, 230 * s), avail);
    final fits = avail - chatW - 10 >= 250 * s;
    final chatOpen = _chatOpen ?? !(sc.s1Panel && !fits);
    final panelW = math.min(310 * s, avail - (chatOpen ? chatW : 70 * s) - 10).clamp(200 * s, 310 * s);
    final hud = _lab.isSidebarOpen ? 58 * s : 0.0;
    return [
      if (sc.scenario == 0 && sc.chat.isNotEmpty)
        Positioned(
          top: inset.top,
          right: inset.right,
          child: chatOpen ? SizedBox(width: chatW, child: _chatPanel(p, s, open: true)) : _chatPanel(p, s, open: false),
        )
      else
        empty,
      if (sc.scenario == 0 && sc.s1Panel)
        Positioned(top: inset.top, left: inset.left, child: _s1Panel(s, panelW))
      else
        empty,
      if (sc.scenario == 1 && sc.jarVisible)
        _lab.isSidebarOpen
            ? Positioned(left: inset.left + 4, bottom: inset.bottom + hud, child: _jarCard(s))
            : Positioned(right: inset.right + 4, bottom: inset.bottom, child: _jarCard(s))
      else
        empty,
      if (sc.scenario == 1 && sc.tableVisible)
        Positioned(
          top: inset.top,
          left: inset.left,
          right: inset.right,
          child: Align(alignment: Alignment.topCenter, child: _table(s, math.min(avail, 640 * s))),
        )
      else
        empty,
      if (_confettiT0 != null)
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _ConfettiPainter(pieces: _confetti, t0: _confettiT0!, scene: _scene, repaint: _frame),
            ),
          ),
        )
      else
        empty,
    ];
  }

  // ------------------------------------------------- shared widgets

  /// Pill chip with a change icon and its name (HTML `.draggable-icon`).
  Widget _chip(_Sign sign, double s, {required double maxW, double icon = 22, double font = 11, bool lifted = false}) {
    final label = Text(
      _t(_signKey(sign)),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: _lab.isDark ? _Colors.slate300 : _Colors.slate700,
        fontSize: font * s,
        fontWeight: FontWeight.w700,
        height: 1.15,
      ),
    );
    final dark = _lab.isDark;
    return Container(
      constraints: BoxConstraints(maxWidth: maxW),
      padding: EdgeInsets.fromLTRB(4 * s, 3 * s, 9 * s, 3 * s),
      decoration: BoxDecoration(
        color: dark ? _Colors.slate800 : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: dark ? _Colors.slate700 : _Colors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: lifted ? 0.35 : 0.14),
            blurRadius: lifted ? 18 : 4,
            offset: Offset(0, lifted ? 8 : 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: icon * s,
            child: CustomPaint(painter: _SignPainter(sign, _signColor(sign))),
          ),
          SizedBox(width: 4 * s),
          Flexible(child: label),
        ],
      ),
    );
  }

  /// Round icon badge for a sign that has been dropped (HTML w-12 h-12
  /// `.draggable-icon` circles).
  Widget _badge(_Sign sign, double s) {
    final dark = _lab.isDark;
    return Tooltip(
      message: _t(_signKey(sign)),
      child: Container(
        width: 34 * s,
        height: 34 * s,
        padding: EdgeInsets.all(7 * s),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: dark ? _Colors.slate800 : Colors.white,
          border: Border.all(color: dark ? _Colors.slate700 : _Colors.slate200),
          boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: CustomPaint(painter: _SignPainter(sign, _signColor(sign))),
      ),
    );
  }

  /// A chip the learner can drag (HTML pointer drag with a lifted copy).
  Widget _draggable<T extends Object>(T data, _Sign sign, double s, double maxW, {Key? key}) {
    final chip = _chip(sign, s, maxW: maxW);
    return Draggable<T>(
      key: key,
      data: data,
      feedback: Material(
        type: MaterialType.transparency,
        child: Transform.scale(scale: 1.1, child: _chip(sign, s, maxW: maxW, lifted: true)),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: chip),
      onDragStarted: () => _Audio.play(_Sound.pickup),
      onDraggableCanceled: (_, _) => _Audio.play(_Sound.wrong),
      child: MouseRegion(cursor: SystemMouseCursors.grab, child: chip),
    );
  }

  /// Drop zone box: violet while hovered, green / red flash after a drop.
  Widget _zoneBox({
    required double s,
    required String id,
    required bool active,
    required Color idleBg,
    required Color idleBorder,
    required BorderRadius radius,
    required Widget child,
    bool dashed = false,
    double? height,
  }) {
    final f = _flash[id];
    final Color border;
    final Color bg;
    if (f != null) {
      border = f.ok ? _Colors.emerald500 : _Colors.red500;
      bg = border.withValues(alpha: 0.2);
    } else if (active) {
      border = _Colors.violet500;
      bg = _Colors.violet500.withValues(alpha: 0.2);
    } else {
      border = idleBorder;
      bg = idleBg;
    }
    final box = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: height,
      padding: EdgeInsets.all(6 * s),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
        border: dashed ? null : Border.all(color: border, width: 1.5),
      ),
      child: child,
    );
    if (!dashed) return box;
    return CustomPaint(
      foregroundPainter: _DashedBorderPainter(color: border, radius: radius.topLeft.x, width: 2),
      child: box,
    );
  }

  /// Small rounded glass card used by the trays and the table.
  BoxDecoration _glass(double s) => BoxDecoration(
    color: _lab.isDark ? const Color(0xEB0F172A) : const Color(0xF2FFFFFF),
    borderRadius: BorderRadius.circular(16 * s),
    border: Border.all(color: _Colors.violet500, width: 2),
    boxShadow: const [BoxShadow(color: Color(0x59000000), blurRadius: 24, offset: Offset(0, 8))],
  );

  /// Fade + slide-in used when a panel appears (HTML `transition-all`).
  Widget _appear(double dy, Widget child, {Key? key}) {
    return TweenAnimationBuilder<double>(
      key: key,
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, dy * (1 - v)), child: child),
      ),
      child: child,
    );
  }

  // --------------------------------------------- scenario 1 overlays

  /// HTML `#s1-chat-dialog`: the conversation, newest at the bottom.
  Widget _chatPanel(LabPalette p, double s, {required bool open}) {
    final dark = _lab.isDark;
    final inset = labOverlayInsets(context, _lab);
    final hud = _lab.isSidebarOpen ? 64 * s : 0.0;
    final chatMaxH = math.max(80 * s, MediaQuery.sizeOf(context).height - inset.top - inset.bottom - hud - 56 * s);
    final title = Text(
      _t('conversation').toUpperCase(),
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: dark ? _Colors.violet300 : _Colors.slate800,
        fontSize: 10.5 * s,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.1,
      ),
    );
    final header = InkWell(
      borderRadius: BorderRadius.circular(10 * s),
      onTap: () {
        _Audio.play(_Sound.click);
        setState(() => _chatOpen = !open);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2 * s, horizontal: 2 * s),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.forum_rounded, size: 17 * s, color: _Colors.violet500),
            SizedBox(width: 6 * s),
            if (open) Expanded(child: title) else _countBadge(s, _scene.chat.length),
            SizedBox(width: 4 * s),
            Icon(open ? Icons.expand_less : Icons.expand_more, size: 18 * s, color: p.textMuted),
          ],
        ),
      ),
    );
    return _appear(
      -10 * s,
      Container(
        padding: EdgeInsets.fromLTRB(10 * s, 8 * s, 10 * s, open ? 10 * s : 8 * s),
        decoration: BoxDecoration(
          color: dark ? const Color(0xE60F172A) : const Color(0xE6FFFFFF),
          borderRadius: BorderRadius.circular((open ? 20 : 16) * s),
          border: Border.all(color: _Colors.violet500.withValues(alpha: 0.35)),
          boxShadow: const [BoxShadow(color: Color(0x59000000), blurRadius: 24, offset: Offset(0, 8))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: open ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
          children: [
            header,
            if (open) ...[
              Container(
                height: 1,
                margin: EdgeInsets.symmetric(vertical: 6 * s),
                color: dark ? const Color(0xFF4C1D95) : const Color(0xFFDDD6FE),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: chatMaxH),
                child: SingleChildScrollView(
                  controller: _chatScroll,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [for (var i = 0; i < _scene.chat.length; i++) _chatMessage(_scene.chat[i], i, s)],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _countBadge(double s, int n) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 1 * s),
      decoration: BoxDecoration(color: _Colors.violet500, borderRadius: BorderRadius.circular(999)),
      child: Text(
        '$n',
        style: TextStyle(color: Colors.white, fontSize: 10 * s, fontWeight: FontWeight.w800),
      ),
    );
  }

  /// One chat bubble (HTML `addChatMessage`): Venkatesh on the left in
  /// blue, Devyani on the right in pink.
  Widget _chatMessage(_Msg m, int index, double s) {
    final dark = _lab.isDark;
    final v = m.venkatesh;
    final nameColor = v ? (dark ? _Colors.blue400 : _Colors.blue600) : (dark ? _Colors.pink400 : _Colors.pink600);
    final bubbleBg = v
        ? (dark ? const Color(0x661E3A8A) : _Colors.blue50)
        : (dark ? const Color(0x66831843) : _Colors.pink50);
    final bubbleBorder = v ? (dark ? _Colors.blue800 : _Colors.blue200) : (dark ? _Colors.pink800 : _Colors.pink200);
    final r = Radius.circular(14 * s);
    final avatar = Container(
      width: 30 * s,
      height: 30 * s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: dark ? _Colors.slate800 : Colors.white,
        border: Border.all(color: dark ? _Colors.slate700 : _Colors.slate200),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 3, offset: Offset(0, 1))],
      ),
      child: ClipOval(
        child: CustomPaint(painter: _HeadIconPainter(girl: !v)),
      ),
    );
    final bubble = Flexible(
      child: Column(
        crossAxisAlignment: v ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4 * s),
            child: Text(
              _t(v ? 'name_venkatesh' : 'name_devyani').toUpperCase(),
              style: TextStyle(color: nameColor, fontSize: 8.5 * s, fontWeight: FontWeight.w900, letterSpacing: 0.8),
            ),
          ),
          SizedBox(height: 2 * s),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 9 * s, vertical: 7 * s),
            decoration: BoxDecoration(
              color: bubbleBg,
              border: Border.all(color: bubbleBorder),
              borderRadius: BorderRadius.only(
                topLeft: v ? Radius.zero : r,
                topRight: v ? r : Radius.zero,
                bottomLeft: r,
                bottomRight: r,
              ),
            ),
            child: Text(
              _t(m.key),
              style: TextStyle(
                color: dark ? _Colors.slate100 : _Colors.slate800,
                fontSize: 12 * s,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
    return TweenAnimationBuilder<double>(
      key: ValueKey('msg-$index'),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 10 * s * (1 - t)), child: child),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: index == 0 ? 2 * s : 8 * s),
        child: FractionallySizedBox(
          widthFactor: 0.94,
          alignment: v ? Alignment.centerLeft : Alignment.centerRight,
          child: Row(
            mainAxisAlignment: v ? MainAxisAlignment.start : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: v ? [avatar, SizedBox(width: 6 * s), bubble] : [bubble, SizedBox(width: 6 * s), avatar],
          ),
        ),
      ),
    );
  }

  /// HTML `#s1-drag-layer`: drag Height / Voice / Moustache into the box.
  Widget _s1Panel(double s, double width) {
    final dark = _lab.isDark;
    final sc = _scene;
    final remaining = [
      for (final g in const [_Sign.height, _Sign.voice, _Sign.moustache])
        if (!sc.s1Zone.contains(g)) g,
    ];
    final chipW = width * 0.45;
    return _appear(
      -16 * s,
      Container(
        width: width,
        padding: EdgeInsets.all(10 * s),
        decoration: _glass(s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _t('drag_icons_here').toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: dark ? _Colors.violet400 : _Colors.violet600,
                fontSize: 10.5 * s,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 8 * s),
            SizedBox(
              height: 118 * s,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: chipW,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: chipW,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final g in remaining)
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 3 * s),
                                child: _draggable<_Sign>(g, g, s, chipW, key: ValueKey('s1-chip-${g.name}')),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3 * s),
                    child: Icon(Icons.arrow_forward_rounded, size: 20 * s, color: _Colors.slate400),
                  ),
                  Expanded(child: _s1Zone(s)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _s1Zone(double s) {
    final dark = _lab.isDark;
    return DragTarget<_Sign>(
      key: const ValueKey('zone-s1'),
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (d) => _dropS1(d.data),
      builder: (context, candidates, _) => _zoneBox(
        s: s,
        id: 's1',
        active: candidates.isNotEmpty,
        dashed: true,
        idleBg: dark ? const Color(0x800F172A) : const Color(0x80F1F5F9),
        idleBorder: _Colors.slate400,
        radius: BorderRadius.circular(12 * s),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _t('signs_zone').toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _Colors.slate400.withValues(alpha: _scene.s1Zone.isEmpty ? 0.75 : 0.3),
                    fontSize: 10 * s,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    height: 1.3,
                  ),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4 * s,
                  runSpacing: 4 * s,
                  children: [
                    for (final g in _scene.s1Zone) _appear(6 * s, _badge(g, s), key: ValueKey('in-${g.name}')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------- scenario 2 overlays

  /// HTML `#s2-jar-container`: the observation jar collecting icons.
  Widget _jarCard(double s) {
    final dark = _lab.isDark;
    return AnimatedBuilder(
      animation: _jarTip,
      builder: (context, child) {
        final v = Curves.easeIn.transform(_jarTip.value);
        return Opacity(
          opacity: 1 - v,
          child: Transform.translate(
            offset: Offset(-60 * s * v, -40 * s * v),
            child: Transform.rotate(
              angle: -math.pi / 2 * v,
              child: Transform.scale(scale: 1 - 0.2 * v, child: child),
            ),
          ),
        );
      },
      child: _appear(
        12 * s,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 7 * s, vertical: 3 * s),
              decoration: BoxDecoration(
                color: dark ? const Color(0xCC0F172A) : const Color(0xCCFFFFFF),
                borderRadius: BorderRadius.circular(6 * s),
              ),
              child: Text(
                _t('observation_jar').toUpperCase(),
                style: TextStyle(
                  color: dark ? _Colors.violet400 : _Colors.violet600,
                  fontSize: 9.5 * s,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
            SizedBox(height: 6 * s),
            SizedBox(
              width: 100 * s,
              height: 118 * s,
              child: CustomPaint(
                painter: _JarPainter(dark: dark, scale: s),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(9 * s, 16 * s, 9 * s, 9 * s),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Wrap(
                      verticalDirection: VerticalDirection.up,
                      alignment: WrapAlignment.center,
                      spacing: 3 * s,
                      runSpacing: 3 * s,
                      children: [for (final item in _scene.jar) _jarIcon(item, s)],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _jarIcon(_JarItem item, double s) {
    final dark = _lab.isDark;
    return _appear(
      10 * s,
      key: ValueKey('jar-${item.id}'),
      Tooltip(
        message: _t(_signKey(item.sign)),
        child: Container(
          width: 24 * s,
          height: 24 * s,
          padding: EdgeInsets.all(3 * s),
          decoration: BoxDecoration(
            color: dark ? _Colors.slate800 : Colors.white,
            borderRadius: BorderRadius.circular(5 * s),
            border: Border.all(color: dark ? _Colors.slate700 : _Colors.slate200),
            boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 3, offset: Offset(0, 1))],
          ),
          child: CustomPaint(painter: _SignPainter(item.sign, _signColor(item.sign))),
        ),
      ),
    );
  }

  /// HTML `#s2-table-container`: three drop columns and the spilled icons.
  Widget _table(double s, double width) {
    final dark = _lab.isDark;
    final sc = _scene;
    final colW = (width - 20 * s - 12 * s) / 3;

    Widget column(_Col col, String key, Color tint, Color headLight, Color headDark) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 30 * s,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 4 * s),
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.2),
                borderRadius: BorderRadius.vertical(top: Radius.circular(10 * s)),
                border: Border.all(color: tint.withValues(alpha: 0.3)),
              ),
              child: Text(
                _t(key).toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: dark ? headDark : headLight,
                  fontSize: 8.5 * s,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  height: 1.15,
                ),
              ),
            ),
            DragTarget<_JarItem>(
              key: ValueKey('col-${col.name}'),
              onWillAcceptWithDetails: (_) => true,
              onAcceptWithDetails: (d) => _dropTable(d.data, col),
              builder: (context, candidates, _) => _zoneBox(
                s: s,
                id: col.name,
                active: candidates.isNotEmpty,
                idleBg: tint.withValues(alpha: dark ? 0.1 : 0.06),
                idleBorder: tint.withValues(alpha: 0.3),
                radius: BorderRadius.vertical(bottom: Radius.circular(10 * s)),
                height: 92 * s,
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 3 * s,
                    runSpacing: 3 * s,
                    children: [
                      for (final item in sc.sorted[col]!)
                        _appear(
                          6 * s,
                          _chip(item.sign, s, maxW: colW - 12 * s, icon: 15, font: 8),
                          key: ValueKey('in-${item.id}'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _appear(
      30 * s,
      Container(
        width: width,
        padding: EdgeInsets.all(10 * s),
        decoration: _glass(s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _t('categorize_changes').toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: dark ? _Colors.violet400 : _Colors.violet600,
                fontSize: 11 * s,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 7 * s),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                column(_Col.boys, 'only_boys', _Colors.blue500, _Colors.blue700, _Colors.blue300),
                SizedBox(width: 6 * s),
                column(_Col.girls, 'only_girls', _Colors.pink500, _Colors.pink700, _Colors.pink300),
                SizedBox(width: 6 * s),
                column(_Col.common, 'common_both', _Colors.purple500, _Colors.purple700, _Colors.purple300),
              ],
            ),
            if (sc.spilled.isNotEmpty)
              Container(
                width: double.infinity,
                constraints: BoxConstraints(minHeight: 36 * s),
                margin: EdgeInsets.only(top: 7 * s),
                padding: EdgeInsets.only(top: 7 * s),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: dark ? _Colors.slate700 : _Colors.slate200)),
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 5 * s,
                  runSpacing: 5 * s,
                  children: [
                    for (final item in sc.spilled)
                      _draggable<_JarItem>(item, item.sign, s, 150 * s, key: ValueKey('chip-${item.id}')),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------- summary popups

  /// HTML summary visual for scenario 1: the three signs.
  Widget _summaryS1() {
    final dark = _lab.isDark;
    final s = context.labScale;
    Widget tile(_Sign sign, Color color, String label) {
      return Expanded(
        child: Column(
          children: [
            Container(
              width: 44 * s,
              height: 44 * s,
              padding: EdgeInsets.all(8 * s),
              decoration: BoxDecoration(
                color: dark ? _Colors.slate800 : _Colors.slate100,
                borderRadius: BorderRadius.circular(9 * s),
                border: Border.all(color: dark ? _Colors.slate700 : _Colors.slate200),
              ),
              child: CustomPaint(painter: _SignPainter(sign, color)),
            ),
            SizedBox(height: 6 * s),
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: dark ? _Colors.slate400 : _Colors.slate500,
                fontSize: 9.5 * s,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(12 * s),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF0B1222) : _Colors.slate50,
        borderRadius: BorderRadius.circular(14 * s),
        border: Border.all(color: dark ? _Colors.violet700 : _Colors.violet300),
      ),
      child: Column(
        children: [
          Text(
            _t('signs_of_adolescence').toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: dark ? _Colors.violet400 : _Colors.violet600,
              fontSize: 13 * s,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.6,
            ),
          ),
          SizedBox(height: 10 * s),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              tile(_Sign.height, dark ? _Colors.blue400 : _Colors.blue500, _t('lbl_height')),
              tile(_Sign.voice, dark ? _Colors.purple400 : _Colors.indigo500, _t('sum_voice')),
              tile(_Sign.moustache, _Colors.indigo500, _t('sum_facial_hair')),
            ],
          ),
        ],
      ),
    );
  }

  /// HTML summary visual for scenario 2: the sorted table.
  Widget _summaryS2() {
    final dark = _lab.isDark;
    final s = context.labScale;
    Widget column(String key, Color tint, Color head, List<_Sign> signs) {
      return Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: dark ? _Colors.slate800 : Colors.white,
            borderRadius: BorderRadius.circular(9 * s),
            border: Border.all(color: dark ? _Colors.slate700 : _Colors.slate200),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4 * s, vertical: 6 * s),
                color: tint.withValues(alpha: dark ? 0.3 : 0.15),
                child: Text(
                  _t(key),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: head, fontSize: 10 * s, fontWeight: FontWeight.w800, height: 1.2),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(6 * s),
                child: Column(
                  children: [
                    for (final sign in signs)
                      Container(
                        margin: EdgeInsets.only(bottom: 4 * s),
                        padding: EdgeInsets.all(4 * s),
                        decoration: BoxDecoration(
                          color: dark ? const Color(0x800F172A) : _Colors.slate50,
                          borderRadius: BorderRadius.circular(7 * s),
                          border: Border.all(color: dark ? _Colors.slate700 : _Colors.slate200),
                        ),
                        child: Row(
                          children: [
                            SizedBox.square(
                              dimension: 18 * s,
                              child: CustomPaint(painter: _SignPainter(sign, _signColor(sign))),
                            ),
                            SizedBox(width: 4 * s),
                            Expanded(
                              child: Text(
                                _t(_signKey(sign)).toUpperCase(),
                                style: TextStyle(
                                  color: dark ? _Colors.slate300 : _Colors.slate700,
                                  fontSize: 8.5 * s,
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
                                ),
                              ),
                            ),
                          ],
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        column('only_boys', _Colors.blue500, dark ? _Colors.blue300 : _Colors.blue700, const [
          _Sign.shoulders,
          _Sign.adams,
        ]),
        SizedBox(width: 6 * s),
        column('only_girls', _Colors.pink500, dark ? _Colors.pink300 : _Colors.pink700, const [_Sign.breasts]),
        SizedBox(width: 6 * s),
        column('common_both', _Colors.purple500, dark ? _Colors.purple300 : _Colors.purple700, const [
          _Sign.height,
          _Sign.pimples,
        ]),
      ],
    );
  }
}

// ============================================================ PAINTING

extension on Path {
  void mv(Offset o) => moveTo(o.dx, o.dy);
  void ln(Offset o) => lineTo(o.dx, o.dy);
  void qd(Offset c, Offset e) => quadraticBezierTo(c.dx, c.dy, e.dx, e.dy);
  void cb(Offset a, Offset b, Offset e) => cubicTo(a.dx, a.dy, b.dx, b.dy, e.dx, e.dy);
}

Path _poly(List<Offset> pts) {
  final path = Path()..mv(pts.first);
  for (final o in pts.skip(1)) {
    path.ln(o);
  }
  return path..close();
}

/// The HTML change icons (24 x 24 SVG view box) drawn into [box].
void _paintSign(Canvas c, _Sign sign, Rect box, Color color) {
  c
    ..save()
    ..translate(box.left, box.top)
    ..scale(box.width / 24, box.height / 24);
  final stroke = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = 2;
  final fill = Paint()..color = color;
  switch (sign) {
    case _Sign.height:
      stroke.strokeWidth = 3;
      c
        ..drawLine(const Offset(12, 19), const Offset(12, 5), stroke)
        ..drawPath(
          Path()
            ..moveTo(5, 12)
            ..lineTo(12, 5)
            ..lineTo(19, 12),
          stroke,
        );
    case _Sign.voice || _Sign.adams:
      for (final (x, h) in const [(3.0, 2.0), (7.5, 4.0), (12.0, 6.0), (16.5, 4.0), (21.0, 2.0)]) {
        c.drawLine(Offset(x, 12 - h), Offset(x, 12 + h), stroke);
      }
    case _Sign.moustache:
      c.drawPath(_moustachePath(), fill);
    case _Sign.shoulders:
      c
        ..drawLine(const Offset(12, 5), const Offset(12, 19), stroke)
        ..drawLine(const Offset(9.5, 12), const Offset(2.5, 12), stroke)
        ..drawLine(const Offset(14.5, 12), const Offset(21.5, 12), stroke)
        ..drawPath(
          Path()
            ..moveTo(5.5, 9)
            ..lineTo(2.5, 12)
            ..lineTo(5.5, 15),
          stroke,
        )
        ..drawPath(
          Path()
            ..moveTo(18.5, 9)
            ..lineTo(21.5, 12)
            ..lineTo(18.5, 15),
          stroke,
        );
    case _Sign.pimples:
      for (final (x, y, r) in const [
        (12.0, 12.0, 3.0),
        (6.0, 8.0, 1.5),
        (17.0, 6.0, 2.0),
        (18.0, 17.0, 1.5),
        (8.0, 18.0, 2.0),
      ]) {
        c.drawCircle(Offset(x, y), r, fill);
      }
    case _Sign.breasts:
      c.drawPath(
        Path()
          ..moveTo(4, 12)
          ..arcToPoint(const Offset(12, 12), radius: const Radius.circular(4))
          ..arcToPoint(const Offset(20, 12), radius: const Radius.circular(4)),
        stroke,
      );
  }
  c.restore();
}

/// Symmetric handlebar moustache in the 24 x 24 icon box.
Path _moustachePath() => Path()
  ..moveTo(12, 11.2)
  ..cubicTo(13.6, 9.6, 16.8, 9.4, 18.6, 11.2)
  ..cubicTo(19.6, 12.2, 20.8, 12.2, 21.6, 11)
  ..cubicTo(21.4, 13.6, 19, 15.4, 16.2, 14.8)
  ..cubicTo(14.4, 14.4, 13, 13.6, 12, 13.2)
  ..cubicTo(11, 13.6, 9.6, 14.4, 7.8, 14.8)
  ..cubicTo(5, 15.4, 2.6, 13.6, 2.4, 11)
  ..cubicTo(3.2, 12.2, 4.4, 12.2, 5.4, 11.2)
  ..cubicTo(7.2, 9.4, 10.4, 9.6, 12, 11.2)
  ..close();

/// Person glyph for the character name tags (HTML `ph-user`).
void _paintPerson(Canvas c, Rect box, Color color) {
  final k = box.width / 24;
  final paint = Paint()..color = color;
  c
    ..drawCircle(box.topLeft + Offset(12 * k, 7.5 * k), 4.3 * k, paint)
    ..drawPath(
      Path()
        ..moveTo(box.left + 3.5 * k, box.top + 21 * k)
        ..cubicTo(
          box.left + 3.5 * k,
          box.top + 15.5 * k,
          box.left + 7.5 * k,
          box.top + 13 * k,
          box.left + 12 * k,
          box.top + 13 * k,
        )
        ..cubicTo(
          box.left + 16.5 * k,
          box.top + 13 * k,
          box.left + 20.5 * k,
          box.top + 15.5 * k,
          box.left + 20.5 * k,
          box.top + 21 * k,
        )
        ..close(),
      paint,
    );
}

/// Floating scene label (HTML `.hotspot-label`): glass pill, coloured
/// border, icon and bold text. [anchor] picks the point of the pill at [at].
void _tag(
  Canvas c,
  String text,
  Offset at,
  Alignment anchor, {
  required bool dark,
  required Color accent,
  _Sign? sign,
  bool person = false,
  double opacity = 1,
  double size = 13,
}) {
  if (opacity <= 0) return;
  Color a(Color col) => col.withValues(alpha: col.a * opacity);
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: a(accent),
        fontFamily: LabFont.active.family,
        fontFamilyFallback: LabFont.active.fallback,
        height: 1.2,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  final icon = size * 1.1;
  final pad = size * 0.55;
  final w = pad + icon + size * 0.35 + tp.width + pad * 1.2;
  final h = math.max(tp.height, icon) + size * 0.55;
  final r = Rect.fromLTWH(at.dx - (anchor.x + 1) / 2 * w, at.dy - (anchor.y + 1) / 2 * h, w, h);
  final rr = RRect.fromRectAndRadius(r, Radius.circular(size * 0.6));
  c
    ..drawRRect(
      rr.shift(const Offset(0, 2)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.2 * opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    )
    ..drawRRect(rr, Paint()..color = a(dark ? const Color(0xEB0F172A) : const Color(0xF2FFFFFF)))
    ..drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, size * 0.09)
        ..color = a(accent),
    );
  final ib = Rect.fromLTWH(r.left + pad, r.center.dy - icon / 2, icon, icon);
  if (person) {
    _paintPerson(c, ib, a(accent));
  } else if (sign != null) {
    _paintSign(c, sign, ib, a(accent));
  }
  tp.paint(c, Offset(ib.right + size * 0.35, r.center.dy - tp.height / 2));
}

/// Draws one student avatar (HTML `createAvatar` + `addG8Details`) in a
/// lit, front-facing 2.5D style. [f] is the point between the feet and [u]
/// the size of one avatar unit in px. [talk] (0..1) opens the mouth and
/// [stache] (0..1) grows the moustache that Devyani points out.
void _paintAvatar(
  Canvas c,
  Offset f,
  double u, {
  required bool girl,
  required bool grade8,
  double talk = 0,
  double stache = 0,
}) {
  Offset pt(double x, double y) => Offset(f.dx + x * u, f.dy - y * u);
  Rect rc(double l, double b, double r, double t) =>
      Rect.fromLTRB(f.dx + l * u, f.dy - t * u, f.dx + r * u, f.dy - b * u);
  Paint shade(Color col, Rect r, {double lo = -0.3, double hi = 0.16}) => Paint()
    ..shader = LinearGradient(
      colors: [labShade(col, lo), labShade(col, hi * 0.5), labShade(col, hi), labShade(col, lo * 0.55)],
      stops: const [0, 0.42, 0.62, 1],
    ).createShader(r);
  Paint line(Color col, double w) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = w * u
    ..color = col;

  const skin = _Colors.skin;
  final shirt = girl ? _Colors.shirtGirl : _Colors.shirtBoy;
  final broad = grade8 && !girl; // HTML: torso scaled 1.3 x
  final hw = broad ? 0.455 : 0.35;
  const top = 1.92;

  // Legs and shoes.
  final legTop = girl ? 0.72 : 0.86;
  for (final sx in const [-1.0, 1.0]) {
    final x = 0.18 * sx;
    c.drawPath(
      _poly([pt(x - 0.092, 0.08), pt(x - 0.118, legTop), pt(x + 0.118, legTop), pt(x + 0.092, 0.08)]),
      shade(skin, rc(x - 0.12, 0, x + 0.12, legTop)),
    );
    final shoe = RRect.fromRectAndCorners(
      rc(x - 0.13 + 0.015 * sx, 0, x + 0.13 + 0.015 * sx, 0.13),
      topLeft: Radius.circular(0.07 * u),
      topRight: Radius.circular(0.07 * u),
      bottomLeft: Radius.circular(0.035 * u),
      bottomRight: Radius.circular(0.035 * u),
    );
    c
      ..drawRRect(
        shoe,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF64748B), Color(0xFF1E293B)],
          ).createShader(shoe.outerRect),
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(shoe.left, shoe.bottom - 0.03 * u, shoe.right, shoe.bottom),
          Radius.circular(0.02 * u),
        ),
        Paint()..color = _Colors.slate200,
      );
  }

  // Shorts (boy) or flared skirt (girl).
  if (!girl) {
    c.drawPath(
      _poly([
        pt(-0.37, 1.2),
        pt(0.37, 1.2),
        pt(0.385, 0.76),
        pt(0.035, 0.76),
        pt(0, 0.84),
        pt(-0.035, 0.76),
        pt(-0.385, 0.76),
      ]),
      shade(_Colors.pants, rc(-0.39, 0.76, 0.39, 1.2), lo: -0.25, hi: 0.3),
    );
  } else {
    final skirt = Path()
      ..mv(pt(-0.33, 1.02))
      ..ln(pt(0.33, 1.02))
      ..ln(pt(0.5, 0.6));
    for (var i = 0; i < 4; i++) {
      final x0 = 0.5 - i * 0.25;
      skirt.qd(pt(x0 - 0.125, 0.53), pt(x0 - 0.25, 0.6));
    }
    skirt.close();
    c.drawPath(skirt, shade(labShade(shirt, -0.08), rc(-0.5, 0.55, 0.5, 1.02)));
    final fold = line(labShade(shirt, -0.35).withValues(alpha: 0.45), 0.018);
    for (final x in const [-0.25, 0.0, 0.25]) {
      c.drawLine(pt(x * 0.6, 0.98), pt(x, 0.6), fold);
    }
  }

  // Torso (shirt) with rounded shoulders.
  final bottom = girl ? 0.94 : 1.04;
  const rs = 0.15;
  final torso = Path()
    ..mv(pt(-hw * 0.95, bottom))
    ..ln(pt(-hw, top - rs))
    ..qd(pt(-hw, top), pt(-hw + rs, top))
    ..ln(pt(hw - rs, top))
    ..qd(pt(hw, top), pt(hw, top - rs))
    ..ln(pt(hw * 0.95, bottom))
    ..close();
  c
    ..drawPath(torso, shade(shirt, rc(-hw, bottom, hw, top)))
    ..drawRect(
      rc(-hw * 0.95, bottom, hw * 0.95, bottom + 0.05),
      Paint()..color = labShade(shirt, -0.25).withValues(alpha: 0.6),
    );
  if (girl && grade8) {
    // Gentle shading where the HTML adds the chest shape.
    final cr = Rect.fromCenter(center: pt(0, 1.6), width: 0.52 * u, height: 0.22 * u);
    c
      ..drawOval(
        cr,
        Paint()
          ..shader = RadialGradient(
            colors: [Colors.white.withValues(alpha: 0.16), Colors.white.withValues(alpha: 0)],
          ).createShader(cr),
      )
      ..drawPath(
        Path()
          ..mv(pt(-0.2, 1.53))
          ..qd(pt(0, 1.47), pt(0.2, 1.53)),
        line(labShade(shirt, -0.3).withValues(alpha: 0.35), 0.02),
      );
  }

  // Neck, collar and (Grade 8 boy) Adam's apple.
  final neck = rc(-0.1, top - 0.08, 0.1, 2.12);
  c
    ..drawRRect(RRect.fromRectAndRadius(neck, Radius.circular(0.04 * u)), shade(skin, neck))
    ..drawRect(rc(-0.1, 2.02, 0.1, 2.12), Paint()..color = labShade(skin, -0.3).withValues(alpha: 0.45))
    ..drawPath(
      Path()
        ..mv(pt(-0.14, top))
        ..qd(pt(0, top - 0.13), pt(0.14, top)),
      line(labShade(shirt, 0.35), 0.035),
    );
  if (broad) {
    c
      ..drawOval(
        Rect.fromCenter(center: pt(0, 1.99), width: 0.075 * u, height: 0.085 * u),
        Paint()..color = labShade(skin, 0.14),
      )
      ..drawPath(
        Path()
          ..mv(pt(-0.03, 1.955))
          ..qd(pt(0, 1.94), pt(0.03, 1.955)),
        line(labShade(skin, -0.35).withValues(alpha: 0.7), 0.012),
      );
  }

  // Arms with short sleeves.
  for (final sx in const [-1.0, 1.0]) {
    final a = pt(sx * (hw - 0.02), 1.82);
    final h = pt(sx * (hw + 0.13), 0.98);
    final d = h - a;
    final n = Offset(-d.dy, d.dx) / d.distance;
    c
      ..drawPath(
        _poly([a + n * 0.09 * u, h + n * 0.068 * u, h - n * 0.068 * u, a - n * 0.09 * u]),
        shade(skin, Rect.fromPoints(a, h).inflate(0.1 * u)),
      )
      ..drawCircle(
        h,
        0.085 * u,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(0.3, -0.3),
            colors: [labShade(skin, 0.15), labShade(skin, -0.18)],
          ).createShader(Rect.fromCircle(center: h, radius: 0.085 * u)),
      );
    final s2 = a + d * 0.34;
    c.drawPath(
      _poly([a + n * 0.12 * u, s2 + n * 0.108 * u, s2 - n * 0.108 * u, a - n * 0.12 * u]),
      shade(shirt, Rect.fromPoints(a, s2).inflate(0.13 * u)),
    );
  }

  _paintHead(c, pt, u, girl: girl, grade8: grade8, talk: talk, stache: stache);
}

/// Head, hair and face of an avatar; [pt] maps avatar units to px.
void _paintHead(
  Canvas c,
  Offset Function(double x, double y) pt,
  double u, {
  required bool girl,
  required bool grade8,
  double talk = 0,
  double stache = 0,
}) {
  Paint line(Color col, double w) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = w * u
    ..color = col;
  const skin = _Colors.skin;
  const hair = _Colors.hair;
  final hc = pt(0, 2.42);
  final hairPaint = Paint()
    ..shader = RadialGradient(
      center: const Alignment(0.35, -0.55),
      radius: 1,
      colors: [labShade(hair, 0.3), hair, labShade(hair, -0.35)],
      stops: const [0, 0.45, 1],
    ).createShader(Rect.fromCircle(center: hc, radius: 0.5 * u));

  // Back hair: girl's bun and long side strands, then the base hair sphere
  // (pushed back so the face shows).
  if (girl) {
    c.drawCircle(pt(0, 2.86), 0.17 * u, hairPaint);
    for (final sx in const [-1.0, 1.0]) {
      c.drawLine(pt(sx * 0.37, 2.45), pt(sx * 0.45, 1.74), line(labShade(hair, -0.05), 0.15));
    }
    c.drawCircle(pt(0, 2.46), 0.435 * u, hairPaint);
  } else {
    c
      ..save()
      ..clipRect(Rect.fromLTRB(hc.dx - u, hc.dy - u, hc.dx + u, pt(0, 2.3).dy));
    c
      ..drawCircle(pt(0, 2.46), 0.43 * u, hairPaint)
      ..restore();
  }

  // Head.
  c.drawCircle(
    hc,
    0.4 * u,
    Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.25, -0.3),
        radius: 0.95,
        colors: [labShade(skin, 0.2), skin, labShade(skin, -0.22)],
        stops: const [0, 0.55, 1],
      ).createShader(Rect.fromCircle(center: hc, radius: 0.4 * u)),
  );

  // Hair cap with the hairline, side hair and fringe / tufts.
  final cap = Path()
    ..mv(pt(-0.415, 2.34))
    ..cb(pt(-0.47, 2.74), pt(-0.22, 2.9), pt(0, 2.9))
    ..cb(pt(0.22, 2.9), pt(0.47, 2.74), pt(0.415, 2.34))
    ..cb(pt(0.37, 2.5), pt(0.3, 2.6), pt(0.13, 2.63))
    ..cb(pt(0.02, 2.65), pt(-0.12, 2.66), pt(-0.2, 2.61))
    ..cb(pt(-0.3, 2.56), pt(-0.37, 2.48), pt(-0.415, 2.34))
    ..close();
  c.drawPath(cap, hairPaint);
  for (final sx in const [-1.0, 1.0]) {
    c.drawOval(Rect.fromCenter(center: pt(sx * 0.365, 2.38), width: 0.13 * u, height: 0.24 * u), hairPaint);
  }
  if (!girl) {
    for (final (x, y, r) in const [(-0.15, 2.74, 0.14), (0.15, 2.77, 0.14), (0.0, 2.82, 0.15)]) {
      c.drawCircle(pt(x, y), r * u, hairPaint);
    }
    c.drawPath(
      _poly([
        pt(-0.32, 2.64),
        pt(-0.24, 2.53),
        pt(-0.15, 2.63),
        pt(-0.05, 2.52),
        pt(0.05, 2.63),
        pt(0.16, 2.53),
        pt(0.25, 2.64),
        pt(0.32, 2.68),
        pt(0, 2.78),
      ]),
      hairPaint,
    );
  } else {
    for (final (x, y) in const [(-0.15, 2.69), (0.15, 2.69), (0.0, 2.71)]) {
      c.drawOval(Rect.fromCenter(center: pt(x, y), width: 0.27 * u, height: 0.15 * u), hairPaint);
    }
  }
  c.drawPath(
    Path()
      ..mv(pt(0.06, 2.85))
      ..qd(pt(0.27, 2.83), pt(0.36, 2.66)),
    line(labShade(hair, 0.55).withValues(alpha: 0.45), 0.035),
  );

  // Face: brows, eyes, cheeks, nose and mouth.
  for (final sx in const [-1.0, 1.0]) {
    c.drawPath(
      Path()
        ..mv(pt(sx * 0.08, 2.555))
        ..qd(pt(sx * 0.14, 2.59), pt(sx * 0.2, 2.56)),
      line(labShade(hair, 0.1), 0.028),
    );
    final e = pt(sx * 0.14, 2.45);
    c
      ..drawOval(Rect.fromCenter(center: e, width: 0.09 * u, height: 0.11 * u), Paint()..color = _Colors.slate800)
      ..drawCircle(e + Offset(0.016 * u, -0.022 * u), 0.017 * u, Paint()..color = Colors.white)
      ..drawCircle(pt(sx * 0.25, 2.32), 0.065 * u, Paint()..color = const Color(0x38F87171));
  }
  c.drawPath(
    Path()
      ..mv(pt(-0.025, 2.355))
      ..qd(pt(0, 2.335), pt(0.025, 2.355)),
    line(labShade(skin, -0.32), 0.02),
  );
  if (talk > 0.02) {
    final mr = Rect.fromCenter(center: pt(0, 2.235), width: 0.12 * u, height: (0.03 + 0.08 * talk) * u);
    c
      ..drawOval(mr, Paint()..color = const Color(0xFF7F1D1D))
      ..drawOval(
        Rect.fromCenter(
          center: mr.center + Offset(0, mr.height * 0.22),
          width: mr.width * 0.6,
          height: mr.height * 0.4,
        ),
        Paint()..color = _Colors.red400,
      );
  } else {
    c.drawPath(
      Path()
        ..mv(pt(-0.065, 2.25))
        ..qd(pt(0, 2.2), pt(0.065, 2.25)),
      line(_Colors.slate600, 0.025),
    );
  }

  // Grade 8 details: a few pimples and (boys) a faint moustache.
  if (grade8) {
    for (final (x, y, r) in const [
      (0.22, 2.36, 0.017),
      (0.27, 2.31, 0.014),
      (0.2, 2.295, 0.012),
      (-0.25, 2.37, 0.014),
    ]) {
      c.drawCircle(pt(x, y), r * u, Paint()..color = const Color(0x99DC2626));
    }
    if (!girl) {
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: pt(0, 2.3), width: 0.2 * u, height: 0.03 * u),
          Radius.circular(0.015 * u),
        ),
        Paint()..color = hair.withValues(alpha: 0.32),
      );
    }
  }
  if (stache > 0.01) {
    final w = 0.28 * u * stache * 24 / 19.2;
    _paintSign(
      c,
      _Sign.moustache,
      Rect.fromCenter(center: pt(0, 2.3) - Offset(0, 0.012 * u), width: w, height: w),
      hair,
    );
  }
}

/// Pulsing floor rings under the character / avatar to use next.
void _pulseRing(Canvas c, Offset at, double w, double t, Color color) {
  final ph = (t * 0.9) % 1.0;
  for (final k in [ph, (ph + 0.5) % 1.0]) {
    final ww = w * (0.85 + 0.7 * k);
    c.drawOval(
      Rect.fromCenter(center: at, width: ww, height: ww * 0.28),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = color.withValues(alpha: 0.75 * (1 - k)),
    );
  }
}

/// The 3D stage: room, floor, characters, stands, cues and labels.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.tr,
    required this.labelPx,
  }) : super(repaint: repaint);

  final _TeenScene scene;
  final bool isDark;
  final bool showLabels;
  final String lang;
  final String Function(String key) tr;

  /// Label text size in design px, so labels stay readable on small screens.
  final double labelPx;

  Color get _tagColor => isDark ? _Colors.violet400 : _Colors.violet600;

  @override
  void paint(Canvas canvas, Size size) {
    final cam = scene.scenario == 0 ? _cam1 : _cam2;
    _paintRoom(canvas, size, cam);
    if (scene.scenario == 0) {
      _paintS1(canvas, cam);
    } else {
      _paintS2(canvas, cam);
    }
  }

  /// Background (HTML scene.background) and the grey floor plane.
  void _paintRoom(Canvas c, Size size, _Cam cam) {
    final b = labBleed(size);
    final horizon = cam.point(0, 0, -5).dy;
    c.drawRect(
      b,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF080D1C), Color(0xFF0F172A), Color(0xFF1B1D3F)]
              : const [Color(0xFFC7E3F8), Color(0xFFE0F2FE), Color(0xFFF0F9FF)],
          stops: const [0, 0.55, 1],
        ).createShader(Rect.fromLTRB(0, 0, size.width, horizon)),
    );
    final glow = Rect.fromCircle(center: Offset(cam.center.dx, horizon - 60), radius: 460);
    c.drawRect(
      b,
      Paint()
        ..shader = RadialGradient(
          colors: [
            (isDark ? _Colors.violet500 : Colors.white).withValues(alpha: isDark ? 0.16 : 0.55),
            (isDark ? _Colors.violet500 : Colors.white).withValues(alpha: 0),
          ],
        ).createShader(glow),
    );

    // Floor.
    final floor = Rect.fromLTRB(b.left, horizon, b.right, b.bottom);
    c.drawRect(
      floor,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark ? const [Color(0xFF2A364B), Color(0xFF3E4C63)] : const [Color(0xFFC3CEDB), Color(0xFF94A3B8)],
        ).createShader(Rect.fromLTRB(0, horizon, size.width, size.height)),
    );
    final grid = Paint()
      ..strokeWidth = 1
      ..color = (isDark ? Colors.white : _Colors.slate700).withValues(alpha: isDark ? 0.05 : 0.08);
    for (var x = -21.0; x <= 21; x += 1.5) {
      c.drawLine(cam.point(x, 0, -5), cam.point(x, 0, 9.5), grid);
    }
    for (var z = -5.0; z <= 9.5; z += 1.5) {
      c.drawLine(Offset(b.left, cam.point(0, 0, z).dy), Offset(b.right, cam.point(0, 0, z).dy), grid);
    }
    c.drawLine(
      Offset(b.left, horizon),
      Offset(b.right, horizon),
      Paint()
        ..strokeWidth = 2
        ..color = (isDark ? _Colors.slate400 : Colors.white).withValues(alpha: isDark ? 0.18 : 0.7),
    );
  }

  double _talk(double until) => scene.time < until ? math.sin(scene.time * 12).abs() : 0;

  /// 1 while a cue is shown, shrinking to 0 after the drag panel opens.
  double _shrink() {
    final t0 = scene.fadeT0;
    if (t0 == null) return 1;
    return 1 - Curves.easeIn.transform(((scene.time - t0) / 0.5).clamp(0.0, 1.0));
  }

  void _paintS1(Canvas c, _Cam cam) {
    final sc = scene;
    final t = sc.time;
    final vp = cam.project(-2, 0, 0);
    final dp = cam.project(2, 0, 0);
    final vu = vp.k * 1.2; // Venkatesh (older, scale 1.2)
    final du = dp.k * 0.9; // Devyani (younger, scale 0.9)

    labGroundShadow(c, vp.p, 1.3 * vu, 0.3 * vu, opacity: 0.35);
    labGroundShadow(c, dp.p, 1.3 * du, 0.3 * du, opacity: 0.35);
    if (sc.step == 1) _pulseRing(c, vp.p, 1.4 * vu, t, _Colors.violet500);
    if (sc.step == 2 || sc.step == 3) _pulseRing(c, dp.p, 1.4 * du, t, _Colors.violet500);

    var stache = 0.0;
    if (sc.stacheT0 != null) {
      stache = Curves.easeOutBack.transform(((t - sc.stacheT0!) / 0.5).clamp(0.0, 1.0)) * _shrink();
    }
    _paintAvatar(c, vp.p, vu, girl: false, grade8: true, talk: _talk(sc.venkTalk), stache: stache);
    _paintAvatar(c, dp.p, du, girl: true, grade8: false, talk: _talk(sc.devTalk));

    // Height arrow next to Devyani (HTML blue ShapeGeometry arrow).
    if (sc.arrowT0 != null) {
      final grow = Curves.elasticOut.transform(((t - sc.arrowT0!) / 0.8).clamp(0.0, 1.0)) * _shrink();
      if (grow > 0.01) _paintArrow(c, cam, grow, _shrink());
    }

    // Soundwave pulsing over Venkatesh's throat (HTML ring, yoyo x 5).
    if (sc.waveT0 != null) {
      final e = t - sc.waveT0!;
      final pulse = e < 3 ? 1 + 0.5 * math.sin(e / 0.5 * math.pi).abs() : 1.0;
      final k = _shrink();
      if (k > 0.01) _paintWave(c, vp.p + Offset(0, -1.98 * vu), 0.26 * vp.k * pulse * k, vp.k, t, k);
    }

    if (showLabels) {
      _tag(
        c,
        tr('name_venkatesh'),
        vp.p + Offset(0, -3.08 * vu),
        Alignment.bottomCenter,
        dark: isDark,
        accent: _tagColor,
        person: true,
        size: labelPx,
      );
      _tag(
        c,
        tr('name_devyani'),
        dp.p + Offset(0, -3.1 * du),
        Alignment.bottomCenter,
        dark: isDark,
        accent: _tagColor,
        person: true,
        size: labelPx,
      );
    }
  }

  void _paintArrow(Canvas c, _Cam cam, double grow, double width) {
    final base = cam.project(0.85, 0, 0);
    final k = base.k;
    Offset p(double x, double y) => base.p + Offset(x * k * width, -y * k * grow);
    final arrow = _poly([p(-0.1, 0), p(0.1, 0), p(0.1, 2.5), p(0.3, 2.5), p(0, 3.2), p(-0.3, 2.5), p(-0.1, 2.5)]);
    final bounds = arrow.getBounds();
    c
      ..drawPath(
        arrow,
        Paint()
          ..color = _Colors.blue500.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      )
      ..drawPath(
        arrow,
        Paint()
          ..shader = LinearGradient(
            colors: [
              _Colors.blue600.withValues(alpha: 0.85),
              _Colors.blue400.withValues(alpha: 0.85),
              _Colors.blue600.withValues(alpha: 0.85),
            ],
          ).createShader(bounds),
      )
      ..drawPath(
        arrow,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = _Colors.blue300.withValues(alpha: 0.9),
      );
  }

  void _paintWave(Canvas c, Offset at, double r, double k, double t, double alpha) {
    c.drawCircle(
      at,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.1 * k
        ..color = _Colors.indigo500.withValues(alpha: 0.8 * alpha),
    );
    // Sound arcs radiating to both sides.
    for (var i = 0; i < 3; i++) {
      final ph = (t * 1.4 + i / 3) % 1.0;
      final rr = r * (1.25 + 1.3 * ph);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 0.05 * k
        ..color = _Colors.indigo500.withValues(alpha: 0.7 * (1 - ph) * alpha);
      final box = Rect.fromCircle(center: at, radius: rr);
      c
        ..drawArc(box, -0.5, 1.0, false, paint)
        ..drawArc(box, math.pi - 0.5, 1.0, false, paint);
    }
  }

  void _paintS2(Canvas c, _Cam cam) {
    final sc = scene;
    final t = sc.time;

    // Background lineups (HTML bgBoys / bgGirls at z = -4).
    final s5 = sc.girls ? 0.9 : 0.85;
    final s8 = sc.girls ? 1.15 : 1.25;
    for (var i = 0; i < 3; i++) {
      _lineAvatar(c, cam, -7 + i * 1.2, s5, grade8: false);
    }
    for (var i = 0; i < 3; i++) {
      _lineAvatar(c, cam, 4.5 + i * 1.2, s8, grade8: true);
    }

    // Stands and draggable avatars, far to near.
    final items = <(double, VoidCallback)>[
      (-1.0, () => _paintStand(c, cam, 0, t)),
      (-1.0, () => _paintStand(c, cam, 1, t)),
      for (final a in sc.avatars.values)
        if (a.visible) (a.z, () => _paintDragAvatar(c, cam, a, t)),
    ]..sort((a, b) => a.$1.compareTo(b.$1));
    for (final item in items) {
      item.$2();
    }

    // Lineup labels (HTML lbl-g5-lineup / lbl-g8-lineup).
    if (sc.step <= 2 || (sc.step == 4 && sc.girls)) {
      for (final (x, key) in const [(-5.5, 'grade5'), (5.5, 'grade8')]) {
        labText(
          c,
          tr(key).toUpperCase(),
          cam.point(x, 0, -1.5) + Offset(0, 10 + labelPx * 0.8),
          size: labelPx * 0.85,
          weight: FontWeight.w900,
          letterSpacing: 2,
          color: isDark ? _Colors.slate300 : _Colors.slate600,
          background: isDark ? const Color(0x990F172A) : const Color(0x99FFFFFF),
          radius: 6,
          padding: EdgeInsets.symmetric(horizontal: labelPx * 0.5, vertical: labelPx * 0.2),
        );
      }
    }

    // Hotspots and their labels.
    for (final s in sc.spots) {
      final a = s.avatar;
      final pr = cam.project(a.x, a.y, a.z);
      final u = pr.k * a.scale;
      final at = pr.p + Offset(s.def.x * u, -s.def.y * u);
      if (s.foundAt == null) {
        final ring = 1 + 0.5 * (0.5 - 0.5 * math.cos(t * math.pi));
        labGlow(c, at, 0.34 * u, _Colors.sky400, intensity: 0.75);
        c.drawCircle(
          at,
          0.2 * u * ring,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.05 * u
            ..color = _Colors.sky400.withValues(alpha: 0.55 * (1.6 - ring)),
        );
        labSphere(c, at, 0.12 * u, _Colors.sky400, highlight: 0.6, opacity: 0.95);
      }
      final found = s.foundAt;
      final opacity = found == null ? (showLabels ? 1.0 : 0.0) : (1 - ((t - found - 1.5) / 0.5).clamp(0.0, 1.0));
      if (opacity <= 0) continue;
      final gap = 0.28 * u;
      final (anchor, off) = switch (s.def.side) {
        _Side.up => (Alignment.bottomCenter, Offset(0, -gap)),
        _Side.leftUp => (Alignment.centerRight, Offset(-gap, -0.45 * u)),
        _Side.rightUp => (Alignment.bottomLeft, Offset(gap, 0.12 * u)),
        _Side.rightDown => (Alignment.topLeft, Offset(gap, -0.12 * u)),
      };
      if (s.def.side == _Side.leftUp) {
        c.drawLine(
          at,
          at + off,
          Paint()
            ..strokeWidth = 1.5
            ..color = (found == null ? _tagColor : _Colors.emerald500).withValues(alpha: 0.8 * opacity),
        );
      }
      _tag(
        c,
        tr(_signKey(s.def.sign)),
        at + off,
        anchor,
        dark: isDark,
        accent: found == null ? _tagColor : _Colors.emerald500,
        sign: s.def.sign,
        opacity: opacity,
        size: labelPx * 0.92,
      );
    }
  }

  void _lineAvatar(Canvas c, _Cam cam, double x, double scale, {required bool grade8}) {
    final pr = cam.project(x, 0, -4);
    final u = pr.k * scale;
    labGroundShadow(c, pr.p, 1.2 * u, 0.26 * u, opacity: 0.3);
    _paintAvatar(c, pr.p, u, girl: scene.girls, grade8: grade8);
  }

  /// Is [a] the avatar the current step asks the learner to drag?
  bool _isNext(_Avatar a) {
    final sc = scene;
    if (!a.visible || a.placed || a.y > 0.01) return false;
    if (!sc.girls) return (sc.step == 1 && a.id == 'g5b') || (sc.step == 2 && a.id == 'g8b');
    return sc.step == 4;
  }

  void _paintDragAvatar(Canvas c, _Cam cam, _Avatar a, double t) {
    final onStand = ((a.x.abs() - 2).abs() < 1) && a.z.abs() < 1;
    final floorY = onStand ? 0.2 : 0.0;
    final sh = cam.project(a.x, floorY, a.z);
    final lift = (a.y - floorY).clamp(0.0, 2.0);
    final su = sh.k * a.scale / (1 + 0.35 * lift);
    labGroundShadow(c, sh.p, 1.2 * su, 0.28 * su, opacity: 0.35 / (1 + lift));
    if (_isNext(a)) _pulseRing(c, sh.p, 1.5 * sh.k * a.scale, t, _Colors.violet500);
    final pr = cam.project(a.x, a.y, a.z);
    _paintAvatar(c, pr.p, pr.k * a.scale, girl: a.girl, grade8: a.grade8);
  }

  /// Comparison stand (HTML 2 x 0.2 x 2 box); violet while an avatar hovers
  /// over it, softly pulsing while it is the next drop target.
  void _paintStand(Canvas c, _Cam cam, int i, double t) {
    final sc = scene;
    final sx = i == 0 ? -2.0 : 2.0;
    final hover = sc.hoverStand == i;
    final empty = !sc.avatars.values.any((a) => a.visible && a.placed && (a.x - sx).abs() < 0.1);
    final target =
        empty && ((!sc.girls && ((sc.step == 1 && i == 0) || (sc.step == 2 && i == 1))) || (sc.girls && sc.step == 4));
    final base = hover ? _Colors.violet500 : (isDark ? const Color(0xFFA3B1C6) : _Colors.slate300);
    Offset p(double x, double y, double z) => cam.point(sx + x, y, z);
    final inner = sx < 0 ? 1.0 : -1.0;
    labGroundShadow(c, p(0, 0, 0.3), 2.3 * cam.project(sx, 0, 0).k, 0.5 * cam.project(sx, 0, 0).k, opacity: 0.3);
    c
      ..drawPath(
        _poly([p(inner, 0.2, -1), p(inner, 0.2, 1), p(inner, 0, 1), p(inner, 0, -1)]),
        Paint()..color = labShade(base, -0.38),
      )
      ..drawPath(_poly([p(-1, 0.2, 1), p(1, 0.2, 1), p(1, 0, 1), p(-1, 0, 1)]), Paint()..color = labShade(base, -0.2));
    final topFace = _poly([p(-1, 0.2, -1), p(1, 0.2, -1), p(1, 0.2, 1), p(-1, 0.2, 1)]);
    c
      ..drawPath(
        topFace,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [labShade(base, 0.05), labShade(base, 0.22)],
          ).createShader(topFace.getBounds()),
      )
      ..drawPath(
        topFace,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = labShade(base, 0.4).withValues(alpha: 0.8),
      );
    if (hover) {
      labGlow(c, p(0, 0.2, 0), 1.6 * cam.project(sx, 0, 0).k, _Colors.violet500, intensity: 0.5);
    } else if (target) {
      final pulse = 0.5 + 0.5 * math.sin(t * 4);
      labDashedPath(
        c,
        _poly([p(-0.85, 0.2, -0.85), p(0.85, 0.2, -0.85), p(0.85, 0.2, 0.85), p(-0.85, 0.2, 0.85)]),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..color = _Colors.violet500.withValues(alpha: 0.45 + 0.45 * pulse),
        dash: 9,
        gap: 6,
        phase: t * 20,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.isDark != isDark || old.showLabels != showLabels || old.lang != lang || old.labelPx != labelPx;
}

/// A change icon painted from [_paintSign].
class _SignPainter extends CustomPainter {
  const _SignPainter(this.sign, this.color);

  final _Sign sign;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) => _paintSign(canvas, sign, Offset.zero & size, color);

  @override
  bool shouldRepaint(covariant _SignPainter old) => old.sign != sign || old.color != color;
}

/// Bust of Venkatesh or Devyani for the chat bubbles (HTML emoji).
class _HeadIconPainter extends CustomPainter {
  const _HeadIconPainter({required this.girl});

  final bool girl;

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / 1.15;
    final f = Offset(size.width / 2, size.height * 0.5 + 2.42 * u);
    _paintAvatar(canvas, f, u, girl: girl, grade8: !girl);
  }

  @override
  bool shouldRepaint(covariant _HeadIconPainter old) => old.girl != girl;
}

/// Glass observation jar with its lid (HTML `#s2-jar`).
class _JarPainter extends CustomPainter {
  const _JarPainter({required this.dark, required this.scale});

  final bool dark;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final s = scale;
    final edge = dark ? _Colors.slate500 : _Colors.slate300;
    final body = RRect.fromRectAndCorners(
      Rect.fromLTWH(2 * s, 6 * s, size.width - 4 * s, size.height - 8 * s),
      topLeft: Radius.circular(4 * s),
      topRight: Radius.circular(4 * s),
      bottomLeft: Radius.circular(16 * s),
      bottomRight: Radius.circular(16 * s),
    );
    canvas
      ..drawRRect(
        body,
        Paint()
          ..shader = LinearGradient(
            colors: dark
                ? const [Color(0xCC1E293B), Color(0xB3334155), Color(0xCC1E293B)]
                : const [Color(0xCCFFFFFF), Color(0x99F1F5F9), Color(0xCCFFFFFF)],
          ).createShader(body.outerRect),
      )
      ..drawRRect(
        body,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5 * s
          ..color = edge,
      )
      ..drawLine(
        Offset(body.left + 9 * s, body.top + 12 * s),
        Offset(body.left + 9 * s, body.bottom - 16 * s),
        Paint()
          ..strokeWidth = 3 * s
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: dark ? 0.12 : 0.6),
      )
      ..drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromCenter(center: Offset(size.width / 2, 4 * s), width: size.width * 0.66, height: 8 * s),
          topLeft: Radius.circular(4 * s),
          topRight: Radius.circular(4 * s),
        ),
        Paint()..color = edge,
      );
  }

  @override
  bool shouldRepaint(covariant _JarPainter old) => old.dark != dark || old.scale != scale;
}

/// Dashed rounded border (HTML `border-dashed`).
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius, required this.width});

  final Color color;
  final double radius;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(width / 2);
    labDashedPath(
      canvas,
      Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius))),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..color = color,
      dash: 7,
      gap: 5,
    );
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color || old.radius != radius || old.width != width;
}

/// One confetti piece (HTML canvas-confetti burst).
class _Confetto {
  const _Confetto(this.angle, this.speed, this.size, this.color, this.spin);

  final double angle;
  final double speed;
  final double size;
  final Color color;
  final double spin;

  static List<_Confetto> burst(int n) {
    final r = math.Random(7);
    const colors = [_Colors.violet500, _Colors.blue500, _Colors.pink500];
    return [
      for (var i = 0; i < n; i++)
        _Confetto(
          -math.pi / 2 + (r.nextDouble() - 0.5) * 70 * math.pi / 180,
          0.55 + 0.75 * r.nextDouble(),
          4 + 5 * r.nextDouble(),
          colors[i % colors.length],
          (r.nextDouble() - 0.5) * 14,
        ),
    ];
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.pieces, required this.t0, required this.scene, required Listenable repaint})
    : super(repaint: repaint);

  final List<_Confetto> pieces;
  final double t0;
  final _TeenScene scene;

  @override
  void paint(Canvas canvas, Size size) {
    final t = scene.time - t0;
    if (t < 0 || t > 3.5) return;
    final unit = math.min(size.width, size.height);
    final origin = Offset(size.width / 2, size.height * 0.3);
    final fade = 1 - ((t - 2.5) / 1).clamp(0.0, 1.0);
    final travel = (1 - math.exp(-2.2 * t)) / 2.2;
    for (final p in pieces) {
      final v = p.speed * unit * 1.6;
      final pos =
          origin + Offset(math.cos(p.angle) * v * travel, math.sin(p.angle) * v * travel + 0.55 * unit * t * t * 0.5);
      canvas
        ..save()
        ..translate(pos.dx, pos.dy)
        ..rotate(p.spin * t);
      canvas
        ..drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.6 * (0.4 + 0.6 * math.cos(p.spin * t * 1.3).abs()),
          ),
          Paint()..color = p.color.withValues(alpha: fade),
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t0 != t0 || old.pieces != pieces;
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
