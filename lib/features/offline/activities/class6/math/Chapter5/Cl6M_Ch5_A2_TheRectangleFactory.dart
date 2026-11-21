// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: unnecessary_to_list_in_spreads, constant_identifier_names, use_super_parameters, camel_case_types, deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(
      MaterialApp(
        title: 'The Rectangle Factory',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F172A),
          fontFamily: 'Plus Jakarta Sans',
        ),
        home: const Cl6M_Ch5_A2_TheRectangleFactory(),
      ),
    );
  });
}

// --- CONSTANTS ---
const double CELL_SIZE = 36.0;
const int GRID_COLS = 18;
const int GRID_ROWS = 18;
const double GRID_X = -324.0;
const double GRID_Y = -120.0;

// --- DATA CLASSES ---

class RectBlock {
  double x, y;
  double targetX, targetY;
  int? gridX, gridY;
  bool isDragging;

  RectBlock({
    required this.x,
    required this.y,
    required this.targetX,
    required this.targetY,
    this.gridX,
    this.gridY,
    this.isDragging = false,
  });
}

class LoggedArrangement {
  final int w;
  final int h;
  LoggedArrangement(this.w, this.h);
}

// --- AUDIO ENGINE ---

class AudioEngine {
  static final AudioPlayer _player1 = AudioPlayer();
  static final AudioPlayer _player2 = AudioPlayer();
  static final AudioPlayer _player3 = AudioPlayer();
  static int _currentPlayer = 1;

  static const String sndTick = 'audio/class6/math/click.mp3';
  static const String sndSuccess = 'audio/class6/math/success.mp3';
  static const String sndError = 'audio/class6/math/mixkit_2955.mp3';
  static const String sndSnap = 'audio/class6/math/mixkit_3005.mp3';
  static const String sndPop = 'audio/class6/math/mixkit_2964.mp3';

  static Future<void> play(String url) async {
    try {
      AudioPlayer player;
      if (_currentPlayer == 1) {
        player = _player1;
        _currentPlayer = 2;
      } else if (_currentPlayer == 2) {
        player = _player2;
        _currentPlayer = 3;
      } else {
        player = _player3;
        _currentPlayer = 1;
      }

      await player.stop();
      await player.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  static void tick() => play(sndTick);
  static void success() => play(sndSuccess);
  static void error() => play(sndError);
  static void snap() => play(sndSnap);
  static void pop() => play(sndPop);
}

// --- LOCALIZATION ---

const Map<String, Map<String, String>> TRANSLATIONS = {
  'en': {
    'resetBtn': 'Reset Lab',
    'shutterTitle': 'The Rectangle Factory',
    'appTitle': 'The Rectangle Factory',
    'appSubtitle': 'Class 6 • Prime and Composite Numbers',
    'enterLab': 'Enter Simulation',
    'selectScenario': 'Select Scenario',
    'stepLabel': 'STEP',
    'learnLbl': 'Objective:',
    'nextScenario': 'Next Scenario',
    'finishLab': 'Finish Lab',
    'summaryTitle': 'Goal Reached!',
    'finalDesc':
        'You have successfully classified numbers by finding their rectangular arrangements!',

    'lbl_start_packing': 'START PACKING',
    'lbl_log_arr': 'LOG ARRANGEMENT',
    'lbl_arr_found': 'Arrangements Found',
    'lbl_duplicate': 'Duplicate!',
    'lbl_prime': 'PRIME',
    'lbl_composite': 'COMPOSITE',
    'lbl_neither': 'NEITHER',
    'lbl_dispenser': 'DISPENSER',
    'lbl_grid': 'ARRANGEMENT GRID',

    's1_title': '1. The Prime Package (7)',
    's1_obj':
        'Understand the visual definition of a prime number by packing 7 blocks.',
    's1_step1_task': "Click the 'Start Packing' button to dispense 7 blocks.",
    's1_step1_out': "7 blocks are now on the grid.",
    's1_step2_task':
        "DRAG the 7 blocks to form a perfect rectangle. Click 'Log Arrangement' to save. Find all possible ways.",
    's1_step2_out': "Only 1x7 and 7x1 rectangles can be formed.",
    's1_step3_task':
        "Observe the number of arrangements found for the number 7.",
    's1_step3_out': "Since only 2 arrangements exist, 7 is a PRIME number.",
    's1_hud1': "Click 'Start Packing' to drop 7 blocks.",
    's1_hud2': "Drag blocks into a perfect rectangle. Click Log.",
    's1_hud3': "Observe the result.",

    's2_title': '2. The Composite Crate (12)',
    's2_obj':
        'Understand composite numbers by packing 12 blocks in multiple ways.',
    's2_step1_task': "Click 'Start Packing' to dispense 12 blocks.",
    's2_step1_out': "12 blocks are ready to be packed.",
    's2_step2_task':
        "DRAG the 12 blocks into perfect rectangles. Log each unique shape you find.",
    's2_step2_out': "You found 1x12, 12x1, 2x6, 6x2, 3x4, and 4x3.",
    's2_step3_task': "Observe the 'Logged Designs' panel.",
    's2_step3_out':
        "Because 12 can form multiple rectangles, it is a COMPOSITE number.",
    's2_hud1': "Click 'Start Packing' to drop 12 blocks.",
    's2_hud2': "Find as many rectangle shapes as possible! Log them.",
    's2_hud3': "Observe the result.",

    's3_title': '3. The Special Singleton (1)',
    's3_obj': 'Understand why the number 1 is a special case.',
    's3_step1_task': "Click 'Start Packing' to dispense 1 block.",
    's3_step1_out': "1 block is available.",
    's3_step2_task': "Form a rectangle and Log the arrangement.",
    's3_step2_out': "You found a 1x1 square.",
    's3_step3_task': "Observe the result for the number 1.",
    's3_step3_out':
        "Only 1 arrangement exists. It is NEITHER prime NOR composite.",
    's3_hud1': "Click 'Start Packing' to drop 1 block.",
    's3_hud2': "Log the only possible arrangement.",
    's3_hud3': "Observe the result.",

    's4_title': '4. Sorting Challenge (13)',
    's4_obj':
        'Classify the number 13 as Prime or Composite by finding its arrangements.',
    's4_step1_task':
        "Click 'Start Packing'. Find at least one arrangement for 13 to unlock the sorting token.",
    's4_step1_out': "13 blocks can only form 1x13 and 13x1.",
    's4_step2_task':
        "DRAG the number '13' token into the correct bin at the bottom.",
    's4_step2_out': "Correct! 13 is a PRIME number.",
    's4_hud1': "Find a valid arrangement for 13 blocks.",
    's4_hud2': "Drag the '13' token to the correct bin.",

    's5_title': '5. Sorting Challenge (18)',
    's5_obj': 'Classify the number 18 as Prime or Composite.',
    's5_step1_task':
        "Click 'Start Packing'. Find at least two unique arrangements for 18 blocks to unlock the sorting token.",
    's5_step1_out': "18 blocks can form multiple arrangements.",
    's5_step2_task': "DRAG the number '18' token into the correct bin.",
    's5_step2_out': "Correct! 18 is a COMPOSITE number.",
    's5_hud1': "Find at least 2 arrangements for 18 blocks.",
    's5_hud2': "Drag the '18' token to the correct bin.",
  },
  'hi': {
    'resetBtn': 'रीसेट करें',
    'shutterTitle': 'आयत फैक्टरी (Rectangle Factory)',
    'appTitle': 'आयत फैक्टरी',
    'appSubtitle': 'कक्षा 6 • अभाज्य और भाज्य संख्याएँ',
    'enterLab': 'सिमुलेशन दर्ज करें',
    'selectScenario': 'परिदृश्य चुनें',
    'stepLabel': 'चरण',
    'learnLbl': 'उद्देश्य:',
    'nextScenario': 'अगला परिदृश्य',
    'finishLab': 'समाप्त करें',
    'summaryTitle': 'लक्ष्य प्राप्त हुआ!',
    'finalDesc':
        'आपने आयताकार व्यवस्थाएं खोजकर संख्याओं को सफलतापूर्वक वर्गीकृत किया है!',

    'lbl_start_packing': 'पैकिंग शुरू करें',
    'lbl_log_arr': 'व्यवस्था लॉग करें',
    'lbl_arr_found': 'मिली व्यवस्थाएं',
    'lbl_duplicate': 'डुप्लिकेट!',
    'lbl_prime': 'अभाज्य (PRIME)',
    'lbl_composite': 'भाज्य (COMPOSITE)',
    'lbl_neither': 'ना अभाज्य, ना भाज्य',
    'lbl_dispenser': 'डिस्पेंसर',
    'lbl_grid': 'व्यवस्था ग्रिड',

    's1_title': '1. प्राइम पैकेज (7)',
    's1_obj': '7 ब्लॉकों को पैक करके अभाज्य संख्या की परिभाषा समझें।',
    's1_step1_task':
        "7 ব্লক प्राप्त करने के लिए 'पैकिंग शुरू करें' पर क्लिक करें।",
    's1_step1_out': "7 ब्लॉक अब ग्रिड पर हैं।",
    's1_step2_task':
        "7 ब्लॉकों को खींचकर एक पूर्ण आयत बनाएं। 'व्यवस्था लॉग करें' पर क्लिक करें। सभी संभव तरीके खोजें।",
    's1_step2_out': "केवल 1x7 और 7x1 आयत बन सकते हैं।",
    's1_step3_task': "संख्या 7 के लिए मिली व्यवस्थाओं का निरीक्षण करें।",
    's1_step3_out':
        "चूंकि केवल 2 व्यवस्थाएं हैं, 7 एक अभाज्य (PRIME) संख्या है।",
    's1_hud1': "7 ब्लॉक गिराने के लिए 'पैकिंग शुरू करें' पर क्लिक करें।",
    's1_hud2': "ब्लॉकों को आयत में व्यवस्थित करें। लॉग करें।",
    's1_hud3': "परिणाम का निरीक्षण करें।",

    's2_title': '2. भाज्य क्रेट (12)',
    's2_obj': '12 ब्लॉकों को कई तरीकों से पैक करके भाज्य संख्याओं को समझें।',
    's2_step1_task':
        "12 ब्लॉक प्राप्त करने के लिए 'पैकिंग शुरू करें' पर क्लिक करें।",
    's2_step1_out': "12 ब्लॉक पैक होने के लिए तैयार हैं।",
    's2_step2_task':
        "12 ब्लॉकों को आयतों में खींचें। आपके द्वारा खोजे गए प्रत्येक अद्वितीय आकार को लॉग करें।",
    's2_step2_out': "आपने 1x12, 12x1, 2x6, 6x2, 3x4, और 4x3 खोजे।",
    's2_step3_task': "'मिली व्यवस्थाएं' पैनल का निरीक्षण करें।",
    's2_step3_out':
        "चूंकि 12 कई आयत बना सकता है, यह एक भाज्य (COMPOSITE) संख्या है।",
    's2_hud1': "12 ब्लॉक गिराने के लिए 'पैकिंग शुरू करें' पर क्लिक करें।",
    's2_hud2': "जितने हो सके उतने आयत आकार खोजें! उन्हें लॉग करें।",
    's2_hud3': "परिणाम का निरीक्षण करें।",

    's3_title': '3. विशेष एकल (1)',
    's3_obj': 'समझें कि संख्या 1 एक विशेष स्थिति क्यों है।',
    's3_step1_task':
        "1 ब्लॉक प्राप्त करने के लिए 'पैकिंग शुरू करें' पर क्लिक करें।",
    's3_step1_out': "1 ब्लॉक उपलब्ध है।",
    's3_step2_task': "एक आयत बनाएं और व्यवस्था को लॉग करें।",
    's3_step2_out': "आपने 1x1 वर्ग खोजा।",
    's3_step3_task': "संख्या 1 के परिणाम का निरीक्षण करें।",
    's3_step3_out': "केवल 1 व्यवस्था मौजूद है। यह ना अभाज्य है ना भाज्य।",
    's3_hud1': "1 ब्लॉक गिराने के लिए 'पैकिंग शुरू करें' पर क्लिक करें।",
    's3_hud2': "एकमात्र संभव व्यवस्था को लॉग करें।",
    's3_hud3': "परिणाम का निरीक्षण करें।",

    's4_title': '4. छँटाई चुनौती (13)',
    's4_obj': 'संख्या 13 को अभाज्य या भाज्य के रूप में वर्गीकृत करें।',
    's4_step1_task':
        "'पैकिंग शुरू करें' पर क्लिक करें। टोकन को अनलॉक करने के लिए 13 के लिए कम से कम एक व्यवस्था खोजें।",
    's4_step1_out': "13 ब्लॉक केवल 1x13 और 13x1 बना सकते हैं।",
    's4_step2_task': "नीचे सही बिन में संख्या '13' टोकन को खींचें।",
    's4_step2_out': "सही! 13 एक अभाज्य संख्या है।",
    's4_hud1': "13 ब्लॉकों के लिए एक वैध व्यवस्था खोजें।",
    's4_hud2': "'13' टोकन को सही बिन में खींचें।",

    's5_title': '5. छँटाई चुनौती (18)',
    's5_obj': 'संख्या 18 को अभाज्य या भाज्य के रूप में वर्गीकृत करें।',
    's5_step1_task':
        "'पैकिंग शुरू करें' पर क्लिक करें। टोकन को अनलॉक करने के लिए 18 के लिए कम से कम दो व्यवस्थाएं खोजें।",
    's5_step1_out': "18 ब्लॉक कई व्यवस्थाएं बना सकते हैं।",
    's5_step2_task': "संख्या '18' टोकन को सही बिन में खींचें।",
    's5_step2_out': "सही! 18 एक भाज्य संख्या है।",
    's5_hud1': "18 ब्लॉकों के लिए कम से कम 2 व्यवस्थाएं खोजें।",
    's5_hud2': "'18' टोकन को सही बिन में खींचें।",
  },
};

class ScenarioConfig {
  final String title;
  final String objective;
  final List<Map<String, String>> steps;
  ScenarioConfig(this.title, this.objective, this.steps);
}

// --- MAIN APP SCREEN ---

class Cl6M_Ch5_A2_TheRectangleFactory extends StatefulWidget {
  const Cl6M_Ch5_A2_TheRectangleFactory({Key? key}) : super(key: key);

  @override
  State<Cl6M_Ch5_A2_TheRectangleFactory> createState() =>
      _Cl6M_Ch5_A2_TheRectangleFactoryState();
}

class _Cl6M_Ch5_A2_TheRectangleFactoryState
    extends State<Cl6M_Ch5_A2_TheRectangleFactory>
    with SingleTickerProviderStateMixin {
  // UI State
  bool _showCurtain = true;
  bool _sidebarOpen = true;
  double _sidebarWidth = 300;
  String _lang = 'en';
  bool _showSuccessPopup = false;

  // Game/Simulation State
  int _scenario = 1;
  int _step = 0;
  int _targetNumber = 7;

  final List<RectBlock> _blocks = [];
  final List<LoggedArrangement> _logged = [];
  bool _isRectangleValid = false;
  LoggedArrangement? _currentRectBounds;

  bool _showToken = false;
  bool _draggedToken = false;
  double _tokenX = 0;
  double _tokenY = 200;

  String _msgOverlay = "";
  int _msgTimer = 0;

  // Viewport/Canvas State
  double _panX = 0;
  double _panY = 0;
  double _zoom = 1.0;

  // Gesture tracking
  double _initialZoom = 1.0;
  RectBlock? _draggingBlock;

  // Animation
  late AnimationController _controller;
  bool _animating = false;
  int _animationFrames = 0;

  final GlobalKey _canvasKey = GlobalKey();

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
    )..addListener(_gameLoop);

    _controller.repeat();
    _loadScenario(1);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.dispose();
    super.dispose();
  }

  String t(String key) {
    return TRANSLATIONS[_lang]?[key] ?? TRANSLATIONS['en']![key] ?? key;
  }

  ScenarioConfig _getScenarioConfig(int id) {
    int numSteps = (id <= 3) ? 3 : 2;
    List<Map<String, String>> steps = [];
    for (int i = 1; i <= numSteps; i++) {
      steps.add({
        'hud': t('s${id}_hud$i'),
        'task': t('s${id}_step${i}_task'),
        'outcome': t('s${id}_step${i}_out'),
      });
    }
    return ScenarioConfig(t('s${id}_title'), t('s${id}_obj'), steps);
  }

  void _gameLoop() {
    // Fading messages
    if (_msgTimer > 0) {
      setState(() {
        _msgTimer--;
        if (_msgTimer <= 0) _msgOverlay = "";
      });
    }

    // Block arrival animation
    if (_animating) {
      setState(() {
        _animationFrames++;
        for (int i = 0; i < _blocks.length; i++) {
          int delay = i * 4;
          if (_animationFrames > delay) {
            double p = min(1.0, (_animationFrames - delay) / 30.0);
            p = Curves.easeOutCubic.transform(p);
            _blocks[i].x = -100 + (_blocks[i].targetX - -100) * p;
            _blocks[i].y = -280 + (_blocks[i].targetY - -280) * p;
          }
        }

        if (_animationFrames > 30 + _blocks.length * 4) {
          _animating = false;
          for (var b in _blocks) {
            b.x = b.targetX;
            b.y = b.targetY;
          }
          if (_scenario <= 3 && _step == 0) _advanceStep();
        }
      });
    }
  }

  void _loadScenario(int id) {
    setState(() {
      if (id == 1) _showCurtain = true;
      _scenario = id;
      _step = 0;
      _animating = false;
      _animationFrames = 0;
      _showSuccessPopup = false;
      _msgOverlay = "";
      _msgTimer = 0;

      if (id == 1) _targetNumber = 7;
      if (id == 2) _targetNumber = 12;
      if (id == 3) _targetNumber = 1;
      if (id == 4) _targetNumber = 13;
      if (id == 5) _targetNumber = 18;

      _blocks.clear();
      _logged.clear();
      _isRectangleValid = false;
      _showToken = false;
      _draggedToken = false;
      _tokenX = 0;
      _tokenY = 200;

      _panX = 0;
      _panY = 0;
      _zoom = 0.8;
    });
    AudioEngine.pop();
  }

  void _advanceStep() {
    setState(() {
      _step++;
    });
  }

  void _checkScenarioSuccess() {
    final conf = _getScenarioConfig(_scenario);
    setState(() {
      _step = conf.steps.length;
    });
    if (_scenario == 5) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        AudioEngine.success();
        setState(() {
          _showSuccessPopup = true;
        });
      });
    } else {
      Future.delayed(const Duration(milliseconds: 1000), () {
        AudioEngine.success();
        setState(() {
          _showSuccessPopup = true;
        });
      });
    }
  }

  void _triggerAction(String actionType) {
    if (actionType == 'start_packing') {
      if (_animating || _blocks.isNotEmpty) return;
      setState(() {
        _animating = true;
        _animationFrames = 0;

        double targetStartX = -500;
        double targetStartY = -40;

        for (int i = 0; i < _targetNumber; i++) {
          int col = i % 3;
          int row = i ~/ 3;
          _blocks.add(
            RectBlock(
              x: -100,
              y: -280,
              targetX: targetStartX + col * (CELL_SIZE + 5),
              targetY: targetStartY + row * (CELL_SIZE + 5),
            ),
          );
        }
      });
      AudioEngine.pop();
    } else if (actionType == 'log') {
      if (!_isRectangleValid || _currentRectBounds == null) return;

      int w = _currentRectBounds!.w;
      int h = _currentRectBounds!.h;
      bool exists = _logged.any((l) => l.w == w && l.h == h);

      if (exists) {
        AudioEngine.error();
        setState(() {
          _msgOverlay = t('lbl_duplicate');
          _msgTimer = 100;
        });
      } else {
        AudioEngine.success();
        setState(() {
          _logged.add(LoggedArrangement(w, h));

          int targetLogs = 0;
          if (_targetNumber == 7) {
            targetLogs = 2;
          } else if (_targetNumber == 12) {
            targetLogs = 6;
          } else if (_targetNumber == 1) {
            targetLogs = 1;
          } else if (_targetNumber == 13) {
            targetLogs = 2;
          } else if (_targetNumber == 18) {
            targetLogs = 6;
          }

          if (_scenario <= 3) {
            if (_logged.length == targetLogs) {
              Future.delayed(const Duration(milliseconds: 800), () {
                _advanceStep();
                if (_step == 2) {
                  Future.delayed(
                    const Duration(milliseconds: 500),
                    _checkScenarioSuccess,
                  );
                }
              });
            }
          } else {
            // Challenges
            if (_scenario == 4 && _logged.isNotEmpty && _step == 0) {
              _showToken = true;
              _advanceStep();
              AudioEngine.pop();
            }
            if (_scenario == 5 && _logged.length >= 2 && _step == 0) {
              _showToken = true;
              _advanceStep();
              AudioEngine.pop();
            }
          }
        });
      }
    }
  }

  void _checkRectangleValidity() {
    if (_blocks.isEmpty || _blocks.any((b) => b.gridX == null)) {
      _isRectangleValid = false;
      return;
    }

    int minX = 999, maxX = -999, minY = 999, maxY = -999;
    Set<String> occupied = {};

    for (var b in _blocks) {
      if (b.gridX! < minX) minX = b.gridX!;
      if (b.gridX! > maxX) maxX = b.gridX!;
      if (b.gridY! < minY) minY = b.gridY!;
      if (b.gridY! > maxY) maxY = b.gridY!;
      occupied.add('${b.gridX},${b.gridY}');
    }

    int w = maxX - minX + 1;
    int h = maxY - minY + 1;

    if (w * h == _targetNumber && occupied.length == _targetNumber) {
      _isRectangleValid = true;
      _currentRectBounds = LoggedArrangement(w, h);
    } else {
      _isRectangleValid = false;
      _currentRectBounds = null;
    }
  }

  // --- GESTURE HANDLING ---

  void _onTapDown(TapDownDetails details) {
    if (_canvasKey.currentContext == null) return;

    final RenderBox box =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final Offset localPos = box.globalToLocal(details.globalPosition);

    double worldX = (localPos.dx - box.size.width / 2 - _panX) / _zoom;
    double worldY = (localPos.dy - box.size.height / 2 - _panY) / _zoom;

    if (!_animating) {
      // 1. Buttons Check for quick taps (Bypasses the delay in scale gestures)
      if (_blocks.isEmpty &&
          worldX > -180 &&
          worldX < -20 &&
          worldY > -240 &&
          worldY < -195) {
        _triggerAction('start_packing');
        return;
      }

      double logBtnX = GRID_X + (GRID_COLS * CELL_SIZE) / 2 - 100;
      double logBtnY = GRID_Y + GRID_ROWS * CELL_SIZE + 30;
      if (_isRectangleValid &&
          worldX > logBtnX &&
          worldX < logBtnX + 200 &&
          worldY > logBtnY &&
          worldY < logBtnY + 50) {
        _triggerAction('log');
        return;
      }
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (_canvasKey.currentContext == null) return;

    final RenderBox box =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final Offset localPos = box.globalToLocal(details.focalPoint);

    double screenX = localPos.dx;
    double screenY = localPos.dy;

    double worldX = (screenX - box.size.width / 2 - _panX) / _zoom;
    double worldY = (screenY - box.size.height / 2 - _panY) / _zoom;

    _initialZoom = _zoom;

    if (!_animating) {
      // 1. Token Check (For Dragging)
      if (_scenario >= 4 &&
          _showToken &&
          worldX > _tokenX - 40 &&
          worldX < _tokenX + 40 &&
          worldY > _tokenY - 40 &&
          worldY < _tokenY + 40) {
        setState(() {
          _draggedToken = true;
          _tokenX = worldX;
          _tokenY = worldY;
        });
        AudioEngine.tick();
        return;
      }

      // 2. Blocks Check (For Dragging - Reverse order for top-most)
      for (int i = _blocks.length - 1; i >= 0; i--) {
        var b = _blocks[i];
        if (worldX > b.x &&
            worldX < b.x + CELL_SIZE &&
            worldY > b.y &&
            worldY < b.y + CELL_SIZE) {
          setState(() {
            b.isDragging = true;
            _draggingBlock = b;
            // Bring to front
            _blocks.removeAt(i);
            _blocks.add(b);
          });
          AudioEngine.tick();
          return;
        }
      }
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_canvasKey.currentContext == null) return;

    final RenderBox box =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final Offset localPos = box.globalToLocal(details.focalPoint);

    double worldX = (localPos.dx - box.size.width / 2 - _panX) / _zoom;
    double worldY = (localPos.dy - box.size.height / 2 - _panY) / _zoom;

    if (_draggedToken) {
      setState(() {
        _tokenX = worldX;
        _tokenY = worldY;
      });
      return;
    }

    if (_draggingBlock != null) {
      setState(() {
        _draggingBlock!.x = worldX - CELL_SIZE / 2;
        _draggingBlock!.y = worldY - CELL_SIZE / 2;
      });
      return;
    }

    // Pan & Zoom
    setState(() {
      _panX += details.focalPointDelta.dx;
      _panY += details.focalPointDelta.dy;
      _zoom = (_initialZoom * details.scale).clamp(0.2, 3.0);
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_draggedToken) {
      setState(() {
        _draggedToken = false;
        double binY = 320;
        bool onPrime =
            _tokenX > -300 &&
            _tokenX < -100 &&
            _tokenY > binY &&
            _tokenY < binY + 100;
        bool onComposite =
            _tokenX > 100 &&
            _tokenX < 300 &&
            _tokenY > binY &&
            _tokenY < binY + 100;

        if ((_scenario == 4 && onPrime) || (_scenario == 5 && onComposite)) {
          AudioEngine.success();
          _showToken = false;
          _advanceStep();
          _checkScenarioSuccess();
        } else if (onPrime || onComposite) {
          AudioEngine.error();
          _tokenX = 0;
          _tokenY = 200;
        } else {
          _tokenX = 0;
          _tokenY = 200;
        }
      });
      return;
    }

    if (_draggingBlock != null) {
      setState(() {
        var b = _draggingBlock!;
        b.isDragging = false;

        int gx = ((b.x - GRID_X) / CELL_SIZE).round();
        int gy = ((b.y - GRID_Y) / CELL_SIZE).round();

        if (gx >= 0 && gx < GRID_COLS && gy >= 0 && gy < GRID_ROWS) {
          bool occupied = _blocks.any(
            (ob) => ob != b && ob.gridX == gx && ob.gridY == gy,
          );
          if (!occupied) {
            b.gridX = gx;
            b.gridY = gy;
            b.x = GRID_X + gx * CELL_SIZE;
            b.y = GRID_Y + gy * CELL_SIZE;
            AudioEngine.snap();
          } else {
            b.x = b.targetX;
            b.y = b.targetY;
            b.gridX = null;
            b.gridY = null;
            AudioEngine.pop();
          }
        } else {
          b.x = b.targetX;
          b.y = b.targetY;
          b.gridX = null;
          b.gridY = null;
          AudioEngine.pop();
        }

        _draggingBlock = null;
        _checkRectangleValidity();
      });
    }
  }

  // --- UI BUILDERS ---

  Widget _buildCurtainRaiser() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOutCubic,
      top: _showCurtain ? 0 : -MediaQuery.of(context).size.height,
      left: 0,
      right: 0,
      height: MediaQuery.of(context).size.height,
      child: Container(
        color: const Color(0xFF0F172A),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 40.0,
                  horizontal: 24.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.6),
                            blurRadius: 40,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.widgets_rounded,
                        size: 100,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      t('shutterTitle'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      t('appSubtitle'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 50),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 10,
                        shadowColor: const Color(0xFF6366F1).withOpacity(0.5),
                      ),
                      icon: const Icon(Icons.play_circle_fill, size: 28),
                      label: Text(
                        t('enterLab'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      onPressed: () {
                        AudioEngine.tick();
                        setState(() => _showCurtain = false);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    final conf = _getScenarioConfig(_scenario);
    return Container(
      color: const Color(0xFF1E293B),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 66,
                        bottom: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withOpacity(0.5),
                        border: const Border(
                          bottom: BorderSide(color: Colors.white10),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.apps_rounded,
                              color: Color(0xFF6366F1),
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t('appTitle'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  t('appSubtitle'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                    color: Colors.white54,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 8,
                                  children: [
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.language,
                                            color: Colors.white70,
                                            size: 22,
                                          ),
                                          Text(
                                            _lang.toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _lang = _lang == 'en' ? 'hi' : 'en';
                                        });
                                      },
                                      tooltip: 'Toggle Language',
                                    ),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.refresh,
                                            color: Colors.redAccent,
                                            size: 22,
                                          ),
                                          Text(
                                            t('resetBtn'),
                                            style: const TextStyle(
                                              color: Colors.redAccent,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      onPressed: () {
                                        AudioEngine.tick();
                                        setState(() {
                                          _showCurtain = true;
                                        });
                                        _loadScenario(1);
                                      },
                                      tooltip: t('resetBtn'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Scrollable Content area takes the remaining space
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t('selectScenario'),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white54,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF334155),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: _scenario,
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF334155),
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.white54,
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  onChanged: (val) {
                                    if (val != null) _loadScenario(val);
                                  },
                                  items: [1, 2, 3, 4, 5].map((id) {
                                    return DropdownMenuItem<int>(
                                      value: id,
                                      child: Text(t('s${id}_title')),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A).withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                        t('learnLbl'),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    conf.objective,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Steps
                            ...conf.steps.asMap().entries.map((entry) {
                              int i = entry.key;
                              var stepData = entry.value;
                              bool isCompleted = i < _step;
                              bool isCurrent =
                                  i == _step && _step != conf.steps.length;
                              bool isFuture = i > _step;

                              Color bg = isCurrent
                                  ? const Color(0xFF6366F1).withOpacity(0.1)
                                  : (isCompleted
                                        ? const Color(
                                            0xFF10B981,
                                          ).withOpacity(0.1)
                                        : Colors.white.withOpacity(0.02));
                              Color border = isCurrent
                                  ? const Color(0xFF6366F1).withOpacity(0.5)
                                  : (isCompleted
                                        ? const Color(
                                            0xFF10B981,
                                          ).withOpacity(0.3)
                                        : Colors.transparent);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: bg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: border),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (isCompleted)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Color(0xFF10B981),
                                        size: 26,
                                      )
                                    else if (isCurrent)
                                      Container(
                                        width: 26,
                                        height: 26,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF6366F1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${i + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      Container(
                                        width: 26,
                                        height: 26,
                                        decoration: const BoxDecoration(
                                          color: Colors.white12,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${i + 1}',
                                            style: const TextStyle(
                                              color: Colors.white54,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
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
                                            '${t('stepLabel')} ${i + 1}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white54,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            stepData['task']!,
                                            style: TextStyle(
                                              color: isFuture
                                                  ? Colors.white30
                                                  : Colors.white,
                                              fontSize: 13,
                                              height: 1.4,
                                            ),
                                          ),
                                          if (isCompleted) ...[
                                            const SizedBox(height: 10),
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFF10B981,
                                                ).withOpacity(0.15),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                stepData['outcome']!,
                                                style: const TextStyle(
                                                  color: Color(0xFF34D399),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),

                    // Footer
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      color: const Color(0xFF0F172A),
                      alignment: Alignment.center,
                      child: const Text(
                        '© ZeroScienceLab - Fall in love with math and Science',
                        style: TextStyle(color: Colors.white30, fontSize: 10),
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

  Widget _buildHUD() {
    final conf = _getScenarioConfig(_scenario);
    String hudTxt = "";
    if (_step < conf.steps.length) hudTxt = conf.steps[_step]['hud']!;

    if (hudTxt.isEmpty) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 30, left: 16, right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border: const Border(
            top: BorderSide(color: Color(0xFF6366F1), width: 3),
          ),
          boxShadow: [
            const BoxShadow(
              color: Colors.black45,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, color: Color(0xFF818CF8), size: 28),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                hudTxt,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.visible,
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessPopup() {
    if (!_showSuccessPopup) return const SizedBox.shrink();
    return Container(
      color: Colors.black87,
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Container(
          width: 450,
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.2),
                blurRadius: 50,
              ),
            ],
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
                    BoxShadow(color: Color(0xFF10B981), blurRadius: 20),
                  ],
                ),
                child: const Icon(Icons.flag, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                t('summaryTitle'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                t('finalDesc'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF34D399),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              if (_scenario < 5)
                ElevatedButton.icon(
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
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(
                    t('nextScenario'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    setState(() => _showSuccessPopup = false);
                    _loadScenario(_scenario + 1);
                  },
                )
              else
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.home),
                  label: Text(
                    t('finishLab'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _showSuccessPopup = false;
                      _showCurtain = true;
                    });
                    _loadScenario(1);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double maxSidebar = sw * 0.9;
    if (_sidebarWidth > maxSidebar) _sidebarWidth = maxSidebar;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // 1. Sidebar Area
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: _sidebarOpen ? 0 : -_sidebarWidth,
              top: 0,
              bottom: 0,
              width: _sidebarWidth,
              child: _buildSidebar(),
            ),

            // 2. Right Border Line of Sidebar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: _sidebarOpen ? _sidebarWidth - 1 : -1,
              top: 0,
              bottom: 0,
              width: 1,
              child: Container(color: Colors.white.withOpacity(0.2)),
            ),

            // 3. Canvas Area
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: _sidebarOpen ? _sidebarWidth : 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: ClipRect(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTapDown: _onTapDown,
                      onScaleStart: _onScaleStart,
                      onScaleUpdate: _onScaleUpdate,
                      onScaleEnd: _onScaleEnd,
                      child: Container(
                        key: _canvasKey,
                        color: const Color(0xFF0F172A),
                        width: double.infinity,
                        height: double.infinity,
                        child: CustomPaint(
                          painter: FactoryPainter(
                            lang: _lang,
                            t: t,
                            scenario: _scenario,
                            step: _step,
                            targetNumber: _targetNumber,
                            blocks: _blocks,
                            logged: _logged,
                            isRectangleValid: _isRectangleValid,
                            showToken: _showToken,
                            draggedToken: _draggedToken,
                            tokenX: _tokenX,
                            tokenY: _tokenY,
                            msgOverlay: _msgOverlay,
                            msgTimer: _msgTimer,
                            panX: _panX,
                            panY: _panY,
                            zoom: _zoom,
                            animating: _animating,
                          ),
                        ),
                      ),
                    ),
                    _buildHUD(),
                  ],
                ),
              ),
            ),

            // 4. Sidebar Resizer Handle
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: _sidebarOpen ? _sidebarWidth - 10 : -20,
              top: 0,
              bottom: 0,
              width: 20,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _sidebarWidth += details.delta.dx;
                      if (_sidebarWidth < 300) _sidebarWidth = 300;
                      if (_sidebarWidth > maxSidebar) {
                        _sidebarWidth = maxSidebar;
                      }
                    });
                  },
                ),
              ),
            ),

            // 5. Floating Menu Button (Always Top Left)
            Positioned(
              left: 10,
              top: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: IconButton(
                  icon: Icon(
                    _sidebarOpen ? Icons.menu_open : Icons.menu,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    AudioEngine.tick();
                    setState(() => _sidebarOpen = !_sidebarOpen);
                  },
                ),
              ),
            ),

            // 6. Success Popup Layer
            if (_showSuccessPopup) Positioned.fill(child: _buildSuccessPopup()),

            // 7. Curtain Raiser
            _buildCurtainRaiser(),
          ],
        ),
      ),
    );
  }
}

// --- CUSTOM PAINTER ---

class FactoryPainter extends CustomPainter {
  final String lang;
  final Function(String) t;
  final int scenario;
  final int step;
  final int targetNumber;
  final List<RectBlock> blocks;
  final List<LoggedArrangement> logged;
  final bool isRectangleValid;
  final bool showToken;
  final bool draggedToken;
  final double tokenX, tokenY;
  final String msgOverlay;
  final int msgTimer;
  final double panX, panY, zoom;
  final bool animating;

  FactoryPainter({
    required this.lang,
    required this.t,
    required this.scenario,
    required this.step,
    required this.targetNumber,
    required this.blocks,
    required this.logged,
    required this.isRectangleValid,
    required this.showToken,
    required this.draggedToken,
    required this.tokenX,
    required this.tokenY,
    required this.msgOverlay,
    required this.msgTimer,
    required this.panX,
    required this.panY,
    required this.zoom,
    required this.animating,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    _drawDispenser(canvas, -100, -360);
    _drawConveyorBelt(canvas, -300, -280, 200);

    // Pack Button
    double btnY = -240;
    Color packBtnColor = (blocks.isEmpty && !animating)
        ? const Color(0xFF22C55E)
        : const Color(0xFF475569);
    _drawRoundedRect(
      canvas,
      -180,
      btnY,
      160,
      45,
      8,
      packBtnColor,
      const Color(0xFF0F172A),
      4,
    );
    _drawTextOutline(
      canvas,
      t('lbl_start_packing'),
      -100,
      btnY + 22.5,
      Colors.white,
      14,
      true,
    );

    // Grid Area
    _drawGridArea(canvas);

    // Log Button
    Color logBtnColor = isRectangleValid
        ? const Color(0xFF3B82F6)
        : const Color(0xFF475569);
    double logBtnX = GRID_X + (GRID_COLS * CELL_SIZE) / 2 - 100;
    double logBtnY = GRID_Y + GRID_ROWS * CELL_SIZE + 30;
    if (isRectangleValid) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(logBtnX, logBtnY, 200, 50),
          const Radius.circular(25),
        ),
        Paint()
          ..color = const Color(0xFF3B82F6).withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
      );
    }
    _drawRoundedRect(
      canvas,
      logBtnX,
      logBtnY,
      200,
      50,
      25,
      logBtnColor,
      const Color(0xFF0F172A),
      4,
    );
    _drawTextOutline(
      canvas,
      t('lbl_log_arr'),
      logBtnX + 100,
      logBtnY + 25,
      Colors.white,
      16,
      true,
    );

    // Logged Panel
    double panelX = 400;
    double panelY = -150;
    _drawRoundedRect(
      canvas,
      panelX,
      panelY,
      200,
      400,
      10,
      const Color(0xFF1E293B),
      const Color(0xFF0F172A),
      4,
    );
    _drawRoundedRectTopRadius(
      canvas,
      panelX,
      panelY,
      200,
      40,
      10,
      const Color(0xFF475569),
      const Color(0xFF0F172A),
      4,
    );

    int maxArr = 0;
    if (targetNumber == 7 || targetNumber == 13) {
      maxArr = 2;
    } else if (targetNumber == 12 || targetNumber == 18) {
      maxArr = 6;
    } else if (targetNumber == 1) {
      maxArr = 1;
    }

    _drawTextOutline(
      canvas,
      '${t('lbl_arr_found')} (${logged.length}/$maxArr)',
      panelX + 100,
      panelY + 20,
      Colors.white,
      12,
      true,
      strokeWidth: 0,
    );

    for (int i = 0; i < logged.length; i++) {
      double lx = panelX + 20 + (i % 2) * 80;
      double ly = panelY + 60 + (i ~/ 2) * 60;
      _drawRoundedRect(
        canvas,
        lx,
        ly,
        70,
        40,
        4,
        const Color(0xFF334155),
        const Color(0xFF0F172A),
        2,
      );
      _drawTextOutline(
        canvas,
        '${logged[i].w} x ${logged[i].h}',
        lx + 35,
        ly + 20,
        Colors.white,
        16,
        true,
        strokeWidth: 0,
      );
    }

    // Challenge Bins
    if (scenario >= 4) {
      double binY = 320;
      _drawRoundedRect(
        canvas,
        -300,
        binY,
        200,
        100,
        15,
        const Color(0xFF10B981),
        const Color(0xFF0F172A),
        5,
      );
      _drawTextOutline(
        canvas,
        t('lbl_prime'),
        -200,
        binY + 50,
        Colors.white,
        24,
        true,
      );

      _drawRoundedRect(
        canvas,
        100,
        binY,
        200,
        100,
        15,
        const Color(0xFFF59E0B),
        const Color(0xFF0F172A),
        5,
      );
      _drawTextOutline(
        canvas,
        t('lbl_composite'),
        200,
        binY + 50,
        Colors.white,
        22,
        true,
      );

      if (showToken) {
        double tx = draggedToken ? tokenX : 0;
        double ty = draggedToken ? tokenY : 200;
        if (!draggedToken) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(tx - 40, ty - 40, 80, 80),
              const Radius.circular(40),
            ),
            Paint()
              ..color = const Color(0xFFFACC15).withOpacity(0.5)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
          );
        }
        _drawRoundedRect(
          canvas,
          tx - 40,
          ty - 40,
          80,
          80,
          40,
          const Color(0xFFF8FAFC),
          const Color(0xFF0F172A),
          5,
        );
        _drawTextOutline(
          canvas,
          '$targetNumber',
          tx,
          ty,
          const Color(0xFF0F172A),
          36,
          true,
          strokeWidth: 0,
        );
      }
    }

    // Blocks
    for (var b in blocks) {
      String state = 'normal';
      if (b.isDragging) {
        state = 'normal';
      } else if (isRectangleValid && b.gridX != null) {
        state = 'valid';
      } else if (b.gridX != null) {
        state = 'invalid';
      }
      _drawCubeBlock(canvas, b.x, b.y, CELL_SIZE, state);
    }

    // Message Overlay
    if (msgTimer > 0 && msgOverlay.isNotEmpty) {
      double alpha = (msgTimer / 20.0).clamp(0.0, 1.0);
      Paint p = Paint()..color = const Color(0xFFEF4444).withOpacity(alpha);
      double mx = logBtnX + 20;
      double my = logBtnY - 50;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(mx, my, 160, 40),
          const Radius.circular(20),
        ),
        p,
      );
      Paint border = Paint()
        ..color = const Color(0xFF0F172A).withOpacity(alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(mx, my, 160, 40),
          const Radius.circular(20),
        ),
        border,
      );
      _drawTextOutline(
        canvas,
        msgOverlay,
        mx + 80,
        my + 20,
        Colors.white.withOpacity(alpha),
        16,
        true,
        strokeWidth: 0,
      );
    }

    canvas.restore();
  }

  void _drawDispenser(Canvas canvas, double x, double y) {
    _drawRoundedRectTopRadius(
      canvas,
      x - 60,
      y - 100,
      120,
      140,
      15,
      const Color(0xFF64748B),
      const Color(0xFF0F172A),
      4,
    );
    _drawRoundedRect(
      canvas,
      x - 40,
      y - 80,
      80,
      50,
      4,
      const Color(0xFF1E293B),
      Colors.transparent,
      0,
    );
    _drawRoundedRect(
      canvas,
      x - 80,
      y + 40,
      160,
      20,
      0,
      const Color(0xFF475569),
      const Color(0xFF0F172A),
      4,
    );
    _drawTextOutline(
      canvas,
      t('lbl_dispenser'),
      x,
      y - 115,
      const Color(0xFFF8FAFC),
      14,
      true,
    );
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(x - 20 + i * 20, y + 20),
        4,
        Paint()..color = const Color(0xFFF8FAFC),
      );
    }
  }

  void _drawConveyorBelt(Canvas canvas, double x, double y, double width) {
    _drawRoundedRect(
      canvas,
      x,
      y - 15,
      width,
      30,
      15,
      const Color(0xFF334155),
      const Color(0xFF0F172A),
      4,
    );
    _drawRoundedRect(
      canvas,
      x + 10,
      y - 10,
      width - 20,
      20,
      10,
      const Color(0xFF1E293B),
      Colors.transparent,
      0,
    );
    for (double wx = x + 20; wx < x + width - 15; wx += 30) {
      canvas.drawCircle(
        Offset(wx, y),
        6,
        Paint()..color = const Color(0xFF94A3B8),
      );
      canvas.drawCircle(
        Offset(wx, y),
        6,
        Paint()
          ..color = const Color(0xFF0F172A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _drawGridArea(Canvas canvas) {
    double w = GRID_COLS * CELL_SIZE;
    double h = GRID_ROWS * CELL_SIZE;

    _drawRoundedRect(
      canvas,
      GRID_X - 10,
      GRID_Y - 10,
      w + 20,
      h + 20,
      10,
      const Color(0xFF1E293B),
      const Color(0xFF0F172A),
      4,
    );

    Paint gridLinePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 2;
    for (int r = 0; r <= GRID_ROWS; r++) {
      double y = GRID_Y + r * CELL_SIZE;
      canvas.drawLine(Offset(GRID_X, y), Offset(GRID_X + w, y), gridLinePaint);
    }
    for (int c = 0; c <= GRID_COLS; c++) {
      double x = GRID_X + c * CELL_SIZE;
      canvas.drawLine(Offset(x, GRID_Y), Offset(x, GRID_Y + h), gridLinePaint);
    }

    _drawTextOutline(
      canvas,
      t('lbl_grid'),
      GRID_X + w / 2,
      GRID_Y - 25,
      Colors.white,
      16,
      true,
      strokeWidth: 0,
    );
  }

  void _drawCubeBlock(
    Canvas canvas,
    double x,
    double y,
    double size,
    String state,
  ) {
    Color fill = const Color(0xFF3B82F6);
    if (state == 'valid') {
      fill = const Color(0xFF22C55E);
    } else if (state == 'invalid') {
      fill = const Color(0xFFEF4444);
    }

    if (state != 'normal') {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, size, size),
          const Radius.circular(4),
        ),
        Paint()
          ..color = fill.withOpacity(0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }

    _drawRoundedRect(
      canvas,
      x,
      y,
      size,
      size,
      4,
      fill,
      const Color(0xFF0F172A),
      3,
    );
    _drawRoundedRect(
      canvas,
      x + 4,
      y + 4,
      size - 8,
      size - 8,
      2,
      Colors.white.withOpacity(0.2),
      Colors.transparent,
      0,
    );
  }

  void _drawRoundedRect(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double r,
    Color fill,
    Color stroke,
    double strokeW,
  ) {
    RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      Radius.circular(r),
    );
    if (fill != Colors.transparent) {
      canvas.drawRRect(rrect, Paint()..color = fill);
    }
    if (strokeW > 0) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  void _drawRoundedRectTopRadius(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double r,
    Color fill,
    Color stroke,
    double strokeW,
  ) {
    RRect rrect = RRect.fromRectAndCorners(
      Rect.fromLTWH(x, y, w, h),
      topLeft: Radius.circular(r),
      topRight: Radius.circular(r),
    );
    if (fill != Colors.transparent) {
      canvas.drawRRect(rrect, Paint()..color = fill);
    }
    if (strokeW > 0) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  void _drawTextOutline(
    Canvas canvas,
    String text,
    double x,
    double y,
    Color fill,
    double fontSize,
    bool bold, {
    double strokeWidth = 3,
  }) {
    TextStyle baseStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: bold ? FontWeight.w900 : FontWeight.normal,
      color: fill,
      fontFamily: 'Plus Jakarta Sans',
      height: 1.2,
    );
    TextPainter tpFill = TextPainter(
      text: TextSpan(text: text, style: baseStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    if (strokeWidth > 0) {
      TextStyle strokeStyle = baseStyle.copyWith(
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..color = const Color(0xFF0F172A)
          ..strokeJoin = StrokeJoin.round,
      );
      TextPainter tpStroke = TextPainter(
        text: TextSpan(text: text, style: strokeStyle),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      tpStroke.paint(
        canvas,
        Offset(x - tpStroke.width / 2, y - tpStroke.height / 2),
      );
    }
    tpFill.paint(canvas, Offset(x - tpFill.width / 2, y - tpFill.height / 2));
  }

  @override
  bool shouldRepaint(covariant FactoryPainter oldDelegate) => true;
}
