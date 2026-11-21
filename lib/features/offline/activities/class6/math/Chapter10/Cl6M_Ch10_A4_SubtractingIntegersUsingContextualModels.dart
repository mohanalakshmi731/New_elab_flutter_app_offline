// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Subtracting Integers',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        fontFamily: 'sans-serif',
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: const Cl6M_Ch10_A4_SubtractingIntegersUsingContextualModels(),
    ),
  );
}

// --- AUDIO MANAGER ---
class AudioManager {
  static final AudioPlayer _clickPlayer = AudioPlayer();
  static final AudioPlayer _pagePlayer = AudioPlayer();
  static final AudioPlayer _dropdownPlayer = AudioPlayer();

  static Future<void> playClick() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/click.mp3'));
  }

  static Future<void> playPageOpen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/science/page_open.mp3'));
  }

  static Future<void> playDropdown() async {
    await _dropdownPlayer.stop();
    await _dropdownPlayer.play(
      AssetSource('audio/class6/science/dropdown.mp3'),
    );
  }

  static Future<void> playError() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/error.mp3'));
  }

  static Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/math/shutter.mp3'));
  }
}

// --- I18N TRANSLATIONS ---
final Map<String, Map<String, String>> tMap = {
  'en': {
    'shutterTitle': "Subtracting Integers: The Lift and The Tokens",
    'appTitle': "Subtracting Integers",
    'appSubtitle': "Class 6 • THE OTHER SIDE OF ZERO",
    'enterLab': "Enter Simulation",
    'selectScenario': "Select Scenario",
    'stepLabel': "STEP",
    'doneBtn': "Done",
    'learnLbl': "Objective:",
    'closeBtn': "Close",
    'summaryTitle': "Goal Reached!",
    'resetBtn': "Reset Lab",
    'finishLab': "Finish Lab",
    'nextScenario': "Next Scenario",
    'lbl_target': "Target Floor",
    'lbl_start': "Starting Floor",
    'lbl_movement': "Movement",
    'lbl_check_ans': "Check Answer",
    'lbl_try_again': "Try Again",
    'summary_title': "✔ Learning Summary:",

    // Scenario details
    's1_title': "1. The Downward Journey",
    's1_obj':
        "To solve (+4) - (+1) by finding the movement needed to travel between floors in a building.",
    's1_step1_task':
        "The equation is (+4) - (+1) = ?. Formula: Target Floor - Starting Floor = Movement. CLICK on the lift at the Starting Floor (+1).",
    's1_step1_out':
        "The lift is activated and ready to find the movement difference.",
    's1_step2_task':
        "DRAG the lift from its current position at Floor +1 up to the Target Floor +4.",
    's1_step2_out':
        "The lift moved UP. The movement meter tracked a positive change of +3.",
    's1_step3_task': "Observe the final result.",
    's1_step3_out':
        "To find (+4) - (+1), we moved UP 3 floors. The movement is +3.",
    's1_hud1': "Click the glowing lift at Floor +1.",
    's1_hud2': "Drag the lift to the Target Floor +4.",
    's1_hud3': "Observe the completed equation.",

    's2_title': "2. Crossing the Ground Floor",
    's2_obj':
        "To solve (+2) - (-3) by finding the movement needed to travel from a basement floor to an upper floor.",
    's2_step1_task':
        "The equation is (+2) - (-3) = ?. CLICK on the lift at the Starting Floor (-3).",
    's2_step1_out': "The lift is active at Floor -3.",
    's2_step2_task': "DRAG the lift from Floor -3 up to the Target Floor +2.",
    's2_step2_out':
        "The lift crossed the ground floor. Total movement was UP 5 floors.",
    's2_step3_task': "Observe the final result.",
    's2_step3_out':
        "To go from -3 to +2, you must move UP 5. Therefore, (+2) - (-3) = +5. Subtracting a negative is like moving up!",
    's2_hud1': "Click the glowing lift at Floor -3.",
    's2_hud2': "Drag the lift to the Target Floor +2.",
    's2_hud3': "Observe the completed equation.",

    's3_title': "3. The Token Take-Away",
    's3_obj':
        "To solve (+3) - (+5) using the 'take away' token model, requiring the use of zero pairs.",
    's3_step1_task':
        "Start with +3 tokens. Identify you cannot take away +5. CLICK the glowing Zero Pair Dispenser.",
    's3_step1_out':
        "The dispenser is activated and ready to provide zero pairs.",
    's3_step2_task':
        "DRAG two 'Zero Pairs' from the dispenser into the workspace.",
    's3_step2_out':
        "Adding zero pairs doesn't change the total value (+3), but it provides enough positive tokens to subtract.",
    's3_step3_task':
        "Now that you have 5 positive tokens, DRAG all 5 positive tokens to the 'Take Away Bin'.",
    's3_step3_out': "You have successfully taken away (+5).",
    's3_step4_task': "Observe your final answer in the workspace.",
    's3_step4_out':
        "After taking away 5 positive tokens, you are left with 2 negative tokens. (+3) - (+5) = -2.",
    's3_hud1': "Click the glowing Dispenser.",
    's3_hud2': "Drag 2 Zero Pairs from the Dispenser into the workspace.",
    's3_hud3': "Drag the 5 Red (+) tokens into the Take Away Bin.",
    's3_hud4': "Observe the final answer.",
    's3_summary':
        "To subtract +5 from +3, we added two 'zero pairs' (+2 and -2) to have enough positive tokens to take away. We were left with -2.",

    's4_title': "4. Basement to Basement",
    's4_obj':
        "Solve the expression (-4) - (-1) using the lift model to find the required movement.",
    's4_step1_task':
        "Solve (-4) - (-1) = ?. DRAG the lift from the Starting Floor (-1) to the Target Floor (-4).",
    's4_step1_out': "You found the movement by dragging the lift.",
    's4_step2_task': "CLICK the 'Check Answer' button on the screen.",
    's4_step2_out':
        "Moving from -1 to -4 requires going DOWN 3 floors. The answer is -3.",
    's4_hud1': "Drag the lift from Floor -1 to Floor -4.",
    's4_hud2': "Click the Check Answer button.",
    's4_bubble_drag':
        "DRAG the lift from the Starting Floor to the Target Floor to find the required movement.",
    's4_bubble_done':
        "Correct result -3 moves to the answer box. Subtraction is complete!",

    's5_title': "5. Subtracting a Negative",
    's5_obj':
        "Solve (-2) - (-5) using the token model by taking away negative tokens.",
    's5_step1_task':
        "Solve (-2) - (-5). You have 2 negative tokens but need to take away 5. DRAG 3 'Zero Pairs' to the workspace.",
    's5_step1_out':
        "You added 3 zero pairs. You now have enough negative tokens.",
    's5_step2_task': "DRAG 5 negative (green) tokens to the Take Away Bin.",
    's5_step2_out': "You have subtracted (-5).",
    's5_step3_task': "CLICK the 'Check Answer' button to finish.",
    's5_step3_out':
        "3 positive tokens remain. (-2) - (-5) = +3. Subtracting a negative gives a positive result!",
    's5_hud1': "Drag 3 Zero Pairs into the workspace.",
    's5_hud2': "Drag the 5 Green (-) tokens into the Take Away Bin.",
    's5_hud3': "Click Check Answer to finalize.",
    's5_summary':
        "To subtract -5 from -2, we added three 'zero pairs' (+3 and -3) to have enough negative tokens to take away. We were left with +3.",
  },
  'hi': {
    'shutterTitle': "पूर्णांकों का घटाव: लिफ्ट और टोकन",
    'appTitle': "पूर्णांकों का घटाव",
    'appSubtitle': "कक्षा 6 • शून्य की दूसरी ओर",
    'enterLab': "सिमुलेशन दर्ज करें",
    'selectScenario': "परिदृश्य चुनें",
    'stepLabel': "चरण",
    'doneBtn': "पूर्ण",
    'learnLbl': "उद्देश्य:",
    'closeBtn': "बंद करें",
    'summaryTitle': "लक्ष्य प्राप्त हुआ!",
    'resetBtn': "रीसेट करें",
    'finishLab': "समाप्त करें",
    'nextScenario': "अगला परिदृश्य",
    'lbl_target': "लक्ष्य मंजिल",
    'lbl_start': "प्रारंभिक मंजिल",
    'lbl_movement': "गति",
    'lbl_check_ans': "उत्तर जाँचें",
    'lbl_try_again': "पुनः प्रयास करें",
    'summary_title': "✔ सीखने का सारांश:",

    's1_title': "1. नीचे की ओर यात्रा",
    's1_obj': "दो मंजिलों के बीच आवश्यक गति ज्ञात करके (+4) - (+1) को हल करना।",
    's1_step1_task':
        "समीकरण (+4) - (+1) = ? है। सूत्र: लक्ष्य मंजिल - प्रारंभिक मंजिल = गति। प्रारंभिक मंजिल (+1) पर लिफ्ट पर क्लिक करें।",
    's1_step1_out': "लिफ्ट सक्रिय हो गई है।",
    's1_step2_task': "लिफ्ट को मंजिल +1 से लक्ष्य मंजिल +4 तक खींचें।",
    's1_step2_out':
        "लिफ्ट ऊपर गई। गति मीटर ने +3 का सकारात्मक परिवर्तन दिखाया।",
    's1_step3_task': "अंतिम परिणाम देखें।",
    's1_step3_out': "(+4) - (+1) खोजने के लिए, हम 3 मंजिल ऊपर गए। गति +3 है।",
    's1_hud1': "मंजिल +1 पर लिफ्ट पर क्लिक करें।",
    's1_hud2': "लिफ्ट को लक्ष्य मंजिल +4 तक खींचें।",
    's1_hud3': "समीकरण देखें।",

    's2_title': "2. ग्राउंड फ्लोर पार करना",
    's2_obj': "बेसमेंट से ऊपरी मंजिल तक गति ज्ञात करके (+2) - (-3) को हल करना।",
    's2_step1_task':
        "समीकरण (+2) - (-3) = ? है। प्रारंभिक मंजिल (-3) पर लिफ्ट पर क्लिक करें।",
    's2_step1_out': "लिफ्ट मंजिल -3 पर सक्रिय है।",
    's2_step2_task': "लिफ्ट को मंजिल -3 से लक्ष्य मंजिल +2 तक खींचें।",
    's2_step2_out':
        "लिफ्ट ने ग्राउंड फ्लोर को पार कर लिया। कुल गति 5 मंजिल ऊपर थी।",
    's2_step3_task': "अंतिम परिणाम देखें।",
    's2_step3_out':
        "-3 से +2 तक जाने के लिए, आपको 5 ऊपर जाना होगा। इसलिए, (+2) - (-3) = +5। ऋणात्मक घटाना ऊपर जाने जैसा है!",
    's2_hud1': "मंजिल -3 पर लिफ्ट पर क्लिक करें।",
    's2_hud2': "लिफ्ट को लक्ष्य मंजिल +2 तक खींचें।",
    's2_hud3': "समीकरण देखें।",

    's3_title': "3. टोकन हटाना",
    's3_obj':
        "'हटाने' (take away) टोकन मॉडल का उपयोग करके (+3) - (+5) को हल करना।",
    's3_step1_task':
        "(+3) - (+5) हल करें। 3 धनात्मक टोकन से शुरू करें। पहचानें कि आप +5 नहीं हटा सकते। चमकते हुए शून्य जोड़ा मशीन पर क्लिक करें।",
    's3_step1_out': "मशीन सक्रिय है और शून्य जोड़े देने के लिए तैयार है।",
    's3_step2_task': "मशीन से दो 'शून्य जोड़े' को कार्यक्षेत्र में खींचें।",
    's3_step2_out':
        "शून्य जोड़े जोड़ने से कुल मूल्य (+3) नहीं बदलता है, लेकिन यह घटाने के लिए पर्याप्त टोकन प्रदान करता है।",
    's3_step3_task':
        "अब जब आपके पास 5 धनात्मक टोकन हैं, तो सभी 5 धनात्मक टोकन को 'हटाने वाले बॉक्स' में खींचें।",
    's3_step3_out': "आपने सफलतापूर्वक (+5) हटा दिया है।",
    's3_step4_task': "कार्यक्षेत्र में अपना अंतिम उत्तर देखें।",
    's3_step4_out':
        "5 धनात्मक टोकन हटाने के बाद, आपके पास 2 ऋणात्मक टोकन बचे हैं। (+3) - (+5) = -2।",
    's3_hud1': "चमकती हुई मशीन पर क्लिक करें।",
    's3_hud2': "मशीन से 2 शून्य जोड़ों को कार्यक्षेत्र में खींचें।",
    's3_hud3': "5 लाल (+) टोकन को हटाने वाले बॉक्स में खींचें।",
    's3_hud4': "अंतिम उत्तर देखें।",
    's3_summary':
        "+3 से +5 घटाने के लिए, हमने दो 'शून्य जोड़े' (+2 और -2) जोड़े ताकि घटाने के लिए पर्याप्त धनात्मक टोकन हों। हमारे पास -2 बचे।",

    's4_title': "4. बेसमेंट से बेसमेंट",
    's4_obj': "लिफ्ट मॉडल का उपयोग करके (-4) - (-1) व्यंजक को हल करें।",
    's4_step1_task':
        "(-4) - (-1) = ? हल करें। लिफ्ट को प्रारंभिक मंजिल (-1) से लक्ष्य मंजिल (-4) तक खींचें।",
    's4_step1_out': "आपने लिफ्ट खींचकर गति ज्ञात कर ली है।",
    's4_step2_task': "स्क्रीन पर 'उत्तर जाँचें' बटन पर क्लिक करें।",
    's4_step2_out':
        "-1 से -4 तक जाने के लिए 3 मंजिल नीचे जाना पड़ता है। उत्तर -3 है।",
    's4_hud1': "लिफ्ट को मंजिल -1 से मंजिल -4 तक खींचें।",
    's4_hud2': "उत्तर जाँचें बटन पर क्लिक करें।",
    's4_bubble_drag':
        "आवश्यक गति ज्ञात करने के लिए लिफ्ट को प्रारंभिक मंजिल से लक्ष्य मंजिल तक खींचें।",
    's4_bubble_done':
        "सही परिणाम -3 उत्तर बॉक्स में चला जाता है। घटाव पूरा हुआ!",

    's5_title': "5. ऋणात्मक को घटाना",
    's5_obj':
        "ऋणात्मक टोकन हटाकर टोकन मॉडल का उपयोग करके (-2) - (-5) को हल करें।",
    's5_step1_task':
        "(-2) - (-5) हल करें। आपके पास 2 ऋणात्मक टोकन हैं लेकिन 5 हटाने हैं। कार्यक्षेत्र में 3 'शून्य जोड़े' खींचें।",
    's5_step1_out':
        "आपने 3 शून्य जोड़े जोड़े हैं। अब आपके पास पर्याप्त ऋणात्मक टोकन हैं।",
    's5_step2_task': "5 ऋणात्मक (हरे) टोकन को हटाने वाले बॉक्स में खींचें।",
    's5_step2_out': "आपने (-5) घटा दिया है।",
    's5_step3_task': "समाप्त करने के लिए 'उत्तर जाँचें' बटन पर क्लिक करें।",
    's5_step3_out':
        "3 धनात्मक टोकन बचे हैं। (-2) - (-5) = +3। ऋणात्मक को घटाने से धनात्मक परिणाम मिलता है!",
    's5_hud1': "3 शून्य जोड़ों को कार्यक्षेत्र में खींचें।",
    's5_hud2': "5 हरे (-) टोकन को हटाने वाले बॉक्स में खींचें।",
    's5_hud3': "समाप्त करने के लिए उत्तर जाँचें पर क्लिक करें।",
    's5_summary':
        "-2 से -5 घटाने के लिए, हमने तीन 'शून्य जोड़े' (+3 और -3) जोड़े ताकि घटाने के लिए पर्याप्त ऋणात्मक टोकन हों। हमारे पास +3 बचे।",
  },
};

// --- MODELS ---
class Token {
  int id;
  int type; // 1 for +, -1 for -
  double x, y;
  String zone; // 'calc', 'ans', 'drag', 'bin'
  bool isDead;
  Token({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    this.zone = 'calc',
    this.isDead = false,
  });
}

class FlyAnim {
  double p, fromX, fromY, toX, toY;
  String text;
  FlyAnim({
    required this.p,
    required this.fromX,
    required this.fromY,
    required this.toX,
    required this.toY,
    required this.text,
  });
}

class SimState {
  String mode = 'lift';
  double liftStart = 0.0, liftTarget = 0.0, liftCurrent = 0.0;
  bool liftActive = false;
  bool isDraggingLift = false;

  List<Token> tokens = [];
  Token? dragToken;
  bool dragIsZeroPair = false;
  double dragZeroPairX = 0.0, dragZeroPairY = 0.0;
  int tokenNextId = 1;
  int zeroPairsAdded = 0;
  int tokensRemoved = 0;

  FlyAnim? flyAnim;
  String msgText = '';
  String msgColor = '';
  double msgOpacity = 0.0;
}

class StepConfig {
  String hud, task, outcome;
  StepConfig({required this.hud, required this.task, required this.outcome});
}

class ScenarioConfig {
  String title, objective;
  List<StepConfig> steps;
  ScenarioConfig({
    required this.title,
    required this.objective,
    required this.steps,
  });
}

// --- MAIN WIDGET ---
class Cl6M_Ch10_A4_SubtractingIntegersUsingContextualModels
    extends StatefulWidget {
  const Cl6M_Ch10_A4_SubtractingIntegersUsingContextualModels({Key? key})
    : super(key: key);

  @override
  State<Cl6M_Ch10_A4_SubtractingIntegersUsingContextualModels> createState() =>
      _Cl6M_Ch10_A4_SubtractingIntegersUsingContextualModelsState();
}

class _Cl6M_Ch10_A4_SubtractingIntegersUsingContextualModelsState
    extends State<Cl6M_Ch10_A4_SubtractingIntegersUsingContextualModels>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  bool isCurtainOpen = true;
  bool isSidebarOpen = true;
  double sidebarWidth = 350.0;
  String lang = 'en';
  int scenario = 1;
  int currentStep = 0;
  bool showSuccessPopup = false;

  double panX = 0.0, panY = 0.0, zoom = 1.0;
  double initialPanX = 0.0, initialPanY = 0.0, initialZoom = 1.0;

  SimState sim = SimState();
  final GlobalKey _canvasKey = GlobalKey();

  String t(String key) => tMap[lang]?[key] ?? key;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _controller.addListener(_gameLoopTick);

    _loadScenario(1);
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _gameLoopTick() {
    bool needsRepaint = false;

    if (sim.flyAnim != null) {
      sim.flyAnim!.p += 0.02;
      if (sim.flyAnim!.p >= 1.0) {
        sim.flyAnim = null;
        AudioManager.playPageOpen();
        _advanceStep();

        // Scenario Observation Steps Auto-Complete
        if ((scenario == 1 && currentStep == 2) ||
            (scenario == 2 && currentStep == 2)) {
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted && currentStep == 2 && showSuccessPopup == false) {
              _advanceStep();
              _checkScenarioSuccess();
            }
          });
        } else {
          Future.delayed(
            const Duration(milliseconds: 1500),
            _checkScenarioSuccess,
          );
        }
      }
      needsRepaint = true;
    }
    if (sim.msgOpacity > 0.0) {
      sim.msgOpacity -= 0.02;
      needsRepaint = true;
    }

    if (needsRepaint) setState(() {});
  }

  void _loadScenario(int id) {
    setState(() {
      scenario = id;
      currentStep = 0;
      sim = SimState();
      showSuccessPopup = false;

      if (scenario == 1) {
        sim.mode = 'lift';
        sim.liftStart = 1.0;
        sim.liftTarget = 4.0;
        sim.liftCurrent = 1.0;
      } else if (scenario == 2) {
        sim.mode = 'lift';
        sim.liftStart = -3.0;
        sim.liftTarget = 2.0;
        sim.liftCurrent = -3.0;
      } else if (scenario == 3) {
        sim.mode = 'token';
        for (int i = 0; i < 3; i++)
          sim.tokens.add(Token(id: sim.tokenNextId++, type: 1, x: 0.0, y: 0.0));
      } else if (scenario == 4) {
        sim.mode = 'lift';
        sim.liftStart = -1.0;
        sim.liftTarget = -4.0;
        sim.liftCurrent = -1.0;
      } else if (scenario == 5) {
        sim.mode = 'token';
        for (int i = 0; i < 2; i++)
          sim.tokens.add(
            Token(id: sim.tokenNextId++, type: -1, x: 0.0, y: 0.0),
          );
      }
      _autoArrangeTokens();
      _fitToScreen();
    });
  }

  void _fitToScreen() {
    zoom = 1.0;
    panX = 0.0;
    panY = 0.0;
  }

  void _advanceStep() {
    setState(() {
      currentStep++;
      _checkScenarioLogic();
    });
  }

  void _checkScenarioSuccess() {
    ScenarioConfig cfg = _getScenarioConfig(scenario);
    if (currentStep >= cfg.steps.length) {
      setState(() {
        showSuccessPopup = true;
      });
    }
  }

  void _autoArrangeTokens() {
    List<Token> calcTokens = sim.tokens
        .where((t) => !t.isDead && t.zone == 'calc')
        .toList();
    List<Token> plusTokens = calcTokens.where((t) => t.type == 1).toList();
    List<Token> minusTokens = calcTokens.where((t) => t.type == -1).toList();

    double startXPlus = -240.0, startYPlus = -100.0;
    for (int i = 0; i < plusTokens.length; i++) {
      plusTokens[i].x = startXPlus + (i % 3) * 55.0;
      plusTokens[i].y = startYPlus + (i ~/ 3) * 55.0;
    }

    double startXMinus = -40.0, startYMinus = -100.0;
    for (int i = 0; i < minusTokens.length; i++) {
      minusTokens[i].x = startXMinus + (i % 3) * 55.0;
      minusTokens[i].y = startYMinus + (i ~/ 3) * 55.0;
    }

    List<Token> ansTokens = sim.tokens
        .where((t) => !t.isDead && t.zone == 'ans')
        .toList();
    double startXAns = -120.0, startYAns = -50.0;
    for (int i = 0; i < ansTokens.length; i++) {
      ansTokens[i].x = startXAns + (i % 3) * 55.0;
      ansTokens[i].y = startYAns + (i ~/ 3) * 55.0;
    }
  }

  void _checkScenarioLogic() {
    if (sim.mode == 'token') {
      if (scenario == 3) {
        if (currentStep == 1 && sim.zeroPairsAdded >= 2) {
          _advanceStep();
        }
        if (currentStep == 2 && sim.tokensRemoved >= 5) {
          for (var t in sim.tokens) {
            if (!t.isDead && t.zone == 'calc') t.zone = 'ans';
          }
          _autoArrangeTokens();
          AudioManager.playPageOpen();
          _advanceStep();

          // Observation Step Auto-Advance
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted && currentStep == 3 && showSuccessPopup == false) {
              _advanceStep();
              _checkScenarioSuccess();
            }
          });
        }
      } else if (scenario == 5) {
        if (currentStep == 0 && sim.zeroPairsAdded >= 3) {
          _advanceStep();
        }
        if (currentStep == 1 && sim.tokensRemoved >= 5) {
          _advanceStep();
        }
      }
    }
  }

  void _showMessage(String text, String color) {
    setState(() {
      sim.msgText = text;
      sim.msgColor = color;
      sim.msgOpacity = 1.5;
    });
  }

  ScenarioConfig _getScenarioConfig(int id) {
    int numSteps = id == 1
        ? 3
        : (id == 2 ? 3 : (id == 3 ? 4 : (id == 4 ? 2 : 3)));
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
    return ScenarioConfig(
      title: t('s${id}_title'),
      objective: t('s${id}_obj'),
      steps: steps,
    );
  }

  // --- GESTURE HANDLING ---
  Offset _getWorldPoint(Offset localFocal) {
    final RenderBox renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox;
    final size = renderBox.size;
    double worldX = (localFocal.dx - size.width / 2.0 - panX) / zoom;
    double worldY = (localFocal.dy - size.height / 2.0 - panY) / zoom;
    return Offset(worldX, worldY);
  }

  bool _hitTestBox(double x, double y, double w, double h, Offset pt) {
    return pt.dx > x && pt.dx < x + w && pt.dy > y && pt.dy < y + h;
  }

  bool _hitTestCircle(double cx, double cy, double r, Offset pt) {
    return (pow(pt.dx - cx, 2) + pow(pt.dy - cy, 2)) <= r * r;
  }

  bool _handleCanvasClick(Offset pt) {
    if (sim.mode == 'lift' && sim.flyAnim == null) {
      double liftX = -145.0 + 80.0 + 5.0;
      double liftY = -(sim.liftCurrent * 45.0);
      double drawY = liftY - 45.0 / 2.0;

      // Lift Activation Clicks
      if (scenario == 1 &&
          currentStep == 0 &&
          _hitTestBox(liftX, drawY, 90.0, 45.0, pt)) {
        AudioManager.playClick();
        setState(() {
          sim.liftActive = true;
        });
        _advanceStep();
        return true;
      }
      if (scenario == 2 &&
          currentStep == 0 &&
          _hitTestBox(liftX, drawY, 90.0, 45.0, pt)) {
        AudioManager.playClick();
        setState(() {
          sim.liftActive = true;
        });
        _advanceStep();
        return true;
      }

      // Check Answer Button Lift
      if (scenario == 4 && currentStep == 1) {
        double meterX = -145.0 + 160.0 + 40.0;
        double panelX = meterX + 110.0;
        double panelY = -(-1.0 * 45.0);
        if (_hitTestBox(panelX - 80.0, panelY + 10.0, 160.0, 40.0, pt)) {
          if (sim.liftCurrent.round() == sim.liftTarget) {
            AudioManager.playClick();
            setState(() {
              sim.flyAnim = FlyAnim(
                p: 0.0,
                fromX: meterX - 30.0,
                fromY: liftY,
                toX: panelX + 75.0,
                toY: panelY - 20.0,
                text: '-3',
              );
            });
          } else {
            AudioManager.playError();
            _showMessage(t('lbl_try_again'), 'red');
            setState(() {
              sim.liftCurrent = sim.liftStart;
            });
          }
          return true;
        }
      }
    } else if (sim.mode == 'token') {
      // Dispenser Activation Click
      if (scenario == 3 &&
          currentStep == 0 &&
          _hitTestBox(220.0, -160.0, 110.0, 150.0, pt)) {
        AudioManager.playClick();
        _advanceStep();
        return true;
      }

      // Check Answer Button Token
      if (scenario == 5 && currentStep == 2 && sim.tokensRemoved >= 5) {
        if (_hitTestBox(-70.0, 100.0, 140.0, 40.0, pt)) {
          int calcPlus = sim.tokens
              .where((t) => !t.isDead && t.zone == 'calc' && t.type == 1)
              .length;
          int calcMinus = sim.tokens
              .where((t) => !t.isDead && t.zone == 'calc' && t.type == -1)
              .length;
          if (calcPlus == 3 && calcMinus == 0) {
            AudioManager.playPageOpen();
            for (var t in sim.tokens) {
              if (!t.isDead && t.zone == 'calc') t.zone = 'ans';
            }
            _autoArrangeTokens();
            _advanceStep();
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) _checkScenarioSuccess();
            });
          } else {
            AudioManager.playError();
            _showMessage(t('lbl_try_again'), 'red');
          }
          return true;
        }
      }
    }
    return false;
  }

  // Handle Pure Clicks (No Drag Required)
  void _onTapUp(TapUpDetails details) {
    Offset pt = _getWorldPoint(details.localPosition);
    _handleCanvasClick(pt);
  }

  void _onScaleStart(ScaleStartDetails details) {
    initialPanX = panX;
    initialPanY = panY;
    initialZoom = zoom;
    Offset pt = _getWorldPoint(details.localFocalPoint);

    if (_handleCanvasClick(pt)) return;

    if (sim.mode == 'lift' && sim.flyAnim == null) {
      double liftX = -145.0 + 80.0 + 5.0;
      double liftY = -(sim.liftCurrent * 45.0);
      double drawY = liftY - 45.0 / 2.0;

      // Start Drag Lift
      if (sim.liftActive || scenario == 4) {
        if (_hitTestBox(liftX, drawY, 90.0, 45.0, pt)) {
          AudioManager.playClick();
          setState(() {
            sim.isDraggingLift = true;
          });
          return;
        }
      }
    } else if (sim.mode == 'token') {
      bool canDispense =
          (scenario == 3 && currentStep == 1) ||
          (scenario == 5 && currentStep == 0);
      if (canDispense && _hitTestBox(220.0, -160.0, 110.0, 150.0, pt)) {
        AudioManager.playClick();
        setState(() {
          sim.dragIsZeroPair = true;
          sim.dragZeroPairX = pt.dx;
          sim.dragZeroPairY = pt.dy;
        });
        return;
      }
      for (int i = sim.tokens.length - 1; i >= 0; i--) {
        if (!sim.tokens[i].isDead &&
            _hitTestCircle(sim.tokens[i].x, sim.tokens[i].y, 20.0, pt)) {
          AudioManager.playClick();
          setState(() {
            sim.dragToken = sim.tokens[i];
            sim.tokens.removeAt(i);
          });
          return;
        }
      }
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (sim.isDraggingLift) {
      Offset pt = _getWorldPoint(details.localFocalPoint);
      double rawFloor = (0.0 - pt.dy) / 45.0;
      setState(() {
        sim.liftCurrent = rawFloor.clamp(-5.0, 5.0);
      });
      return;
    }
    if (sim.dragIsZeroPair) {
      Offset pt = _getWorldPoint(details.localFocalPoint);
      setState(() {
        sim.dragZeroPairX = pt.dx;
        sim.dragZeroPairY = pt.dy;
      });
      return;
    }
    if (sim.dragToken != null) {
      Offset pt = _getWorldPoint(details.localFocalPoint);
      setState(() {
        sim.dragToken!.x = pt.dx;
        sim.dragToken!.y = pt.dy;
      });
      return;
    }

    // Pan & Zoom Update smoothly if no interactable is being dragged
    setState(() {
      zoom = (initialZoom * details.scale).clamp(0.4, 2.0);
      panX = initialPanX + details.focalPointDelta.dx;
      panY = initialPanY + details.focalPointDelta.dy;
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (sim.isDraggingLift) {
      AudioManager.playClick();
      setState(() {
        sim.isDraggingLift = false;
        sim.liftCurrent = sim.liftCurrent.roundToDouble();
      });

      if (scenario == 1 && currentStep == 1 && sim.liftCurrent == 4.0) {
        setState(() {
          sim.liftActive = false;
          sim.flyAnim = FlyAnim(
            p: 0.0,
            fromX: -145.0 + 270.0,
            fromY: -(2.5 * 45.0),
            toX: 70.0,
            toY: -(5.0 * 45.0) - 20.0,
            text: '+3',
          );
        });
      } else if (scenario == 2 && currentStep == 1 && sim.liftCurrent == 2.0) {
        setState(() {
          sim.liftActive = false;
          sim.flyAnim = FlyAnim(
            p: 0.0,
            fromX: -145.0 + 270.0,
            fromY: -(-0.5 * 45.0),
            toX: 70.0,
            toY: -(5.0 * 45.0) - 20.0,
            text: '+5',
          );
        });
      } else if (scenario == 4 && currentStep == 0) {
        if (sim.liftCurrent == sim.liftTarget) {
          setState(() {
            sim.liftActive = false;
          });
          _advanceStep();
        }
      }
      return;
    }

    if (sim.dragIsZeroPair) {
      if (_hitTestBox(
        -300.0,
        -160.0,
        480.0,
        320.0,
        Offset(sim.dragZeroPairX, sim.dragZeroPairY),
      )) {
        AudioManager.playClick();
        setState(() {
          sim.tokens.add(
            Token(
              id: sim.tokenNextId++,
              type: 1,
              x: sim.dragZeroPairX - 25.0,
              y: sim.dragZeroPairY,
            ),
          );
          sim.tokens.add(
            Token(
              id: sim.tokenNextId++,
              type: -1,
              x: sim.dragZeroPairX + 25.0,
              y: sim.dragZeroPairY,
            ),
          );
          sim.zeroPairsAdded++;
        });
      } else {
        AudioManager.playError();
      }
      setState(() {
        sim.dragIsZeroPair = false;
      });
      _autoArrangeTokens();
      _checkScenarioLogic();
      return;
    }

    if (sim.dragToken != null) {
      int targetBinType = scenario == 3 ? 1 : -1;
      Offset pt = Offset(sim.dragToken!.x, sim.dragToken!.y);
      bool success = false;

      if (_hitTestBox(220.0, 40.0, 110.0, 120.0, pt)) {
        if (sim.dragToken!.type == targetBinType) {
          sim.dragToken!.isDead = true;
          sim.tokensRemoved++;
          success = true;
          AudioManager.playClick();
        } else {
          AudioManager.playError();
        }
      } else if (_hitTestBox(-300.0, -160.0, 480.0, 320.0, pt)) {
        sim.dragToken!.zone = 'calc';
        sim.tokens.add(sim.dragToken!);
        success = true;
        AudioManager.playClick();
      }

      if (!success && !sim.dragToken!.isDead && sim.dragToken!.zone != 'calc') {
        AudioManager.playError();
      }

      setState(() {
        sim.dragToken = null;
      });
      _autoArrangeTokens();
      _checkScenarioLogic();
    }
  }

  // --- UI BUILDING ---
  @override
  Widget build(BuildContext context) {
    ScenarioConfig scenarioCfg = _getScenarioConfig(scenario);
    String currentHud = currentStep < scenarioCfg.steps.length
        ? scenarioCfg.steps[currentStep].hud
        : '';

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: Scaffold(
        body: Stack(
          children: [
            // Canvas Area
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isSidebarOpen ? sidebarWidth : 0,
              top: 0,
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTapUp: _onTapUp,
                onScaleStart: _onScaleStart,
                onScaleUpdate: _onScaleUpdate,
                onScaleEnd: _onScaleEnd,
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          key: _canvasKey,
                          painter: LabPainter(
                            sim: sim,
                            scenario: scenario,
                            step: currentStep,
                            zoom: zoom,
                            panX: panX,
                            panY: panY,
                            t: t,
                          ),
                        ),
                      ),
                      // HUD
                      if (currentHud.isNotEmpty)
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white24),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black54,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: Colors.indigoAccent,
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: Text(
                                      currentHud,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Left Sidebar - Fully scrollable
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isSidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  border: Border(
                    right: BorderSide(color: Colors.white24, width: 1.0),
                  ),
                ),
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          // Header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              16.0,
                              64.0,
                              16.0,
                              16.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.science,
                                      color: Colors.indigoAccent,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        t('appTitle'),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  t('appSubtitle'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Language and Reset actions
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white12,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.language,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        lang.toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      onPressed: () {
                                        AudioManager.playClick();
                                        setState(() {
                                          lang = lang == 'en' ? 'hi' : 'en';
                                        });
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent
                                            .withOpacity(0.2),
                                        foregroundColor: Colors.redAccent,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                      ),
                                      icon: const Icon(Icons.refresh, size: 16),
                                      label: Text(
                                        t('resetBtn'),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onPressed: () {
                                        AudioManager.playPageOpen();
                                        setState(() {
                                          isCurtainOpen = true;
                                          _loadScenario(1);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                            color: Colors.white12,
                            height: 1.0,
                            thickness: 1.0,
                          ),
                          // Content Items
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
                                      color: Colors.white54,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF334155),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        value: scenario,
                                        isExpanded: true,
                                        dropdownColor: const Color(0xFF334155),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        items: List.generate(
                                          5,
                                          (index) => DropdownMenuItem(
                                            value: index + 1,
                                            child: Text(
                                              t('s${index + 1}_title'),
                                            ),
                                          ),
                                        ),
                                        onChanged: (val) {
                                          if (val != null) {
                                            AudioManager.playDropdown();
                                            _loadScenario(val);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F172A),
                                      borderRadius: BorderRadius.circular(10),
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
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              t('learnLbl'),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          scenarioCfg.objective,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ...List.generate(scenarioCfg.steps.length, (
                                    i,
                                  ) {
                                    bool isCompleted = i < currentStep;
                                    bool isActive = i == currentStep;
                                    Color bgColor = isActive
                                        ? Colors.indigo.withOpacity(0.2)
                                        : (isCompleted
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.white.withOpacity(0.05));
                                    Color borderColor = isActive
                                        ? Colors.indigoAccent
                                        : (isCompleted
                                              ? Colors.green
                                              : Colors.transparent);
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: bgColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: borderColor),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: isCompleted
                                                  ? Colors.green
                                                  : (isActive
                                                        ? Colors.indigoAccent
                                                        : Colors.white24),
                                              shape: BoxShape.circle,
                                            ),
                                            alignment: Alignment.center,
                                            child: isCompleted
                                                ? const Icon(
                                                    Icons.check,
                                                    size: 16,
                                                    color: Colors.white,
                                                  )
                                                : Text(
                                                    '${i + 1}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${t("stepLabel")} ${i + 1}',
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white54,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                RichText(
                                                  text: TextSpan(
                                                    style: TextStyle(
                                                      color: isActive
                                                          ? Colors.white
                                                          : Colors.white70,
                                                      fontSize: 13,
                                                    ),
                                                    children: [
                                                      const TextSpan(
                                                        text: "Action: ",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .indigoAccent,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: scenarioCfg
                                                            .steps[i]
                                                            .task,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (isCompleted)
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                          top: 8,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: RichText(
                                                      text: TextSpan(
                                                        style: const TextStyle(
                                                          color: Colors
                                                              .greenAccent,
                                                          fontSize: 13,
                                                        ),
                                                        children: [
                                                          const TextSpan(
                                                            text: "Outcome: ",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: scenarioCfg
                                                                .steps[i]
                                                                .outcome,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                              ],
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
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              "© ZeroScienceLab - Fall in love with math and Science",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Sidebar Resizer (Right edge of left sidebar)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isSidebarOpen ? sidebarWidth - 10.0 : -20.0,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (details) {
                  setState(() {
                    sidebarWidth = (sidebarWidth + details.delta.dx).clamp(
                      300.0,
                      MediaQuery.of(context).size.width * 0.6,
                    );
                  });
                },
                child: Container(
                  width: 20.0,
                  alignment: Alignment.center,
                  child: Container(
                    width: 4.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: Colors.white38,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
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
                      width: 400.0,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(24.0),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                            size: 80.0,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            t('summaryTitle'),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigoAccent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            onPressed: () {
                              AudioManager.playPageOpen();
                              if (scenario < 5) {
                                _loadScenario(scenario + 1);
                              } else {
                                setState(() {
                                  isCurtainOpen = true;
                                  showSuccessPopup = false;
                                  _loadScenario(1);
                                });
                              }
                            },
                            icon: Icon(
                              scenario < 5 ? Icons.arrow_forward : Icons.flag,
                              size: 24.0,
                              color: Colors.white,
                            ),
                            label: Text(
                              scenario < 5 ? t('nextScenario') : t('finishLab'),
                              style: const TextStyle(
                                fontSize: 18,
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
            if (isCurtainOpen)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        vertical: 48.0,
                        horizontal: 24.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.elevator,
                            size: 100.0,
                            color: Colors.indigoAccent,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            t('shutterTitle'),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t('appSubtitle'),
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigoAccent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            onPressed: () {
                              AudioManager.curtainScreen();
                              setState(() {
                                isCurtainOpen = false;
                              });
                            },
                            icon: const Icon(
                              Icons.play_circle_fill,
                              size: 28.0,
                              color: Colors.white,
                            ),
                            label: Text(
                              t('enterLab'),
                              style: const TextStyle(
                                fontSize: 20,
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

            // Menu Button (Top Left Fixed)
            if (!isCurtainOpen)
              Positioned(
                top: 16.0,
                left: 16.0,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: const Color(0xFF334155),
                  child: Icon(
                    isSidebarOpen ? Icons.menu_open : Icons.menu,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    AudioManager.playClick();
                    setState(() {
                      isSidebarOpen = !isSidebarOpen;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- PAINTER ---
class LabPainter extends CustomPainter {
  final SimState sim;
  final int scenario;
  final int step;
  final double zoom, panX, panY;
  final String Function(String) t;

  LabPainter({
    required this.sim,
    required this.scenario,
    required this.step,
    required this.zoom,
    required this.panX,
    required this.panY,
    required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2.0 + panX, size.height / 2.0 + panY);
    canvas.scale(zoom, zoom);

    if (sim.mode == 'lift')
      _drawLiftMode(canvas);
    else if (sim.mode == 'token')
      _drawTokenMode(canvas);

    canvas.restore();
  }

  void _drawLiftMode(Canvas canvas) {
    double fh = 45.0;
    double roomW = 80.0, shaftW = 100.0;
    double bLeft = -145.0;
    double shaftLeft = bLeft + roomW;
    double rightRoomLeft = shaftLeft + shaftW;

    // Shaft
    _drawRect(
      canvas,
      shaftLeft,
      -(5.0 * fh) - fh / 2.0,
      shaftW,
      (11.0 * fh),
      const Color(0xFF1E293B),
    );

    // Walls
    _drawRect(
      canvas,
      bLeft,
      -(5.0 * fh) - fh / 2.0,
      roomW,
      (11.0 * fh),
      const Color(0xFFE6CCB2),
    );
    _drawRect(
      canvas,
      rightRoomLeft,
      -(5.0 * fh) - fh / 2.0,
      roomW,
      (11.0 * fh),
      const Color(0xFFD4A373),
    );

    // Floors
    for (int l = 5; l >= -5; l--) {
      double y = -(l.toDouble() * fh);
      _drawLine(
        canvas,
        bLeft,
        y + fh / 2.0,
        bLeft + roomW,
        y + fh / 2.0,
        const Color(0xFFB08D6A),
        2.0,
      );
      _drawLine(
        canvas,
        rightRoomLeft,
        y + fh / 2.0,
        rightRoomLeft + roomW,
        y + fh / 2.0,
        const Color(0xFFB08D6A),
        2.0,
      );

      bool isTarget = (scenario == 4 && l == sim.liftTarget);
      if (isTarget && step < 2) {
        _drawRoundedRect(
          canvas,
          rightRoomLeft + 15.0,
          y - 12.0,
          50.0,
          24.0,
          6.0,
          const Color(0xFFFED7AA),
          stroke: const Color(0xFFEA580C),
        );
        _drawText(
          canvas,
          _fmt(l),
          rightRoomLeft + 40.0,
          y,
          16.0,
          Colors.deepOrange,
          isBold: true,
        );
      } else {
        _drawRoundedRect(
          canvas,
          rightRoomLeft + 15.0,
          y - 12.0,
          50.0,
          24.0,
          6.0,
          const Color(0xFFF8FAFC),
          stroke: const Color(0xFF94A3B8),
        );
        _drawText(
          canvas,
          _fmt(l),
          rightRoomLeft + 40.0,
          y,
          14.0,
          const Color(0xFF475569),
          isBold: true,
        );
      }
    }

    _drawLine(
      canvas,
      shaftLeft,
      -(5.0 * fh) - fh / 2.0,
      shaftLeft,
      -(-5.0 * fh) + fh / 2.0,
      const Color(0xFF475569),
      4.0,
    );
    _drawLine(
      canvas,
      rightRoomLeft,
      -(5.0 * fh) - fh / 2.0,
      rightRoomLeft,
      -(-5.0 * fh) + fh / 2.0,
      const Color(0xFF475569),
      4.0,
    );

    // Lift
    double liftX = shaftLeft + 5.0;
    double liftY = -(sim.liftCurrent * fh);
    double drawY = liftY - fh / 2.0;

    bool isGlow =
        (step == 0 &&
            sim.liftCurrent == sim.liftStart &&
            !sim.isDraggingLift) ||
        (scenario == 4 && step == 0 && !sim.isDraggingLift);

    if (isGlow) {
      canvas.drawShadow(
        Path()..addRect(Rect.fromLTWH(liftX, drawY, 90.0, 45.0)),
        Colors.orangeAccent,
        10.0,
        true,
      );
    }

    _drawRoundedRect(
      canvas,
      liftX,
      drawY + 2.0,
      90.0,
      41.0,
      4.0,
      Colors.white.withOpacity(0.2),
      stroke: const Color(0xFF94A3B8),
    );
    _drawRect(
      canvas,
      liftX + 5.0,
      drawY + 6.0,
      38.0,
      33.0,
      Colors.lightBlue.withOpacity(0.4),
    );
    _drawRect(
      canvas,
      liftX + 47.0,
      drawY + 6.0,
      38.0,
      33.0,
      Colors.lightBlue.withOpacity(0.4),
    );

    // Character
    canvas.drawCircle(
      Offset(liftX + 45.0, liftY - 5.0),
      6.0,
      Paint()..color = const Color(0xFFFCA5A5),
    );
    _drawRect(canvas, liftX + 39.0, liftY + 1.0, 12.0, 12.0, Colors.blue);
    _drawRect(
      canvas,
      liftX + 40.0,
      liftY + 13.0,
      4.0,
      8.0,
      const Color(0xFF0F172A),
    );
    _drawRect(
      canvas,
      liftX + 46.0,
      liftY + 13.0,
      4.0,
      8.0,
      const Color(0xFF0F172A),
    );

    if (isGlow) {
      canvas.drawCircle(
        Offset(liftX + 45.0, drawY + fh / 2.0),
        25.0,
        Paint()..color = Colors.orange.withOpacity(0.9),
      );
      _drawText(
        canvas,
        "DRAG",
        liftX + 45.0,
        drawY + fh / 2.0,
        12.0,
        Colors.white,
        isBold: true,
      );
    }

    if (scenario == 4 && step == 0) {
      _drawRoundedRect(
        canvas,
        liftX - 190.0,
        liftY + 40.0,
        180.0,
        80.0,
        8.0,
        Colors.white,
        stroke: Colors.lightBlue,
      );
      _drawText(
        canvas,
        t('s4_bubble_drag'),
        liftX - 100.0,
        liftY + 80.0,
        14.0,
        Colors.black,
        maxW: 160.0,
      );
    }

    // Meter
    double meterX = rightRoomLeft + roomW + 40.0;
    double meterY = -(5.0 * fh);

    Rect meterRect = Rect.fromLTWH(meterX, meterY, 30.0, 11.0 * fh);
    Paint meterPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(meterX, meterY),
        Offset(meterX, meterY + 11.0 * fh),
        [Colors.blue, Colors.green, Colors.yellow, Colors.orange, Colors.red],
        [0.0, 0.25, 0.5, 0.75, 1.0],
      );
    canvas.drawRRect(
      RRect.fromRectAndRadius(meterRect, const Radius.circular(15.0)),
      meterPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(meterRect, const Radius.circular(15.0)),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
    );

    _drawText(
      canvas,
      "MOVEMENT\nMETER",
      meterX + 15.0,
      meterY - 20.0,
      12.0,
      Colors.white70,
      isBold: true,
    );

    for (int l = 5; l >= -5; l--) {
      _drawText(
        canvas,
        _fmt(l),
        meterX + 50.0,
        -(l.toDouble() * fh),
        14.0,
        Colors.white,
        isBold: true,
      );
    }

    // Difference Indicator
    double startY = -(sim.liftStart * fh);
    if ((sim.liftCurrent - sim.liftStart).abs() > 0.01) {
      double diff = sim.liftCurrent - sim.liftStart;
      _drawLine(
        canvas,
        meterX - 15.0,
        startY,
        meterX - 15.0,
        liftY,
        Colors.white,
        4.0,
        isDashed: true,
      );

      Path p = Path();
      if (diff > 0) {
        p.moveTo(meterX - 15.0, liftY);
        p.lineTo(meterX - 25.0, liftY + 15.0);
        p.lineTo(meterX - 5.0, liftY + 15.0);
      } else {
        p.moveTo(meterX - 15.0, liftY);
        p.lineTo(meterX - 25.0, liftY - 15.0);
        p.lineTo(meterX - 5.0, liftY - 15.0);
      }
      canvas.drawPath(p, Paint()..color = Colors.white);

      int diffVal = diff.round();
      _drawRoundedRect(
        canvas,
        meterX - 45.0,
        liftY - 15.0,
        30.0,
        30.0,
        8.0,
        diffVal > 0 ? Colors.green : Colors.red,
        stroke: Colors.white,
      );
      _drawText(
        canvas,
        _fmt(diffVal),
        meterX - 30.0,
        liftY,
        14.0,
        Colors.white,
        isBold: true,
      );
    }

    // Equation Panel
    String eqStart = _fmt(sim.liftStart.toInt());
    String eqTarget = _fmt(sim.liftTarget.toInt());
    String eqMove = (step >= 3 || sim.flyAnim != null)
        ? _fmt((sim.liftTarget - sim.liftStart).toInt())
        : "?";
    if (scenario == 4 && step >= 2)
      eqMove = _fmt((sim.liftTarget - sim.liftStart).toInt());

    if (scenario == 4) {
      _drawText(
        canvas,
        "(-4) - (-1)",
        bLeft + 40.0,
        -(4.0 * fh) - 10.0,
        24.0,
        Colors.white,
        isBold: true,
      );
      _drawText(
        canvas,
        "(-4) - (-1)",
        bLeft + 40.0,
        -(-1.0 * fh) - 10.0,
        24.0,
        Colors.white,
        isBold: true,
      );
    } else {
      double eqY = -(5.0 * fh) - 100.0;
      _drawRoundedRect(
        canvas,
        -180.0,
        eqY,
        360.0,
        40.0,
        8.0,
        const Color(0xFF334155),
        stroke: const Color(0xFF64748B),
      );
      _drawText(
        canvas,
        "${t('lbl_target')} - ${t('lbl_start')} = ${t('lbl_movement')}",
        0,
        eqY + 20.0,
        16.0,
        Colors.greenAccent,
        isBold: true,
      );
      _drawRoundedRect(
        canvas,
        -120.0,
        eqY + 50.0,
        240.0,
        60.0,
        12.0,
        const Color(0xFF1E293B),
        stroke: Colors.indigoAccent,
      );
      _drawText(
        canvas,
        "($eqTarget) - ($eqStart) = ",
        -20.0,
        eqY + 80.0,
        28.0,
        Colors.white,
        isBold: true,
      );
      _drawText(
        canvas,
        eqMove,
        70.0,
        eqY + 80.0,
        30.0,
        Colors.greenAccent,
        isBold: true,
      );
    }

    if (scenario == 4 && step == 1) {
      double panelX = meterX + 110.0;
      double panelY = -(-1.0 * fh);
      _drawRoundedRect(
        canvas,
        panelX - 120.0,
        panelY - 50.0,
        240.0,
        110.0,
        10.0,
        Colors.white,
        stroke: Colors.grey,
      );
      _drawText(
        canvas,
        "(-4) - (-1) = ",
        panelX - 20.0,
        panelY - 20.0,
        20.0,
        Colors.black,
        isBold: true,
      );
      _drawRoundedRect(
        canvas,
        panelX + 50.0,
        panelY - 40.0,
        50.0,
        40.0,
        8.0,
        Colors.orange[200]!,
        stroke: Colors.orange,
      );

      _drawRoundedRect(
        canvas,
        panelX - 80.0,
        panelY + 10.0,
        160.0,
        40.0,
        8.0,
        Colors.yellow,
        stroke: Colors.black,
      );
      _drawText(
        canvas,
        t('lbl_check_ans'),
        panelX,
        panelY + 30.0,
        18.0,
        Colors.black,
        isBold: true,
      );
    }

    if (scenario == 4 && step == 2) {
      double panelX = meterX + 110.0;
      double panelY = -(-1.0 * fh);
      _drawRoundedRect(
        canvas,
        panelX - 120.0,
        panelY - 50.0,
        240.0,
        60.0,
        10.0,
        Colors.white,
        stroke: Colors.green,
      );
      _drawText(
        canvas,
        "(-4) - (-1) = -3",
        panelX,
        panelY - 20.0,
        20.0,
        Colors.black,
        isBold: true,
      );
      _drawRoundedRect(
        canvas,
        panelX - 120.0,
        panelY + 20.0,
        240.0,
        70.0,
        8.0,
        Colors.white,
        stroke: Colors.lightBlue,
      );
      _drawText(
        canvas,
        t('s4_bubble_done'),
        panelX,
        panelY + 55.0,
        13.0,
        Colors.black,
        maxW: 220.0,
      );
    }

    if (sim.flyAnim != null) {
      double fX =
          sim.flyAnim!.fromX +
          (sim.flyAnim!.toX - sim.flyAnim!.fromX) * sim.flyAnim!.p;
      double fY =
          sim.flyAnim!.fromY +
          (sim.flyAnim!.toY - sim.flyAnim!.fromY) * sim.flyAnim!.p;
      _drawText(
        canvas,
        sim.flyAnim!.text,
        fX,
        fY,
        36.0,
        Colors.greenAccent,
        isBold: true,
      );
    }

    if ((scenario == 1 && step >= 3) || (scenario == 2 && step >= 3)) {
      double sy = 250.0;
      _drawRoundedRect(
        canvas,
        -180.0,
        sy - 80.0,
        360.0,
        160.0,
        12.0,
        Colors.amber[100]!,
        stroke: Colors.amber[900]!,
      );
      _drawText(
        canvas,
        "Learning Summary",
        0,
        sy - 60.0,
        18.0,
        Colors.black,
        isBold: true,
      );
      _drawText(
        canvas,
        scenario == 1 ? t('s1_step3_out') : t('s2_step3_out'),
        0,
        sy + 10.0,
        16.0,
        Colors.black87,
        maxW: 320.0,
      );
    }

    _drawMsgOverlay(canvas);
  }

  void _drawTokenMode(Canvas canvas) {
    String eqStr = "";
    if (scenario == 3) eqStr = "(+3) - (+5) = " + (step >= 3 ? "-2" : "?");
    if (scenario == 5) eqStr = "(-2) - (-5) = " + (step >= 2 ? "+3" : "?");

    _drawRoundedRect(
      canvas,
      -200.0,
      -260.0,
      400.0,
      60.0,
      12.0,
      const Color(0xFF1E293B),
      stroke: const Color(0xFF334155),
    );
    _drawText(
      canvas,
      "Token Take-Away: $eqStr",
      0,
      -230.0,
      26.0,
      Colors.white,
      isBold: true,
    );

    // Workspace
    _drawRoundedRect(
      canvas,
      -300.0,
      -160.0,
      480.0,
      320.0,
      15.0,
      const Color(0xFF1E293B),
      stroke: const Color(0xFF475569),
    );

    // Dispenser
    double dx = 220.0, dy = -160.0, dw = 110.0, dh = 150.0;
    bool dGlow = (scenario == 3 && step == 0) || (scenario == 5 && step == 0);
    if (dGlow) {
      canvas.drawShadow(
        Path()..addRect(Rect.fromLTWH(dx, dy, dw, dh)),
        Colors.cyanAccent,
        15.0,
        true,
      );
    }
    _drawRoundedRect(
      canvas,
      dx,
      dy,
      dw,
      dh,
      8.0,
      const Color(0xFF94A3B8),
      stroke: const Color(0xFF64748B),
    );
    _drawRoundedRect(
      canvas,
      dx + 15.0,
      dy + 15.0,
      dw - 30.0,
      dh - 60.0,
      6.0,
      const Color(0xFF1E293B),
    );
    _drawTokenSVG(canvas, dx + dw / 2.0 - 12.0, dy + 40.0, 12.0, 1);
    _drawTokenSVG(canvas, dx + dw / 2.0 + 12.0, dy + 40.0, 12.0, -1);
    _drawTokenSVG(canvas, dx + dw / 2.0 - 12.0, dy + 70.0, 12.0, 1);
    _drawTokenSVG(canvas, dx + dw / 2.0 + 12.0, dy + 70.0, 12.0, -1);
    _drawRoundedRect(
      canvas,
      dx + 20.0,
      dy + dh - 30.0,
      dw - 40.0,
      10.0,
      4.0,
      const Color(0xFF475569),
    );
    _drawText(
      canvas,
      "Zero Pair\nDispenser",
      dx + dw / 2.0,
      dy - 25.0,
      14.0,
      Colors.white,
      isBold: true,
    );

    // Bin
    double bx = 220.0, by = 40.0, bw = 110.0, bh = 120.0;
    bool bGlow = (scenario == 3 && step == 2) || (scenario == 5 && step == 1);
    if (bGlow)
      canvas.drawShadow(
        Path()..addRect(Rect.fromLTWH(bx, by, bw, bh)),
        Colors.cyanAccent,
        15.0,
        true,
      );
    _drawRoundedRect(
      canvas,
      bx,
      by - 15.0,
      bw,
      15.0,
      4.0,
      Colors.blue,
      stroke: Colors.blue[900]!,
    );
    _drawRoundedRect(
      canvas,
      bx + 5.0,
      by,
      bw - 10.0,
      bh,
      8.0,
      Colors.blue[400]!,
      stroke: Colors.blue[700]!,
    );
    _drawText(
      canvas,
      "Take Away\nBin",
      bx + bw / 2.0,
      by + bh + 25.0,
      14.0,
      Colors.white,
      isBold: true,
    );

    if (sim.tokensRemoved > 0) {
      _drawTokenSVG(
        canvas,
        bx + bw / 2.0,
        by + 30.0,
        15.0,
        scenario == 3 ? 1 : -1,
      );
    }

    if (scenario == 3 && step == 0) {
      _drawRoundedRect(
        canvas,
        -100.0,
        0.0,
        220.0,
        60.0,
        8.0,
        const Color(0xFF334155),
        stroke: const Color(0xFF475569),
      );
      _drawText(
        canvas,
        "Start with +3 tokens. Identify you cannot take away +5.",
        10.0,
        30.0,
        14.0,
        Colors.white,
        maxW: 200.0,
      );
    }
    if (scenario == 5 && step == 0) {
      _drawRoundedRect(
        canvas,
        -100.0,
        0.0,
        220.0,
        60.0,
        8.0,
        const Color(0xFF334155),
        stroke: const Color(0xFF475569),
      );
      _drawText(
        canvas,
        "Start with -2 tokens. Identify you cannot take away -5.",
        10.0,
        30.0,
        14.0,
        Colors.white,
        maxW: 200.0,
      );
    }

    // Tokens
    for (var t in sim.tokens) {
      if (!t.isDead) _drawTokenSVG(canvas, t.x, t.y, 20.0, t.type);
    }

    if (sim.dragIsZeroPair) {
      canvas.drawShadow(
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              sim.dragZeroPairX - 45.0,
              sim.dragZeroPairY - 25.0,
              90.0,
              50.0,
            ),
            const Radius.circular(25.0),
          ),
        ),
        Colors.cyanAccent,
        15.0,
        true,
      );
      _drawRoundedRect(
        canvas,
        sim.dragZeroPairX - 45.0,
        sim.dragZeroPairY - 25.0,
        90.0,
        50.0,
        25.0,
        Colors.white.withOpacity(0.8),
        stroke: Colors.cyan,
      );
      _drawTokenSVG(
        canvas,
        sim.dragZeroPairX - 22.0,
        sim.dragZeroPairY,
        20.0,
        1,
      );
      _drawTokenSVG(
        canvas,
        sim.dragZeroPairX + 22.0,
        sim.dragZeroPairY,
        20.0,
        -1,
      );
    } else if (sim.dragToken != null) {
      _drawTokenSVG(
        canvas,
        sim.dragToken!.x,
        sim.dragToken!.y,
        20.0,
        sim.dragToken!.type,
      );
    }

    if ((scenario == 3 && step >= 3) ||
        (scenario == 5 && step >= 2 && sim.tokensRemoved >= 5)) {
      _drawRoundedRect(
        canvas,
        -220.0,
        90.0,
        440.0,
        110.0,
        8.0,
        const Color(0xFF1E293B),
        stroke: Colors.green,
      );
      _drawText(
        canvas,
        t('summary_title'),
        0,
        110.0,
        16.0,
        Colors.green,
        isBold: true,
      );
      _drawText(
        canvas,
        scenario == 3 ? t('s3_summary') : t('s5_summary'),
        0,
        150.0,
        16.0,
        Colors.white70,
        maxW: 400.0,
      );
    }

    if (scenario == 5 && step == 2 && sim.tokensRemoved >= 5) {
      _drawRoundedRect(
        canvas,
        -70.0,
        100.0,
        140.0,
        40.0,
        8.0,
        Colors.yellow,
        stroke: Colors.black,
      );
      _drawText(
        canvas,
        t('lbl_check_ans'),
        0,
        120.0,
        18.0,
        Colors.black,
        isBold: true,
      );
    }

    _drawMsgOverlay(canvas);
  }

  void _drawMsgOverlay(Canvas canvas) {
    if (sim.msgOpacity > 0.0) {
      int a = (min(1.0, sim.msgOpacity) * 255.0).toInt();
      Color bg = sim.msgColor == 'red'
          ? Colors.red[100]!.withAlpha(a)
          : Colors.green[100]!.withAlpha(a);
      Color fg = sim.msgColor == 'red'
          ? Colors.red[900]!.withAlpha(a)
          : Colors.green[900]!.withAlpha(a);
      _drawRoundedRect(canvas, -100.0, -80.0, 200.0, 40.0, 8.0, bg, stroke: fg);
      _drawText(canvas, sim.msgText, 0, -60.0, 16.0, fg, isBold: true);
    }
  }

  void _drawRect(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    Color color,
  ) {
    canvas.drawRect(Rect.fromLTWH(x, y, w, h), Paint()..color = color);
  }

  void _drawRoundedRect(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double r,
    Color fill, {
    Color? stroke,
  }) {
    RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      Radius.circular(r),
    );
    canvas.drawRRect(rrect, Paint()..color = fill);
    if (stroke != null) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }
  }

  void _drawLine(
    Canvas canvas,
    double x1,
    double y1,
    double x2,
    double y2,
    Color color,
    double width, {
    bool isDashed = false,
  }) {
    Paint p = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    if (isDashed) {
      double dx = x2 - x1, dy = y2 - y1;
      double dist = sqrt(dx * dx + dy * dy);
      double dashLen = 8.0, gapLen = 8.0;
      double nx = dx / dist, ny = dy / dist;
      for (double i = 0.0; i < dist; i += dashLen + gapLen) {
        canvas.drawLine(
          Offset(x1 + nx * i, y1 + ny * i),
          Offset(
            x1 + nx * min(i + dashLen, dist),
            y1 + ny * min(i + dashLen, dist),
          ),
          p,
        );
      }
    } else {
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), p);
    }
  }

  void _drawTokenSVG(Canvas canvas, double cx, double cy, double r, int type) {
    Color bg = type == 1 ? Colors.red : Colors.green;
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = bg);
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = (type == 1 ? Colors.red[900]! : Colors.green[900]!)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    Paint fg = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy), width: r * 1.0, height: r * 0.2),
      fg,
    );
    if (type == 1) {
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: r * 0.2,
          height: r * 1.0,
        ),
        fg,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y,
    double fontSize,
    Color color, {
    bool isBold = false,
    double? maxW,
  }) {
    TextSpan span = TextSpan(
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
      text: text,
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    if (maxW != null) {
      tp.layout(maxWidth: maxW);
    } else {
      tp.layout();
    }
    tp.paint(canvas, Offset(x - tp.width / 2.0, y - tp.height / 2.0));
  }

  String _fmt(int n) => n > 0 ? "+$n" : n.toString();

  @override
  bool shouldRepaint(covariant LabPainter oldDelegate) => true;
}
