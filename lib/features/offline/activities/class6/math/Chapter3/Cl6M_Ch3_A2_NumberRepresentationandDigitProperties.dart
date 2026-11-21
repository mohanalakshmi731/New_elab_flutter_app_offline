// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use, use_super_parameters, camel_case_types, non_constant_identifier_names

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'ZSL Virtual Lab | Number Play',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF10B981),
          surface: Color(0xFF1E293B),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Plus Jakarta Sans'),
        ),
      ),
      home: const Cl6M_Ch3_A2_NumberRepresentationandDigitProperties(),
    ),
  );
}

// --- STATE MANAGEMENT ---

class GameState {
  String lang = 'en';
  bool sidebarOpen = true;
  double zoom = 1.0;
  double panX = 0.0;
  double panY = 0.0;
  bool isLocked = true;

  int scenario = 1;
  int step = 0;
  double canvasWidth = 0;
  double canvasHeight = 0;

  bool animating = false;
  double animProgress = 0;

  // S1 State
  List<List<int>> s1_grid = [
    [8632, 4580, 9870],
    [1944, 4795, 8280],
    [5785, 1000, 9230],
  ];
  List<Map<String, dynamic>> s1_tested = [];
  List<Map<String, dynamic>> s1_beams = [];

  // S2 State
  List<int> s2_blocksInTray = [68, 545];
  int? s2_inMachine;
  double s2_animStage = 0;
  List<int> s2_weighed = [];

  // S3 State
  int s3_num = 47;
  double s3_animStage = 0;

  // S4 State
  List<int> s4_tray = [110, 100, 150, 130, 280, 200, 230, 210, 270];
  List<int?> s4_grid = List.filled(9, null);
  int s4_score = 0;
  List<int> s4_glows = [];

  // S5 State
  List<int> s5_tray = [6382, 5683, 1980];
  int? s5_current;
  double s5_animStage = 0;
  int s5_animRound = 0;
  bool s5_done = false;

  String? activeDragEntity;
  double dragX = 0;
  double dragY = 0;

  void resetScenario() {
    animating = false;
    activeDragEntity = null;
    if (scenario == 1) {
      s1_tested.clear();
      s1_beams.clear();
    } else if (scenario == 2) {
      s2_inMachine = null;
      s2_weighed.clear();
      s2_animStage = 0;
    } else if (scenario == 3) {
      s3_animStage = 0;
    } else if (scenario == 4) {
      s4_grid.fillRange(0, 9, null);
      s4_score = 0;
      s4_glows.clear();
      s4_tray = [110, 100, 150, 130, 280, 200, 230, 210, 270];
    } else if (scenario == 5) {
      s5_current = null;
      s5_done = false;
      s5_animStage = 0;
      s5_animRound = 0;
    }
  }
}

// --- LOCALIZATION ---

class AppTranslations {
  static const Map<String, Map<String, String>> data = {
    'en': {
      'resetbtn': 'Reset',
      'shutterTitle': 'Number Representation and Digit Properties',
      'appTitle': 'Number Play Lab',
      'appSubtitle': 'Class 6 • DIGIT PROPERTIES',
      'enterLab': 'Enter Simulation',
      'selectScenario': 'Select Scenario',
      'stepLabel': 'STEP',
      'learnLbl': 'Observations:',
      'summaryTitle': 'Goal Reached!',
      'finishLab': 'Finish Lab',
      'nextScenario': 'Next Scenario',
      'finalDesc':
          'You have successfully explored number patterns and properties!',
      's1_title': '1. The Supercell Summit',
      's1_obj':
          "Identify all the 'Supercells' in a grid. A Supercell is a number that is larger than all of its immediate neighbors.",
      's1_step1_task': "Drag on the central block labeled '8632'.",
      's1_step1_out':
          "The block '8632' glows green. Its neighbors briefly flash red.",
      's1_step2_task': "Drag on the block labeled '4580'.",
      's1_step2_out':
          "The block '4580' flashes red. A red beam indicates '8632' is larger.",
      's1_step3_task':
          "Drag on every block in the grid to test if it is a Supercell.",
      's1_step3_out': "The blocks 8632, 9870, 9230, and 5785 are Supercells.",
      's1_step4_task': "Observe the Supercell concept.",
      's1_step4_out':
          "A Supercell is greater than all its adjacent neighbors, like a mountain peak.",
      's1_hud1': "Drag the block '8632'.",
      's1_hud2': "Drag the block '4580'.",
      's1_hud3': "Drag all remaining blocks.",
      's1_hud4': "Challenge Complete!",
      's2_title': '2. The Digit Sum Scale',
      's2_obj':
          'Understand the concept of a digit sum by visually deconstructing numbers.',
      's2_step1_task':
          "DRAG the block '68' and DROP it into the Digit Sum Machine.",
      's2_step1_out': "The machine splits '68' into '6' and '8'.",
      's2_step2_task': "Watch the machine weigh the digits.",
      's2_step2_out': "The scale pointer moves to 14. 6 + 8 = 14.",
      's2_step3_task': "DRAG the block '545' into the machine.",
      's2_step3_out':
          "The machine splits '545' into '5', '4', '5' and weighs them as 14.",
      's2_step4_task': "Observe the Digit Sum result.",
      's2_step4_out': "Different numbers can have the same Digit Sum!",
      's2_hud1': "Drag block '68' into the machine funnel.",
      's2_hud2': "Observe the weighing process.",
      's2_hud3': "Drag block '545' into the machine funnel.",
      's2_hud4': "Challenge Complete!",
      's3_title': '3. The Palindrome Flipper',
      's3_obj':
          'Discover how the reverse-and-add method can create a palindromic number.',
      's3_step1_task': "CLICK the 'Start' button to process the block '47'.",
      's3_step1_out': "A robotic arm picks up '47'.",
      's3_step2_task': "Observe the Reverse station.",
      's3_step2_out': "The block is duplicated and reversed to '74'.",
      's3_step3_task': "Observe the Add station.",
      's3_step3_out':
          "The blocks '47' and '74' are pressed together to form '121'.",
      's3_step4_task': "Observe the Palindrome Check.",
      's3_step4_out':
          "The scanner confirms '121' reads the same forwards and backwards.",
      's3_step5_task': "Observe the summary.",
      's3_step5_out':
          "You created a Palindrome by adding a number to its reverse.",
      's3_hud1': "Click Start to process 47.",
      's3_hud2': "Observe the duplication and reversal.",
      's3_hud3': "Observe the addition.",
      's3_hud4': "Observe the scanner check.",
      's3_hud5': "Challenge Complete!",
      's4_title': '4. Supercell Architect',
      's4_obj':
          'Arrange a set of numbers in a grid to create the maximum possible number of Supercells (5).',
      's4_step1_task': "DRAG each block from the tray into the 3x3 grid.",
      's4_step1_out': "All 9 blocks are placed in the grid.",
      's4_step2_task': "CLICK the 'Check Grid' button.",
      's4_step2_out':
          "The system highlights Supercells and updates the counter.",
      's4_step3_task':
          "SWAP blocks by dragging one over another to increase the count.",
      's4_step3_out': "The blocks exchange places.",
      's4_step4_task': "Achieve the maximum possible number of Supercells (5).",
      's4_step4_out': "You found the optimal pattern!",
      's4_hud1': "Place all 9 blocks into the grid.",
      's4_hud2': "Click 'Check Grid' to see your score.",
      's4_hud3': "Swap blocks to increase your score.",
      's4_hud4': "Reach a score of 5 Supercells!",
      's5_title': '5. The Kaprekar Engine',
      's5_obj':
          'Perform the Kaprekar routine on a 4-digit number to discover the Kaprekar Constant.',
      's5_step1_task':
          "DRAG a 4-digit number block into the engine's input slot.",
      's5_step1_out': "The engine receives the number and begins Round 1.",
      's5_step2_task': "Observe Stage 1: Sort & Separate.",
      's5_step2_out':
          "The digits are sorted into the largest and smallest possible numbers.",
      's5_step3_task': "Observe Stage 2: Subtract.",
      's5_step3_out':
          "The smaller number is subtracted from the larger number.",
      's5_step4_task': "Observe Stage 3: Loop.",
      's5_step4_out': "The result loops back as the new input.",
      's5_step5_task': "Wait for the engine to reach a constant.",
      's5_step5_out': "The engine reached the constant 6174!",
      's5_step6_task': "CLICK 'Reset' and try a different 4-digit number.",
      's5_step6_out': "All paths lead to Kaprekar's Constant: 6174.",
      's5_hud1': "Drag a number into the Kaprekar Engine.",
      's5_hud2': "Observe the sorting process.",
      's5_hud3': "Observe the subtraction.",
      's5_hud4': "Observe the looping process.",
      's5_hud5': "Wait for the Kaprekar Constant.",
      's5_hud6': "Click 'Reset' to try another number.",
    },
    'hi': {
      'resetbtn': 'रीसेट',
      'shutterTitle': 'संख्या प्रतिनिधित्व और अंक गुण',
      'appTitle': 'नंबर प्ले लैब',
      'appSubtitle': 'कक्षा 6 • अंक गुण',
      'enterLab': 'सिमुलेशन दर्ज करें',
      'selectScenario': 'परिदृश्य चुनें',
      'stepLabel': 'चरण',
      'learnLbl': 'अवलोकन:',
      'summaryTitle': 'लक्ष्य प्राप्त हुआ!',
      'finishLab': 'समाप्त करें',
      'nextScenario': 'अगला परिदृश्य',
      'finalDesc': 'आपने सफलतापूर्वक संख्या पैटर्न और गुणों का पता लगाया है!',
      's1_title': '1. सुपरसेल समिट',
      's1_obj':
          "ग्रिड में 'सुपरसेल' पहचानें। सुपरसेल वह संख्या है जो अपने पड़ोसियों से बड़ी होती है।",
      's1_step1_task': "'8632' वाले केंद्रीय ब्लॉक को खींचें।",
      's1_step1_out': "ब्लॉक '8632' हरा चमकता है।",
      's1_step2_task': "'4580' वाले ब्लॉक को खींचें।",
      's1_step2_out': "ब्लॉक '4580' लाल चमकता है।",
      's1_step3_task': "ग्रिड के सभी ब्लॉकों को खींचें।",
      's1_step3_out': "8632, 9870, 9230 और 5785 सुपरसेल हैं।",
      's1_step4_task': "सुपरसेल अवधारणा का निरीक्षण करें।",
      's1_step4_out': "सुपरसेल एक पहाड़ की चोटी की तरह है।",
      's1_hud1': "ब्लॉक '8632' को खींचें।",
      's1_hud2': "ब्लॉक '4580' को खींचें।",
      's1_hud3': "बाकी सभी ब्लॉकों को खींचें।",
      's1_hud4': "चुनौती पूर्ण!",
      's2_title': '2. डिजिट सम स्केल',
      's2_obj': 'संख्याओं को तोड़कर अंकों के योग को समझें।',
      's2_step1_task': "ब्लॉक '68' को मशीन में खींचें।",
      's2_step1_out': "मशीन '68' को '6' और '8' में विभाजित करती है।",
      's2_step2_task': "मशीन द्वारा अंकों को तोलते हुए देखें।",
      's2_step2_out': "स्केल 14 पर जाता है। 6 + 8 = 14.",
      's2_step3_task': "ब्लॉक '545' को मशीन में खींचें।",
      's2_step3_out': "मशीन '545' को तोलती है और योग 14 है।",
      's2_step4_task': "परिणाम देखें।",
      's2_step4_out': "अलग-अलग संख्याओं का डिजिट सम समान हो सकता है!",
      's2_hud1': "'68' को मशीन में खींचें।",
      's2_hud2': "तोलने की प्रक्रिया देखें।",
      's2_hud3': "'545' को मशीन में खींचें।",
      's2_hud4': "चुनौती पूर्ण!",
      's3_title': '3. पैलिंड्रोम फ्लिपर',
      's3_obj': 'जानें कि कैसे उलटने और जोड़ने से पैलिंड्रोम बनता है।',
      's3_step1_task': "'प्रारंभ' बटन पर क्लिक करें।",
      's3_step1_out': "रोबोटिक बांह '47' को उठाती है।",
      's3_step2_task': "रिवर्स स्टेशन देखें।",
      's3_step2_out': "ब्लॉक को उल्टा कर '74' बनाया गया।",
      's3_step3_task': "एडिशन स्टेशन देखें।",
      's3_step3_out': "'47' और '74' को जोड़कर '121' बनाया गया।",
      's3_step4_task': "पैलिंड्रोम चेक देखें।",
      's3_step4_out': "स्कैनर पुष्टि करता है कि '121' आगे-पीछे एक समान है।",
      's3_step5_task': "सारांश देखें।",
      's3_step5_out':
          "आपने एक संख्या और उसके उल्टे को जोड़कर पैलिंड्रोम बनाया।",
      's3_hud1': "प्रारंभ पर क्लिक करें।",
      's3_hud2:': "उलटने की प्रक्रिया देखें।",
      's3_hud3:': "जोड़ने की प्रक्रिया देखें।",
      's3_hud4:': "स्कैनिंग देखें।",
      's3_hud5:': "चुनौती पूर्ण!",
      's4_title': '4. सुपरसेल आर्किटेक्ट',
      's4_obj':
          'ग्रिड में संख्याओं को व्यवस्थित करके अधिकतम सुपरसेल (5) बनाएं।',
      's4_step1_task': "ट्रे से 9 ब्लॉकों को 3x3 ग्रिड में खींचें।",
      's4_step1_out': "सभी 9 ब्लॉक ग्रिड में रखे गए हैं।",
      's4_step2_task': "'चेक ग्रिड' बटन पर क्लिक करें।",
      's4_step2_out': "सिस्टम सुपरसेल को हाइलाइट करता है।",
      's4_step3_task': "ब्लॉकों को आपस में बदलें।",
      's4_step3_out': "ब्लॉक स्थान बदलते हैं।",
      's4_step4_task': "अधिकतम सुपरसेल (5) प्राप्त करें।",
      's4_step4_out': "आपने सही पैटर्न खोज लिया!",
      's4_hud1': "सभी 9 ब्लॉकों को ग्रिड में रखें।",
      's4_hud2': "'चेक ग्रिड' पर क्लिक करें।",
      's4_hud3': "अपना स्कोर बढ़ाने के लिए ब्लॉक बदलें।",
      's4_hud4': "5 का स्कोर प्राप्त करें!",
      's5_title': '5. काप्रेकर इंजन',
      's5_obj': '4-अंकीय संख्या पर काप्रेकर रूटीन करें।',
      's5_step1_task': "एक 4-अंकीय संख्या को इंजन में खींचें।",
      's5_step1_out': "इंजन राउंड 1 शुरू करता है।",
      's5_step2_task': "अंक छँटाई देखें।",
      's5_step2_out':
          "अंकों को सबसे बड़ी और सबसे छोटी संख्या में क्रमबद्ध किया गया।",
      's5_step3_task': "घटाना देखें।",
      's5_step3_out': "छोटी संख्या को बड़ी से घटाया जाता है।",
      's5_step4_task': "लूप देखें।",
      's5_step4_out': "परिणाम वापस इनपुट में जाता है।",
      's5_step5_task': "निरंतर की प्रतीक्षा करें।",
      's5_step5_out': "इंजन 6174 पर पहुँच गया!",
      's5_step6_task': "'रीसेट' पर क्लिक करें और दूसरी संख्या आज़माएं।",
      's5_step6_out': "सभी रास्ते 6174 तक जाते हैं।",
      's5_hud1': "संख्या को इंजन में खींचें।",
      's5_hud2': "छँटाई प्रक्रिया देखें।",
      's5_hud3': "घटाना देखें।",
      's5_hud4': "लूपिंग देखें।",
      's5_hud5': "काप्रेकर निरंतर की प्रतीक्षा करें।",
      's5_hud6': "रीसेट करें और दूसरी संख्या आज़माएं।",
    },
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['en']![key] ?? key;
  }
}

class StepConfig {
  final String hud;
  final String task;
  final String outcome;

  StepConfig({required this.hud, required this.task, required this.outcome});
}

class ScenarioConfig {
  final String title;
  final String objective;
  final List<StepConfig> steps;

  ScenarioConfig(this.title, this.objective, this.steps);
}

// --- MAIN WIDGET ---

class Cl6M_Ch3_A2_NumberRepresentationandDigitProperties
    extends StatefulWidget {
  const Cl6M_Ch3_A2_NumberRepresentationandDigitProperties({Key? key})
    : super(key: key);

  @override
  State<Cl6M_Ch3_A2_NumberRepresentationandDigitProperties> createState() =>
      _Cl6M_Ch3_A2_NumberRepresentationandDigitPropertiesState();
}

class _Cl6M_Ch3_A2_NumberRepresentationandDigitPropertiesState
    extends State<Cl6M_Ch3_A2_NumberRepresentationandDigitProperties>
    with SingleTickerProviderStateMixin {
  final GameState state = GameState();
  bool showCurtain = true;
  bool showSuccessPopup = false;

  late Ticker _ticker;
  Duration _lastTime = Duration.zero;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final String popSound = 'audio/class6/science/correct.mp3';
  final String tickSound = 'audio/class6/math/click.mp3';
  final String snapSound = 'audio/class6/math/click.mp3';
  final String successSound = 'audio/class6/math/success.mp3';
  final String errorSound = 'audio/class6/math/mixkit_2955.mp3';

  final GlobalKey _canvasKey = GlobalKey();
  double _baseZoom = 1.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _audioPlayer.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _playSound(String url) async {
    try {
      await _audioPlayer.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio play error: $e");
    }
  }

  void _onTick(Duration current) {
    double dt = (current - _lastTime).inMilliseconds / 1000.0;
    _lastTime = current;

    if (state.animating) {
      if (state.scenario == 2) {
        state.s2_animStage += dt * 5.0; // speed up animation slightly
        if (state.s2_animStage >= 2.0) {
          state.animating = false;
          state.s2_weighed.add(state.s2_inMachine!);
          state.s2_animStage = 0;
          state.s2_inMachine = null;
          _playSound(successSound);
          advanceStep();
          if (state.step == 4) _triggerSuccessPopup();
        }
      } else if (state.scenario == 3) {
        state.s3_animStage += dt * 1.5;
        if (state.s3_animStage >= 1.5 && state.step == 1) advanceStep();
        if (state.s3_animStage >= 3.5 && state.step == 2) {
          _playSound(snapSound);
          advanceStep();
        }
        if (state.s3_animStage >= 5.0 && state.step == 3) advanceStep();
        if (state.s3_animStage >= 6.0) {
          state.animating = false;
          _playSound(successSound);
          _triggerSuccessPopup();
        }
      }
    }
    setState(() {});
  }

  String t(String key) => AppTranslations.get(state.lang, key);

  ScenarioConfig getScenarioConfig(int id) {
    int numSteps = id == 1
        ? 4
        : id == 2
        ? 4
        : id == 3
        ? 5
        : id == 4
        ? 4
        : 6;
    List<StepConfig> steps = [];
    for (int i = 1; i <= numSteps; i++) {
      steps.add(
        StepConfig(
          hud: t('s${id}_hud$i'),
          task: t('s${id}_step${i}_task'),
          outcome: t('s${id}_step${i}_out'),
        ),
      );
    }
    return ScenarioConfig(t('s${id}_title'), t('s${id}_obj'), steps);
  }

  void advanceStep() {
    state.step++;
    setState(() {});
  }

  void _triggerSuccessPopup() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        showSuccessPopup = true;
      });
    });
  }

  void triggerAction(String actionType, dynamic param) {
    if (actionType == 's1_check') {
      state.animating = true;
      _playSound(tickSound);
      int r = param['r'];
      int c = param['c'];
      int val = state.s1_grid[r][c];

      List<Map<String, int>> nbs = [];
      if (r > 0) nbs.add({'r': r - 1, 'c': c});
      if (r < 2) nbs.add({'r': r + 1, 'c': c});
      if (c > 0) nbs.add({'r': r, 'c': c - 1});
      if (c < 2) nbs.add({'r': r, 'c': c + 1});

      bool isSuper = true;
      state.s1_beams = nbs.map((n) {
        int nVal = state.s1_grid[n['r']!][n['c']!];
        bool isGreater = val > nVal;
        if (!isGreater) isSuper = false;
        return {
          'r1': r,
          'c1': c,
          'r2': n['r'],
          'c2': n['c'],
          'color': isGreater
              ? const Color(0xFF4ADE80)
              : const Color(0xFFEF4444),
        };
      }).toList();

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        setState(() {
          state.s1_tested.add({'r': r, 'c': c, 'isSuper': isSuper});
          state.animating = false;
          state.s1_beams.clear();
          if (isSuper) {
            _playSound(successSound);
          } else {
            _playSound(errorSound);
          }

          if (state.step == 0 && val == 8632) advanceStep();
          if (state.step == 1 && val == 4580) advanceStep();
          if (state.step == 2 && state.s1_tested.length == 9) {
            advanceStep();
            _triggerSuccessPopup();
          }
        });
      });
    } else if (actionType == 's3_start') {
      if (state.animating) return;
      state.animating = true;
      _playSound(tickSound);
      advanceStep();
    } else if (actionType == 's4_check') {
      _playSound(tickSound);
      state.s4_glows.clear();
      state.s4_score = 0;
      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < 3; c++) {
          int idx = r * 3 + c;
          if (state.s4_grid[idx] != null) {
            int val = state.s4_grid[idx]!;
            bool isSuper = true;
            List<Map<String, int>> nbs = [];
            if (r > 0) nbs.add({'r': r - 1, 'c': c});
            if (r < 2) nbs.add({'r': r + 1, 'c': c});
            if (c > 0) nbs.add({'r': r, 'c': c - 1});
            if (c < 2) nbs.add({'r': r, 'c': c + 1});
            for (var nb in nbs) {
              int? nVal = state.s4_grid[nb['r']! * 3 + nb['c']!];
              if (nVal == null || nVal >= val) isSuper = false;
            }
            if (isSuper) {
              state.s4_glows.add(idx);
              state.s4_score++;
            }
          }
        }
      }
      if (state.s4_score == 5) {
        _playSound(successSound);
        advanceStep();
        _triggerSuccessPopup();
      } else {
        _playSound(snapSound);
      }
      if (state.step == 1) advanceStep();
    } else if (actionType == 's5_reset') {
      _playSound(tickSound);
      state.s5_current = null;
      state.s5_done = false;
      state.s5_animStage = 0;
      state.s5_animRound = 0;
      if (state.step == 5) {
        advanceStep();
        _triggerSuccessPopup();
      }
    }
  }

  void loadScenario(int id) {
    setState(() {
      if (id == 1) showCurtain = true;
      state.scenario = id;
      state.step = 0;
      state.resetScenario();
      showSuccessPopup = false;
      _playSound(popSound);
      state.panX = 0;
      state.panY = 0;
      state.zoom = 1.0;
    });
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (_canvasKey.currentContext == null) return;
    RenderBox box = _canvasKey.currentContext!.findRenderObject() as RenderBox;
    Offset local = box.globalToLocal(details.focalPoint);

    double worldX = (local.dx - box.size.width / 2 - state.panX) / state.zoom;
    double worldY = (local.dy - box.size.height / 2 - state.panY) / state.zoom;

    _baseZoom = state.zoom;

    if (state.scenario == 1 && !state.animating) {
      double cx = -100;
      double cy = -100;
      double sz = 100;
      double gap = 20;
      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < 3; c++) {
          double bx = cx + c * (sz + gap);
          double by = cy + r * (sz + gap);
          if (worldX >= bx - sz / 2 &&
              worldX <= bx + sz / 2 &&
              worldY >= by - sz / 2 &&
              worldY <= by + sz / 2) {
            if (state.s1_tested.any((t) => t['r'] == r && t['c'] == c)) return;
            if (state.step == 0 && state.s1_grid[r][c] != 8632) return;
            if (state.step == 1 && state.s1_grid[r][c] != 4580) return;
            triggerAction('s1_check', {'r': r, 'c': c});
            return;
          }
        }
      }
    } else if (state.scenario == 2 && !state.animating) {
      for (int i = 0; i < state.s2_blocksInTray.length; i++) {
        int b = state.s2_blocksInTray[i];
        if (!state.s2_weighed.contains(b)) {
          double bx = -270;
          double by = -130.0 + i * 80;
          if (worldX >= bx &&
              worldX <= bx + 60 &&
              worldY >= by &&
              worldY <= by + 60) {
            if (state.step == 0 && b != 68) {
              _playSound(errorSound);
              return;
            }
            if (state.step == 2 && b != 545) {
              _playSound(errorSound);
              return;
            }
            state.activeDragEntity = 's2_$b';
            state.dragX = worldX;
            state.dragY = worldY;
            _playSound(tickSound);
            return;
          }
        }
      }
    } else if (state.scenario == 3 && !state.animating && state.step == 0) {
      if (worldX >= -100 && worldX <= 20 && worldY >= 150 && worldY <= 190) {
        triggerAction('s3_start', null);
        return;
      }
    } else if (state.scenario == 4 && !state.animating) {
      if (worldX >= -120 && worldX <= 80 && worldY >= 150 && worldY <= 200) {
        triggerAction('s4_check', null);
        return;
      }
      for (int i = 0; i < state.s4_tray.length; i++) {
        int v = state.s4_tray[i];
        if (!state.s4_grid.contains(v)) {
          int col = i % 2;
          int row = i ~/ 2;
          double bx = -370.0 + col * 80;
          double by = -130.0 + row * 55;
          if (worldX >= bx &&
              worldX <= bx + 60 &&
              worldY >= by &&
              worldY <= by + 60) {
            state.activeDragEntity = 's4_$v';
            state.dragX = worldX;
            state.dragY = worldY;
            _playSound(tickSound);
            return;
          }
        }
      }
      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < 3; c++) {
          int idx = r * 3 + c;
          double bx = -100.0 + c * 90;
          double by = -120.0 + r * 90;
          if (state.s4_grid[idx] != null &&
              worldX >= bx - 40 &&
              worldX <= bx + 40 &&
              worldY >= by - 40 &&
              worldY <= by + 40) {
            state.activeDragEntity = 's4_${state.s4_grid[idx]}';
            state.s4_grid[idx] = null;
            state.dragX = worldX;
            state.dragY = worldY;
            _playSound(tickSound);
            return;
          }
        }
      }
    } else if (state.scenario == 5 && !state.animating) {
      if (state.s5_done &&
          worldX >= -60 &&
          worldX <= 60 &&
          worldY >= 250 &&
          worldY <= 290) {
        triggerAction('s5_reset', null);
        return;
      }
      if (state.s5_current == null) {
        for (int i = 0; i < state.s5_tray.length; i++) {
          int v = state.s5_tray[i];
          double bx = -370;
          double by = -70.0 + i * 80;
          if (worldX >= bx &&
              worldX <= bx + 60 &&
              worldY >= by &&
              worldY <= by + 60) {
            state.activeDragEntity = 's5_$v';
            state.dragX = worldX;
            state.dragY = worldY;
            _playSound(tickSound);
            return;
          }
        }
      }
    }
  }

  // Required for compilation mapping but logic moved below
  void _onScaleUpdateReal(ScaleUpdateDetails details) {
    if (_canvasKey.currentContext == null) return;
    RenderBox box = _canvasKey.currentContext!.findRenderObject() as RenderBox;
    Offset local = box.globalToLocal(details.focalPoint);

    double worldX = (local.dx - box.size.width / 2 - state.panX) / state.zoom;
    double worldY = (local.dy - box.size.height / 2 - state.panY) / state.zoom;

    if (state.activeDragEntity != null) {
      setState(() {
        state.dragX = worldX;
        state.dragY = worldY;
      });
      return;
    }

    setState(() {
      state.zoom = (_baseZoom * details.scale).clamp(0.3, 3.0);
      state.panX += details.focalPointDelta.dx;
      state.panY += details.focalPointDelta.dy;
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (state.activeDragEntity != null) {
      double worldX = state.dragX;
      double worldY = state.dragY;

      if (state.activeDragEntity!.startsWith('s2_')) {
        int val = int.parse(state.activeDragEntity!.split('_')[1]);
        if (worldX >= -150 && worldX <= 150 && worldY >= -250 && worldY <= 0) {
          state.s2_inMachine = val;
          state.animating = true;
          _playSound(snapSound);
          if (state.step == 0 || state.step == 2) advanceStep();
        } else {
          _playSound(errorSound);
        }
      } else if (state.activeDragEntity!.startsWith('s4_')) {
        int val = int.parse(state.activeDragEntity!.split('_')[1]);
        bool placed = false;
        for (int r = 0; r < 3; r++) {
          for (int c = 0; c < 3; c++) {
            int idx = r * 3 + c;
            double bx = -100.0 + c * 90;
            double by = -120.0 + r * 90;
            if (worldX >= bx - 40 &&
                worldX <= bx + 40 &&
                worldY >= by - 40 &&
                worldY <= by + 40) {
              if (state.s4_grid[idx] != null) {
                // Return existing to tray conceptually handled as we replace
              }
              state.s4_grid[idx] = val;
              placed = true;
              _playSound(snapSound);
            }
          }
        }
        if (!placed && !state.s4_grid.contains(val)) _playSound(errorSound);
        if (state.step == 0 && !state.s4_grid.contains(null)) advanceStep();
      } else if (state.activeDragEntity!.startsWith('s5_')) {
        int val = int.parse(state.activeDragEntity!.split('_')[1]);
        if (worldX >= -80 && worldX <= 80 && worldY >= -120 && worldY <= -80) {
          state.s5_current = val;
          state.animating = true;
          _playSound(snapSound);
          state.s5_animRound = 1;
          if (state.step == 0) advanceStep();
          _runKaprekarLoop();
        } else {
          _playSound(errorSound);
        }
      }

      setState(() {
        state.activeDragEntity = null;
      });
    }
  }

  void _runKaprekarLoop() async {
    if (state.s5_current == 6174 || state.s5_animRound > 8) {
      if (mounted) {
        setState(() {
          state.s5_done = true;
          state.animating = false;
          _playSound(successSound);
          if (state.step == 4) advanceStep();
        });
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      state.s5_animStage = 1;
    });
    _playSound(tickSound);

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    if (state.step == 1) advanceStep();

    setState(() {
      state.s5_animStage = 2;
    });
    _playSound(tickSound);

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    if (state.step == 2) advanceStep();

    List<int> digits = state.s5_current
        .toString()
        .padLeft(4, '0')
        .split('')
        .map(int.parse)
        .toList();
    List<int> ascL = List.from(digits)..sort();
    List<int> descL = List.from(digits)..sort((a, b) => b.compareTo(a));
    int asc = int.parse(ascL.join(''));
    int desc = int.parse(descL.join(''));

    setState(() {
      state.s5_current = desc - asc;
      state.s5_animRound++;
      state.s5_animStage = 0;
    });
    _playSound(popSound);
    if (state.step == 3) advanceStep();

    await Future.delayed(const Duration(milliseconds: 1000));
    _runKaprekarLoop();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = math.max(300, screenWidth * 0.3);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Canvas Area
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: state.sidebarOpen ? sidebarWidth : 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: ClipRect(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) {
                    _onScaleStart(
                      ScaleStartDetails(
                        focalPoint: details.globalPosition,
                        localFocalPoint: details.localPosition,
                        pointerCount: 1,
                      ),
                    );
                  },
                  onScaleStart: _onScaleStart,
                  onScaleUpdate: _onScaleUpdateReal,
                  onScaleEnd: _onScaleEnd,
                  child: CustomPaint(
                    key: _canvasKey,
                    painter: NumberLabPainter(state),
                    child: Container(),
                  ),
                ),
              ),
            ),

            // Sidebar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: state.sidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: Container(
                color: const Color(0xFF1E293B),
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header inside sidebar
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 66, 16, 12),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.white12),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF6366F1,
                                        ).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.grid_view_rounded,
                                        color: Color(0xFF818CF8),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        t('appTitle'),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 20,
                                          color: Colors.yellowAccent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.only(left: 44),
                                  child: Text(
                                    t('appSubtitle'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        icon: const Icon(
                                          Icons.language,
                                          size: 16,
                                        ),
                                        label: Text(
                                          state.lang == 'en' ? 'EN' : 'HI',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white10,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            state.lang = state.lang == 'en'
                                                ? 'hi'
                                                : 'en';
                                          });
                                          _playSound(popSound);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent
                                            .withOpacity(0.15),
                                        foregroundColor: Colors.redAccent,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          loadScenario(state.scenario);
                                          showCurtain = true;
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          const Icon(Icons.refresh, size: 18),
                                          const SizedBox(width: 4),
                                          Text(
                                            t('resetbtn'),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Body
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t('selectScenario').toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F172A),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        value: state.scenario,
                                        isExpanded: true,
                                        dropdownColor: const Color(0xFF1E293B),
                                        items: [1, 2, 3, 4, 5]
                                            .map(
                                              (id) => DropdownMenuItem(
                                                value: id,
                                                child: Text(
                                                  t('s${id}_title'),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (val) {
                                          if (val != null) loadScenario(val);
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF0F172A,
                                      ).withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.track_changes,
                                              color: Colors.pinkAccent,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              t('learnLbl'),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.yellowAccent,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          getScenarioConfig(
                                            state.scenario,
                                          ).objective,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  ..._buildSteps(
                                    getScenarioConfig(state.scenario).steps,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Footer
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            color: const Color(0xFF020617),
                            child: const Text(
                              '© ZeroScienceLab | Fall in Love with Math and Science',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Floating Menu Icon
            Positioned(
              left: 16,
              top: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 8),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: IconButton(
                    key: ValueKey(state.sidebarOpen),
                    icon: Icon(
                      state.sidebarOpen ? Icons.menu_open : Icons.menu,
                      size: 28,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        state.sidebarOpen = !state.sidebarOpen;
                      });
                      _playSound(popSound);
                    },
                  ),
                ),
              ),
            ),

            // HUD
            if (getScenarioConfig(state.scenario).steps.isNotEmpty &&
                state.step < getScenarioConfig(state.scenario).steps.length)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: state.sidebarOpen ? sidebarWidth : 0,
                right: 0,
                bottom: 40,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xEE0F172A),
                        borderRadius: BorderRadius.circular(16),
                        border: const Border(
                          top: BorderSide(color: Color(0xFF6366F1), width: 4),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFF818CF8),
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            child: Text(
                              getScenarioConfig(
                                state.scenario,
                              ).steps[state.step].hud,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Curtain Screen
            if (showCurtain)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF6366F1),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x996366F1),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.grid_view,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          t('shutterTitle'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          t('appSubtitle'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              showCurtain = false;
                            });
                            _playSound(popSound);
                          },
                          icon: const Icon(Icons.play_circle_fill, size: 28),
                          label: Text(
                            t('enterLab'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Success Popup
            if (showSuccessPopup)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: Container(
                      width: 400,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x6610B981),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.flag,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            t('summaryTitle'),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            t('finalDesc'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                showSuccessPopup = false;
                                if (state.scenario < 5) {
                                  loadScenario(state.scenario + 1);
                                } else {
                                  loadScenario(1);
                                }
                              });
                            },
                            icon: Icon(
                              state.scenario < 5
                                  ? Icons.arrow_forward
                                  : Icons.check,
                            ),
                            label: Text(
                              state.scenario < 5
                                  ? t('nextScenario')
                                  : t('finishLab'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: state.scenario < 5
                                  ? const Color(0xFF6366F1)
                                  : const Color(0xFFF59E0B),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
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

  List<Widget> _buildSteps(List<StepConfig> steps) {
    List<Widget> widgets = [];
    for (int i = 0; i < steps.length; i++) {
      bool isPast = i < state.step;
      bool isCurrent = i == state.step;

      Color bgColor = isCurrent
          ? const Color(0x1A6366F1)
          : (isPast ? const Color(0xFF0F172A) : const Color(0x400F172A));
      Color borderColor = isCurrent
          ? const Color(0xFF6366F1)
          : (isPast ? const Color(0xFF10B981) : Colors.white12);

      widgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
            boxShadow: isCurrent
                ? const [BoxShadow(color: Color(0x226366F1), blurRadius: 10)]
                : [],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isPast
                      ? const Color(0xFF10B981)
                      : (isCurrent
                            ? const Color(0xFF6366F1)
                            : const Color(0xFF334155)),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isPast
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Text(
                          '${i + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${t('stepLabel')} ${i + 1}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      steps[i].task,
                      style: TextStyle(
                        fontSize: 13,
                        color: isCurrent ? Colors.white : Colors.white70,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    if (isPast) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0x3310B981),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0x6610B981)),
                        ),
                        child: Text(
                          steps[i].outcome,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6EE7B7),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }
}

// --- PAINTER ---

class NumberLabPainter extends CustomPainter {
  final GameState state;

  NumberLabPainter(this.state);

  final Color outlineColor = const Color(0xFF0F172A);

  void drawRoundedRect(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double r,
    Color fill,
    Color stroke,
    double lineW,
  ) {
    final RRect rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      Radius.circular(r),
    );
    if (fill != Colors.transparent) {
      canvas.drawRRect(
        rect,
        Paint()
          ..color = fill
          ..style = PaintingStyle.fill,
      );
    }
    if (lineW > 0) {
      canvas.drawRRect(
        rect,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = lineW,
      );
    }
  }

  void drawTextWithOutline(
    Canvas canvas,
    String text,
    double x,
    double y,
    double fontSize,
    Color fillStyle, [
    FontWeight weight = FontWeight.bold,
  ]) {
    TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: weight,
          color: fillStyle,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  void drawStoneBlock(
    Canvas canvas,
    double x,
    double y,
    double size,
    String numText, [
    String stateColor = 'normal',
  ]) {
    Color bg;
    if (stateColor == 'green') {
      bg = const Color(0xFF4ADE80);
    } else if (stateColor == 'red') {
      bg = const Color(0xFFF87171);
    } else if (stateColor == 'yellow') {
      bg = const Color(0xFFFEF08A);
    } else {
      bg = const Color(0xFF94A3B8);
    }

    drawRoundedRect(
      canvas,
      x - size / 2,
      y - size / 2,
      size,
      size,
      8,
      bg,
      outlineColor,
      4,
    );
    drawRoundedRect(
      canvas,
      x - size / 2 + 5,
      y - size / 2 + 5,
      size - 10,
      size - 10,
      4,
      Colors.white.withOpacity(0.2),
      Colors.transparent,
      0,
    );
    drawTextWithOutline(canvas, numText, x, y, size * 0.35, outlineColor);
  }

  void drawLine(
    Canvas canvas,
    double x1,
    double y1,
    double x2,
    double y2,
    Color color,
    double width,
  ) {
    canvas.drawLine(
      Offset(x1, y1),
      Offset(x2, y2),
      Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
  }

  void drawGlowLine(
    Canvas canvas,
    double x1,
    double y1,
    double x2,
    double y2,
    Color color,
    double width,
  ) {
    Paint glow = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    Paint solid = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), glow);
    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), solid);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF0F172A),
    );

    canvas.save();
    canvas.translate(size.width / 2 + state.panX, size.height / 2 + state.panY);
    canvas.scale(state.zoom, state.zoom);

    if (state.scenario == 1) {
      renderScenario1(canvas);
    } else if (state.scenario == 2) {
      renderScenario2(canvas);
    } else if (state.scenario == 3) {
      renderScenario3(canvas);
    } else if (state.scenario == 4) {
      renderScenario4(canvas);
    } else if (state.scenario == 5) {
      renderScenario5(canvas);
    }

    canvas.restore();
  }

  void renderScenario1(Canvas canvas) {
    double s = 100;
    double gap = 20;
    double startX = -(s * 3 + gap * 2) / 2 + s / 2;
    double startY = -100;

    for (var b in state.s1_beams) {
      double x1 = startX + b['c1'] * (s + gap);
      double y1 = startY + b['r1'] * (s + gap);
      double x2 = startX + b['c2'] * (s + gap);
      double y2 = startY + b['r2'] * (s + gap);
      drawGlowLine(canvas, x1, y1, x2, y2, b['color'] as Color, 8);
    }

    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        double bx = startX + c * (s + gap);
        double by = startY + r * (s + gap);
        int val = state.s1_grid[r][c];
        String sColor = 'normal';

        var tested = state.s1_tested
            .where((t) => t['r'] == r && t['c'] == c)
            .toList();
        if (tested.isNotEmpty) {
          sColor = tested.first['isSuper'] ? 'green' : 'normal';
        }

        if (state.animating && state.s1_tested.isNotEmpty) {
          var activeTest = state.s1_tested.last;
          if (activeTest['r'] == r && activeTest['c'] == c) {
            sColor = activeTest['isSuper'] ? 'green' : 'red';
          }
          if ((activeTest['r'] == r - 1 && activeTest['c'] == c) ||
              (activeTest['r'] == r + 1 && activeTest['c'] == c) ||
              (activeTest['r'] == r && activeTest['c'] == c - 1) ||
              (activeTest['r'] == r && activeTest['c'] == c + 1)) {
            sColor = 'red';
          }
        }
        drawStoneBlock(canvas, bx, by, s, val.toString(), sColor);
      }
    }

    if (state.step == 3) {
      drawRoundedRect(
        canvas,
        -150,
        160,
        300,
        60,
        10,
        const Color(0xFF1E293B),
        outlineColor,
        3,
      );
      drawTextWithOutline(
        canvas,
        "Supercells Found: 4",
        0,
        190,
        18,
        const Color(0xFF4ADE80),
      );
    }
  }

  void renderScenario2(Canvas canvas) {
    double mX = 0;
    double mY = -150;

    // The Machine (Digit Splitter)
    drawRoundedRect(
      canvas,
      mX - 100,
      mY,
      200,
      120,
      10,
      Colors.white.withOpacity(0.1),
      outlineColor,
      4,
    );
    // Funnel at the top
    drawLine(canvas, mX - 60, mY - 60, mX - 60, mY, outlineColor, 4);
    drawLine(canvas, mX + 60, mY - 60, mX + 60, mY, outlineColor, 4);
    drawTextWithOutline(canvas, "DIGIT SUM", mX, mY + 20, 14, Colors.white);

    // The Scale
    double scX = 0;
    double scY = 160;

    // Scale Stand & Base
    drawLine(
      canvas,
      scX,
      scY - 80,
      scX,
      scY,
      outlineColor,
      6,
    ); // Vertical stand
    drawLine(canvas, scX - 60, scY, scX + 60, scY, outlineColor, 6); // Base

    // Scale Platform
    drawRoundedRect(
      canvas,
      scX - 80,
      scY - 90,
      160,
      20,
      6,
      const Color(0xFFCBD5E1),
      outlineColor,
      4,
    );

    // Scale Dial (Top-half arc)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(scX, scY), radius: 60),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // Dial Numbers
    for (int i = 0; i <= 20; i += 2) {
      double ang = math.pi + (i / 20) * math.pi;
      double tx = scX + math.cos(ang) * 75;
      double ty = scY + math.sin(ang) * 75;
      drawTextWithOutline(canvas, i.toString(), tx, ty, 12, Colors.white);
    }

    // Calculate sum for Needle
    double targetSum = 0;
    if (state.animating && state.s2_inMachine != null) {
      targetSum = state.s2_inMachine!
          .toString()
          .split('')
          .fold(0, (a, b) => a + int.parse(b))
          .toDouble();
    } else if (state.s2_weighed.isNotEmpty) {
      targetSum = state.s2_weighed.last
          .toString()
          .split('')
          .fold(0, (a, b) => a + int.parse(b))
          .toDouble();
    }

    double currentAngle = math.pi + (targetSum / 20) * math.pi;
    if (state.animating && state.s2_animStage > 1) {
      double prog = math.min(1.0, state.s2_animStage - 1);
      currentAngle = math.pi + (targetSum * prog / 20) * math.pi;
    }

    // Draw Needle
    drawLine(
      canvas,
      scX,
      scY,
      scX + math.cos(currentAngle) * 55,
      scY + math.sin(currentAngle) * 55,
      const Color(0xFFEF4444),
      4,
    );
    canvas.drawCircle(Offset(scX, scY), 6, Paint()..color = Colors.white);

    // Draw digits on the platform if weighed
    if (state.s2_weighed.isNotEmpty && !state.animating) {
      String numStr = state.s2_weighed.last.toString();
      double totalWidth = numStr.length * 40.0;
      double startX = scX - (totalWidth / 2) + 20;
      for (int i = 0; i < numStr.length; i++) {
        drawStoneBlock(
          canvas,
          startX + i * 40,
          scY - 110,
          30,
          numStr[i],
          'yellow',
        );
      }
    } else if (state.animating &&
        state.s2_animStage > 0 &&
        state.s2_inMachine != null) {
      String numStr = state.s2_inMachine.toString();
      // Drop digits from machine to platform
      double splitY = mY + 60 + state.s2_animStage * 110;
      double totalWidth = numStr.length * 40.0;
      double startX = mX - (totalWidth / 2) + 20;
      for (int i = 0; i < numStr.length; i++) {
        drawStoneBlock(
          canvas,
          startX + i * 40,
          splitY,
          30,
          numStr[i],
          'yellow',
        );
      }
    }

    // Number Tray (Left side)
    drawRoundedRect(
      canvas,
      -290,
      -160,
      100,
      250,
      10,
      const Color(0xFF334155),
      outlineColor,
      4,
    );
    for (int i = 0; i < state.s2_blocksInTray.length; i++) {
      int b = state.s2_blocksInTray[i];
      if (!state.s2_weighed.contains(b) &&
          (b != state.s2_inMachine ||
              (state.s2_inMachine != null && !state.animating))) {
        drawStoneBlock(canvas, -240, -100.0 + i * 80, 60, b.toString());
      }
    }

    if (state.activeDragEntity != null &&
        state.activeDragEntity!.startsWith('s2_')) {
      drawStoneBlock(
        canvas,
        state.dragX,
        state.dragY,
        60,
        state.activeDragEntity!.split('_')[1],
      );
    }
  }

  void renderScenario3(Canvas canvas) {
    drawRoundedRect(
      canvas,
      -250,
      50,
      500,
      30,
      15,
      const Color(0xFF475569),
      outlineColor,
      4,
    );
    for (double i = -230; i < 250; i += 40) {
      canvas.drawCircle(
        Offset(i, 65),
        8,
        Paint()
          ..color = const Color(0xFF94A3B8)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        Offset(i, 65),
        8,
        Paint()
          ..color = outlineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    drawRoundedRect(
      canvas,
      -100,
      150,
      120,
      40,
      8,
      state.step == 0 ? const Color(0xFF4ADE80) : const Color(0xFFCBD5E1),
      outlineColor,
      3,
    );
    drawTextWithOutline(canvas, "START", -40, 170, 16, outlineColor);

    drawTextWithOutline(canvas, "Reverse", -150, 110, 16, Colors.white);
    drawTextWithOutline(canvas, "Add", 0, 110, 16, Colors.white);
    drawTextWithOutline(canvas, "Scan", 150, 110, 16, Colors.white);

    if (state.s3_animStage == 0) {
      drawStoneBlock(canvas, -200, 20, 50, '47', 'normal');
    } else if (state.s3_animStage > 0 && state.s3_animStage <= 1) {
      double prog = state.s3_animStage;
      drawStoneBlock(canvas, -150, 20, 50, '47', 'normal');
      canvas.save();
      canvas.translate(-150, -40);
      canvas.scale(1, 1 - prog * 2);
      drawStoneBlock(canvas, 0, 0, 50, prog > 0.5 ? '74' : '47', 'yellow');
      canvas.restore();
    } else if (state.s3_animStage > 1 && state.s3_animStage <= 2) {
      double prog = state.s3_animStage - 1;
      drawStoneBlock(canvas, -150 + prog * 150, 20, 50, '47', 'normal');
      drawStoneBlock(canvas, -150 + prog * 150, -40, 50, '74', 'yellow');
    } else if (state.s3_animStage > 2 && state.s3_animStage <= 3) {
      drawStoneBlock(
        canvas,
        0,
        -10,
        60 + (state.s3_animStage - 2) * 10,
        '121',
        'green',
      );
    } else if (state.s3_animStage > 3 && state.s3_animStage <= 4) {
      double prog = state.s3_animStage - 3;
      drawStoneBlock(canvas, 0 + prog * 150, -10, 70, '121', 'green');
    } else if (state.s3_animStage > 4) {
      drawStoneBlock(canvas, 150, -10, 70, '121', 'green');
      double scanX =
          110 + (math.sin(state.s3_animStage * math.pi * 2) + 1) * 40;
      drawLine(canvas, scanX, -50, scanX, 30, const Color(0xFF4ADE80), 4);
      if (state.s3_animStage > 5.5) {
        Path checkPath = Path()
          ..moveTo(130, -50)
          ..lineTo(145, -35)
          ..lineTo(170, -70);
        canvas.drawPath(
          checkPath,
          Paint()
            ..color = const Color(0xFF4ADE80)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6,
        );
      }
    }
  }

  void renderScenario4(Canvas canvas) {
    double s = 80;
    double gap = 10;
    double startX = -100;
    double startY = -120;

    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        double bx = startX + c * (s + gap);
        double by = startY + r * (s + gap);
        drawRoundedRect(
          canvas,
          bx - s / 2,
          by - s / 2,
          s,
          s,
          6,
          const Color(0xFF334155),
          outlineColor,
          3,
        );
        int idx = r * 3 + c;
        if (state.s4_grid[idx] != null) {
          bool isGlow = state.s4_glows.contains(idx);
          drawStoneBlock(
            canvas,
            bx,
            by,
            s,
            state.s4_grid[idx].toString(),
            isGlow ? 'green' : 'normal',
          );
        }
      }
    }

    drawRoundedRect(
      canvas,
      -380,
      -150,
      160,
      300,
      10,
      const Color(0xFF1E293B),
      outlineColor,
      4,
    );
    for (int i = 0; i < state.s4_tray.length; i++) {
      int v = state.s4_tray[i];
      if (!state.s4_grid.contains(v) && (state.activeDragEntity != 's4_$v')) {
        int col = i % 2;
        int row = i ~/ 2;
        drawStoneBlock(
          canvas,
          -340.0 + col * 80,
          -100.0 + row * 55,
          60,
          v.toString(),
        );
      }
    }

    drawRoundedRect(
      canvas,
      200,
      -50,
      160,
      100,
      10,
      const Color(0xFF1E293B),
      outlineColor,
      4,
    );
    drawTextWithOutline(canvas, "SUPERCELLS", 280, -20, 16, Colors.white);
    drawTextWithOutline(
      canvas,
      state.s4_score.toString(),
      280,
      20,
      40,
      state.s4_score == 5 ? const Color(0xFFFACC15) : const Color(0xFF4ADE80),
    );

    drawRoundedRect(
      canvas,
      startX - 20,
      150,
      200,
      50,
      10,
      const Color(0xFF3B82F6),
      outlineColor,
      4,
    );
    drawTextWithOutline(
      canvas,
      "Check Grid",
      startX + 80,
      175,
      18,
      Colors.white,
    );

    if (state.activeDragEntity != null &&
        state.activeDragEntity!.startsWith('s4_')) {
      drawStoneBlock(
        canvas,
        state.dragX,
        state.dragY,
        60,
        state.activeDragEntity!.split('_')[1],
      );
    }
  }

  void renderScenario5(Canvas canvas) {
    drawRoundedRect(
      canvas,
      -150,
      -100,
      300,
      250,
      20,
      const Color(0xFF1E293B),
      outlineColor,
      5,
    );
    drawRoundedRect(
      canvas,
      -80,
      -120,
      160,
      40,
      5,
      const Color(0xFF475569),
      outlineColor,
      4,
    );
    drawTextWithOutline(
      canvas,
      "KAPREKAR ENGINE",
      0,
      -80,
      18,
      const Color(0xFFFACC15),
    );
    drawTextWithOutline(
      canvas,
      "ROUND: ${state.s5_animRound}",
      0,
      -50,
      14,
      Colors.white,
    );

    if (state.s5_current != null) {
      if (state.s5_animStage == 0) {
        drawStoneBlock(canvas, 0, 0, 70, state.s5_current.toString(), 'normal');
      } else if (state.s5_animStage == 1) {
        List<int> digits = state.s5_current
            .toString()
            .padLeft(4, '0')
            .split('')
            .map(int.parse)
            .toList();
        List<int> asc = List.from(digits)..sort();
        List<int> desc = List.from(digits)..sort((a, b) => b.compareTo(a));
        drawStoneBlock(canvas, -70, 20, 60, desc.join(''), 'yellow');
        drawStoneBlock(canvas, 70, 20, 60, asc.join(''), 'normal');
        drawTextWithOutline(canvas, "-", 0, 20, 30, Colors.white);
      } else if (state.s5_animStage == 2) {
        List<int> digits = state.s5_current
            .toString()
            .padLeft(4, '0')
            .split('')
            .map(int.parse)
            .toList();
        List<int> asc = List.from(digits)..sort();
        List<int> desc = List.from(digits)..sort((a, b) => b.compareTo(a));
        int diff = int.parse(desc.join('')) - int.parse(asc.join(''));
        drawStoneBlock(
          canvas,
          0,
          80,
          80,
          diff.toString().padLeft(4, '0'),
          'green',
        );
      }
    }

    if (state.s5_done) {
      drawRoundedRect(
        canvas,
        -180,
        170,
        360,
        60,
        10,
        const Color(0xFFFEF08A),
        outlineColor,
        4,
      );
      drawTextWithOutline(
        canvas,
        "CONSTANT REACHED: 6174",
        0,
        200,
        22,
        const Color(0xFFDC2626),
      );

      drawRoundedRect(
        canvas,
        -60,
        250,
        120,
        40,
        8,
        const Color(0xFFEF4444),
        outlineColor,
        3,
      );
      drawTextWithOutline(canvas, "RESET", 0, 270, 16, Colors.white);
    }

    drawRoundedRect(
      canvas,
      -400,
      -100,
      120,
      250,
      10,
      const Color(0xFF334155),
      outlineColor,
      4,
    );
    for (int i = 0; i < state.s5_tray.length; i++) {
      int v = state.s5_tray[i];
      if (state.s5_current != v || state.s5_done) {
        drawStoneBlock(canvas, -340, -40.0 + i * 80, 60, v.toString());
      }
    }

    if (state.activeDragEntity != null &&
        state.activeDragEntity!.startsWith('s5_')) {
      drawStoneBlock(
        canvas,
        state.dragX,
        state.dragY,
        60,
        state.activeDragEntity!.split('_')[1],
      );
    }
  }

  @override
  bool shouldRepaint(covariant NumberLabPainter oldDelegate) => true;
}
