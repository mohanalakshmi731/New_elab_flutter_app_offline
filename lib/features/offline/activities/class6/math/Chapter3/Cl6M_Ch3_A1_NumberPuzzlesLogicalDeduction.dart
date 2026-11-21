// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Number Puzzles & Logical Deduction',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: const Cl6M_Ch3_A1_NumberPuzzlesLogicalDeduction(),
    ),
  );
}

// --- स्थानीयकरण और टेक्स्ट (LOCALIZATION & TEXT) ---
const Map<String, Map<String, String>> translations = {
  'en': {
    'appTitle': "Number Puzzles & Logical Deduction",
    'appSubtitle': "Class 6 • Number Play",
    'enterLab': "Enter Simulation",
    'settings': "Settings",
    'theme': "Theme",
    'selectScenario': "Select Scenario",
    'stepLabel': "STEP",
    'doneBtn': "Done",
    'learnLbl': "Objective:",
    'summaryTitle': "Goal Reached!",
    'resetBtn': "Reset Lab",
    'finishLab': "Finish Lab",
    'nextScenario': "Next Scenario",
    's1_title': "1. The Taller Neighbours",
    's1_obj':
        "Arrange a line of children of different heights so that the numbers below them match a target sequence.",
    's1_step1_task':
        "Observe the children and the numbers. DRAG a tall child between two shorter ones.",
    's1_step1_out':
        "Notice how the number represents how many taller neighbors they have.",
    's1_step2_task':
        "DRAG and DROP to match the target sequence: 0, 1, 2, 1, 0.",
    's1_step2_out':
        "You matched the pattern! Shortest can have '2', tallest always has '0'.",
    's1_hud1':
        "Drag children to swap positions and change their neighbor count.",
    's1_hud2': "Match the target: 0, 1, 2, 1, 0.",
    's2_title': "2. Supercell Hunter",
    's2_obj':
        "Identify 'supercells'—numbers strictly larger than their immediate neighbors.",
    's2_step1_task':
        "A supercell is bigger than its neighbors. CLICK the block with 626.",
    's2_step1_out':
        "Correct! 626 is a supercell because it's greater than 577 and 345.",
    's2_step2_task': "Now, CLICK on the block with 200.",
    's2_step2_out':
        "Incorrect! 200 is smaller than 577, so it's not a supercell.",
    's2_step3_task': "Find and CLICK all the supercells in the new grid.",
    's2_step3_out': "Found them! The peaks in the sequence.",
    's2_step4_task': "CLICK the 'CHECK' button to verify.",
    's2_step4_out':
        "Great job! A supercell is always a 'peak'. The largest number is always one.",
    's2_hud1': "Click block '626'.",
    's2_hud2': "Click block '200'.",
    's2_hud3': "Select all supercells.",
    's2_hud4': "Click Check.",
    's3_title': "3. The Kaprekar Machine",
    's3_obj':
        "Follow the Kaprekar process on a 4-digit number to find the magic constant.",
    's3_step1_task': "Number 6382 is loaded. CLICK 'START'.",
    's3_step1_out':
        "Digits sort to Largest (8632) and Smallest (2368), then subtract.",
    's3_step2_task': "Observe the first result (6264).",
    's3_step2_out': "The output becomes the new input.",
    's3_step3_task': "CLICK 'REPEAT' to cycle the machine.",
    's3_step3_out': "The process continues with the new digits.",
    's3_step4_task':
        "Continue clicking 'REPEAT' until the output stops changing.",
    's3_step4_out': "6174 is the Kaprekar Constant! It loops into itself.",
    's3_hud1': "Click START to begin.",
    's3_hud2': "Watch the machine sort and subtract.",
    's3_hud3': "Click REPEAT.",
    's3_hud4': "Keep repeating until it stays 6174.",
    's4_title': "4. Maximum Supercells",
    's4_obj':
        "Arrange 9 numbers on a 3x3 grid to maximize the Supercell Score.",
    's4_step1_task':
        "DRAG tiles from the rack to the grid to create supercells.",
    's4_step1_out':
        "Tiles glow blue when they are larger than all orthogonal neighbors.",
    's4_step2_task':
        "Experiment with corners and centers to maximize the score.",
    's4_step2_out': "Placing large numbers away from each other helps.",
    's4_step3_task': "Try to achieve the maximum score of 5.",
    's4_step3_out': "You got 5! You mastered spatial number logic.",
    's4_hud1': "Drag tiles to the grid.",
    's4_hud2': "Strategize to get more blue tiles.",
    's4_hud3': "Reach a score of 5.",
    's5_title': "5. The Collatz Coaster",
    's5_obj': "Explore the Collatz Conjecture: Even ÷ 2, Odd × 3 + 1.",
    's5_step1_task': "Enter '12' in the launcher and CLICK 'LAUNCH'.",
    's5_step1_out': "The ball travels down (Even ÷ 2) and up (Odd × 3 + 1).",
    's5_step2_task': "Observe the ball's journey until it loops.",
    's5_step2_out': "It entered the famous 4 → 2 → 1 loop.",
    's5_step3_task': "Try a new starting number (e.g., 27) and LAUNCH.",
    's5_step3_out':
        "Every number tested eventually falls into 4-2-1. Unsolved math!",
    's5_hud1': "Ensure 12 is in the box and Launch.",
    's5_hud2': "Watch the sequence unfold.",
    's5_hud3': "Try another number!",
  },
  'hi': {
    'appTitle': "संख्या पहेलियाँ और तार्किक कटौती",
    'appSubtitle': "कक्षा 6 • संख्याओं का खेल",
    'enterLab': "सिमुलेशन दर्ज करें",
    'settings': "सेटिंग्स",
    'theme': "थीम",
    'selectScenario': "परिदृश्य चुनें",
    'stepLabel': "चरण",
    'doneBtn': "पूर्ण",
    'learnLbl': "उद्देश्य:",
    'summaryTitle': "लक्ष्य प्राप्त हुआ!",
    'resetBtn': "रीसेट करें",
    'finishLab': "समाप्त करें",
    'nextScenario': "अगला परिदृश्य",
    's1_title': "1. लम्बे पड़ोसी",
    's1_obj':
        "विभिन्न ऊंचाइयों के बच्चों को व्यवस्थित करें ताकि उनके नीचे की संख्या लक्ष्य क्रम से मेल खाए।",
    's1_step1_task':
        "बच्चों और संख्याओं का निरीक्षण करें। दो छोटे बच्चों के बीच एक लंबा बच्चा खींचें।",
    's1_step1_out':
        "ध्यान दें कि संख्या यह दर्शाती है कि उनके कितने लम्बे पड़ोसी हैं।",
    's1_step2_task':
        "लक्ष्य क्रम से मेल खाने के लिए खींचें और छोड़ें: 0, 1, 2, 1, 0.",
    's1_step2_out': "आपने पैटर्न का मिलान कर लिया!",
    's1_hud1': "बच्चों की स्थिति बदलने के लिए उन्हें खींचें।",
    's1_hud2': "लक्ष्य का मिलान करें: 0, 1, 2, 1, 0.",
    's2_title': "2. सुपरसेल हंटर",
    's2_obj':
        "'सुपरसेल' को पहचानें—वे संख्याएँ जो अपने निकटतम पड़ोसियों से बड़ी हैं।",
    's2_step1_task':
        "एक सुपरसेल अपने पड़ोसियों से बड़ा होता है। 626 वाले ब्लॉक पर क्लिक करें।",
    's2_step1_out': "सही! 626 एक सुपरसेल है क्योंकि यह 577 और 345 से बड़ा है।",
    's2_step2_task': "अब, 200 वाले ब्लॉक पर क्लिक करें।",
    's2_step2_out': "गलत! 200, 577 से छोटा है, इसलिए यह सुपरसेल नहीं है।",
    's2_step3_task': "नए ग्रिड में सभी सुपरसेल ढूंढें और क्लिक करें।",
    's2_step3_out': "ढूंढ लिया! अनुक्रम में चोटियाँ।",
    's2_step4_task': "सत्यापित करने के लिए 'चेक' बटन पर क्लिक करें।",
    's2_step4_out': "बहुत बढ़िया! सबसे बड़ी संख्या हमेशा एक सुपरसेल होती है।",
    's2_hud1': "ब्लॉक '626' पर क्लिक करें।",
    's2_hud2': "ब्लॉक '200' पर क्लिक करें।",
    's2_hud3': "सभी सुपरसेल चुनें।",
    's2_hud4': "चेक पर क्लिक करें।",
    's3_title': "3. काप्रेकर मशीन",
    's3_obj':
        "जादुई स्थिरांक खोजने के लिए 4 अंकों की संख्या पर काप्रेकर प्रक्रिया का पालन करें।",
    's3_step1_task': "संख्या 6382 लोड है। 'स्टार्ट' पर क्लिक करें।",
    's3_step1_out':
        "अंक सबसे बड़े (8632) और सबसे छोटे (2368) में क्रमबद्ध होते हैं, फिर घटते हैं।",
    's3_step2_task': "पहला परिणाम (6264) देखें।",
    's3_step2_out': "आउटपुट नया इनपुट बन जाता है।",
    's3_step3_task': "मशीन को चक्रित करने के लिए 'रिपीट' पर क्लिक करें।",
    's3_step3_out': "प्रक्रिया नए अंकों के साथ जारी रहती है।",
    's3_step4_task':
        "तब तक 'रिपीट' पर क्लिक करना जारी रखें जब तक आउटपुट बदलना बंद न हो जाए।",
    's3_step4_out': "6174 काप्रेकर स्थिरांक है!",
    's3_hud1': "शुरू करने के लिए स्टार्ट पर क्लिक करें।",
    's3_hud2': "मशीन को छांटते और घटाते हुए देखें।",
    's3_hud3': "रिपीट पर क्लिक करें।",
    's3_hud4': "तब तक दोहराते रहें जब तक यह 6174 न हो जाए।",
    's4_title': "4. अधिकतम सुपरसेल",
    's4_obj':
        "सुपरसेल स्कोर को अधिकतम करने के लिए 3x3 ग्रिड पर 9 नंबर व्यवस्थित करें।",
    's4_step1_task': "सुपरसेल बनाने के लिए रैक से ग्रिड तक टाइलें खींचें।",
    's4_step1_out':
        "टाइलें नीले रंग में चमकती हैं जब वे सभी पड़ोसियों से बड़ी होती हैं।",
    's4_step2_task':
        "स्कोर को अधिकतम करने के लिए कोनों और केंद्रों के साथ प्रयोग करें।",
    's4_step2_out': "बड़ी संख्याओं को एक-दूसरे से दूर रखने से मदद मिलती है।",
    's4_step3_task': "अधिकतम 5 का स्कोर प्राप्त करने का प्रयास करें।",
    's4_step3_out': "आपको 5 मिल गए!",
    's4_hud1': "टाइलें ग्रिड पर खींचें।",
    's4_hud2': "अधिक नीली टाइलें प्राप्त करने के लिए रणनीति बनाएं।",
    's4_hud3': "5 के स्कोर तक पहुँचें।",
    's5_title': "5. द कोलैट्ज़ कोस्टर",
    's5_obj': "कोलैट्ज़ अनुमान का अन्वेषण करें: सम ÷ 2, विषम × 3 + 1।",
    's5_step1_task': "लॉन्चर में '12' दर्ज करें और 'लॉन्च' पर क्लिक करें।",
    's5_step1_out': "गेंद नीचे (सम ÷ 2) और ऊपर (विषम × 3 + 1) जाती है।",
    's5_step2_task': "गेंद की यात्रा तब तक देखें जब तक वह लूप न हो जाए।",
    's5_step2_out': "यह प्रसिद्ध 4 → 2 → 1 लूप में प्रवेश कर गया।",
    's5_step3_task': "एक नया प्रारंभिक नंबर आज़माएं और लॉन्च करें।",
    's5_step3_out':
        "परीक्षण की गई प्रत्येक संख्या अंततः 4-2-1 में गिर जाती है।",
    's5_hud1': "बॉक्स में 12 सुनिश्चित करें और लॉन्च करें।",
    's5_hud2': "अनुक्रम को सामने आते हुए देखें।",
    's5_hud3': "एक और नंबर आज़माएं!",
  },
};

String t(String lang, String key) {
  return translations[lang]?[key] ?? translations['en']![key] ?? key;
}

// --- डेटा मॉडल (DATA MODELS) ---

class ScenarioStep {
  final String task;
  final String outcome;
  final String hud;
  ScenarioStep(this.task, this.outcome, this.hud);
}

class S1Child {
  int id;
  int h;
  S1Child(this.id, this.h);
}

class S5Node {
  double x, y;
  int val;
  S5Node(this.x, this.y, this.val);
}

// --- मुख्य विजेट (MAIN WIDGET) ---

class Cl6M_Ch3_A1_NumberPuzzlesLogicalDeduction extends StatefulWidget {
  const Cl6M_Ch3_A1_NumberPuzzlesLogicalDeduction({super.key});

  @override
  State<Cl6M_Ch3_A1_NumberPuzzlesLogicalDeduction> createState() =>
      _Cl6M_Ch3_A1_NumberPuzzlesLogicalDeductionState();
}

class _Cl6M_Ch3_A1_NumberPuzzlesLogicalDeductionState
    extends State<Cl6M_Ch3_A1_NumberPuzzlesLogicalDeduction>
    with TickerProviderStateMixin {
  final GlobalKey _canvasKey = GlobalKey();
  late AnimationController _gameLoop;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // (Layout State)
  bool _isSidebarOpen = true;
  bool _isCurtainOpen = true;
  bool _showSuccessPopup = false;
  String _lang = 'en';

  // (Camera & Interaction State)
  double _panX = 0, _panY = 0, _zoom = 1.0;
  bool _isInteracting = false;

  double _baseZoom = 1.0;

  // (Simulation Global State)
  int _scenario = 1;
  int _step = 0;
  bool _animating = false;

  // (Active Drag)
  String? _activeDragEntity;
  Offset _dragWorldPos = Offset.zero;
  int _s1DragIndex = -1;

  // (S1 Data)
  List<S1Child> s1Children = [];
  final List<int> s1Target = [0, 1, 2, 1, 0];

  // (S2 Data)
  List<int> s2Grid1 = [200, 577, 626, 345, 790];
  List<int> s2Grid2 = [6828, 670, 9435, 3780, 3708, 7308, 8000, 5583, 52];
  Map<int, int> s2State1 = {};
  Map<int, int> s2State2 = {};

  // (S3 Data)
  String s3Num = "6382";
  int s3Phase = 0;
  double s3Progress = 0.0;
  String s3L = "", s3S = "", s3Res = "";

  // (S4 Data)
  List<int?> s4Rack = [];
  List<int?> s4Grid = [];

  // (S5 Data)
  List<S5Node> s5Path = [];
  int s5PathIdx = 0;
  Offset s5BallPos = Offset.zero;
  int s5Val = 0;
  final TextEditingController _collatzController = TextEditingController(
    text: "12",
  );

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _gameLoop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _gameLoop.addListener(() {
      setState(() {}); // CustomPainter
    });

    _loadScenario(1);
  }

  @override
  void dispose() {
    _gameLoop.dispose();
    _audioPlayer.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // --- (AUDIO HELPER) ---
  void _playSound(String type) async {
    String url = '';
    switch (type) {
      case 'success':
        url = 'audio/class6/math/mixkit_2013.mp3';
        break;
      case 'error':
        url = 'audio/class6/math/mixkit_2955.mp3';
        break;
      case 'pop':
        url = 'audio/class6/math/click.mp3';
        break;
      case 'tick':
        url = 'audio/class6/math/shutter.mp3';
        break;
      case 'snap':
        url = 'audio/class6/math/click.mp3';
        break;
      case 'enter':
        url = 'audio/class6/math/success.mp3';
        break;
    }
    if (url.isNotEmpty) {
      await _audioPlayer.play(AssetSource(url));
    }
  }

  // --- (LOGIC HELPER METHODS) ---

  List<ScenarioStep> _getStepsForScenario(int scenario) {
    int numSteps = [0, 2, 4, 4, 3, 3][scenario];
    List<ScenarioStep> steps = [];
    for (int i = 1; i <= numSteps; i++) {
      steps.add(
        ScenarioStep(
          t(_lang, 's${scenario}_step${i}_task'),
          t(_lang, 's${scenario}_step${i}_out'),
          t(_lang, 's${scenario}_hud$i'),
        ),
      );
    }
    return steps;
  }

  void _loadScenario(int id) {
    _scenario = id;
    _step = 0;
    _animating = false;
    _activeDragEntity = null;
    _showSuccessPopup = false;
    _zoom = 1.0;
    _panX = 0;
    _panY = 0;

    s1Children = [
      S1Child(1, 2),
      S1Child(2, 5),
      S1Child(3, 1),
      S1Child(4, 4),
      S1Child(5, 3),
    ];
    s2State1.clear();
    s2State2.clear();
    s3Num = "6382";
    s3Phase = 0;
    s3Progress = 0;
    s4Grid = List.filled(9, null);
    s4Rack = [105, 234, 381, 492, 576, 618, 795, 840, 927];
    s5Path.clear();

    _playSound('pop');
  }

  void _advanceStep() {
    setState(() {
      _step++;
    });
  }

  void _checkScenarioSuccess() {
    int maxSteps = _getStepsForScenario(_scenario).length;
    setState(() {
      _step = maxSteps;
      if (_scenario == 5) {
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            _showSuccessPopup = true;
          });
          _playSound('success');
        });
      }
    });
  }

  // (S1 Calculations)
  List<int> _calcNeighborsTaller(List<S1Child> arr) {
    List<int> res = [];
    for (int i = 0; i < arr.length; i++) {
      int taller = 0;
      if (i > 0 && arr[i - 1].h > arr[i].h) taller++;
      if (i < arr.length - 1 && arr[i + 1].h > arr[i].h) taller++;
      res.add(taller);
    }
    return res;
  }

  // (S2 Calculations)
  bool _isSupercellArr(List<int> arr, int i) {
    int val = arr[i];
    int left = i > 0 ? arr[i - 1] : -999999;
    int right = i < arr.length - 1 ? arr[i + 1] : -999999;
    return val > left && val > right;
  }

  // (S4 Calculations)
  bool _isSupercell(List<int?> grid, int i) {
    int? val = grid[i];
    if (val == null) return false;
    int row = i ~/ 3;
    int col = i % 3;
    List<int?> n = [];
    if (row > 0) n.add(grid[i - 3]);
    if (row < 2) n.add(grid[i + 3]);
    if (col > 0) n.add(grid[i - 1]);
    if (col < 2) n.add(grid[i + 1]);

    for (int? neighbor in n) {
      if (neighbor != null && val <= neighbor) return false;
    }
    return true;
  }

  // (Actions)
  void _triggerAction(String action) async {
    if (_animating) return;

    if (action == 's2_check') {
      bool c1 = s2State2[0] == 1;
      bool c2 = s2State2[2] == 1;
      bool c3 = s2State2[6] == 1;
      int correct = (c1 ? 1 : 0) + (c2 ? 1 : 0) + (c3 ? 1 : 0);
      int wrong = 0;
      for (int i = 0; i < 9; i++) {
        if (!_isSupercellArr(s2Grid2, i) && s2State2[i] == 1) wrong++;
      }

      if (correct == 3 && wrong == 0) {
        _playSound('success');
        _checkScenarioSuccess();
      } else {
        _playSound('error');
      }
    } else if (action == 's3_start') {
      _animating = true;
      _playSound('tick');
      String numStr = s3Num.padLeft(4, '0');
      List<String> arr = numStr.split('')..sort();
      s3S = arr.join('');
      s3L = arr.reversed.join('');
      s3Res = (int.parse(s3L) - int.parse(s3S)).toString().padLeft(4, '0');

      // (Phase 1)
      s3Phase = 1;
      await _animateValue(
        1.0,
        const Duration(milliseconds: 1000),
        (v) => s3Progress = v,
      );

      // (Phase 2)
      s3Phase = 2;
      _playSound('tick');
      await _animateValue(
        1.0,
        const Duration(milliseconds: 800),
        (v) => s3Progress = v,
      );

      // (Phase 3)
      s3Phase = 3;
      _playSound('snap');
      await _animateValue(
        1.0,
        const Duration(milliseconds: 600),
        (v) => s3Progress = v,
      );

      _animating = false;
      s3Num = s3Res;
      if (_step == 0) _advanceStep();
    } else if (action == 's3_repeat') {
      if (s3Res == "6174") {
        _playSound('success');
        if (_step == 2) {
          _advanceStep();
          Future.delayed(const Duration(seconds: 1), _checkScenarioSuccess);
        }
        return;
      }
      if (_step == 1) _advanceStep();
      _triggerAction('s3_start');
    }
  }

  Future<void> _animateValue(
    double target,
    Duration duration,
    Function(double) onUpdate,
  ) async {
    AnimationController ctrl = AnimationController(
      vsync: this,
      duration: duration,
    );
    Animation<double> anim = Tween<double>(
      begin: 0.0,
      end: target,
    ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeInOut));

    ctrl.addListener(() {
      setState(() {
        onUpdate(anim.value);
      });
    });

    await ctrl.forward();
    ctrl.dispose();
  }

  void _launchCollatz() async {
    if (_animating) return;
    int? input = int.tryParse(_collatzController.text);
    if (input == null || input < 1) {
      _playSound('error');
      return;
    }

    _animating = true;
    _playSound('pop');

    if (_step == 0 && input == 12) _advanceStep();

    s5Path.clear();
    double cx = 0, cy = 0;
    int val = input;
    s5Path.add(S5Node(cx, cy, val));

    int sanity = 0;
    while (val != 1 && sanity < 500) {
      if (val % 2 == 0) {
        val = val ~/ 2;
        cx += 120;
        cy += 80;
      } else {
        val = val * 3 + 1;
        cx += 120;
        cy -= 80;
      }
      s5Path.add(S5Node(cx, cy, val));
      sanity++;
    }

    s5PathIdx = 0;
    s5BallPos = Offset(s5Path[0].x, s5Path[0].y);
    s5Val = s5Path[0].val;

    // (Auto fit math)
    if (s5Path.isNotEmpty) {
      double minX = s5Path.map((p) => p.x).reduce(math.min);
      double maxX = s5Path.map((p) => p.x).reduce(math.max);
      double minY = s5Path.map((p) => p.y).reduce(math.min);
      double maxY = s5Path.map((p) => p.y).reduce(math.max);

      double pW = math.max(maxX - minX, 1000);
      double pH = math.max(maxY - minY, 600);

      RenderBox? box =
          _canvasKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        double scaleX = (box.size.width - 100) / pW;
        double scaleY = (box.size.height - 250) / pH;
        _zoom = math.max(0.05, math.min(1.2, math.min(scaleX, scaleY)));
        _panX = -((minX + maxX) / 2) * _zoom;
        _panY = -((minY + maxY) / 2) * _zoom + 40;
      }
    }

    int animDurationMs = math.max(20, math.min(500, 10000 ~/ s5Path.length));

    for (int i = 0; i < s5Path.length - 1; i++) {
      S5Node p1 = s5Path[i];
      S5Node p2 = s5Path[i + 1];

      _playSound('tick');
      await _animateValue(1.0, Duration(milliseconds: animDurationMs), (p) {
        s5BallPos = Offset(p1.x + (p2.x - p1.x) * p, p1.y + (p2.y - p1.y) * p);
      });
      s5PathIdx++;
      s5Val = s5Path[s5PathIdx].val;
    }

    _animating = false;
    _playSound('success');
    if (_step == 1 && input == 12) {
      _advanceStep();
    } else if (_step == 2 && input != 12) {
      _advanceStep();
      Future.delayed(const Duration(seconds: 1), _checkScenarioSuccess);
    }
  }

  // --- (GESTURE & TRANSFORM HELPER) ---
  Offset _screenToWorld(Offset localScreen) {
    RenderBox? box =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return Offset.zero;
    double cx = box.size.width / 2;
    double cy = box.size.height / 2;
    double worldX = (localScreen.dx - cx - _panX) / _zoom;
    double worldY = (localScreen.dy - cy - _panY) / _zoom;
    return Offset(worldX, worldY);
  }

  bool _hitTestBox(double x, double y, double w, double h, Offset worldPt) {
    return worldPt.dx > x &&
        worldPt.dx < x + w &&
        worldPt.dy > y &&
        worldPt.dy < y + h;
  }

  void _onScaleStart(ScaleStartDetails details) {
    _baseZoom = _zoom;
    _isInteracting = false; // Reset interaction flag on new touch

    Offset worldPt = _screenToWorld(details.localFocalPoint);

    if (_scenario == 1) {
      double bx = -350, by = 100, slotW = 100, gap = 40;
      for (int i = 0; i < 5; i++) {
        double cx = bx + 40 + i * (slotW + gap);
        if (_hitTestBox(cx, by - 200, slotW, 200, worldPt)) {
          _isInteracting = true; // Lock panning to grab object
          setState(() {
            _activeDragEntity = 's1_child';
            _s1DragIndex = i;
            _dragWorldPos = worldPt;
          });
          _playSound('tick');
          break;
        }
      }
    } else if (_scenario == 2) {
      if (_step <= 1) {
        double g1X = -350, g1Y = -150, bSize = 100, gap = 40;
        for (int i = 0; i < 5; i++) {
          if (_hitTestBox(
            g1X + i * (bSize + gap),
            g1Y,
            bSize,
            bSize,
            worldPt,
          )) {
            _isInteracting = true;
            if (_step == 0) {
              if (i == 2) {
                setState(() => s2State1[i] = 1);
                _playSound('success');
                Future.delayed(const Duration(milliseconds: 800), _advanceStep);
              } else {
                setState(() => s2State1[i] = -1);
                _playSound('error');
                Future.delayed(
                  const Duration(milliseconds: 500),
                  () => setState(() => s2State1[i] = 0),
                );
              }
            } else if (_step == 1) {
              if (i == 0) {
                setState(() => s2State1[i] = -1);
                _playSound('success');
                Future.delayed(const Duration(milliseconds: 800), _advanceStep);
              } else {
                setState(() => s2State1[i] = -1);
                _playSound('error');
                Future.delayed(
                  const Duration(milliseconds: 500),
                  () => setState(() => s2State1[i] = 0),
                );
              }
            }
          }
        }
      } else {
        double g2X = -480, g2Y = -50, bSize = 90, gap = 20;
        for (int i = 0; i < 9; i++) {
          if (_hitTestBox(
            g2X + i * (bSize + gap),
            g2Y,
            bSize,
            bSize,
            worldPt,
          )) {
            _isInteracting = true;
            if (_step == 2) {
              if (_isSupercellArr(s2Grid2, i)) {
                setState(() => s2State2[i] = s2State2[i] == 1 ? 0 : 1);
                _playSound('tick');

                int correct =
                    (s2State2[0] == 1 ? 1 : 0) +
                    (s2State2[2] == 1 ? 1 : 0) +
                    (s2State2[6] == 1 ? 1 : 0);
                if (correct == 3) {
                  _playSound('success');
                  Future.delayed(
                    const Duration(milliseconds: 500),
                    _advanceStep,
                  );
                }
              } else {
                setState(() => s2State2[i] = -1);
                _playSound('error');
                Future.delayed(
                  const Duration(milliseconds: 500),
                  () => setState(() => s2State2[i] = 0),
                );
              }
            }
          }
        }
        if ((_step == 2 || _step == 3) &&
            _hitTestBox(-100, g2Y + 160, 200, 60, worldPt)) {
          _isInteracting = true;
          _triggerAction('s2_check');
        }
      }
    } else if (_scenario == 3) {
      double btnY = 200;
      if (_step == 0 && _hitTestBox(-80, btnY, 160, 60, worldPt)) {
        _isInteracting = true;
        _triggerAction('s3_start');
      } else if (_step >= 1 &&
          s3Phase == 3 &&
          _hitTestBox(-80, btnY, 160, 60, worldPt)) {
        _isInteracting = true;
        _triggerAction('s3_repeat');
      }
    } else if (_scenario == 4) {
      double gX = -180, gY = -280, tSize = 120, gap = 10;
      for (int i = 0; i < 9; i++) {
        double cx = gX + (i % 3) * (tSize + gap);
        double cy = gY + (i ~/ 3) * (tSize + gap);
        if (s4Grid[i] != null && _hitTestBox(cx, cy, tSize, tSize, worldPt)) {
          _isInteracting = true;
          setState(() {
            _activeDragEntity = 'g_$i';
            _dragWorldPos = worldPt;
          });
          _playSound('tick');
        }
      }
      double rX = -400, rY = 160, rSize = 80;
      for (int i = 0; i < 9; i++) {
        double cx = rX + i * (rSize + gap);
        if (s4Rack[i] != null && _hitTestBox(cx, rY, rSize, rSize, worldPt)) {
          _isInteracting = true;
          setState(() {
            _activeDragEntity = 'r_$i';
            _dragWorldPos = worldPt;
          });
          _playSound('tick');
        }
      }
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_activeDragEntity != null) {
      setState(() {
        _dragWorldPos = _screenToWorld(details.localFocalPoint);
      });
    } else if (!_isInteracting) {
      // Free Canvas Pan and Zoom logic!
      setState(() {
        _zoom = (_baseZoom * details.scale).clamp(0.2, 5.0);
        // We use += for focalPointDelta so it smoothly translates frame-by-frame
        _panX += details.focalPointDelta.dx;
        _panY += details.focalPointDelta.dy;
      });
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_activeDragEntity == 's1_child') {
      double bx = -350, slotW = 100, gap = 40;
      int dropIdx = math.max(
        0,
        math.min(4, ((_dragWorldPos.dx - (bx + 40)) / (slotW + gap)).round()),
      );

      setState(() {
        S1Child child = s1Children.removeAt(_s1DragIndex);
        s1Children.insert(dropIdx, child);
        _playSound('snap');

        List<int> stats = _calcNeighborsTaller(s1Children);
        bool match = true;
        for (int i = 0; i < 5; i++) {
          if (stats[i] != s1Target[i]) match = false;
        }

        if (match && _step <= 1) {
          _playSound('success');
          _advanceStep();
          if (_step == 1) {
            _advanceStep();
            Future.delayed(const Duration(seconds: 1), _checkScenarioSuccess);
          }
        }

        _activeDragEntity = null;
        _s1DragIndex = -1;
      });
    } else if (_activeDragEntity != null &&
        (_activeDragEntity!.startsWith('r_') ||
            _activeDragEntity!.startsWith('g_'))) {
      bool isGrid = _activeDragEntity!.startsWith('g_');
      int sourceIdx = int.parse(_activeDragEntity!.split('_')[1]);
      int val = isGrid ? s4Grid[sourceIdx]! : s4Rack[sourceIdx]!;

      double gX = -180, gY = -280, tSize = 120, gap = 10;
      bool dropped = false;

      for (int i = 0; i < 9; i++) {
        double cx = gX + (i % 3) * (tSize + gap);
        double cy = gY + (i ~/ 3) * (tSize + gap);
        if (_hitTestBox(
          cx - 10,
          cy - 10,
          tSize + 20,
          tSize + 20,
          _dragWorldPos,
        )) {
          dropped = true;
          if (s4Grid[i] == null) {
            setState(() {
              s4Grid[i] = val;
              if (isGrid) {
                s4Grid[sourceIdx] = null;
              } else {
                s4Rack[sourceIdx] = null;
              }
            });
            _playSound('snap');
          } else {
            _playSound('error');
          }
          break;
        }
      }

      if (!dropped) {
        double rX = -400, rY = 160, rSize = 80;
        for (int i = 0; i < 9; i++) {
          double cx = rX + i * (rSize + gap);
          if (_hitTestBox(
            cx - 10,
            rY - 10,
            rSize + 20,
            rSize + 20,
            _dragWorldPos,
          )) {
            dropped = true;
            if (s4Rack[i] == null) {
              setState(() {
                s4Rack[i] = val;
                if (isGrid) {
                  s4Grid[sourceIdx] = null;
                } else {
                  s4Rack[sourceIdx] = null;
                }
              });
              _playSound('snap');
            } else {
              _playSound('error');
            }
            break;
          }
        }
        if (!dropped) {
          for (int i = 0; i < 9; i++) {
            if (s4Rack[i] == null) {
              setState(() {
                s4Rack[i] = val;
                if (isGrid) {
                  s4Grid[sourceIdx] = null;
                } else {
                  s4Rack[sourceIdx] = null;
                }
              });
              break;
            }
          }
          _playSound('pop');
        }
      }

      int score = 0;
      for (int i = 0; i < 9; i++) {
        if (_isSupercell(s4Grid, i)) score++;
      }

      if (_step == 0 && s4Grid.any((v) => v != null)) {
        _advanceStep();
      } else if (_step == 1 && score >= 2) {
        _advanceStep();
      } else if (_step == 2 && score == 5 && !_animating) {
        _animating = true;
        Future.delayed(const Duration(seconds: 1), () {
          _animating = false;
          _advanceStep();
          Future.delayed(const Duration(seconds: 1), _checkScenarioSuccess);
        });
      }

      setState(() {
        _activeDragEntity = null;
      });
    }
  }

  // --- (UI BUILDING) ---

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double sidebarWidth = math.max(300, constraints.maxWidth * 0.35);

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
          },
          child: Scaffold(
            body: Stack(
              children: [
                // (CANVAS AREA)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  left: _isSidebarOpen ? sidebarWidth : 0,
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: Container(
                    color: const Color(0xFF0F172A), // Dark bg
                    child: Stack(
                      children: [
                        // (Listener and GestureDetector for Mouse Wheel + Touch/Drag Pan/Zoom)
                        Positioned.fill(
                          child: Listener(
                            onPointerSignal: (PointerSignalEvent event) {
                              if (event is PointerScrollEvent &&
                                  !_isInteracting) {
                                // Support zooming via mouse scroll wheel
                                setState(() {
                                  double zoomChange = event.scrollDelta.dy > 0
                                      ? -0.1
                                      : 0.1;
                                  _zoom = (_zoom + zoomChange).clamp(0.2, 5.0);
                                });
                              }
                            },
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
                              onScaleUpdate: _onScaleUpdate,
                              onScaleEnd: _onScaleEnd,
                              child: ClipRect(
                                child: CustomPaint(
                                  key: _canvasKey,
                                  painter: LabPainter(
                                    scenario: _scenario,
                                    step: _step,
                                    panX: _panX,
                                    panY: _panY,
                                    zoom: _zoom,
                                    activeDragEntity: _activeDragEntity,
                                    dragWorldPos: _dragWorldPos,
                                    s1DragIndex: _s1DragIndex,
                                    s1Children: s1Children,
                                    s1Target: s1Target,
                                    s1CalcNeighborsTaller: _calcNeighborsTaller,
                                    s2Grid1: s2Grid1,
                                    s2Grid2: s2Grid2,
                                    s2State1: s2State1,
                                    s2State2: s2State2,
                                    s3Num: s3Num,
                                    s3Phase: s3Phase,
                                    s3Progress: s3Progress,
                                    s3L: s3L,
                                    s3S: s3S,
                                    s3Res: s3Res,
                                    s4Rack: s4Rack,
                                    s4Grid: s4Grid,
                                    s4IsSupercell: _isSupercell,
                                    s5Path: s5Path,
                                    s5BallPos: s5BallPos,
                                    s5Val: s5Val,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // HUD
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: _buildHUD(),
                        ),

                        // ZOOM & PAN UI CONTROLS (Right side floating buttons)
                        Positioned(
                          right: 24,
                          top: 84,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 8),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(
                                      () =>
                                          _zoom = (_zoom + 0.2).clamp(0.2, 5.0),
                                    );
                                    _playSound('tick');
                                  },
                                  tooltip: "Zoom In",
                                ),
                                const Divider(height: 1, color: Colors.white24),
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(
                                      () =>
                                          _zoom = (_zoom - 0.2).clamp(0.2, 5.0),
                                    );
                                    _playSound('tick');
                                  },
                                  tooltip: "Zoom Out",
                                ),
                                const Divider(height: 1, color: Colors.white24),
                                IconButton(
                                  icon: const Icon(
                                    Icons.center_focus_strong,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _zoom = 1.0;
                                      _panX = 0;
                                      _panY = 0;
                                    });
                                    _playSound('pop');
                                  },
                                  tooltip: "Center Camera",
                                ),
                              ],
                            ),
                          ),
                        ),

                        // (Collatz Overlay UI)
                        if (_scenario == 5)
                          Positioned(
                            top: 24,
                            left: 0,
                            right: 80, // Offset to not hit zoom controls
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF1E293B,
                                  ).withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.white24),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black45,
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.rocket_launch,
                                      color: Color(0xFF6366F1),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      "Start Number:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 80,
                                      child: TextField(
                                        controller: _collatzController,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding: const EdgeInsets.all(
                                            8,
                                          ),
                                          filled: true,
                                          fillColor: const Color(0xFF0F172A),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton(
                                      onPressed: _launchCollatz,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF6366F1,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        "LAUNCH",
                                        style: TextStyle(
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

                        // (Next Scenario Button)
                        if (_step == _getStepsForScenario(_scenario).length &&
                            _scenario < 5)
                          Positioned(
                            bottom: 24,
                            right: 24,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _loadScenario(_scenario + 1);
                              },
                              icon: const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                              ),
                              label: Text(
                                t(_lang, 'nextScenario'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 8,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  left: _isSidebarOpen ? 0 : -sidebarWidth,
                  top: 0,
                  bottom: 0,
                  width: sidebarWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF1E293B,
                      ).withOpacity(0.95), // (Panel Background)
                      border: const Border(
                        right: BorderSide(color: Colors.white12),
                      ),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 10),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // (Header)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 60,
                                  left: 16,
                                  right: 16,
                                  bottom: 16,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.extension,
                                          color: Color(0xFF6366F1),
                                          size: 28,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                t(_lang, 'appTitle'),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                t(_lang, 'appSubtitle'),
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        IconButton(
                                          icon: Row(
                                            children: [
                                              const Icon(
                                                Icons.language,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _lang.toUpperCase(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _lang = _lang == 'en'
                                                  ? 'hi'
                                                  : 'en';
                                            });
                                            _playSound('pop');
                                          },
                                          tooltip: "Toggle Language",
                                        ),
                                        IconButton(
                                          icon: Row(
                                            children: [
                                              const Icon(
                                                Icons.refresh,
                                                color: Colors.redAccent,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                t(_lang, 'resetBtn'),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.redAccent,
                                                ),
                                              ),
                                            ],
                                          ),
                                          onPressed: () {
                                            _loadScenario(1);
                                            _isCurtainOpen = true;
                                          },
                                          tooltip: "Reset Lab",
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1, color: Colors.white12),

                              // (Content)
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t(_lang, 'selectScenario').toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white60,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0F172A),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.white12,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<int>(
                                          value: _scenario,
                                          isExpanded: true,
                                          dropdownColor: const Color(
                                            0xFF1E293B,
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          items: [1, 2, 3, 4, 5]
                                              .map(
                                                (id) => DropdownMenuItem(
                                                  value: id,
                                                  child: Text(
                                                    t(_lang, 's${id}_title'),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (v) {
                                            if (v != null) _loadScenario(v);
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // (Objective Card)
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF0F172A,
                                        ).withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white12,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.track_changes,
                                                color: Color(0xFFF43F5E),
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                t(_lang, 'learnLbl'),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            t(_lang, 's${_scenario}_obj'),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // (Steps list)
                                    ..._buildSteps(),
                                  ],
                                ),
                              ),

                              const Spacer(),

                              // (Footer)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                color: const Color(0xFF0F172A),
                                child: const Text(
                                  "© ZeroScienceLab | Fall in Love with Math and Science",
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

                // (Menu Toggle Button - Fixed at Top Left)
                Positioned(
                  top: 16,
                  left: 16,
                  child: SafeArea(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSidebarOpen = !_isSidebarOpen;
                        });
                        _playSound('pop');
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isSidebarOpen ? Icons.menu_open : Icons.menu,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),

                // (Success Popup)
                if (_showSuccessPopup)
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
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF10B981,
                                      ).withOpacity(0.4),
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
                                t(_lang, 'summaryTitle'),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _scenario < 5
                                    ? "Great job! Ready for the next challenge?"
                                    : "You have successfully completed all number puzzles using logical deduction!",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton.icon(
                                onPressed: () {
                                  if (_scenario < 5) {
                                    _loadScenario(_scenario + 1);
                                  } else {
                                    _loadScenario(1);
                                  }
                                },
                                icon: Icon(
                                  _scenario < 5
                                      ? Icons.arrow_forward
                                      : Icons.refresh,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  _scenario < 5
                                      ? t(_lang, 'nextScenario')
                                      : t(_lang, 'finishLab'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _scenario < 5
                                      ? const Color(0xFF6366F1)
                                      : const Color(0xFFF59E0B),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
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

                // (Curtain Raiser)
                if (_isCurtainOpen)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeInOutCubic,
                    top: _isCurtainOpen ? 0 : -constraints.maxHeight,
                    left: 0,
                    right: 0,
                    height: constraints.maxHeight,
                    child: Container(
                      color: const Color(0xFF0F172A),
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.extension,
                                size: 80,
                                color: Color(0xFF6366F1),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                t(_lang, 'appTitle'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                t(_lang, 'appSubtitle'),
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white54,
                                ),
                              ),
                              const SizedBox(height: 48),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _isCurtainOpen = false;
                                  });
                                  _playSound('enter');
                                },
                                icon: const Icon(
                                  Icons.play_circle_fill,
                                  size: 28,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  t(_lang, 'enterLab'),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6366F1),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  elevation: 10,
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
      },
    );
  }

  // --- (SUB WIDGET BUILDERS) ---

  Widget _buildHUD() {
    List<ScenarioStep> steps = _getStepsForScenario(_scenario);
    String hudText = "";
    if (_step < steps.length) {
      hudText = steps[_step].hud;
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: hudText.isEmpty ? 0 : 1.0,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
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
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  hudText,
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
    );
  }

  List<Widget> _buildSteps() {
    List<ScenarioStep> steps = _getStepsForScenario(_scenario);
    List<Widget> widgets = [];

    for (int i = 0; i < steps.length; i++) {
      ScenarioStep s = steps[i];
      bool isPast = i < _step;
      bool isCurrent = i == _step;
      bool isFuture = i > _step;

      Color bgColor = isCurrent
          ? const Color(0xFF6366F1).withOpacity(0.1)
          : (isPast
                ? const Color(0xFF10B981).withOpacity(0.05)
                : const Color(0xFF1E293B).withOpacity(0.5));
      Color borderColor = isCurrent
          ? const Color(0xFF6366F1).withOpacity(0.5)
          : (isPast
                ? const Color(0xFF10B981).withOpacity(0.2)
                : Colors.white12);

      Widget iconObj = isPast
          ? const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 28)
          : Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCurrent
                    ? const Color(0xFF6366F1)
                    : const Color(0xFF334155),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  "${i + 1}",
                  style: TextStyle(
                    color: isCurrent ? Colors.white : Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );

      widgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              iconObj,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${t(_lang, 'stepLabel')} ${i + 1}",
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white54,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: "Task: ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF818CF8),
                            ),
                          ),
                          TextSpan(
                            text: s.task,
                            style: TextStyle(
                              color: isFuture ? Colors.white54 : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isPast) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF10B981).withOpacity(0.2),
                          ),
                        ),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: "Observation: ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF34D399),
                                ),
                              ),
                              TextSpan(
                                text: s.outcome,
                                style: const TextStyle(
                                  color: Color(0xFFA7F3D0),
                                ),
                              ),
                            ],
                          ),
                          style: const TextStyle(fontSize: 13),
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

// --- (CANVAS PAINTER) ---

class LabPainter extends CustomPainter {
  final int scenario;
  final int step;
  final double panX, panY, zoom;

  final String? activeDragEntity;
  final Offset dragWorldPos;
  final int s1DragIndex;

  final List<S1Child> s1Children;
  final List<int> s1Target;
  final List<int> Function(List<S1Child>) s1CalcNeighborsTaller;

  final List<int> s2Grid1;
  final List<int> s2Grid2;
  final Map<int, int> s2State1;
  final Map<int, int> s2State2;

  final String s3Num;
  final int s3Phase;
  final double s3Progress;
  final String s3L, s3S, s3Res;

  final List<int?> s4Rack;
  final List<int?> s4Grid;
  final bool Function(List<int?>, int) s4IsSupercell;

  final List<S5Node> s5Path;
  final Offset s5BallPos;
  final int s5Val;

  LabPainter({
    required this.scenario,
    required this.step,
    required this.panX,
    required this.panY,
    required this.zoom,
    required this.activeDragEntity,
    required this.dragWorldPos,
    required this.s1DragIndex,
    required this.s1Children,
    required this.s1Target,
    required this.s1CalcNeighborsTaller,
    required this.s2Grid1,
    required this.s2Grid2,
    required this.s2State1,
    required this.s2State2,
    required this.s3Num,
    required this.s3Phase,
    required this.s3Progress,
    required this.s3L,
    required this.s3S,
    required this.s3Res,
    required this.s4Rack,
    required this.s4Grid,
    required this.s4IsSupercell,
    required this.s5Path,
    required this.s5BallPos,
    required this.s5Val,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    if (scenario == 1) {
      _renderScenario1(canvas);
    } else if (scenario == 2) {
      _renderScenario2(canvas);
    } else if (scenario == 3) {
      _renderScenario3(canvas);
    } else if (scenario == 4) {
      _renderScenario4(canvas);
    } else if (scenario == 5) {
      _renderScenario5(canvas);
    }
    canvas.restore();
  }

  // (Draw Helpers)
  void _drawRoundedRect(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double r,
    Color fill,
    Color stroke, [
    double lw = 2,
  ]) {
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      Radius.circular(r),
    );
    if (fill != Colors.transparent) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = fill
          ..style = PaintingStyle.fill,
      );
    }
    if (stroke != Colors.transparent && lw > 0) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = lw,
      );
    }
  }

  void _drawCustomRoundedRect(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double tl,
    double tr,
    double br,
    double bl,
    Color fill,
    Color stroke, [
    double lw = 2,
  ]) {
    final RRect rrect = RRect.fromRectAndCorners(
      Rect.fromLTWH(x, y, w, h),
      topLeft: Radius.circular(tl),
      topRight: Radius.circular(tr),
      bottomLeft: Radius.circular(bl),
      bottomRight: Radius.circular(br),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = fill
        ..style = PaintingStyle.fill,
    );
    if (stroke != Colors.transparent && lw > 0) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = lw,
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

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y,
    double fontSize,
    Color color, {
    bool bold = false,
  }) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        fontFamily: 'monospace',
      ),
    );
    final tp = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  // SCENARIO 1
  void _drawPillarChild(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    bool isTarget,
  ) {
    Color bodyCol = isTarget
        ? const Color(0xFF818CF8)
        : const Color(0xFF38BDF8);
    _drawCustomRoundedRect(
      canvas,
      x,
      y - h,
      w,
      h,
      8,
      8,
      0,
      0,
      bodyCol,
      const Color(0xFF0F172A),
      4,
    );

    Paint pDark = Paint()..color = const Color(0xFF0F172A);
    canvas.drawCircle(Offset(x + w / 2 - 8, y - h + 20), 4, pDark);
    canvas.drawCircle(Offset(x + w / 2 + 8, y - h + 20), 4, pDark);

    Path smile = Path()
      ..addArc(
        Rect.fromCircle(center: Offset(x + w / 2, y - h + 32), radius: 6),
        0,
        math.pi,
      );
    canvas.drawPath(
      smile,
      Paint()
        ..color = pDark.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _renderScenario1(Canvas canvas) {
    double bx = -350, by = 100, bw = 700;
    _drawLine(canvas, bx, by, bx + bw, by, const Color(0xFF475569), 8); // ज़मीन

    _drawRoundedRect(
      canvas,
      bx + 100,
      -250,
      500,
      80,
      16,
      const Color(0xFF334155),
      const Color(0xFF0F172A),
      4,
    );
    _drawText(
      canvas,
      "TARGET SEQUENCE",
      0,
      -230,
      16,
      const Color(0xFF94A3B8),
      bold: true,
    );
    for (int i = 0; i < s1Target.length; i++) {
      _drawText(
        canvas,
        "${s1Target[i]}",
        bx + 180 + i * 85,
        -195,
        32,
        const Color(0xFFFACC15),
        bold: true,
      );
    }

    List<int> currentStats = s1CalcNeighborsTaller(s1Children);
    double slotW = 100, gap = 40;

    for (int i = 0; i < s1Children.length; i++) {
      if (activeDragEntity == 's1_child' && s1DragIndex == i) continue;

      double cx = bx + 40 + i * (slotW + gap);
      _drawCustomRoundedRect(
        canvas,
        cx,
        by,
        slotW,
        20,
        0,
        0,
        8,
        8,
        const Color(0xFF94A3B8),
        const Color(0xFF0F172A),
        3,
      );
      _drawRoundedRect(
        canvas,
        cx + 15,
        by + 30,
        70,
        50,
        8,
        const Color(0xFF0F172A),
        const Color(0xFF334155),
        4,
      );
      _drawText(
        canvas,
        "${currentStats[i]}",
        cx + 50,
        by + 55,
        28,
        const Color(0xFF38BDF8),
        bold: true,
      );

      double heightPx = s1Children[i].h * 40 + 40.0;
      _drawPillarChild(
        canvas,
        cx + 10,
        by,
        slotW - 20,
        heightPx,
        currentStats[i] == s1Target[i],
      );
    }

    if (activeDragEntity == 's1_child') {
      double heightPx = s1Children[s1DragIndex].h * 40 + 40.0;
      _drawPillarChild(
        canvas,
        dragWorldPos.dx - slotW / 2 + 10,
        dragWorldPos.dy + heightPx / 2,
        slotW - 20,
        heightPx,
        false,
      );

      int dropIdx = math.max(
        0,
        math.min(4, ((dragWorldPos.dx - (bx + 40)) / (slotW + gap)).round()),
      );
      double idxX = bx + 40 + dropIdx * (slotW + gap);
      canvas.drawRect(
        Rect.fromLTWH(idxX, by - 200, slotW, 220),
        Paint()..color = const Color(0xFF6366F1).withOpacity(0.3),
      );
    }
  }

  // SCENARIO 2
  void _draw3DBlock(
    Canvas canvas,
    double x,
    double y,
    double size,
    int num,
    Color baseCol,
    int stateCode,
  ) {
    Color frontCol = const Color(0xFF0F172A);
    if (stateCode == 1) frontCol = const Color(0xFF22C55E);
    if (stateCode == -1) frontCol = const Color(0xFFEF4444);

    _drawRoundedRect(canvas, x, y, size, size, 8, frontCol, Colors.white, 2);
    _drawText(
      canvas,
      "$num",
      x + size / 2,
      y + size / 2,
      size * 0.35,
      Colors.white,
      bold: true,
    );

    if (stateCode == 1) {
      canvas.drawCircle(
        Offset(x + size, y),
        12,
        Paint()..color = const Color(0xFF22C55E),
      );
      canvas.drawCircle(
        Offset(x + size, y),
        12,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      // (Checkmark)
      Path p = Path()
        ..moveTo(x + size - 5, y)
        ..lineTo(x + size - 1, y + 4)
        ..lineTo(x + size + 6, y - 5);
      canvas.drawPath(
        p,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    } else if (stateCode == -1) {
      canvas.drawCircle(
        Offset(x + size, y),
        12,
        Paint()..color = const Color(0xFFEF4444),
      );
      canvas.drawCircle(
        Offset(x + size, y),
        12,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      // (Cross)
      Path p = Path()
        ..moveTo(x + size - 4, y - 4)
        ..lineTo(x + size + 4, y + 4)
        ..moveTo(x + size + 4, y - 4)
        ..lineTo(x + size - 4, y + 4);
      canvas.drawPath(
        p,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
  }

  void _renderScenario2(Canvas canvas) {
    if (step <= 1) {
      double g1X = -350, g1Y = -150, bSize = 100, gap = 40;
      _drawText(
        canvas,
        "Find the Supercell: A block bigger than its neighbors.",
        0,
        g1Y - 60,
        24,
        Colors.white,
        bold: true,
      );
      for (int i = 0; i < s2Grid1.length; i++) {
        _draw3DBlock(
          canvas,
          g1X + i * (bSize + gap),
          g1Y,
          bSize,
          s2Grid1[i],
          const Color(0xFF3B82F6),
          s2State1[i] ?? 0,
        );
      }
    }

    if (step >= 2) {
      double g2X = -480, g2Y = -50;
      _drawText(
        canvas,
        "Select ALL Supercells in this row",
        0,
        g2Y - 60,
        24,
        Colors.white,
        bold: true,
      );
      for (int i = 0; i < s2Grid2.length; i++) {
        _draw3DBlock(
          canvas,
          g2X + i * (90 + 20),
          g2Y,
          90,
          s2Grid2[i],
          const Color(0xFF8B5CF6),
          s2State2[i] ?? 0,
        );
      }

      if (step == 2 || step == 3) {
        _drawRoundedRect(
          canvas,
          -100,
          g2Y + 160,
          200,
          60,
          30,
          const Color(0xFF10B981),
          const Color(0xFF065F46),
          4,
        );
        _drawText(canvas, "CHECK", 0, g2Y + 190, 24, Colors.white, bold: true);
      }
    }
  }

  // SCENARIO 3
  void _renderScenario3(Canvas canvas) {
    double x = 0, y = -120;

    _drawRoundedRect(
      canvas,
      x - 300,
      y - 200,
      600,
      400,
      24,
      const Color(0xFF334155),
      const Color(0xFF0F172A),
      6,
    );
    _drawCustomRoundedRect(
      canvas,
      x - 80,
      y - 280,
      160,
      100,
      10,
      10,
      0,
      0,
      const Color(0xFF475569),
      const Color(0xFF0F172A),
      4,
    );
    _drawText(
      canvas,
      "INPUT",
      x,
      y - 250,
      20,
      const Color(0xFF94A3B8),
      bold: true,
    );

    _drawLine(
      canvas,
      x - 200,
      y - 60,
      x + 80,
      y - 60,
      const Color(0xFF1E293B),
      20,
    );
    _drawLine(
      canvas,
      x - 200,
      y + 60,
      x + 80,
      y + 60,
      const Color(0xFF1E293B),
      20,
    );
    _drawText(
      canvas,
      "SORT DESC",
      x - 120,
      y - 85,
      12,
      const Color(0xFFCBD5E1),
      bold: true,
    );
    _drawText(
      canvas,
      "SORT ASC",
      x - 120,
      y + 35,
      12,
      const Color(0xFFCBD5E1),
      bold: true,
    );

    _drawRoundedRect(
      canvas,
      x + 100,
      y - 100,
      140,
      200,
      16,
      const Color(0xFFB91C1C),
      const Color(0xFF7F1D1D),
      4,
    );
    _drawText(
      canvas,
      "SUBTRACT",
      x + 170,
      y,
      20,
      const Color(0xFFFECACA),
      bold: true,
    );

    _drawCustomRoundedRect(
      canvas,
      x - 80,
      y + 200,
      160,
      80,
      0,
      0,
      10,
      10,
      const Color(0xFF475569),
      const Color(0xFF0F172A),
      4,
    );

    void drawBlock(double bx, double by, String txt, Color bg) {
      _drawRoundedRect(
        canvas,
        bx - 25,
        by - 25,
        50,
        50,
        8,
        bg,
        const Color(0xFF0F172A),
        3,
      );
      _drawText(canvas, txt, bx, by, 20, Colors.white, bold: true);
    }

    if (s3Phase == 0) {
      drawBlock(x, y - 200, s3Num, const Color(0xFF3B82F6));
    } else if (s3Phase == 1) {
      double bxL = x - 200 + s3Progress * 250;
      double bxS = x - 200 + s3Progress * 250;
      drawBlock(bxL, y - 60, s3L, const Color(0xFF8B5CF6));
      drawBlock(bxS, y + 60, s3S, const Color(0xFF10B981));
    } else if (s3Phase == 2) {
      double shift = math.sin(s3Progress * 20) * 5;
      _drawText(
        canvas,
        "PROCESSING",
        x + 170 + shift,
        y + 40,
        16,
        const Color(0xFFFCA5A5),
        bold: true,
      );
    } else if (s3Phase == 3) {
      double outY = y + 100 + s3Progress * 140;
      drawBlock(x, outY, s3Res, const Color(0xFFF59E0B));
    }

    double btnY = y + 320;
    if (step == 0) {
      _drawRoundedRect(
        canvas,
        x - 80,
        btnY,
        160,
        60,
        30,
        const Color(0xFF10B981),
        const Color(0xFF065F46),
        4,
      );
      _drawText(canvas, "START", x, btnY + 30, 24, Colors.white, bold: true);
    } else if (step >= 1 && s3Phase == 3) {
      _drawRoundedRect(
        canvas,
        x - 80,
        btnY,
        160,
        60,
        30,
        const Color(0xFF6366F1),
        const Color(0xFF4338CA),
        4,
      );
      _drawText(canvas, "REPEAT", x, btnY + 30, 20, Colors.white, bold: true);
    }
  }

  // SCENARIO 4
  void _renderScenario4(Canvas canvas) {
    double gX = -180, gY = -280, tSize = 120, gap = 10;
    _drawRoundedRect(
      canvas,
      gX - 20,
      gY - 20,
      tSize * 3 + gap * 2 + 40,
      tSize * 3 + gap * 2 + 40,
      16,
      const Color(0xFF312E81),
      const Color(0xFF1E1B4B),
      6,
    );

    int score = 0;
    for (int i = 0; i < 9; i++) {
      if (s4IsSupercell(s4Grid, i)) score++;
    }

    for (int i = 0; i < 9; i++) {
      int row = i ~/ 3;
      int col = i % 3;
      double cx = gX + col * (tSize + gap);
      double cy = gY + row * (tSize + gap);
      _drawRoundedRect(
        canvas,
        cx,
        cy,
        tSize,
        tSize,
        8,
        const Color(0xFF4338CA),
        const Color(0xFF312E81),
        4,
      );

      int? val = s4Grid[i];
      if (val != null && activeDragEntity != 'g_$i') {
        bool isS = s4IsSupercell(s4Grid, i);
        if (isS) {
          canvas.drawShadow(
            Path()
              ..addRect(Rect.fromLTWH(cx + 5, cy + 5, tSize - 10, tSize - 10)),
            const Color(0xFF60A5FA),
            10,
            false,
          );
        }
        _drawRoundedRect(
          canvas,
          cx + 5,
          cy + 5,
          tSize - 10,
          tSize - 10,
          8,
          isS ? const Color(0xFF3B82F6) : const Color(0xFFCBD5E1),
          const Color(0xFF0F172A),
          3,
        );
        _drawText(
          canvas,
          "$val",
          cx + tSize / 2,
          cy + tSize / 2,
          36,
          const Color(0xFF0F172A),
          bold: true,
        );
      }
    }

    _drawRoundedRect(
      canvas,
      -150,
      -360,
      300,
      70,
      35,
      const Color(0xFFFACC15),
      const Color(0xFFB45309),
      4,
    );
    _drawText(
      canvas,
      "SUPERCELLS: $score",
      0,
      -325,
      24,
      const Color(0xFF0F172A),
      bold: true,
    );

    double rX = -400, rY = 160, rSize = 80;
    _drawRoundedRect(
      canvas,
      rX - 20,
      rY - 20,
      rSize * 9 + gap * 8 + 40,
      rSize + 40,
      16,
      const Color(0xFF334155),
      const Color(0xFF0F172A),
      4,
    );
    for (int i = 0; i < 9; i++) {
      double cx = rX + i * (rSize + gap);
      _drawRoundedRect(
        canvas,
        cx,
        rY,
        rSize,
        rSize,
        8,
        const Color(0xFF475569),
        const Color(0xFF1E293B),
        4,
      );

      int? val = s4Rack[i];
      if (val != null && activeDragEntity != 'r_$i') {
        _drawRoundedRect(
          canvas,
          cx + 5,
          rY + 5,
          rSize - 10,
          rSize - 10,
          8,
          const Color(0xFFCBD5E1),
          const Color(0xFF0F172A),
          3,
        );
        _drawText(
          canvas,
          "$val",
          cx + rSize / 2,
          rY + rSize / 2,
          24,
          const Color(0xFF0F172A),
          bold: true,
        );
      }
    }

    if (activeDragEntity != null) {
      String type = activeDragEntity!.split('_')[0];
      if (type == 'r' || type == 'g') {
        int idx = int.parse(activeDragEntity!.split('_')[1]);
        int val = type == 'r' ? s4Rack[idx]! : s4Grid[idx]!;
        _drawRoundedRect(
          canvas,
          dragWorldPos.dx - tSize / 2,
          dragWorldPos.dy - tSize / 2,
          tSize,
          tSize,
          8,
          const Color(0xFFF8FAFC),
          const Color(0xFF0F172A),
          4,
        );
        _drawText(
          canvas,
          "$val",
          dragWorldPos.dx,
          dragWorldPos.dy,
          36,
          const Color(0xFF0F172A),
          bold: true,
        );
      }
    }
  }

  // SCENARIO 5
  void _renderScenario5(Canvas canvas) {
    if (s5Path.isEmpty) return;

    for (int i = 0; i < s5Path.length - 1; i++) {
      S5Node p1 = s5Path[i];
      S5Node p2 = s5Path[i + 1];
      bool isEven = p1.val % 2 == 0;

      _drawLine(
        canvas,
        p1.x,
        p1.y,
        p2.x,
        p2.y,
        isEven ? const Color(0xFF3B82F6) : const Color(0xFFEF4444),
        12,
      );

      double midX = (p1.x + p2.x) / 2;
      double midY = (p1.y + p2.y) / 2 - 15;
      _drawText(
        canvas,
        isEven ? "÷2" : "×3+1",
        midX,
        midY,
        16,
        isEven ? const Color(0xFF93C5FD) : const Color(0xFFFCA5A5),
        bold: true,
      );
    }

    for (int i = 0; i < s5Path.length; i++) {
      S5Node n = s5Path[i];
      bool is421 = [4, 2, 1].contains(n.val) && i >= s5Path.length - 4;
      canvas.drawCircle(
        Offset(n.x, n.y),
        25,
        Paint()
          ..color = is421 ? const Color(0xFFFACC15) : const Color(0xFF1E293B),
      );
      canvas.drawCircle(
        Offset(n.x, n.y),
        25,
        Paint()
          ..color = const Color(0xFF0F172A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      _drawText(
        canvas,
        "${n.val}",
        n.x,
        n.y,
        16,
        is421 ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        bold: true,
      );
    }

    canvas.drawCircle(s5BallPos, 18, Paint()..color = const Color(0xFFF8FAFC));
    canvas.drawCircle(
      s5BallPos,
      18,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    _drawText(
      canvas,
      "$s5Val",
      s5BallPos.dx,
      s5BallPos.dy,
      14,
      const Color(0xFF0F172A),
      bold: true,
    );
  }

  @override
  bool shouldRepaint(covariant LabPainter oldDelegate) => true;
}
