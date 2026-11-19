// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart'; // ऑडियो पैकेज इम्पोर्ट किया गया है

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'ZSL Virtual Lab | The Liquid Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(
          0xFF050B14,
        ), // छवि पृष्ठभूमि से मेल खाने वाला गहरा नीला रंग
        colorScheme: const ColorScheme.dark(
          primary: Colors.orangeAccent,
          secondary: Colors.blueAccent,
          surface: Color(0xFF1E293B),
        ),
        fontFamily: 'Roboto', // डिफ़ॉल्ट फ़ॉन्ट
      ),
      home: const AdditionandSubtractionDecimalNumbers(),
    ),
  );
}

// --- अनुवाद शब्दकोश ---
class AppTranslations {
  static const Map<String, Map<String, String>> strings = {
    'title_main': {
      'EN': 'The Liquid Lab: Pouring, Mixing, and Measuring Decimals',
      'HI': 'द लिक्विड लैब: दशमलव को डालना, मिलाना और मापना',
    },
    'title_short': {
      'EN': 'The Liquid Lab: Pouring, Mixing, and Measuring Decimals',
      'HI': 'द लिक्विड लैब: दशमलव को डालना, मिलाना और मापना',
    },
    'subtitle': {
      'EN': 'Class 7 • A PEEK BEYOND THE POINT',
      'HI': 'कक्षा 7 • दशमलव के पार एक झलक',
    },
    'btn_enter': {'EN': 'Enter Lab', 'HI': 'प्रयोगशाला में प्रवेश करें'},
    'mission_obj': {'EN': 'MISSION OBJECTIVE', 'HI': 'मिशन का उद्देश्य'},
    'target': {'EN': 'Target', 'HI': 'लक्ष्य'},
    'current': {'EN': 'Current', 'HI': 'वर्तमान'},
    'units': {'EN': 'Units', 'HI': 'इकाई'},
    'tenths': {'EN': 'Tenths', 'HI': 'दसवां'},
    'hunds': {'EN': 'Hund.', 'HI': 'सौवां'},
    'units_label': {'EN': 'Units (1.0)', 'HI': 'इकाई (1.0)'},
    'tenths_label': {'EN': 'Tenths (0.1)', 'HI': 'दसवां (0.1)'},
    'hunds_label': {'EN': 'Hund. (0.01)', 'HI': 'सौवां (0.01)'},
    'first_amount': {'EN': 'First Amount', 'HI': 'पहली राशि'},
    'second_amount': {'EN': 'Second Amount', 'HI': 'दूसरी राशि'},
    'result_area': {'EN': 'Result Area', 'HI': 'परिणाम क्षेत्र'},
    'btn_check': {'EN': 'Check Workspace', 'HI': 'कार्यक्षेत्र जांचें'},
    'btn_combine': {'EN': 'Combine Containers', 'HI': 'कंटेनरों को मिलाएं'},
    'btn_regroup': {'EN': 'Execute Regroup', 'HI': 'पुनर्समूहन निष्पादित करें'},
    'btn_validate': {'EN': 'Validate Model', 'HI': 'मॉडल को मान्य करें'},
    'btn_continue': {'EN': 'Continue', 'HI': 'आगे बढ़ें'},
    'scenario_complete': {'EN': 'Scenario Complete!', 'HI': 'परिदृश्य पूर्ण!'},
    'msg_lang': {'EN': 'Language switched to: ', 'HI': 'भाषा इसमें बदली गई: '},
    'msg_reset': {'EN': 'Lab Reset', 'HI': 'प्रयोगशाला रीसेट की गई'},
    'msg_drop_error': {
      'EN': 'Drop items in the designated active area.',
      'HI': 'वस्तुओं को निर्धारित सक्रिय क्षेत्र में छोड़ें।',
    },
    'msg_correct': {
      'EN': 'Correct! Proceeding to next step.',
      'HI': 'सही! अगले चरण पर जा रहे हैं।',
    },
    'msg_incorrect': {
      'EN': 'Incorrect quantities. Check the Target Values.',
      'HI': 'गलत मात्राएँ। लक्ष्य मूल्यों की जाँच करें।',
    },
    'msg_combine_error': {
      'EN': "It's not time to combine yet!",
      'HI': 'अभी मिलाने का समय नहीं हुआ है!',
    },
    'tooltip_reset_view': {'EN': 'Reset View', 'HI': 'दृश्य रीसेट करें'},
    // परिदृश्य 1
    's1_title': {
      'EN': 'Scenario 1: Simple Sums (2.14 + 1.32)',
      'HI': 'परिदृश्य 1: साधारण जोड़ (2.14 + 1.32)',
    },
    's1_obj': {
      'EN':
          'To visually add two decimal numbers (2.14 + 1.32) where no regrouping (carrying over) is required.',
      'HI':
          'दो दशमलव संख्याओं (2.14 + 1.32) को दृश्य रूप से जोड़ने के लिए जहां कोई पुनर्समूहन (हासिल) आवश्यक नहीं है।',
    },
    's1_s1_t': {'EN': 'Step 1: First Amount', 'HI': 'चरण 1: पहली राशि'},
    's1_s1_th': {
      'EN':
          "For the Number 2.14, From the 'Containers Shelf', DRAG 2 'Unit Beakers', 1 'Tenths Cylinder', and 4 'Hundredths Test Tubes' onto the top workspace labeled 'First Amount'.",
      'HI':
          "संख्या 2.14 के लिए, 'कंटेनर शेल्फ' से 2 'इकाई बीकर', 1 'दसवां सिलेंडर', और 4 'सौवां टेस्ट ट्यूब' खींचकर 'पहली राशि' वाले कार्यक्षेत्र में रखें।",
    },
    's1_s1_h': {
      'EN':
          "Place 2 Beakers, 1 Cylinder, and 4 Test Tubes into 'First Amount'. Click 'Check' when done.",
      'HI':
          "2 बीकर, 1 सिलेंडर, और 4 टेस्ट ट्यूब 'पहली राशि' में रखें। हो जाने पर 'जांचें' पर क्लिक करें।",
    },
    's1_s2_t': {'EN': 'Step 2: Second Amount', 'HI': 'चरण 2: दूसरी राशि'},
    's1_s2_th': {
      'EN':
          "For the Number 1.32, From the 'Containers Shelf', DRAG 1 'Unit Beaker', 3 'Tenths Cylinders', and 2 'Hundredths Test Tubes' onto the workspace labeled 'Second Amount'.",
      'HI':
          "संख्या 1.32 के लिए, 'कंटेनर शेल्फ' से 1 'इकाई बीकर', 3 'दसवां सिलेंडर', और 2 'सौवां टेस्ट ट्यूब' 'दूसरी राशि' वाले कार्यक्षेत्र में रखें।",
    },
    's1_s2_h': {
      'EN':
          "Place 1 Beaker, 3 Cylinders, and 2 Test Tubes into 'Second Amount'. Click 'Check'.",
      'HI':
          "1 बीकर, 3 सिलेंडर, और 2 टेस्ट ट्यूब 'दूसरी राशि' में रखें। 'जांचें' पर क्लिक करें।",
    },
    's1_s3_t': {'EN': 'Step 3: Combine', 'HI': 'चरण 3: मिलाएं'},
    's1_s3_th': {
      'EN': "Click the pulsing 'Combine' button to mix them.",
      'HI':
          "उन्हें मिलाने के लिए स्पंदित 'कंटेनरों को मिलाएं' बटन पर क्लिक करें।",
    },
    's1_s3_h': {
      'EN': "Click 'Combine' to merge the amounts.",
      'HI': "राशियों को मिलाने के लिए 'मिलाएं' पर क्लिक करें।",
    },
    's1_s4_t': {'EN': 'Step 4: Conclusion', 'HI': 'चरण 4: निष्कर्ष'},
    's1_s4_th': {
      'EN':
          "Count the containers in the 'Result Area' and observe the final digital display.",
      'HI':
          "'परिणाम क्षेत्र' में कंटेनरों की गिनती करें और अंतिम डिजिटल डिस्प्ले देखें।",
    },
    's1_s4_h': {
      'EN':
          "Investigation Complete! Select Scenario 2 to learn about regrouping.",
      'HI':
          "जांच पूरी हुई! पुनर्समूहन के बारे में जानने के लिए परिदृश्य 2 का चयन करें।",
    },
    's1_s4_sum': {
      'EN':
          "You combined 2.14 and 1.32. By adding the containers for each place value, you found the total is 3.46. Notice how no container type exceeded 9, so no regrouping was needed.",
      'HI':
          "आपने 2.14 और 1.32 को मिलाया। प्रत्येक स्थानीय मान के लिए कंटेनरों को जोड़कर, आपने पाया कि कुल 3.46 है। ध्यान दें कि कोई भी कंटेनर 9 से अधिक नहीं हुआ, इसलिए किसी पुनर्समूहन की आवश्यकता नहीं थी।",
    },
    // परिदृश्य 2
    's2_title': {
      'EN': 'Scenario 2: The Tipping Point (1.85 + 2.46)',
      'HI': 'परिदृश्य 2: टिपिंग पॉइंट (1.85 + 2.46)',
    },
    's2_obj': {
      'EN':
          'To visually add two decimal numbers (1.85 + 2.46) to understand the concept of regrouping (carrying over).',
      'HI':
          'पुनर्समूहन (हासिल) की अवधारणा को समझने के लिए दो दशमलव संख्याओं (1.85 + 2.46) को दृश्य रूप से जोड़ना।',
    },
    's2_s1_t': {'EN': 'Step 1: First Amount', 'HI': 'चरण 1: पहली राशि'},
    's2_s1_th': {
      'EN':
          "Represent the number 1.85 by DRAGGING 1 'Unit Beaker', 8 'Tenths Cylinders', and 5 'Hundredths Test Tubes' to the 'First Amount' workspace.",
      'HI':
          "संख्या 1.85 को दर्शाने के लिए 1 'इकाई बीकर', 8 'दसवां सिलेंडर', और 5 'सौवां टेस्ट ट्यूब' को 'पहली राशि' कार्यक्षेत्र में खींचें।",
    },
    's2_s1_h': {
      'EN':
          "Place 1 Beaker, 8 Cylinders, and 5 Test Tubes into 'First Amount'. Click 'Check'.",
      'HI':
          "1 बीकर, 8 सिलेंडर, और 5 टेस्ट ट्यूब 'पहली राशि' में रखें। 'जांचें' पर क्लिक करें।",
    },
    's2_s2_t': {'EN': 'Step 2: Second Amount', 'HI': 'चरण 2: दूसरी राशि'},
    's2_s2_th': {
      'EN':
          "Represent the number 2.46 by DRAGGING 2 'Unit Beakers', 4 'Tenths Cylinders', and 6 'Hundredths Test Tubes' to the 'Second Amount' workspace.",
      'HI':
          "संख्या 2.46 को दर्शाने के लिए 2 'इकाई बीकर', 4 'दसवां सिलेंडर', और 6 'सौवां टेस्ट ट्यूब' को 'दूसरी राशि' कार्यक्षेत्र में खींचें।",
    },
    's2_s2_h': {
      'EN':
          "Place 2 Beakers, 4 Cylinders, and 6 Test Tubes into 'Second Amount'. Click 'Check'.",
      'HI':
          "2 बीकर, 4 सिलेंडर, और 6 टेस्ट ट्यूब 'दूसरी राशि' में रखें। 'जांचें' पर क्लिक करें।",
    },
    's2_s3_t': {'EN': 'Step 3: Combine', 'HI': 'चरण 3: मिलाएं'},
    's2_s3_th': {
      'EN': "Click the pulsing 'Combine' button.",
      'HI': "स्पंदित 'कंटेनरों को मिलाएं' बटन पर क्लिक करें।",
    },
    's2_s3_h': {
      'EN': "Click 'Combine' to merge the amounts.",
      'HI': "राशियों को मिलाने के लिए 'मिलाएं' पर क्लिक करें।",
    },
    's2_s4_t': {
      'EN': 'Step 4: Regrouping Hundredths',
      'HI': 'चरण 4: सौवें हिस्से का पुनर्समूहन',
    },
    's2_s4_th': {
      'EN':
          "Observe the 'Hundredths' section in the 'Result Area'.\n\nYou have 11 of them! Because 10 hundredths equal 1 tenth, we must 'carry over'.",
      'HI':
          "'परिणाम क्षेत्र' में 'सौवां' भाग देखें।\n\nआपके पास उनमें से 11 हैं! क्योंकि 10 सौवां भाग 1 दसवें के बराबर होता है, हमें 'हासिल' लेना होगा।",
    },
    's2_s4_h': {
      'EN':
          "Watch the animation. 10 Test Tubes will combine into 1 new Cylinder (Tenth).",
      'HI':
          "एनिमेशन देखें। 10 टेस्ट ट्यूब मिलकर 1 नया सिलेंडर (दसवां) बनाएंगे।",
    },
    's2_s5_t': {
      'EN': 'Step 5: Regrouping Tenths',
      'HI': 'चरण 5: दसवें हिस्से का पुनर्समूहन',
    },
    's2_s5_th': {
      'EN':
          "Observe the 'Tenths' section in the 'Result Area'.\n\nYou have 13 of them! (12 original + 1 carried over). Because 10 tenths equal 1 whole unit, we must 'carry over' again.",
      'HI':
          "'परिणाम क्षेत्र' में 'दसवां' भाग देखें।\n\nआपके पास उनमें से 13 हैं! (12 मूल + 1 हासिल)। क्योंकि 10 दसवां भाग 1 पूर्ण इकाई के बराबर होता है, हमें फिर से 'हासिल' लेना होगा।",
    },
    's2_s5_h': {
      'EN':
          "Watch the animation. 10 Cylinders will combine into 1 new Beaker (Unit).",
      'HI': "एनिमेशन देखें। 10 सिलेंडर मिलकर 1 नया बीकर (इकाई) बनाएंगे।",
    },
    's2_s6_t': {'EN': 'Conclusion', 'HI': 'निष्कर्ष'},
    's2_s6_th': {
      'EN': "Count the final containers and observe the digital display.",
      'HI': "अंतिम कंटेनरों की गिनती करें और डिजिटल डिस्प्ले देखें।",
    },
    's2_s6_h': {'EN': "Investigation Complete!", 'HI': "जांच पूरी हुई!"},
    's2_s6_sum': {
      'EN':
          "When you had 11 hundredths, 10 of them regrouped to become 1 tenth. When you had 13 tenths, 10 of them regrouped to become 1 unit. This is 'carrying over'! 1.85 + 2.46 = 4.31.",
      'HI':
          "जब आपके पास 11 सौवां भाग था, तो उनमें से 10 पुनर्समूहित होकर 1 दसवां भाग बन गए। जब आपके पास 13 दसवां भाग था, तो उनमें से 10 पुनर्समूहित होकर 1 इकाई बन गए। यही 'हासिल' है! 1.85 + 2.46 = 4.31।",
    },
  };
}

// --- मॉडल (MODELS) ---

enum ItemType { unit, tenth, hundredth }

enum ActionType { build, combine, regroup, done }

class LabStep {
  final String title;
  final String theory;
  final String hud;
  final ActionType action;
  final int? targetPad; // 1 पहले के लिए, 2 दूसरे के लिए
  final int targetUnits;
  final int targetTenths;
  final int targetHundredths;
  final String? summaryText;
  final String? mathResult;

  LabStep({
    required this.title,
    required this.theory,
    required this.hud,
    required this.action,
    this.targetPad,
    this.targetUnits = 0,
    this.targetTenths = 0,
    this.targetHundredths = 0,
    this.summaryText,
    this.mathResult,
  });
}

class Scenario {
  final int id;
  final String title;
  final String objective;
  final String mathText;
  final List<LabStep> steps;

  Scenario({
    required this.id,
    required this.title,
    required this.objective,
    required this.mathText,
    required this.steps,
  });
}

// --- मुख्य स्क्रीन (MAIN SCREEN) ---

class AdditionandSubtractionDecimalNumbers extends StatefulWidget {
  const AdditionandSubtractionDecimalNumbers({super.key});

  @override
  State<AdditionandSubtractionDecimalNumbers> createState() =>
      _AdditionandSubtractionDecimalNumbersState();
}

class _AdditionandSubtractionDecimalNumbersState
    extends State<AdditionandSubtractionDecimalNumbers>
    with TickerProviderStateMixin {
  bool _isSidebarOpen = true;
  final double _sidebarWidth = 300.0;

  // कैनवास को ज़ूम और पैन करने के लिए नियंत्रक
  final TransformationController _transformationController =
      TransformationController();

  // एप्लिकेशन की स्थिति
  bool _showCurtain = true;
  String _currentLanguage = 'EN'; // Set to English by default

  // परिदृश्य डेटा
  late List<Scenario> _scenarios;
  int _currentScenarioIndex = 0;
  int _currentStepIndex = 0;

  // प्रयोगशाला की स्थिति (पुल)
  final List<ItemType> _pad1 = [];
  final List<ItemType> _pad2 = [];
  final List<ItemType> _resultPad = [];

  // 3D लेआउट के लिए हिट परीक्षण हाइलाइट्स
  bool _isHoveringPad1 = false;
  bool _isHoveringPad2 = false;

  bool _isAnimating = false;
  String _validationMessage = "";
  Color _validationColor = Colors.transparent;

  // --- ऑडियो प्लेयर्स इनिशियलाइज़ेशन ---
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();
  final AudioPlayer _errorPlayer = AudioPlayer();
  final AudioPlayer _curtainPlayer = AudioPlayer();

  // सहायक: त्वरित अनुवाद प्राप्तकर्ता
  String _t(String key) {
    final dict = AppTranslations.strings[key];
    if (dict == null) return key;
    return dict[_currentLanguage] ?? dict['EN'] ?? key;
  }

  // --- ऑडियो प्लेबैक मेथड्स ---
  Future<void> playClick() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(
      AssetSource(
        'audio/class7/mixkit_2073.mp3',
      ),
    );
  }

  Future<void> playPageOpen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(
      AssetSource(
        'audio/class7/gotitem.mp3',
      ),
    );
  }

  Future<void> playDropdown() async {
    await _dropdownPlayer.stop();
    await _dropdownPlayer.play(
      AssetSource(
        'audio/class7/mixkit_1491.mp3',
      ),
    );
  }

  Future<void> playError() async {
    await _errorPlayer.stop();
    await _errorPlayer.play(
      AssetSource(
        'audio/class7/mixkit_946.mp3',
      ),
    );
  }

  Future<void> curtainScreen() async {
    await _curtainPlayer.stop();
    await _curtainPlayer.play(
      AssetSource(
        'audio/class7/mixkit_2574.mp3',
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _initScenarios();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _transformationController.dispose();

    // ऑडियो प्लेयर्स को डिस्पोज़ करें ताकि मेमोरी लीक न हो
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();
    _errorPlayer.dispose();
    _curtainPlayer.dispose();

    super.dispose();
  }

  void _initScenarios() {
    _scenarios = [
      Scenario(
        id: 1,
        title: _t('s1_title'),
        objective: _t('s1_obj'),
        mathText: "2.14 + 1.32",
        steps: [
          LabStep(
            title: _t('s1_s1_t'),
            theory: _t('s1_s1_th'),
            hud: _t('s1_s1_h'),
            action: ActionType.build,
            targetPad: 1,
            targetUnits: 2,
            targetTenths: 1,
            targetHundredths: 4,
          ),
          LabStep(
            title: _t('s1_s2_t'),
            theory: _t('s1_s2_th'),
            hud: _t('s1_s2_h'),
            action: ActionType.build,
            targetPad: 2,
            targetUnits: 1,
            targetTenths: 3,
            targetHundredths: 2,
          ),
          LabStep(
            title: _t('s1_s3_t'),
            theory: _t('s1_s3_th'),
            hud: _t('s1_s3_h'),
            action: ActionType.combine,
          ),
          LabStep(
            title: _t('s1_s4_t'),
            theory: _t('s1_s4_th'),
            hud: _t('s1_s4_h'),
            action: ActionType.done,
            mathResult: "2.14 + 1.32 = 3.46",
            summaryText: _t('s1_s4_sum'),
          ),
        ],
      ),
      Scenario(
        id: 2,
        title: _t('s2_title'),
        objective: _t('s2_obj'),
        mathText: "1.85 + 2.46",
        steps: [
          LabStep(
            title: _t('s2_s1_t'),
            theory: _t('s2_s1_th'),
            hud: _t('s2_s1_h'),
            action: ActionType.build,
            targetPad: 1,
            targetUnits: 1,
            targetTenths: 8,
            targetHundredths: 5,
          ),
          LabStep(
            title: _t('s2_s2_t'),
            theory: _t('s2_s2_th'),
            hud: _t('s2_s2_h'),
            action: ActionType.build,
            targetPad: 2,
            targetUnits: 2,
            targetTenths: 4,
            targetHundredths: 6,
          ),
          LabStep(
            title: _t('s2_s3_t'),
            theory: _t('s2_s3_th'),
            hud: _t('s2_s3_h'),
            action: ActionType.combine,
          ),
          LabStep(
            title: _t('s2_s4_t'),
            theory: _t('s2_s4_th'),
            hud: _t('s2_s4_h'),
            action: ActionType.regroup,
          ),
          LabStep(
            title: _t('s2_s5_t'),
            theory: _t('s2_s5_th'),
            hud: _t('s2_s5_h'),
            action: ActionType.regroup,
          ),
          LabStep(
            title: _t('s2_s6_t'),
            theory: _t('s2_s6_th'),
            hud: _t('s2_s6_h'),
            action: ActionType.done,
            mathResult: "1.85 + 2.46 = 4.31",
            summaryText: _t('s2_s6_sum'),
          ),
        ],
      ),
    ];
  }

  void _showTempMessage(String msg, Color color) {
    setState(() {
      _validationMessage = msg;
      _validationColor = color;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _validationMessage = "";
        });
      }
    });
  }

  void _loadScenario(int index) {
    setState(() {
      _currentScenarioIndex = index;
      _currentStepIndex = 0;
      _pad1.clear();
      _pad2.clear();
      _resultPad.clear();
      _validationMessage = "";
    });
  }

  void _toggleLanguage() {
    playClick(); // भाषा बदलने पर ध्वनि
    setState(() {
      if (_currentLanguage == 'EN') {
        _currentLanguage = 'HI';
      } else {
        _currentLanguage = 'EN';
      }
      _initScenarios();
    });
    _showTempMessage("${_t('msg_lang')}$_currentLanguage", Colors.orangeAccent);
  }

  void _resetLab() {
    playClick(); // लैब रीसेट करने पर ध्वनि
    setState(() {
      _showCurtain = true; // पर्दे वाली स्क्रीन (Curtain Screen) को वापस लाएं
    });
    _loadScenario(0);
    _transformationController.value = Matrix4.identity();
    _showTempMessage(_t('msg_reset'), Colors.orangeAccent);
  }

  void _handleItemDrop(ItemType item, int targetPadId) {
    if (_isAnimating) return;

    final step = _scenarios[_currentScenarioIndex].steps[_currentStepIndex];
    if (step.action != ActionType.build) return;

    if (step.targetPad != targetPadId) {
      playError(); // गलत जगह छोड़ने पर त्रुटि ध्वनि
      _showTempMessage(_t('msg_drop_error'), Colors.redAccent);
      return;
    }

    List<ItemType> activePad = targetPadId == 1 ? _pad1 : _pad2;
    int currentCount = activePad.where((e) => e == item).length;
    int targetCount = 0;
    if (item == ItemType.unit) targetCount = step.targetUnits;
    if (item == ItemType.tenth) targetCount = step.targetTenths;
    if (item == ItemType.hundredth) targetCount = step.targetHundredths;

    if (currentCount >= targetCount) {
      playError();
      _showTempMessage(_t('msg_incorrect'), Colors.redAccent);
      return;
    }

    playDropdown(); // सही जगह ड्रॉप करने पर ध्वनि
    setState(() {
      if (targetPadId == 1) _pad1.add(item);
      if (targetPadId == 2) _pad2.add(item);
      if (targetPadId == 3) _resultPad.add(item);

      if (targetPadId == 1) _isHoveringPad1 = false;
      if (targetPadId == 2) _isHoveringPad2 = false;
    });
  }

  void _removeItem(ItemType item, int padId) {
    if (_isAnimating) return;
    final step = _scenarios[_currentScenarioIndex].steps[_currentStepIndex];
    if (step.action != ActionType.build || step.targetPad != padId) return;

    playClick(); // आइटम हटाने पर क्लिक ध्वनि
    setState(() {
      if (padId == 1) _pad1.remove(item);
      if (padId == 2) _pad2.remove(item);
      if (padId == 3) _resultPad.remove(item);
    });
  }

  void _checkBuildStep() {
    if (_isAnimating) return;
    final step = _scenarios[_currentScenarioIndex].steps[_currentStepIndex];
    if (step.action != ActionType.build) return;

    List<ItemType> activePad = step.targetPad == 1 ? _pad1 : _pad2;
    int units = activePad.where((e) => e == ItemType.unit).length;
    int tenths = activePad.where((e) => e == ItemType.tenth).length;
    int hunds = activePad.where((e) => e == ItemType.hundredth).length;

    if (units == step.targetUnits &&
        tenths == step.targetTenths &&
        hunds == step.targetHundredths) {
      playPageOpen(); // सही मात्रा पर सफलता की ध्वनि
      _showTempMessage(_t('msg_correct'), Colors.greenAccent);
      setState(() {
        _currentStepIndex++;
      });
    } else {
      playError(); // गलत मात्रा पर त्रुटि की ध्वनि
      _showTempMessage(_t('msg_incorrect'), Colors.redAccent);
    }
  }

  void _executeCombine() async {
    if (_isAnimating) return;
    final step = _scenarios[_currentScenarioIndex].steps[_currentStepIndex];
    if (step.action != ActionType.combine) {
      playError(); // गलत समय पर मिलाने पर त्रुटि ध्वनि
      _showTempMessage(_t('msg_combine_error'), Colors.redAccent);
      return;
    }

    playDropdown(); // मिलाने की प्रक्रिया शुरू होने पर ध्वनि
    _showTempMessage(_t('btn_combine'), Colors.blueAccent);
    setState(() {
      _isAnimating = true;
    });

    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        if (_pad1.isNotEmpty) {
          _resultPad.add(_pad1.removeLast());
        }
        if (_pad2.isNotEmpty) {
          _resultPad.add(_pad2.removeLast());
        }
      });
    }

    setState(() {
      _resultPad.addAll(_pad1);
      _resultPad.addAll(_pad2);
      _pad1.clear();
      _pad2.clear();
    });

    await Future.delayed(const Duration(milliseconds: 500));
    playPageOpen(); // प्रक्रिया पूरी होने पर सफलता की ध्वनि
    setState(() {
      _isAnimating = false;
      _currentStepIndex++;
    });
  }

  void _executeRegroup() async {
    if (_isAnimating) return;
    final step = _scenarios[_currentScenarioIndex].steps[_currentStepIndex];
    if (step.action != ActionType.regroup) return;

    playDropdown(); // पुनर्समूहन प्रक्रिया शुरू होने पर ध्वनि
    setState(() {
      _isAnimating = true;
    });

    bool isHundredths =
        step.title.contains("Hundredths") || step.title.contains("सौवें");
    ItemType typeToRemove = isHundredths ? ItemType.hundredth : ItemType.tenth;
    ItemType typeToAdd = isHundredths ? ItemType.tenth : ItemType.unit;

    int count = _resultPad.where((e) => e == typeToRemove).length;
    if (count >= 10) {
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 150));
        setState(() {
          int idx = _resultPad.lastIndexOf(typeToRemove);
          if (idx != -1) _resultPad.removeAt(idx);
        });
      }

      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _resultPad.add(typeToAdd);
      });
    }

    await Future.delayed(const Duration(milliseconds: 800));
    playPageOpen(); // पुनर्समूहन पूरा होने पर सफलता की ध्वनि
    setState(() {
      _isAnimating = false;
      _currentStepIndex++;
    });
  }

  Widget _buildLabelBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2532),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFB38D4B), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildLabItem(
    ItemType type, {
    bool isDragging = false,
    double scale = 1.0,
  }) {
    double finalScale = isDragging ? scale * 1.2 : scale;
    Widget shape;
    switch (type) {
      case ItemType.unit:
        shape = CustomPaint(
          size: const Size(60, 80),
          painter: GlassPainter(
            liquidColor: Colors.blueAccent,
            fillPercent: 0.8,
          ),
        );
        break;
      case ItemType.tenth:
        shape = CustomPaint(
          size: const Size(30, 90),
          painter: GlassPainter(
            liquidColor: Colors.greenAccent,
            fillPercent: 0.7,
          ),
        );
        break;
      case ItemType.hundredth:
        shape = CustomPaint(
          size: const Size(15, 60),
          painter: GlassPainter(
            liquidColor: Colors.amber,
            fillPercent: 0.6,
            isTube: true,
          ),
        );
        break;
    }
    return Transform.scale(scale: finalScale, child: shape);
  }

  Widget _buildDraggableSource(ItemType type) {
    return Draggable<ItemType>(
      data: type,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: () {
        playClick(); // ड्रैग शुरू करने पर हल्की क्लिक ध्वनि
      },
      feedback: Transform.scale(
        scale: _transformationController.value.getMaxScaleOnAxis(),
        alignment: Alignment.topLeft,
        child: Material(
          color: Colors.transparent,
          child: _buildLabItem(type, isDragging: true),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: _buildLabItem(type)),
      child: _buildLabItem(type),
    );
  }

  Widget _buildDragTargetPad(int padId, List<ItemType> items) {
    final step = _scenarios[_currentScenarioIndex].steps[_currentStepIndex];
    bool isActive = step.targetPad == padId && step.action == ActionType.build;

    return DragTarget<ItemType>(
      onWillAcceptWithDetails: (details) {
        if (!isActive) return false;
        setState(
          () => padId == 1 ? _isHoveringPad1 = true : _isHoveringPad2 = true,
        );
        return true;
      },
      onLeave: (data) {
        setState(
          () => padId == 1 ? _isHoveringPad1 = false : _isHoveringPad2 = false,
        );
      },
      onAcceptWithDetails: (details) => _handleItemDrop(details.data, padId),
      builder: (context, candidateData, rejectedData) {
        return Container(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 24,
              left: 12,
              right: 12,
              bottom: 12,
            ),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: items.map((item) {
                  return GestureDetector(
                    onTap: () => _removeItem(item, padId),
                    child: _buildLabItem(item, scale: 0.8),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultPadContent() {
    return Container(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 24,
          left: 16,
          right: 16,
          bottom: 16,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResultSection(ItemType.unit),
            _buildResultSection(ItemType.tenth),
            _buildResultSection(ItemType.hundredth),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection(ItemType type) {
    List<ItemType> items = _resultPad.where((e) => e == type).toList();
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: items
                    .map((item) => _buildLabItem(item, scale: 0.8))
                    .toList(),
              ),
            ),
          ),
          if (items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                items.length.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLabDesk() {
    final step = _scenarios[_currentScenarioIndex].steps[_currentStepIndex];
    bool pad1Active = step.targetPad == 1 && step.action == ActionType.build;
    bool pad2Active = step.targetPad == 2 && step.action == ActionType.build;

    return Center(
      child: Container(
        width: 1000,
        height: 700,
        decoration: const BoxDecoration(color: Color(0xFF050B14)),
        child: Stack(
          children: [
            // 1. डेस्क का फर्श और ज़ोन बॉर्डर बनाएं (सबसे निचली परत)
            Positioned.fill(
              child: CustomPaint(
                painter: DeskBackgroundPainter(
                  pad1Highlight: _isHoveringPad1 || pad1Active,
                  pad2Highlight: _isHoveringPad2 || pad2Active,
                ),
              ),
            ),

            // 2. 3D शेल्फ बनाएं
            Positioned.fill(child: CustomPaint(painter: ShelfPainter())),

            Positioned(
              left: 500 - 150,
              top: 15,
              width: 300,
              child: Align(
                alignment: Alignment.center,
                child: _buildLabelBox('Containers Shelf'),
              ),
            ),

            // -- इकाई संपत्तियां (UNIT ASSETS) --
            Positioned(
              left: 333 - 100,
              top: 80,
              width: 200,
              child: Align(
                alignment: Alignment.center,
                child: _buildLabelBox(_t('units_label')),
              ),
            ),
            Positioned(
              left: 333 - 50,
              top: 130,
              width: 100,
              height: 105,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: _buildDraggableSource(ItemType.unit),
              ),
            ),

            // -- दसवां संपत्तियां (TENTHS ASSETS) --
            Positioned(
              left: 500 - 100,
              top: 80,
              width: 200,
              child: Align(
                alignment: Alignment.center,
                child: _buildLabelBox(_t('tenths_label')),
              ),
            ),
            Positioned(
              left: 500 - 50,
              top: 130,
              width: 100,
              height: 105,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: _buildDraggableSource(ItemType.tenth),
              ),
            ),

            // -- सौवां संपत्तियां (HUNDREDTHS ASSETS) --
            Positioned(
              left: 666 - 100,
              top: 80,
              width: 200,
              child: Align(
                alignment: Alignment.center,
                child: _buildLabelBox(_t('hunds_label')),
              ),
            ),
            Positioned(
              left: 666 - 50,
              top: 130,
              width: 100,
              height: 105,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: _buildDraggableSource(ItemType.hundredth),
              ),
            ),

            // -- ड्रैग लक्ष्य 1 (पहली राशि) --
            Positioned(
              left: 180,
              top: 320,
              width: 310,
              height: 110,
              child: _buildDragTargetPad(1, _pad1),
            ),
            Positioned(
              left: 335 - 100,
              top: 295,
              width: 200,
              child: Align(
                alignment: Alignment.center,
                child: _buildLabelBox(_t('first_amount')),
              ),
            ),

            // -- ड्रैग लक्ष्य 2 (दूसरी राशि) --
            Positioned(
              left: 510,
              top: 320,
              width: 310,
              height: 110,
              child: _buildDragTargetPad(2, _pad2),
            ),
            Positioned(
              left: 665 - 100,
              top: 295,
              width: 200,
              child: Align(
                alignment: Alignment.center,
                child: _buildLabelBox(_t('second_amount')),
              ),
            ),

            // -- परिणाम क्षेत्र (RESULT AREA) --
            Positioned(
              left: 100,
              top: 480,
              width: 800,
              height: 170,
              child: _buildResultPadContent(),
            ),
            Positioned(
              left: 500 - 100,
              top: 455,
              width: 200,
              child: Align(
                alignment: Alignment.center,
                child: _buildLabelBox(_t('result_area')),
              ),
            ),
            Positioned(
              left: 500 - 100,
              top: 495,
              width: 200,
              child: Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: _executeCombine,
                  child: _buildLabelBox('Combine'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomControls() {
    return Positioned(
      bottom: 24,
      right: 24,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orangeAccent.withOpacity(0.4)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.center_focus_strong,
                color: Colors.orangeAccent,
              ),
              tooltip: _t('tooltip_reset_view'),
              onPressed: () {
                playClick(); // ज़ूम रीसेट करने पर ध्वनि
                _transformationController.value = Matrix4.identity();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepActionButton(LabStep step) {
    if (step.action == ActionType.build) {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orangeAccent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.check_circle_outline),
        label: Text(
          _t('btn_check'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        onPressed: _checkBuildStep,
      );
    } else if (step.action == ActionType.combine) {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.merge_type),
        label: Text(
          _t('btn_combine'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        onPressed: _executeCombine,
      );
    } else if (step.action == ActionType.regroup) {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.greenAccent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.auto_awesome),
        label: Text(
          _t('btn_regroup'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        onPressed: _executeRegroup,
      );
    } else if (step.action == ActionType.done) {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orangeAccent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.school),
        label: Text(
          _t('btn_validate'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        onPressed: () {
          playPageOpen(); // पॉपअप खोलने पर सफलता की ध्वनि
          _showSummaryPopup();
        },
      );
    }
    return const SizedBox.shrink();
  }

  // --- पूर्ण रूप से स्क्रॉल करने योग्य साइडबार विजेट ---
  Widget _buildSidebar() {
    final scenario = _scenarios[_currentScenarioIndex];
    final step = scenario.steps[_currentStepIndex];

    return Container(
      width: _sidebarWidth,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.95),
        border: const Border(right: BorderSide(color: Colors.white10)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 15,
            offset: Offset(5, 0),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // 1. शीर्ष हेडर: शीर्षक, नियंत्रण और ड्रॉपडाउन
                    Container(
                      padding: const EdgeInsets.only(
                        top: 66,
                        left: 20,
                        right: 20,
                        bottom: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        border: const Border(
                          bottom: BorderSide(color: Colors.white10),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.science,
                                color: Colors.orangeAccent,
                                size: 28,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _t('title_short'),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orangeAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _t('subtitle'),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white54,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: _toggleLanguage,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.orangeAccent.withOpacity(
                                          0.8,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.language,
                                          color: Colors.orangeAccent,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _currentLanguage,
                                          style: const TextStyle(
                                            color: Colors.orangeAccent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              InkWell(
                                onTap: _resetLab,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.orangeAccent.withOpacity(
                                        0.8,
                                      ),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.refresh,
                                    color: Colors.orangeAccent,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                isExpanded: true,
                                dropdownColor: const Color(0xFF1E293B),
                                value: _currentScenarioIndex,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.orangeAccent,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                items: _scenarios.asMap().entries.map((e) {
                                  return DropdownMenuItem<int>(
                                    value: e.key,
                                    child: Text(e.value.title),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    playDropdown(); // ड्रॉपडाउन बदलने पर ध्वनि
                                    _loadScenario(val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. मुख्य भाग: उद्देश्य, परिणाम पूर्वावलोकन और चरणों की सूची
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.track_changes,
                                        color: Colors.blueAccent,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _t('mission_obj'),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    scenario.objective,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                step.mathResult ?? scenario.mathText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: step.mathResult != null
                                      ? Colors.orangeAccent
                                      : Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            ...scenario.steps.asMap().entries.map((e) {
                              int idx = e.key;
                              LabStep s = e.value;
                              bool isCompleted = idx < _currentStepIndex;
                              bool isCurrent = idx == _currentStepIndex;

                              Color bgColor = isCurrent
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.transparent;
                              Color borderColor = isCurrent
                                  ? Colors.orangeAccent.withOpacity(0.5)
                                  : Colors.white10;
                              Color titleColor = isCurrent
                                  ? Colors.orangeAccent
                                  : (isCompleted
                                        ? Colors.white54
                                        : Colors.white70);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          isCompleted
                                              ? Icons.check_circle
                                              : (isCurrent
                                                    ? Icons.arrow_circle_right
                                                    : Icons.circle_outlined),
                                          color: isCompleted
                                              ? Colors.green
                                              : (isCurrent
                                                    ? Colors.orangeAccent
                                                    : Colors.white30),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            s.title,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: titleColor,
                                              decoration: isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      s.theory,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isCompleted
                                            ? Colors.white30
                                            : (isCurrent
                                                  ? Colors.white
                                                  : Colors.white54),
                                        height: 1.4,
                                        decoration: isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),

                    // 3. निचला क्षेत्र: मान्यताएं और कार्रवाई (Validations & Action Execution)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E293B),
                        border: Border(top: BorderSide(color: Colors.white10)),
                      ),
                      child: Column(
                        children: [
                          if (_validationMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                _validationMessage,
                                style: TextStyle(
                                  color: _validationColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          if (step.action == ActionType.build) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatusColumn(
                                  _t('target'),
                                  step.targetUnits,
                                  step.targetTenths,
                                  step.targetHundredths,
                                  Colors.white,
                                ),
                                Container(
                                  height: 40,
                                  width: 1,
                                  color: Colors.white24,
                                ),
                                _buildStatusColumn(
                                  _t('current'),
                                  step.targetPad == 1
                                      ? _pad1
                                            .where((e) => e == ItemType.unit)
                                            .length
                                      : _pad2
                                            .where((e) => e == ItemType.unit)
                                            .length,
                                  step.targetPad == 1
                                      ? _pad1
                                            .where((e) => e == ItemType.tenth)
                                            .length
                                      : _pad2
                                            .where((e) => e == ItemType.tenth)
                                            .length,
                                  step.targetPad == 1
                                      ? _pad1
                                            .where(
                                              (e) => e == ItemType.hundredth,
                                            )
                                            .length
                                      : _pad2
                                            .where(
                                              (e) => e == ItemType.hundredth,
                                            )
                                            .length,
                                  Colors.orangeAccent,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: _buildStepActionButton(step),
                          ),
                        ],
                      ),
                    ),
                    // कॉपीराइट हेडर
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      color: Colors.black.withOpacity(0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          '© ZeroScienceLab - Fall in love with math and Science',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white54,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- तैरता हुआ मिशन कार्ड (FLOATING MISSION CARD) ---
  Widget _buildFloatingMissionCard() {
    final scenario = _scenarios[_currentScenarioIndex];
    final step = scenario.steps[_currentStepIndex];

    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orangeAccent.withOpacity(0.6),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.assignment,
                color: Colors.orangeAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  step.title,
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  step.mathResult ?? scenario.mathText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            step.hud,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (_validationMessage.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _validationMessage,
              style: TextStyle(
                color: _validationColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: _buildStepActionButton(step),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusColumn(String title, int u, int t, int h, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white54,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "$u ${_t('units')}",
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "$t ${_t('tenths')}",
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "$h ${_t('hunds')}",
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showSummaryPopup() {
    final step = _scenarios[_currentScenarioIndex].steps.last;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 450,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.stars,
                        color: Colors.orangeAccent,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _t('scenario_complete'),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54),
                        onPressed: () {
                          playClick(); // बंद करने पर क्लिक ध्वनि
                          Navigator.of(context).pop();
                          _loadScenario(_currentScenarioIndex == 0 ? 1 : 0);
                        },
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 32),
                  Text(
                    step.mathResult ?? "",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    step.summaryText ?? "",
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.5,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        playClick(); // आगे बढ़ने पर क्लिक ध्वनि
                        Navigator.of(context).pop();
                        _loadScenario(_currentScenarioIndex == 0 ? 1 : 0);
                      },
                      child: Text(
                        _t('btn_continue'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        },
        child: Stack(
          children: [
            // लैब लॉजिक और ग्राफ़िक्स
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.only(
                  left: _isSidebarOpen ? _sidebarWidth : 0,
                ),
                color: const Color(0xFF050B14),
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.1,
                  maxScale: 4.0,
                  boundaryMargin: const EdgeInsets.all(2000),
                  constrained: false,
                  child: _buildLabDesk(),
                ),
              ),
            ),

            // साइडबार विजेट ओवरले
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: _isSidebarOpen ? 0 : -_sidebarWidth,
              width: _sidebarWidth,
              child: _buildSidebar(),
            ),

            // मेनू टॉगल बटन
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.orangeAccent,
                iconSize: 28,
                onPressed: () {
                  playClick(); // साइडबार खोलने/बंद करने पर ध्वनि
                  HapticFeedback.lightImpact();
                  setState(() {
                    _isSidebarOpen = !_isSidebarOpen;
                  });
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Colors.orangeAccent.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            ),

            // ज़ूम नियंत्रण
            _buildZoomControls(),

            // तैरता हुआ मिशन कार्ड ओवरले (जब साइडबार छिपा हो)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: _isSidebarOpen ? -400 : 24,
              left: 20,
              child: _buildFloatingMissionCard(),
            ),

            // प्रारंभिक स्क्रीन ओवरले (Intro Screen)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutCubic,
              top: _showCurtain ? 0 : -MediaQuery.of(context).size.height,
              bottom: _showCurtain ? 0 : MediaQuery.of(context).size.height,
              left: 0,
              right: 0,
              child: Container(
                color: const Color(0xFF050B14),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.science,
                          size: 80,
                          color: Colors.orangeAccent,
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            _t('title_main'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _t('subtitle'),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white54,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 10,
                          ),
                          icon: Text(
                            _t('btn_enter'),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          label: const Icon(Icons.arrow_forward, size: 24),
                          onPressed: () {
                            curtainScreen(); // लैब में प्रवेश करते समय कर्टेन ध्वनि
                            setState(() {
                              _showCurtain = false;
                            });
                          },
                        ),
                      ],
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
}

// --- कस्टम पेंटर्स (CUSTOM PAINTERS) ---

class DeskBackgroundPainter extends CustomPainter {
  final bool pad1Highlight;
  final bool pad2Highlight;

  DeskBackgroundPainter({
    required this.pad1Highlight,
    required this.pad2Highlight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. डेस्क का फर्श (गहरा रंग)
    final tablePaint = Paint()..color = const Color(0xFF754522);
    final tablePath = Path()
      ..moveTo(100, 250)
      ..lineTo(900, 250)
      ..lineTo(1200, 800)
      ..lineTo(-200, 800)
      ..close();
    canvas.drawPath(tablePath, tablePaint);

    // 2. पहली राशि का क्षेत्र (Pad 1)
    _drawPad(canvas, 230, 320, 480, 320, 490, 430, 180, 430, pad1Highlight);

    // 3. दूसरी राशि का क्षेत्र (Pad 2)
    _drawPad(canvas, 520, 320, 770, 320, 820, 430, 510, 430, pad2Highlight);

    // 4. परिणाम क्षेत्र (Pad 3)
    _drawPad(canvas, 200, 480, 800, 480, 900, 650, 100, 650, false);
  }

  void _drawPad(
    Canvas canvas,
    double tlX,
    double tlY,
    double trX,
    double trY,
    double brX,
    double brY,
    double blX,
    double blY,
    bool isHighlight,
  ) {
    final path = Path()
      ..moveTo(tlX, tlY)
      ..lineTo(trX, trY)
      ..lineTo(brX, brY)
      ..lineTo(blX, blY)
      ..close();

    if (isHighlight) {
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.amber.withOpacity(0.5)
          ..style = PaintingStyle.fill,
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant DeskBackgroundPainter oldDelegate) {
    return oldDelegate.pad1Highlight != pad1Highlight ||
        oldDelegate.pad2Highlight != pad2Highlight;
  }
}

class ShelfPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // शेल्फ का ऊपरी भाग
    canvas.drawPath(
      Path()
        ..moveTo(220, 220)
        ..lineTo(820, 220)
        ..lineTo(800, 250)
        ..lineTo(200, 250)
        ..close(),
      Paint()..color = const Color(0xFF6A7994),
    );
    // शेल्फ का सामने का भाग
    canvas.drawPath(
      Path()
        ..moveTo(200, 250)
        ..lineTo(800, 250)
        ..lineTo(800, 290)
        ..lineTo(200, 290)
        ..close(),
      Paint()..color = const Color(0xFF41506B),
    );
    // शेल्फ का दाईं ओर का भाग
    canvas.drawPath(
      Path()
        ..moveTo(800, 250)
        ..lineTo(820, 220)
        ..lineTo(820, 260)
        ..lineTo(800, 290)
        ..close(),
      Paint()..color = const Color(0xFF2C3950),
    );

    // शेल्फ के ऊपर छाया
    final shadowPaint = Paint()..color = Colors.black38;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(333, 235), width: 70, height: 25),
      shadowPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(500, 235), width: 60, height: 22),
      shadowPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(666, 235), width: 50, height: 18),
      shadowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GlassPainter extends CustomPainter {
  final Color liquidColor;
  final double fillPercent;
  final bool isTube;

  GlassPainter({
    required this.liquidColor,
    required this.fillPercent,
    this.isTube = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final glassPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final glassBorder = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final liquidPaint = Paint()
      ..color = liquidColor.withOpacity(0.85)
      ..style = PaintingStyle.fill;

    Path outline = Path();
    if (isTube) {
      outline.moveTo(0, 0);
      outline.lineTo(0, size.height - size.width / 2);
      outline.arcToPoint(
        Offset(size.width, size.height - size.width / 2),
        radius: Radius.circular(size.width / 2),
        clockwise: false,
      );
      outline.lineTo(size.width, 0);
      outline.close();
    } else {
      double lip = 2.0;
      outline.moveTo(-lip, 0);
      outline.lineTo(size.width + lip, 0);
      outline.lineTo(size.width, size.height);
      outline.lineTo(0, size.height);
      outline.close();
    }

    canvas.drawPath(outline, glassPaint);

    if (fillPercent > 0) {
      double liquidTop = size.height * (1.0 - fillPercent);
      Path liquidPath = Path();
      if (isTube) {
        liquidPath.moveTo(0, liquidTop);
        liquidPath.lineTo(0, size.height - size.width / 2);
        liquidPath.arcToPoint(
          Offset(size.width, size.height - size.width / 2),
          radius: Radius.circular(size.width / 2),
          clockwise: false,
        );
        liquidPath.lineTo(size.width, liquidTop);
        liquidPath.quadraticBezierTo(
          size.width / 2,
          liquidTop + 2,
          0,
          liquidTop,
        );
      } else {
        liquidPath.moveTo(0, liquidTop);
        liquidPath.lineTo(0, size.height);
        liquidPath.lineTo(size.width, size.height);
        liquidPath.lineTo(size.width, liquidTop);
        liquidPath.quadraticBezierTo(
          size.width / 2,
          liquidTop + 3,
          0,
          liquidTop,
        );
      }
      canvas.drawPath(liquidPath, liquidPaint);

      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      Path highlight = Path();
      highlight.moveTo(2, liquidTop + 2);
      highlight.lineTo(2, size.height - 2);
      highlight.lineTo(size.width * 0.3, size.height - 2);
      highlight.lineTo(size.width * 0.3, liquidTop + 2);
      highlight.close();
      canvas.drawPath(highlight, highlightPaint);
    }

    canvas.drawPath(outline, glassBorder);

    canvas.drawOval(
      Rect.fromLTWH(
        isTube ? 0 : -2,
        -3,
        isTube ? size.width : size.width + 4,
        6,
      ),
      glassBorder,
    );
  }

  @override
  bool shouldRepaint(covariant GlassPainter oldDelegate) {
    return oldDelegate.liquidColor != liquidColor ||
        oldDelegate.fillPercent != fillPercent;
  }
}
