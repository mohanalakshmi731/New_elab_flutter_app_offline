// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: library_private_types_in_public_api, use_super_parameters, camel_case_types, deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'ZSL Virtual Lab | The Number Factory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Roboto',
      ),
      home: const Cl6M_Ch3_A3_TheNumberFactory(),
    ),
  );
}

// ============================================================================
// I18N / TRANSLATIONS
// ============================================================================
final Map<String, Map<String, String>> translations = {
  'en': {
    'shutterTitle': "Iterative Number Transformations and Conjectures",
    'appTitle': "The Number Factory",
    'appSubtitle': "Class 6 • TRANSFORMATIONS & CONJECTURES",
    'enterLab': "Enter Simulation",
    'settings': "Settings",
    'selectScenario': "Select Scenario",
    'stepLabel': "STEP",
    'learnLbl': "Objective:",
    'summaryTitle': "Goal Reached!",
    'resetBtn': "Reset Lab",
    'finishLab': "Finish Lab",
    'nextScenario': "Next Scenario",
    'finalDesc': "You have successfully explored these mathematical mysteries!",
    'lbl_drag': "DRAG",
    'lbl_start': "START",
    'lbl_continue': "CONTINUE",
    'lbl_transform': "TRANSFORM",
    'lbl_merge': "MERGE",

    // S1
    's1_title': "1. The 3-Digit Kaprekar Machine",
    's1_obj':
        "Discover that any 3-digit number (with at least two different digits) will always reach the constant '495'.",
    's1_step1_task': "DRAG the number block '351' into the hopper.",
    's1_step1_out': "The block separates into digits 3, 5, 1.",
    's1_step2_task': "CLICK 'START' to sort.",
    's1_step2_out': "Digits are sorted into MAX (531) and MIN (135).",
    's1_step3_task': "Observe the subtraction.",
    's1_step3_out': "531 - 135 = 396.",
    's1_step4_task': "CLICK 'CONTINUE' repeatedly.",
    's1_step4_out': "The machine loops until it hits 495.",
    's1_hud1': "Drag '351' to the hopper.",
    's1_hud2': "Click START.",
    's1_hud3': "Observe the calculation.",
    's1_hud4': "Click CONTINUE to loop.",

    // S2
    's2_title': "2. The 4-Digit Kaprekar Machine",
    's2_obj': "Discover the 4-digit Kaprekar constant, '6174'.",
    's2_step1_task': "DRAG '6382' into the machine.",
    's2_step1_out': "Separates into 6, 3, 8, 2.",
    's2_step2_task': "CLICK 'START' and observe.",
    's2_step2_out': "Sorts and subtracts: 8632 - 2368 = 6264.",
    's2_step3_task': "CLICK 'CONTINUE' until it halts.",
    's2_step3_out': "The constant 6174 is found.",
    's2_hud1': "Drag '6382' to the hopper.",
    's2_hud2': "Click START.",
    's2_hud3': "Click CONTINUE until constant.",

    // S3
    's3_title': "3. The Palindrome Bridge",
    's3_obj':
        "Understand the 'reverse-and-add' algorithm and confirm palindromes.",
    's3_step1_task': "DRAG '47' to the left platform.",
    's3_step1_out': "Number 47 placed.",
    's3_step2_task': "CLICK 'TRANSFORM'.",
    's3_step2_out': "Clones and reverses to 74.",
    's3_step3_task': "CLICK 'MERGE'.",
    's3_step3_out': "47 + 74 = 121.",
    's3_step4_task': "Observe Palindrome Scanner.",
    's3_step4_out': "121 reads the same both ways. Bridge completes!",
    's3_hud1': "Drag '47' to the start.",
    's3_hud2': "Click TRANSFORM.",
    's3_hud3': "Click MERGE.",
    's3_hud4': "Observe the scanner.",

    // S4
    's4_title': "4. Collatz Hailstone Path",
    's4_obj': "Explore the 3n+1 problem and observe the path to 1.",
    's4_step1_task': "DRAG '12' to the start.",
    's4_step1_out': "Number 12 ready.",
    's4_step2_task': "CLICK 'START' to run the rule.",
    's4_step2_out':
        "Even numbers halve (÷ 2), Odd numbers triple and add one (× 3 + 1).",
    's4_step3_task': "Observe the journey.",
    's4_step3_out': "The path always ends at 1. An unsolved mystery!",
    's4_hud1': "Drag '12' to the start.",
    's4_hud2': "Click START to run the Collatz rule.",
    's4_hud3': "Watch the path trace to 1.",

    // S5
    's5_title': "5. The Lychrel Black Hole",
    's5_obj':
        "Explore Lychrel numbers (like 196) which may never form a palindrome.",
    's5_step1_task': "DRAG '196' to the platform.",
    's5_step1_out': "Number 196 placed.",
    's5_step2_task': "CLICK 'TRANSFORM' then 'MERGE'.",
    's5_step2_out': "196 + 691 = 887. Not a palindrome.",
    's5_step3_task': "CLICK 'CONTINUE' repeatedly.",
    's5_step3_out': "Numbers grow rapidly. Warning!",
    's5_step4_task': "Observe final outcome.",
    's5_step4_out': "Process fails and collapses into a black hole.",
    's5_hud1': "Drag '196' to the start.",
    's5_hud2': "Transform and Merge.",
    's5_hud3': "Click CONTINUE multiple times.",
    's5_hud4': "Observe the Lychrel collapse.",

    // Canvas
    'c_history': "HISTORY",
    'c_max': "MAX",
    'c_min': "MIN",
    'c_sub': "SUBTRACT",
    'c_res': "RESULT",
    'c_const': "CONSTANT FOUND!",
    'c_pal_scan': "SCANNING...",
    'c_pal_yes': "PALINDROME!",
    'c_pal_no': "NOT A PALINDROME",
    'c_even': "EVEN (÷2)",
    'c_odd': "ODD (×3+1)",
    'c_warn': "ALERT: LYCHREL CANDIDATE!",
  },
  'hi': {
    'shutterTitle': "पुनरावृत्त संख्या परिवर्तन और अनुमान",
    'appTitle': "संख्या कारखाना",
    'appSubtitle': "कक्षा 6 • परिवर्तन और अनुमान",
    'enterLab': "सिमुलेशन दर्ज करें",
    'settings': "सेटिंग्स",
    'selectScenario': "परिदृश्य चुनें",
    'stepLabel': "चरण",
    'learnLbl': "उद्देश्य:",
    'summaryTitle': "लक्ष्य प्राप्त हुआ!",
    'resetBtn': "रीसेट करें",
    'finishLab': "समाप्त करें",
    'nextScenario': "अगला परिदृश्य",
    'finalDesc': "आपने इन गणितीय रहस्यों का सफलतापूर्वक पता लगाया है!",
    'lbl_drag': "खींचें",
    'lbl_start': "प्रारंभ",
    'lbl_continue': "जारी रखें",
    'lbl_transform': "बदलें",
    'lbl_merge': "मिलाएं",

    's1_title': "1. 3-अंकीय काप्रेकर मशीन",
    's1_obj': "पता लगाएं कि कोई भी 3-अंकीय संख्या हमेशा '495' तक पहुंचती है।",
    's1_step1_task': "ब्लॉक '351' को हॉपर में खींचें।",
    's1_step1_out': "ब्लॉक 3, 5, 1 में अलग होता है।",
    's1_step2_task': "'प्रारंभ' पर क्लिक करें।",
    's1_step2_out': "अंक MAX और MIN में सॉर्ट किए गए हैं।",
    's1_step3_task': "घटाव देखें।",
    's1_step3_out': "531 - 135 = 396.",
    's1_step4_task': "बार-बार 'जारी रखें' पर क्लिक करें।",
    's1_step4_out': "मशीन 495 तक लूप करती है।",
    's1_hud1': "'351' को हॉपर में खींचें।",
    's1_hud2': "प्रारंभ पर क्लिक करें।",
    's1_hud3': "गणना देखें।",
    's1_hud4': "लूप के लिए जारी रखें पर क्लिक करें।",

    's2_title': "2. 4-अंकीय काप्रेकर मशीन",
    's2_obj': "4-अंकीय काप्रेकर स्थिरांक '6174' खोजें।",
    's2_step1_task': "'6382' को मशीन में खींचें।",
    's2_step1_out': "6, 3, 8, 2 में अलग होता है।",
    's2_step2_task': "'प्रारंभ' पर क्लिक करें।",
    's2_step2_out': "8632 - 2368 = 6264.",
    's2_step3_task': "रुकने तक 'जारी रखें' पर क्लिक करें।",
    's2_step3_out': "स्थिरांक 6174 मिल गया।",
    's2_hud1': "'6382' को हॉपर में खींचें।",
    's2_hud2': "प्रारंभ पर क्लिक करें।",
    's2_hud3': "स्थिरांक तक जारी रखें।",

    's3_title': "3. पैलिंड्रोम ब्रिज",
    's3_obj': "'उल्टा-और-जोड़' एल्गोरिथ्म समझें।",
    's3_step1_task': "'47' को प्लेटफॉर्म पर खींचें।",
    's3_step1_out': "47 रखा गया।",
    's3_step2_task': "'बदलें' पर क्लिक करें।",
    's3_step2_out': "क्लोन और 74 में उलट जाता है।",
    's3_step3_task': "'मिलाएं' पर क्लिक करें।",
    's3_step3_out': "47 + 74 = 121.",
    's3_step4_task': "स्कैनर देखें।",
    's3_step4_out': "121 एक पैलिंड्रोम है।",
    's3_hud1': "'47' को शुरुआत में खींचें।",
    's3_hud2': "बदलें पर क्लिक करें।",
    's3_hud3': "मिलाएं पर क्लिक करें।",
    's3_hud4': "स्कैनर देखें।",

    's4_title': "4. कोलाट्ज़ पाथ",
    's4_obj': "3n+1 समस्या का अन्वेषण करें।",
    's4_step1_task': "'12' को शुरुआत में खींचें।",
    's4_step1_out': "12 तैयार।",
    's4_step2_task': "'प्रारंभ' पर क्लिक करें।",
    's4_step2_out': "सम (÷ 2), विषम (× 3 + 1)।",
    's4_step3_task': "यात्रा देखें।",
    's4_step3_out': "मार्ग हमेशा 1 पर समाप्त होता है।",
    's4_hud1': "'12' को शुरुआत में खींचें।",
    's4_hud2': "प्रारंभ पर क्लिक करें।",
    's4_hud3': "यात्रा देखें।",

    's5_title': "5. लाइक्रेल ब्लैक होल",
    's5_obj':
        "196 जैसी संख्याओं का अन्वेषण करें जो कभी पैलिंड्रोम नहीं बन सकतीं।",
    's5_step1_task': "'196' को खींचें।",
    's5_step1_out': "196 रखा गया।",
    's5_step2_task': "बदलें और मिलाएं।",
    's5_step2_out': "196 + 691 = 887 (पैलिंड्रोम नहीं)।",
    's5_step3_task': "कई बार 'जारी रखें' पर क्लिक करें।",
    's5_step3_out': "संख्याएं तेजी से बढ़ती हैं।",
    's5_step4_task': "अंतिम परिणाम देखें।",
    's5_step4_out': "ब्लैक होल में गिर जाता है।",
    's5_hud1': "'196' को खींचें।",
    's5_hud2': "बदलें और मिलाएं।",
    's5_hud3': "जारी रखें पर क्लिक करें।",
    's5_hud4': "ब्लैक होल देखें।",

    'c_history': "इतिहास",
    'c_max': "अधिकतम",
    'c_min': "न्यूनतम",
    'c_sub': "घटाव",
    'c_res': "परिणाम",
    'c_const': "स्थिरांक मिला!",
    'c_pal_scan': "स्कैनिंग...",
    'c_pal_yes': "पैलिंड्रोम!",
    'c_pal_no': "पैलिंड्रोम नहीं",
    'c_even': "सम (÷2)",
    'c_odd': "विषम (×3+1)",
    'c_warn': "चेतावनी: लाइक्रेल!",
  },
};

String t(String lang, String key) {
  return translations[lang]?[key] ?? translations['en']?[key] ?? key;
}

class StepConfig {
  final String task;
  final String out;
  final String hud;
  StepConfig(this.task, this.out, this.hud);
}

// ============================================================================
// MAIN GAME SCREEN
// ============================================================================
class Cl6M_Ch3_A3_TheNumberFactory extends StatefulWidget {
  const Cl6M_Ch3_A3_TheNumberFactory({Key? key}) : super(key: key);

  @override
  _Cl6M_Ch3_A3_TheNumberFactoryState createState() =>
      _Cl6M_Ch3_A3_TheNumberFactoryState();
}

class _Cl6M_Ch3_A3_TheNumberFactoryState
    extends State<Cl6M_Ch3_A3_TheNumberFactory>
    with TickerProviderStateMixin {
  // --- UI State ---
  String _lang = 'en';
  bool _sidebarOpen = true;
  bool _showCurtain = true;
  bool _showSuccessPopup = false;

  // --- Canvas Control ---
  double _zoom = 1.0;
  double _baseZoom = 1.0;
  double _panX = 0.0;
  double _panY = 0.0;
  final GlobalKey _canvasKey = GlobalKey();

  // --- Simulation State ---
  int _scenario = 1; // 1-5
  int _step = 0;
  bool _animating = false;
  double _animProgress = 0.0;
  int _animStartTime = 0;
  int _animDuration = 1000;

  // Kaprekar (S1, S2)
  String? _kapNum;
  final List<String> _kapHistory = [];
  String? _kapMax;
  String? _kapMin;
  String? _kapRes;
  String _kapAnimState = 'idle'; // idle, sorting, sub
  bool _kapConst = false;

  // Palindrome (S3, S5)
  String? _palNum;
  String? _palRev;
  String? _palSum;
  String _palAnimState = 'idle'; // idle, clone, merge, scan, result, success
  final List<String> _palHistory = [];
  bool _palExploded = false;

  // Collatz (S4)
  int? _colNum;
  final List<int> _colHistory = [];
  String _colAnimState = 'idle'; // idle, eval, done

  // Dragging
  String? _activeDragEntity;
  double _dragX = 0;
  double _dragY = 0;

  // Audio Engines
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();
  final AudioPlayer _errorPlayer = AudioPlayer();

  // Animation Controller for Game Loop
  late AnimationController _gameLoop;

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
      duration: const Duration(milliseconds: 1000),
    )..addListener(_tickLoop);
    _gameLoop.repeat();
  }

  @override
  void dispose() {
    _gameLoop.dispose();
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();
    _errorPlayer.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> playClick() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/click.mp3'));
  }

  Future<void> playPageOpen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/science/page_open.mp3'));
  }

  Future<void> playDropdown() async {
    await _dropdownPlayer.stop();
    await _dropdownPlayer.play(
      AssetSource('audio/class6/science/dropdown.mp3'),
    );
  }

  Future<void> playError() async {
    await _errorPlayer.stop();
    await _errorPlayer.play(AssetSource('audio/class6/science/error.mp3'));
  }

  Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/math/shutter.mp3'));
  }

  void _playSound(String type) {
    switch (type) {
      case 'tick':
      case 'pop':
        playClick();
        break;
      case 'snap':
      case 'weld':
        playDropdown();
        break;
      case 'success':
        playPageOpen();
        break;
      case 'error':
      case 'explosion':
        playError();
        break;
      case 'curtain':
        curtainScreen();
        break;
    }
  }

  void _tickLoop() {
    if (_animStartTime > 0) {
      int now = DateTime.now().millisecondsSinceEpoch;
      double p = (now - _animStartTime) / _animDuration;
      if (p >= 1.0) {
        p = 1.0;
        _animStartTime = 0;
        _onAnimComplete();
      }
      setState(() {
        _animProgress = p;
      });
    } else {
      // Force repaint
      setState(() {});
    }
  }

  void _onAnimComplete() {
    if (_scenario == 1 || _scenario == 2) {
      if (_kapAnimState == 'sorting') {
        _kapAnimState = 'sub';
        _playSound('snap');
        _startAnim(1000);
      } else if (_kapAnimState == 'sub') {
        _kapAnimState = 'idle';
        _animating = false;
        _playSound('success');
        _advanceStep();
      }
    } else if (_scenario == 3 || _scenario == 5) {
      if (_palAnimState == 'clone') {
        _animating = false;
        _palRev = _palNum!.split('').reversed.join('');
        _playSound('snap');
        _advanceStep();
      } else if (_palAnimState == 'merge') {
        _palSum = (int.parse(_palNum!) + int.parse(_palRev!)).toString();
        _palAnimState = 'scan';
        _playSound('weld');
        _startAnim(1000);
      } else if (_palAnimState == 'scan') {
        bool isPal = _palSum == _palSum!.split('').reversed.join('');
        _palAnimState = isPal ? 'success' : 'result';
        if (isPal) {
          _playSound('success');
          if (_scenario == 3) {
            _advanceStep();
            Future.delayed(const Duration(milliseconds: 1500), _checkSuccess);
          }
        } else {
          _playSound('error');
          if (_scenario == 5) {
            _advanceStep();
          }
        }
        _animating = false;
      }
    }
  }

  void _startAnim(int durationMs) {
    _animDuration = durationMs;
    _animProgress = 0.0;
    _animStartTime = DateTime.now().millisecondsSinceEpoch;
    _animating = true;
  }

  void _advanceStep() {
    setState(() {
      _step++;
    });
  }

  void _checkSuccess() {
    setState(() {
      _step = _getScenarioSteps(_scenario).length;
    });
    // Triggers success popup for ANY completed scenario
    Future.delayed(const Duration(milliseconds: 1000), _showFinalPopup);
  }

  void _showFinalPopup() {
    _playSound('success');
    setState(() {
      _showSuccessPopup = true;
    });
  }

  void _triggerAction(String action) {
    if (_animating) return;

    if (action == 'kap_start') {
      if (_kapNum == null) return;
      _playSound('tick');
      String numStr = _kapNum!.padLeft(_scenario == 1 ? 3 : 4, '0');
      List<String> arr = numStr.split('');

      List<String> maxArr = List.from(arr)..sort((a, b) => b.compareTo(a));
      List<String> minArr = List.from(arr)..sort((a, b) => a.compareTo(b));

      _kapMax = maxArr.join('');
      _kapMin = minArr.join('');
      _kapRes = (int.parse(_kapMax!) - int.parse(_kapMin!)).toString().padLeft(
        _scenario == 1 ? 3 : 4,
        '0',
      );

      _kapAnimState = 'sorting';
      _startAnim(1000);
    } else if (action == 'kap_cont') {
      if (_kapRes == null || _kapConst) return;
      _kapNum = _kapRes;
      _kapHistory.add(_kapNum!);

      String target = _scenario == 1 ? "495" : "6174";
      if (_kapNum == target) {
        _kapConst = true;
        _playSound('success');
        _advanceStep();
        Future.delayed(const Duration(milliseconds: 1500), _checkSuccess);
        return;
      }

      _kapMax = null;
      _kapMin = null;
      _kapRes = null;
      _playSound('tick');
      _triggerAction('kap_start');
    } else if (action == 'pal_transform') {
      if (_palNum == null) return;
      _playSound('tick');
      _palAnimState = 'clone';
      _startAnim(800);
    } else if (action == 'pal_merge') {
      if (_palRev == null) return;
      _playSound('tick');
      _palAnimState = 'merge';
      _startAnim(1000);
    } else if (action == 'pal_cont') {
      if (_palSum == null) return;
      _palHistory.add(_palSum!);
      if (_palHistory.length > 4) {
        _palExploded = true;
        _playSound('explosion');
        _advanceStep();
        Future.delayed(const Duration(milliseconds: 2000), _checkSuccess);
        return;
      }
      _palNum = _palSum;
      _palRev = null;
      _palSum = null;
      _palAnimState = 'idle';
      _playSound('pop');
    } else if (action == 'col_start') {
      if (_colNum == null) return;
      _playSound('tick');
      _stepCollatz();
    }
  }

  void _stepCollatz() {
    if (_scenario != 4 || _colNum == null) {
      _animating = false;
      return;
    }
    _animating = true;
    if (_colNum == 1) {
      _animating = false;
      _colAnimState = 'done';
      _playSound('success');
      _advanceStep();
      Future.delayed(const Duration(milliseconds: 1500), _checkSuccess);
      return;
    }

    setState(() {
      _colAnimState = 'eval';
    });
    _playSound('pop');

    Future.delayed(const Duration(milliseconds: 400), () {
      if (_scenario != 4 || _colNum == null) {
        _animating = false;
        return;
      }
      setState(() {
        _colNum = (_colNum! % 2 == 0) ? _colNum! ~/ 2 : _colNum! * 3 + 1;
        _colHistory.add(_colNum!);
        _colAnimState = 'idle';
      });
      _playSound('snap');
      Future.delayed(const Duration(milliseconds: 400), _stepCollatz);
    });
  }

  void _loadScenario(int id) {
    setState(() {
      if (id == 1) _showCurtain = true;
      _scenario = id;
      _step = 0;
      _animating = false;
      _animStartTime = 0;
      _showSuccessPopup = false;

      // Kaprekar reset
      _kapNum = null;
      _kapHistory.clear();
      _kapMax = null;
      _kapMin = null;
      _kapRes = null;
      _kapConst = false;
      _kapAnimState = 'idle';
      // Palindrome reset
      _palNum = null;
      _palRev = null;
      _palSum = null;
      _palExploded = false;
      _palHistory.clear();
      _palAnimState = 'idle';
      // Collatz reset
      _colNum = null;
      _colHistory.clear();
      _colAnimState = 'idle';

      _panX = 0;
      _panY = 0;
      _zoom = 1.0;
    });
    _playSound('pop');
  }

  void _handleReset() {
    _playSound('error');
    setState(() {
      _showCurtain = true;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      _loadScenario(1);
    });
  }

  void _toggleLanguage() {
    setState(() {
      _lang = _lang == 'en' ? 'hi' : 'en';
    });
    _playSound('pop');
  }

  // --- Interaction Mapping ---
  Offset _screenToWorld(Offset screenPoint, Size canvasSize) {
    double cx = canvasSize.width / 2;
    double cy = canvasSize.height / 2;
    double worldX = (screenPoint.dx - cx - _panX) / _zoom;
    double worldY = (screenPoint.dy - cy - _panY) / _zoom;
    return Offset(worldX, worldY);
  }

  bool _hitTestBox(double x, double y, double w, double h, Offset pt) {
    return pt.dx > x && pt.dx < x + w && pt.dy > y && pt.dy < y + h;
  }

  void _onScaleStart(ScaleStartDetails details) {
    _baseZoom = _zoom;

    if (_canvasKey.currentContext == null) return;
    RenderBox box = _canvasKey.currentContext!.findRenderObject() as RenderBox;
    Offset localPt = box.globalToLocal(details.focalPoint);
    Offset worldPt = _screenToWorld(localPt, box.size);

    if (!_animating) {
      if (_scenario == 1 || _scenario == 2) {
        if (_hitTestBox(290, -150, 180, 200, worldPt) && _step == 0) {
          _activeDragEntity = 'block';
          _dragX = worldPt.dx;
          _dragY = worldPt.dy;
          _playSound('tick');
        }
        if (_hitTestBox(-120, 190, 100, 40, worldPt)) {
          _triggerAction('kap_start');
        }
        if (_hitTestBox(20, 190, 120, 40, worldPt)) _triggerAction('kap_cont');
      } else if (_scenario == 3 || _scenario == 5) {
        if (_hitTestBox(-480, -80, 60, 60, worldPt) && _step == 0) {
          _activeDragEntity = 'block';
          _dragX = worldPt.dx;
          _dragY = worldPt.dy;
          _playSound('tick');
        }
        if (_hitTestBox(-350, 100, 120, 40, worldPt)) {
          _triggerAction('pal_transform');
        }
        if (_hitTestBox(-200, 100, 100, 40, worldPt)) {
          _triggerAction('pal_merge');
        }
        if (_scenario == 5 && _hitTestBox(-50, 100, 100, 40, worldPt)) {
          _triggerAction('pal_cont');
        }
      } else if (_scenario == 4) {
        if (_hitTestBox(-330, -230, 60, 60, worldPt) && _step == 0) {
          _activeDragEntity = 'block';
          _dragX = worldPt.dx;
          _dragY = worldPt.dy;
          _playSound('tick');
        }
        if (_hitTestBox(-50, -280, 100, 40, worldPt)) {
          _triggerAction('col_start');
        }
      }
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_canvasKey.currentContext == null) return;
    RenderBox box = _canvasKey.currentContext!.findRenderObject() as RenderBox;

    if (_activeDragEntity != null) {
      Offset localPt = box.globalToLocal(details.focalPoint);
      Offset worldPt = _screenToWorld(localPt, box.size);
      setState(() {
        _dragX = worldPt.dx;
        _dragY = worldPt.dy;
      });
      return;
    }

    setState(() {
      // Calculate smooth focal-point zoom (Google Maps style)
      double oldZoom = _zoom;
      _zoom = (_baseZoom * details.scale).clamp(0.4, 3.0);

      Offset localFocalPoint = box.globalToLocal(details.focalPoint);
      double cx = box.size.width / 2;
      double cy = box.size.height / 2;

      // Adjust pan to keep the point under the fingers stationary while scaling
      double zoomRatio = _zoom / oldZoom;
      _panX =
          localFocalPoint.dx -
          cx -
          (localFocalPoint.dx - cx - _panX) * zoomRatio;
      _panY =
          localFocalPoint.dy -
          cy -
          (localFocalPoint.dy - cy - _panY) * zoomRatio;

      // Apply standard drag translation
      _panX += details.focalPointDelta.dx;
      _panY += details.focalPointDelta.dy;
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_activeDragEntity == 'block') {
      Offset worldPt = Offset(_dragX, _dragY);

      if (_scenario == 1 || _scenario == 2) {
        if (_hitTestBox(-150, -250, 300, 200, worldPt)) {
          setState(() {
            _kapNum = _scenario == 1 ? "351" : "6382";
            _kapHistory.add(_kapNum!);
            _activeDragEntity = null;
          });
          _playSound('snap');
          _advanceStep();
        } else {
          _playSound('error');
        }
      } else if (_scenario == 3 || _scenario == 5) {
        if (_hitTestBox(-300, -50, 150, 80, worldPt)) {
          setState(() {
            _palNum = _scenario == 3 ? "47" : "196";
            _activeDragEntity = null;
          });
          _playSound('snap');
          _advanceStep();
        } else {
          _playSound('error');
        }
      } else if (_scenario == 4) {
        if (_hitTestBox(-100, -250, 200, 100, worldPt)) {
          setState(() {
            _colNum = 12;
            _colHistory.add(12);
            _activeDragEntity = null;
          });
          _playSound('snap');
          _advanceStep();
        } else {
          _playSound('error');
        }
      }
      setState(() {
        _activeDragEntity = null;
      });
    }
  }

  // --- UI Helpers ---
  List<StepConfig> _getScenarioSteps(int id) {
    int numSteps = (id == 2 || id == 4) ? 3 : 4;
    List<StepConfig> steps = [];
    for (int i = 1; i <= numSteps; i++) {
      steps.add(
        StepConfig(
          t(_lang, 's${id}_step${i}_task'),
          t(_lang, 's${id}_step${i}_out'),
          t(_lang, 's${id}_hud$i'),
        ),
      );
    }
    return steps;
  }

  String _getObjective(int id) {
    return t(_lang, 's${id}_obj');
  }

  // --- Builders ---
  Widget _buildSidebar(double width, double height) {
    List<StepConfig> steps = _getScenarioSteps(_scenario);
    String obj = _getObjective(_scenario);

    return Container(
      width: width,
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(right: BorderSide(color: Colors.white24, width: 1)),
      ),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: height),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.only(
                    top: 64,
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white12)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.science,
                            color: Color(0xFF6366F1),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              t(_lang, 'appTitle'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 36.0),
                        child: Text(
                          t(_lang, 'appSubtitle'),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.only(left: 36.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.language, size: 16),
                              label: Text(
                                _lang.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F172A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 0,
                                ),
                                minimumSize: const Size(0, 36),
                              ),
                              onPressed: _toggleLanguage,
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.refresh, size: 16),
                              label: Text(
                                t(_lang, 'resetBtn'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent.withOpacity(
                                  0.2,
                                ),
                                foregroundColor: Colors.redAccent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 0,
                                ),
                                minimumSize: const Size(0, 36),
                                elevation: 0,
                              ),
                              onPressed: _handleReset,
                            ),
                          ],
                        ),
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
                          t(_lang, 'selectScenario').toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _scenario,
                              isExpanded: true,
                              dropdownColor: const Color(0xFF1E293B),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              items: [1, 2, 3, 4, 5].map((id) {
                                return DropdownMenuItem<int>(
                                  value: id,
                                  child: Text(
                                    t(_lang, 's${id}_title'),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  playDropdown();
                                  _loadScenario(val);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Objective
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                    t(_lang, 'learnLbl'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.yellowAccent,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                obj,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Steps
                        ...List.generate(steps.length, (i) {
                          bool isCompleted = i < _step;
                          bool isActive = i == _step;
                          bool isFuture = i > _step;

                          Color bgColor = isActive
                              ? const Color(0xFF6366F1).withOpacity(0.1)
                              : (isCompleted
                                    ? Colors.green.withOpacity(0.05)
                                    : Colors.transparent);
                          Color borderColor = isActive
                              ? const Color(0xFF6366F1)
                              : (isCompleted
                                    ? Colors.green.withOpacity(0.3)
                                    : Colors.white12);
                          double opacity = isFuture ? 0.4 : 1.0;

                          return Opacity(
                            opacity: opacity,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isCompleted)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 28,
                                    )
                                  else
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? const Color(0xFF6366F1)
                                            : Colors.white24,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${i + 1}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
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
                                          '${t(_lang, 'stepLabel')} ${i + 1}',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white54,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          steps[i].task,
                                          style: TextStyle(
                                            color: isActive
                                                ? Colors.white
                                                : Colors.white70,
                                            fontWeight: isActive
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        if (isCompleted) ...[
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              steps[i].out,
                                              style: const TextStyle(
                                                color: Colors.greenAccent,
                                                fontSize: 13,
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
                        }),
                      ],
                    ),
                  ),
                ),

                // Footer
                Container(
                  padding: const EdgeInsets.all(8),
                  color: const Color(0xFF0F172A),
                  alignment: Alignment.center,
                  child: const Text(
                    '© ZEROSCIENCELAB | Fall in Love with Math and Science',
                    style: TextStyle(fontSize: 10, color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurtain() {
    if (!_showCurtain) return const SizedBox.shrink();
    return Container(
      color: const Color(0xFF0F172A),
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.science, size: 80, color: Color(0xFF6366F1)),
            const SizedBox(height: 24),
            Text(
              t(_lang, 'shutterTitle'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              t(_lang, 'appSubtitle'),
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white54,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_circle_fill, size: 28),
              label: Text(
                t(_lang, 'enterLab'),
                style: const TextStyle(
                  fontSize: 20,
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
              onPressed: () {
                _playSound('curtain');
                setState(() {
                  _showCurtain = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHUD() {
    List<StepConfig> steps = _getScenarioSteps(_scenario);
    String? hudText = (_step < steps.length) ? steps[_step].hud : null;

    if (hudText == null || _showSuccessPopup) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: const Border(
              top: BorderSide(color: Color(0xFF6366F1), width: 4),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
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
                color: Color(0xFF818CF8),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                hudText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessPopup() {
    if (!_showSuccessPopup) return const SizedBox.shrink();
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.flag, color: Colors.greenAccent, size: 64),
            const SizedBox(height: 16),
            Text(
              t(_lang, 'summaryTitle'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              t(_lang, 'finalDesc'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.greenAccent),
            ),
            const SizedBox(height: 32),
            if (_scenario < 5)
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward),
                label: Text(t(_lang, 'nextScenario')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  _playSound('tick');
                  _loadScenario(_scenario + 1);
                },
              )
            else
              ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: Text(t(_lang, 'finishLab')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _handleReset,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            double screenW = constraints.maxWidth;
            double sidebarW = max(300.0, screenW * 0.3);
            double canvasW = _sidebarOpen ? screenW - sidebarW : screenW;
            double canvasLeft = _sidebarOpen ? sidebarW : 0;

            return Stack(
              children: [
                // CANVAS AREA
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  top: 0,
                  bottom: 0,
                  left: canvasLeft,
                  width: canvasW,
                  child: GestureDetector(
                    onScaleStart: _onScaleStart,
                    onScaleUpdate: _onScaleUpdate,
                    onScaleEnd: _onScaleEnd,
                    child: Container(
                      key: _canvasKey,
                      color: const Color(0xFF0F172A),
                      child: ClipRect(
                        child: CustomPaint(
                          painter: NumberFactoryPainter(
                            lang: _lang,
                            scenario: _scenario,
                            step: _step,
                            zoom: _zoom,
                            panX: _panX,
                            panY: _panY,
                            animProgress: _animProgress,
                            animating: _animating,
                            activeDragEntity: _activeDragEntity,
                            dragX: _dragX,
                            dragY: _dragY,

                            kapNum: _kapNum,
                            kapHistory: _kapHistory,
                            kapMax: _kapMax,
                            kapMin: _kapMin,
                            kapRes: _kapRes,
                            kapAnimState: _kapAnimState,
                            kapConst: _kapConst,

                            palNum: _palNum,
                            palRev: _palRev,
                            palSum: _palSum,
                            palHistory: _palHistory,
                            palAnimState: _palAnimState,
                            palExploded: _palExploded,

                            colNum: _colNum,
                            colHistory: _colHistory,
                            colAnimState: _colAnimState,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // SIDEBAR
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  top: 0,
                  bottom: 0,
                  left: _sidebarOpen ? 0 : -sidebarW,
                  width: sidebarW,
                  child: _buildSidebar(sidebarW, constraints.maxHeight),
                ),

                // MENU TOGGLE BUTTON
                Positioned(
                  top: 16,
                  left: 16,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    child: Icon(_sidebarOpen ? Icons.menu_open : Icons.menu),
                    onPressed: () {
                      _playSound('tick');
                      setState(() {
                        _sidebarOpen = !_sidebarOpen;
                      });
                    },
                  ),
                ),

                // HUD OVERLAY
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  top: 0,
                  bottom: 0,
                  left: canvasLeft,
                  width: canvasW,
                  child: _buildHUD(),
                ),

                // POPUPS & CURTAIN
                if (_showSuccessPopup)
                  Positioned.fill(child: _buildSuccessPopup()),

                if (_showCurtain) Positioned.fill(child: _buildCurtain()),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// CUSTOM PAINTER - NATIVE RENDERING
// ============================================================================
class NumberFactoryPainter extends CustomPainter {
  final String lang;
  final int scenario;
  final int step;
  final double zoom;
  final double panX;
  final double panY;

  final double animProgress;
  final bool animating;
  final String? activeDragEntity;
  final double dragX;
  final double dragY;

  // Kaprekar
  final String? kapNum;
  final List<String> kapHistory;
  final String? kapMax;
  final String? kapMin;
  final String? kapRes;
  final String kapAnimState;
  final bool kapConst;

  // Palindrome
  final String? palNum;
  final String? palRev;
  final String? palSum;
  final List<String> palHistory;
  final String palAnimState;
  final bool palExploded;

  // Collatz
  final int? colNum;
  final List<int> colHistory;
  final String colAnimState;

  NumberFactoryPainter({
    required this.lang,
    required this.scenario,
    required this.step,
    required this.zoom,
    required this.panX,
    required this.panY,
    required this.animProgress,
    required this.animating,
    required this.activeDragEntity,
    required this.dragX,
    required this.dragY,

    this.kapNum,
    required this.kapHistory,
    this.kapMax,
    this.kapMin,
    this.kapRes,
    required this.kapAnimState,
    required this.kapConst,
    this.palNum,
    this.palRev,
    this.palSum,
    required this.palHistory,
    required this.palAnimState,
    required this.palExploded,
    this.colNum,
    required this.colHistory,
    required this.colAnimState,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    if (scenario == 1 || scenario == 2) {
      _drawKaprekar(canvas);
    } else if (scenario == 3 || scenario == 5) {
      _drawPalindrome(canvas);
    } else if (scenario == 4) {
      _drawCollatz(canvas);
    }

    canvas.restore();
  }

  // --- DRAWING UTILS ---
  void _drawRoundedRect(
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
    Rect rect = Rect.fromLTWH(x, y, w, h);
    RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(r));

    Paint fillPaint = Paint()
      ..color = fill
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, fillPaint);

    if (lineW > 0) {
      Paint strokePaint = Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineW;
      canvas.drawRRect(rrect, strokePaint);
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y,
    double fontSize,
    Color fillStyle, {
    bool isMonospace = false,
    TextAlign align = TextAlign.center,
  }) {
    TextSpan span = TextSpan(
      text: text,
      style: TextStyle(
        color: fillStyle,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        fontFamily: isMonospace ? 'monospace' : 'sans-serif',
      ),
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: align,
      textDirection: TextDirection.ltr,
    );
    tp.layout();

    double dx = x;
    if (align == TextAlign.center) dx = x - tp.width / 2;
    double dy = y - tp.height / 2;

    tp.paint(canvas, Offset(dx, dy));
  }

  void _drawNumBlock(
    Canvas canvas,
    String num,
    double x,
    double y, {
    double size = 60,
    Color fill = const Color(0xFF6366F1),
  }) {
    _drawRoundedRect(
      canvas,
      x - size / 2,
      y - size / 2,
      size,
      size,
      8,
      fill,
      const Color(0xFF0F172A),
      3,
    );
    _drawText(canvas, num, x, y, size * 0.4, Colors.white, isMonospace: true);
  }

  void _drawButton(
    Canvas canvas,
    String label,
    double x,
    double y,
    double w,
    double h,
    Color color,
    bool disabled,
  ) {
    Color bg = disabled ? const Color(0xFF94A3B8) : color;
    _drawRoundedRect(canvas, x, y, w, h, 8, bg, const Color(0xFF0F172A), 3);
    _drawText(
      canvas,
      label,
      x + w / 2,
      y + h / 2,
      16,
      disabled ? const Color(0xFF475569) : Colors.white,
    );
  }

  // --- SCENARIO 1 & 2: KAPREKAR ---
  void _drawKaprekar(Canvas canvas) {
    String expectedConst = scenario == 1 ? "495" : "6174";

    // Machine Body
    double mx = -250, my = -150, mw = 500, mh = 400;
    _drawRoundedRect(
      canvas,
      mx,
      my,
      mw,
      mh,
      16,
      const Color(0xFF94A3B8),
      const Color(0xFF0F172A),
      5,
    );

    // Hopper
    Path hopperPath = Path();
    hopperPath.moveTo(mx + mw / 2 - 80, my - 60);
    hopperPath.lineTo(mx + mw / 2 + 80, my - 60);
    hopperPath.lineTo(mx + mw / 2 + 40, my);
    hopperPath.lineTo(mx + mw / 2 - 40, my);
    hopperPath.close();
    canvas.drawPath(
      hopperPath,
      Paint()
        ..color = const Color(0xFF475569)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      hopperPath,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    _drawRoundedRect(
      canvas,
      mx + mw / 2 - 40,
      my,
      80,
      20,
      0,
      const Color(0xFF0F172A),
      Colors.transparent,
      0,
    );
    _drawText(canvas, "HOPPER", mx + mw / 2, my - 30, 14, Colors.white);

    // Displays
    _drawRoundedRect(
      canvas,
      mx + 50,
      my + 50,
      150,
      60,
      4,
      const Color(0xFF1E293B),
      const Color(0xFF0F172A),
      3,
    );
    _drawText(canvas, t(lang, 'c_max'), mx + 125, my + 40, 14, Colors.white);

    _drawRoundedRect(
      canvas,
      mx + 300,
      my + 50,
      150,
      60,
      4,
      const Color(0xFF1E293B),
      const Color(0xFF0F172A),
      3,
    );
    _drawText(canvas, t(lang, 'c_min'), mx + 375, my + 40, 14, Colors.white);

    _drawText(
      canvas,
      "-",
      mx + 250,
      my + 80,
      40,
      Colors.redAccent,
      isMonospace: true,
    );

    _drawRoundedRect(
      canvas,
      mx + 150,
      my + 160,
      200,
      70,
      4,
      const Color(0xFF1E293B),
      const Color(0xFF0F172A),
      3,
    );
    _drawText(canvas, t(lang, 'c_res'), mx + 250, my + 150, 14, Colors.white);

    // Conveyor
    _drawRoundedRect(
      canvas,
      mx + 50,
      my + 280,
      400,
      40,
      20,
      const Color(0xFF334155),
      const Color(0xFF0F172A),
      3,
    );
    for (double cx = mx + 70; cx < mx + 440; cx += 30) {
      canvas.drawCircle(
        Offset(cx, my + 300),
        10,
        Paint()
          ..color = const Color(0xFF64748B)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        Offset(cx, my + 300),
        10,
        Paint()
          ..color = const Color(0xFF0F172A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Values
    if (kapMax != null) {
      _drawText(
        canvas,
        kapMax!,
        mx + 125,
        my + 80,
        30,
        Colors.greenAccent,
        isMonospace: true,
      );
    }
    if (kapMin != null) {
      _drawText(
        canvas,
        kapMin!,
        mx + 375,
        my + 80,
        30,
        Colors.blueAccent,
        isMonospace: true,
      );
    }
    if (kapRes != null) {
      _drawText(
        canvas,
        kapRes!,
        mx + 250,
        my + 195,
        36,
        Colors.amberAccent,
        isMonospace: true,
      );
    }

    // Constant Found Banner
    if (kapConst) {
      _drawRoundedRect(
        canvas,
        mx + 100,
        my - 120,
        300,
        60,
        8,
        Colors.amberAccent,
        const Color(0xFF0F172A),
        4,
      );
      _drawText(
        canvas,
        "$expectedConst ${t(lang, 'c_const')}",
        mx + 250,
        my - 90,
        20,
        const Color(0xFF0F172A),
      );
    }

    // Controls
    double bStartX = mx + mw + 40;
    double bStartY = my;
    String sLabel = scenario == 1 ? '351' : '6382';

    _drawRoundedRect(
      canvas,
      bStartX,
      bStartY,
      180,
      200,
      8,
      const Color(0xFFCBD5E1),
      const Color(0xFF0F172A),
      3,
    );
    _drawText(
      canvas,
      "PARTS BIN",
      bStartX + 90,
      bStartY + 20,
      14,
      const Color(0xFF0F172A),
    );

    if (kapNum == null && activeDragEntity == null) {
      _drawNumBlock(canvas, sLabel, bStartX + 90, bStartY + 100);
    }
    if (activeDragEntity == 'block') {
      _drawNumBlock(canvas, sLabel, dragX, dragY);
    }

    if (kapNum != null) {
      double bx = mx + mw / 2;
      double by = my + 260;
      if (kapAnimState == 'sorting') {
        by = (my - 50) * (1 - animProgress) + (my + 80) * animProgress;
      } else if (kapAnimState == 'sub') {
        by = (my + 195) * animProgress + (my + 260) * (1 - animProgress);
      }
      if (kapAnimState == 'idle' && !kapConst) {
        _drawNumBlock(canvas, kapNum!, bx, by);
      }
    }

    Color startBtnCol = (step == 1 && kapNum != null)
        ? Colors.green
        : const Color(0xFF64748B);
    Color contBtnCol = (step >= 2 && kapRes != null && !kapConst)
        ? Colors.blue
        : const Color(0xFF64748B);

    _drawButton(
      canvas,
      t(lang, 'lbl_start'),
      mx + mw / 2 - 120,
      my + 340,
      100,
      40,
      startBtnCol,
      kapNum == null || step != 1,
    );
    _drawButton(
      canvas,
      t(lang, 'lbl_continue'),
      mx + mw / 2 + 20,
      my + 340,
      120,
      40,
      contBtnCol,
      step < 2 || kapRes == null || kapConst,
    );

    // History Panel
    double hx = mx - 220;
    double hy = my;
    _drawRoundedRect(
      canvas,
      hx,
      hy,
      180,
      400,
      8,
      const Color(0xFFF8FAFC),
      const Color(0xFF0F172A),
      3,
    );
    _drawText(
      canvas,
      t(lang, 'c_history'),
      hx + 90,
      hy + 20,
      14,
      const Color(0xFF0F172A),
    );
    for (int i = 0; i < kapHistory.length; i++) {
      _drawText(
        canvas,
        kapHistory[i],
        hx + 90,
        hy + 60 + i * 30,
        16,
        const Color(0xFF0F172A),
        isMonospace: true,
      );
    }
  }

  // --- SCENARIO 3 & 5: PALINDROME BRIDGE ---
  void _drawPalindrome(Canvas canvas) {
    String startLabel = scenario == 3 ? '47' : '196';

    // Environment
    canvas.drawRect(
      const Rect.fromLTWH(-2000, 150, 4000, 1000),
      Paint()..color = const Color(0xFF14532D),
    );

    // Cliffs
    Paint cliffPaint = Paint()
      ..color = const Color(0xFF78350F)
      ..style = PaintingStyle.fill;
    Paint cliffStroke = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    canvas.drawRect(const Rect.fromLTWH(-400, 0, 300, 400), cliffPaint);
    canvas.drawRect(const Rect.fromLTWH(-400, 0, 300, 400), cliffStroke);
    canvas.drawRect(const Rect.fromLTWH(100, 0, 300, 400), cliffPaint);
    canvas.drawRect(const Rect.fromLTWH(100, 0, 300, 400), cliffStroke);

    // Platform Left
    _drawRoundedRect(
      canvas,
      -300,
      -20,
      150,
      20,
      0,
      const Color(0xFF475569),
      const Color(0xFF0F172A),
      3,
    );

    // Cloner Gear
    _drawRoundedRect(
      canvas,
      -380,
      -60,
      60,
      60,
      4,
      const Color(0xFF94A3B8),
      const Color(0xFF0F172A),
      3,
    );
    canvas.drawCircle(
      const Offset(-350, -30),
      15,
      Paint()
        ..color = const Color(0xFF64748B)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      const Offset(-350, -30),
      15,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Bridge Segments
    bool bridgeComplete = palAnimState == 'success';
    int bridgeDraw = bridgeComplete ? 5 : (palHistory.isNotEmpty ? 2 : 0);
    for (int i = 0; i < bridgeDraw; i++) {
      _drawRoundedRect(
        canvas,
        -100 + i * 40,
        0,
        40,
        20,
        0,
        Colors.amber.shade700,
        const Color(0xFF0F172A),
        3,
      );
    }

    // Target Palace S3
    if (scenario == 3) {
      _drawRoundedRect(
        canvas,
        150,
        -100,
        100,
        100,
        0,
        Colors.yellow.shade400,
        const Color(0xFF0F172A),
        4,
      );
      _drawRoundedRect(
        canvas,
        175,
        -50,
        50,
        50,
        0,
        Colors.yellow.shade700,
        const Color(0xFF0F172A),
        3,
      );
      Path roof = Path()
        ..moveTo(130, -100)
        ..lineTo(200, -150)
        ..lineTo(270, -100)
        ..close();
      canvas.drawPath(
        roof,
        Paint()
          ..color = Colors.redAccent
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        roof,
        Paint()
          ..color = const Color(0xFF0F172A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    // Entities
    if (palNum == null && activeDragEntity == null) {
      _drawNumBlock(canvas, startLabel, -450, -50);
    }
    if (activeDragEntity == 'block') {
      _drawNumBlock(canvas, startLabel, dragX, dragY);
    }

    if (palNum != null) {
      double px = -225;
      double py = -50;
      double textSz = palNum!.length > 4 ? 12 : 24;

      if (palExploded) {
        // Vortex
        canvas.save();
        canvas.translate(0, 100);
        double rot = DateTime.now().millisecondsSinceEpoch / 200;
        canvas.rotate(rot);
        for (int i = 0; i < 10; i++) {
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset.zero,
              width: 160.0 + i * 20,
              height: 80.0 + i * 10,
            ),
            Paint()
              ..color = Colors.deepPurpleAccent.withOpacity(1 - i / 10)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
        }
        canvas.restore();
        _drawText(
          canvas,
          palNum!,
          0,
          100,
          textSz,
          Colors.white,
          isMonospace: true,
        );

        _drawRoundedRect(
          canvas,
          -150,
          -150,
          300,
          60,
          8,
          Colors.redAccent,
          const Color(0xFF0F172A),
          4,
        );
        _drawText(canvas, t(lang, 'c_warn'), 0, -120, 18, Colors.white);
      } else if (palAnimState == 'clone') {
        double rx = -225 + 100 * animProgress;
        _drawNumBlock(canvas, palNum!, -225, py);
        _drawNumBlock(
          canvas,
          palRev ?? palNum!,
          rx,
          py,
          fill: Colors.blueAccent,
        );
      } else if (palAnimState == 'merge') {
        double lx = -225 + 150 * animProgress;
        double rx = -125 + 50 * (1 - animProgress);
        _drawNumBlock(canvas, palNum!, lx, py);
        _drawNumBlock(canvas, palRev!, rx, py, fill: Colors.blueAccent);
      } else if (palAnimState == 'scan' ||
          palAnimState == 'result' ||
          palAnimState == 'success') {
        _drawNumBlock(canvas, palSum!, 0, py, fill: Colors.amberAccent);
        _drawText(
          canvas,
          palSum!,
          0,
          py,
          textSz,
          Colors.black,
          isMonospace: true,
        );

        // Laser
        if (palAnimState == 'scan') {
          canvas.drawLine(
            const Offset(0, -200),
            Offset(0, py - 30),
            Paint()
              ..color = Colors.cyanAccent
              ..strokeWidth = 4,
          );
          _drawText(canvas, t(lang, 'c_pal_scan'), 0, -220, 16, Colors.white);
        } else if (palAnimState == 'success') {
          _drawText(
            canvas,
            t(lang, 'c_pal_yes'),
            0,
            -220,
            18,
            Colors.greenAccent,
          );
        } else if (palAnimState == 'result') {
          _drawText(canvas, t(lang, 'c_pal_no'), 0, -220, 18, Colors.redAccent);
        }
      } else {
        _drawNumBlock(canvas, palNum!, px, py);
        _drawText(
          canvas,
          palNum!,
          px,
          py,
          textSz,
          Colors.white,
          isMonospace: true,
        );
      }
    }

    // Controls
    Color tCol = (step == 1 && palNum != null)
        ? Colors.blue
        : const Color(0xFF64748B);
    Color mCol = (step == 2 && palRev != null)
        ? Colors.amberAccent
        : const Color(0xFF64748B);
    Color cCol = (scenario == 5 && step == 2 && palSum != null)
        ? Colors.redAccent
        : const Color(0xFF64748B);

    _drawButton(
      canvas,
      t(lang, 'lbl_transform'),
      -350,
      100,
      120,
      40,
      tCol,
      palNum == null || step != 1,
    );
    _drawButton(
      canvas,
      t(lang, 'lbl_merge'),
      -200,
      100,
      100,
      40,
      mCol,
      palRev == null || step != 2,
    );
    if (scenario == 5) {
      _drawButton(
        canvas,
        t(lang, 'lbl_continue'),
        -50,
        100,
        100,
        40,
        cCol,
        palSum == null || step < 2,
      );
    }

    // History Panel S5
    if (scenario == 5) {
      double hx = 200;
      double hy = -150;
      _drawRoundedRect(
        canvas,
        hx,
        hy,
        180,
        300,
        8,
        const Color(0xFFF8FAFC),
        const Color(0xFF0F172A),
        3,
      );
      _drawText(
        canvas,
        t(lang, 'c_history'),
        hx + 90,
        hy + 20,
        14,
        const Color(0xFF0F172A),
      );
      for (int i = 0; i < palHistory.length; i++) {
        _drawText(
          canvas,
          palHistory[i],
          hx + 90,
          hy + 50 + i * 20,
          12,
          const Color(0xFF0F172A),
          isMonospace: true,
        );
      }
    }
  }

  // --- SCENARIO 4: COLLATZ ---
  void _drawCollatz(Canvas canvas) {
    // Mountain
    Path mtPath = Path()
      ..moveTo(-600, 400)
      ..lineTo(0, -200)
      ..lineTo(600, 400)
      ..close();
    canvas.drawPath(
      mtPath,
      Paint()
        ..color = const Color(0xFF334155)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      mtPath,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // Cottage
    _drawRoundedRect(
      canvas,
      -50,
      350,
      100,
      60,
      0,
      const Color(0xFF78350F),
      const Color(0xFF0F172A),
      4,
    );
    Path roof = Path()
      ..moveTo(-60, 350)
      ..lineTo(0, 300)
      ..lineTo(60, 350)
      ..close();
    canvas.drawPath(
      roof,
      Paint()
        ..color = Colors.red.shade700
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      roof,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    _drawText(canvas, "1", 0, 380, 24, Colors.white, isMonospace: true);

    // Paths UI
    _drawRoundedRect(
      canvas,
      -200,
      -100,
      120,
      40,
      8,
      Colors.blueAccent,
      const Color(0xFF0F172A),
      3,
    );
    _drawText(canvas, t(lang, 'c_even'), -140, -80, 14, Colors.white);

    _drawRoundedRect(
      canvas,
      80,
      -100,
      120,
      40,
      8,
      Colors.redAccent,
      const Color(0xFF0F172A),
      3,
    );
    _drawText(canvas, t(lang, 'c_odd'), 140, -80, 14, Colors.white);

    // History Graph
    if (colHistory.isNotEmpty) {
      Path graphPath = Path();
      for (int i = 0; i < colHistory.length; i++) {
        double gx = -400.0 + i * 40;
        double gy = 200.0 - (colHistory[i] * 10);
        if (i == 0) {
          graphPath.moveTo(gx, gy);
        } else {
          graphPath.lineTo(gx, gy);
        }
      }
      canvas.drawPath(
        graphPath,
        Paint()
          ..color = Colors.amberAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );

      for (int i = 0; i < colHistory.length; i++) {
        double gx = -400.0 + i * 40;
        double gy = 200.0 - (colHistory[i] * 10);
        canvas.drawCircle(
          Offset(gx, gy),
          5,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          Offset(gx, gy),
          5,
          Paint()
            ..color = const Color(0xFF0F172A)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
      }
    }

    // Current Num
    if (colNum == null && activeDragEntity == null) {
      _drawNumBlock(canvas, "12", -300, -200);
    }
    if (activeDragEntity == 'block') {
      _drawNumBlock(canvas, "12", dragX, dragY);
    }

    if (colNum != null) {
      double cy = -200;
      double cx = 0;
      if (colAnimState == 'eval') {
        cx = (colNum! % 2 == 0) ? -140 : 140;
        cy = -150;
      } else if (colAnimState == 'done') {
        cx = 0;
        cy = 350;
      }
      _drawNumBlock(canvas, colNum!.toString(), cx, cy);
    }

    Color startBtnCol = (step == 1 && colNum != null && colAnimState == 'idle')
        ? Colors.green
        : const Color(0xFF64748B);
    _drawButton(
      canvas,
      t(lang, 'lbl_start'),
      -50,
      -280,
      100,
      40,
      startBtnCol,
      colNum == null || step != 1,
    );
  }

  @override
  bool shouldRepaint(covariant NumberFactoryPainter oldDelegate) {
    return true; // Simple approach to ensure continuous 60fps repaints during animations
  }
}
