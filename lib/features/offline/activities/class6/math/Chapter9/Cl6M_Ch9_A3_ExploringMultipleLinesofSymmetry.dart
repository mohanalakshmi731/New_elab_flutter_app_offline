// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use, camel_case_types

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart'; // Added audioplayers import

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      title: 'ZSL Virtual Lab | Lines of Symmetry',
      debugShowCheckedModeBanner: false,
      home: Cl6M_Ch9_A3_ExploringMultipleLinesofSymmetry(),
    ),
  );
}

// --- DATA MODELS ---

class PolyLine {
  final String id;
  final Offset p1;
  final Offset p2;
  final bool valid;
  final int step;

  PolyLine({
    required this.id,
    required this.p1,
    required this.p2,
    required this.valid,
    this.step = 0,
  });
}

class ScenarioStep {
  final String hud;
  final String task;
  final String outcome;

  ScenarioStep({required this.hud, required this.task, required this.outcome});
}

class ScenarioConfig {
  final String title;
  final String objective;
  final List<ScenarioStep> steps;

  ScenarioConfig({
    required this.title,
    required this.objective,
    required this.steps,
  });
}

// --- TRANSLATIONS ---

const Map<String, Map<String, String>> i18n = {
  'en': {
    'shutterTitle': "Exploring Multiple Lines of Symmetry",
    'appTitle': "Exploring Multiple Lines of Symmetry",
    'appSubtitle': "Class 6 • THE SYMMETRY FOLDER",
    'enterLab': "Enter Virtual Lab",
    'selectScenario': "Select Scenario",
    'stepLabel': "STEP",
    'learnLbl': "Mission Objective:",
    'summaryTitle': "Goal Reached!",
    'finishLab': "Finish Lab",
    'nextScenario': "Next Scenario",
    'finalDesc':
        "You have successfully discovered lines of symmetry for all shapes through virtual folding!",
    'scenarioCompleted': "Excellent! You've successfully analyzed this shape.",
    'toolsTitle': "TOOLS",
    'btnUnfold': "Unfold Shape",
    'btnTestFold': "Test Fold",

    's1_title': "1. The Perfect Square",
    's1_obj':
        "To discover and verify all four lines of symmetry of a square through guided virtual folding.",
    's1_hud1': "Drag the 'Folding Tool' onto the vertical dotted line.",
    's1_step1_task':
        "DRAG the 'Folding Tool' from the toolbox and DROP it onto the vertical dotted line in the middle of the square.",
    's1_step1_out':
        "The square folds in half vertically. The halves perfectly overlap. The line is solid green.",
    's1_hud2': "Click 'Unfold', then drag the tool onto the horizontal line.",
    's1_step2_task':
        "CLICK the 'Unfold' button. DRAG the 'Folding Tool' onto the horizontal dotted line.",
    's1_step2_out':
        "The square folds horizontally. The top and bottom halves overlap perfectly.",
    's1_hud3': "Click 'Unfold', then try the first diagonal.",
    's1_step3_task':
        "CLICK 'Unfold'. DRAG the 'Folding Tool' onto the diagonal line (top-left to bottom-right).",
    's1_step3_out':
        "The square folds along the diagonal. The two triangular halves overlap perfectly.",
    's1_hud4': "Click 'Unfold', then try the second diagonal.",
    's1_step4_task':
        "CLICK 'Unfold'. DRAG the 'Folding Tool' onto the final diagonal line.",
    's1_step4_out':
        "The final diagonal fold perfectly matches. A square has 4 lines of symmetry: one vertical, one horizontal, and two diagonal.",

    's2_title': "2. The Tricky Rectangle",
    's2_obj':
        "To discover the two lines of symmetry of a rectangle and understand why its diagonals are not lines of symmetry.",
    's2_hud1': "Drag the 'Folding Tool' onto the vertical dotted line.",
    's2_step1_task':
        "DRAG the 'Folding Tool' onto the vertical dotted line of the rectangle.",
    's2_step1_out': "The rectangle folds vertically, halves perfectly overlap.",
    's2_hud2': "Click 'Unfold', then drag the tool onto the horizontal line.",
    's2_step2_task':
        "CLICK 'Unfold'. DRAG the 'Folding Tool' onto the horizontal dotted line.",
    's2_step2_out':
        "The rectangle folds horizontally, halves perfectly overlap.",
    's2_hud3': "Click 'Unfold', then try folding along the diagonal.",
    's2_step3_task':
        "CLICK 'Unfold'. DRAG the 'Folding Tool' onto the diagonal dotted line.",
    's2_step3_out':
        "Notice that? When folded along the diagonal, the corners do not match! A rectangle has only 2 lines of symmetry. Its diagonals are not lines of symmetry.",

    's3_title': "3. The Elegant Equilateral Triangle",
    's3_obj': "To find the three lines of symmetry in an equilateral triangle.",
    's3_hud1': "Drag the 'Folding Tool' onto the vertical dotted line.",
    's3_step1_task':
        "DRAG the 'Folding Tool' onto the vertical dotted line connecting the top vertex to the bottom base.",
    's3_step1_out':
        "The triangle folds along the vertical line. The two halves match perfectly.",
    's3_hud2': "Click 'Unfold', then try the next dotted line.",
    's3_step2_task':
        "CLICK 'Unfold'. DRAG the 'Folding Tool' onto the line connecting the bottom-left vertex to the opposite side.",
    's3_step2_out': "The triangle folds perfectly along this axis.",
    's3_hud3': "Click 'Unfold', then try the final dotted line.",
    's3_step3_task':
        "CLICK 'Unfold'. DRAG the 'Folding Tool' onto the final dotted line.",
    's3_step3_out':
        "Excellent! An equilateral triangle has 3 lines of symmetry. Each line connects a vertex to the middle of the opposite side.",

    's4_title': "4. The Isosceles Challenge",
    's4_obj':
        "To independently find the single line of symmetry for an isosceles triangle using the drawing tool.",
    's4_hud1': "Select the 'Line Drawer' tool.",
    's4_step1_task': "Select the 'Line Drawer' tool from the toolbox.",
    's4_step1_out':
        "The Line Drawer is ready. You can draw lines across the shape.",
    's4_hud2': "Draw a vertical line down the middle, then click 'Test Fold'.",
    's4_step2_task':
        "Draw a vertical line from the top point straight down to the middle of the bottom edge. Then CLICK 'Test Fold'.",
    's4_step2_out': "The fold is perfect! One line of symmetry found.",
    's4_hud3': "Draw another line (like a diagonal) to see what happens.",
    's4_step3_task':
        "Try drawing any other line, for example, connecting a bottom corner to the opposite side. CLICK 'Test Fold'.",
    's4_step3_out':
        "The fold fails. An isosceles triangle has exactly one line of symmetry.",

    's5_title': "5. The Kite Puzzle",
    's5_obj':
        "To independently discover the single, diagonal line of symmetry for a kite.",
    's5_hud1': "Select the 'Line Drawer' tool.",
    's5_step1_task':
        "Ensure the 'Line Drawer' is selected to find the kite's symmetry line.",
    's5_step1_out': "The Line Drawer is active.",
    's5_hud2': "Draw the short horizontal diagonal, then click 'Test Fold'.",
    's5_step2_task':
        "DRAW a line connecting the left and right corners (the shorter diagonal). CLICK 'Test Fold'.",
    's5_step2_out': "The fold fails. The top and bottom halves do not match.",
    's5_hud3': "Draw the long vertical diagonal, then click 'Test Fold'.",
    's5_step3_task':
        "DRAW a line connecting the top and bottom corners (the longer diagonal). CLICK 'Test Fold'.",
    's5_step3_out':
        "Great job! The left and right halves match perfectly. A kite has exactly one line of symmetry.",
  },
  'hi': {
    'shutterTitle': "सममिति की रेखाओं की खोज",
    'appTitle': "सममिति की रेखाओं की खोज",
    'appSubtitle': "कक्षा 6 • सममिति फ़ोल्डर",
    'enterLab': "वर्चुअल लैब में प्रवेश करें",
    'selectScenario': "परिदृश्य चुनें",
    'stepLabel': "चरण",
    'learnLbl': "मिशन उद्देश्य:",
    'summaryTitle': "लक्ष्य प्राप्त हुआ!",
    'finishLab': "समाप्त करें",
    'nextScenario': "अगला परिदृश्य",
    'finalDesc':
        "आपने वर्चुअल फोल्डिंग के माध्यम से सभी आकृतियों के लिए सममिति की रेखाएं सफलतापूर्वक खोज ली हैं!",
    'scenarioCompleted':
        "बहुत बढ़िया! आपने सफलतापूर्वक इस आकृति का विश्लेषण किया है।",
    'toolsTitle': "उपकरण",
    'btnUnfold': "आकृति खोलें",
    'btnTestFold': "मोड़ का परीक्षण करें",

    's1_title': "1. आदर्श वर्ग",
    's1_obj':
        "निर्देशित वर्चुअल फोल्डिंग के माध्यम से एक वर्ग की सभी चार सममिति रेखाओं को खोजना।",
    's1_hud1': "वर्टिकल डॉटेड लाइन पर 'फोल्डिंग टूल' खींचें।",
    's1_step1_task':
        "टूलबॉक्स से 'फोल्डिंग टूल' खींचें और इसे वर्ग के बीच में वर्टिकल डॉटेड लाइन पर छोड़ दें।",
    's1_step1_out':
        "वर्ग लंबवत रूप से आधा मुड़ जाता है। हिस्से पूरी तरह से ओवरलैप करते हैं। रेखा ठोस हरी है।",
    's1_hud2': "क्षैतिज रेखा पर उपकरण खींचें।",
    's1_step2_task':
        "'अनफोल्ड' बटन पर क्लिक करें। क्षैतिज डॉटेड लाइन पर 'फोल्डिंग टूल' खींचें।",
    's1_step2_out':
        "वर्ग क्षैतिज रूप से मुड़ता है। हिस्से पूरी तरह से ओवरलैप करते हैं।",
    's1_hud3': "पहले विकर्ण पर प्रयास करें।",
    's1_step3_task': "विकर्ण रेखा पर 'फोल्डिंग टूल' खींचें।",
    's1_step3_out':
        "वर्ग विकर्ण के साथ मुड़ता है। त्रिकोणीय हिस्से पूरी तरह से ओवरलैप करते हैं।",
    's1_hud4': "दूसरे विकर्ण पर प्रयास करें।",
    's1_step4_task': "अंतिम विकर्ण रेखा पर 'फोल्डिंग टूल' खींचें।",
    's1_step4_out': "एक वर्ग में सममिति की 4 रेखाएँ होती हैं।",

    's2_title': "2. मुश्किल आयत",
    's2_obj':
        "आयत की दो सममिति रेखाओं की खोज करना और यह समझना कि इसके विकर्ण सममिति रेखाएं क्यों नहीं हैं।",
    's2_hud1': "वर्टिकल डॉटेड लाइन पर फोल्डिंग टूल खींचें।",
    's2_step1_task': "आयत की लंबवत डॉटेड लाइन पर टूल खींचें।",
    's2_step1_out': "आयत लंबवत रूप से मुड़ता है, पूरी तरह से मेल खाता है।",
    's2_hud2': "क्षैतिज रेखा पर प्रयास करें।",
    's2_step2_task': "क्षैतिज डॉटेड लाइन पर टूल खींचें।",
    's2_step2_out': "आयत क्षैतिज रूप से मुड़ता है, पूरी तरह से मेल खाता है।",
    's2_hud3': "विकर्ण के साथ मोड़ने का प्रयास करें।",
    's2_step3_task': "विकर्ण डॉटेड लाइन पर टूल खींचें।",
    's2_step3_out':
        "कोने मेल नहीं खाते! एक आयत में केवल 2 सममिति रेखाएं होती हैं।",

    's3_title': "3. समबाहु त्रिभुज",
    's3_obj': "समबाहु त्रिभुज में सममिति की तीन रेखाएँ खोजना।",
    's3_hud1': "वर्टिकल डॉटेड लाइन पर फोल्डिंग टूल खींचें।",
    's3_step1_task': "वर्टिकल डॉटेड लाइन पर 'फोल्डिंग टूल' खींचें।",
    's3_step1_out':
        "त्रिभुज लंबवत मुड़ता है। दो हिस्से पूरी तरह से मेल खाते हैं।",
    's3_hud2': "अगली डॉटेड लाइन पर प्रयास करें।",
    's3_step2_task': "अगली डॉटेड लाइन पर टूल खींचें।",
    's3_step2_out': "त्रिभुज पूरी तरह से मेल खाता है।",
    's3_hud3': "अंतिम डॉटेड लाइन पर प्रयास करें।",
    's3_step3_task': "अंतिम डॉटेड लाइन पर टूल खींचें।",
    's3_step3_out': "समबाहु त्रिभुज में 3 सममिति रेखाएँ होती हैं।",

    's4_title': "4. समद्विबाहु चुनौती",
    's4_obj':
        "समद्विबाहु त्रिभुज के लिए स्वतंत्र रूप से सममिति की एकल रेखा खोजना।",
    's4_hud1': "लाइन ड्राअर टूल चुनें।",
    's4_step1_task': "टूलबॉक्स से 'लाइन ड्राअर' चुनें।",
    's4_step1_out': "अब आप रेखाएँ खींच सकते हैं।",
    's4_hud2': "बीच में एक लंबवत रेखा खींचें।",
    's4_step2_task':
        "शीर्ष से नीचे तक एक लंबवत रेखा खींचें। फिर 'मोड़ का परीक्षण करें' पर क्लिक करें।",
    's4_step2_out': "मोड़ एकदम सही है! एक सममिति रेखा मिल गई।",
    's4_hud3': "कोई अन्य रेखा खींचकर देखें।",
    's4_step3_task':
        "कोई अन्य रेखा खींचने का प्रयास करें। 'परीक्षण' पर क्लिक करें।",
    's4_step3_out':
        "मोड़ विफल। समद्विबाहु त्रिभुज में केवल एक सममिति रेखा होती है।",

    's5_title': "5. पतंग पहेली",
    's5_obj': "पतंग के लिए सममिति की एकल रेखा खोजना।",
    's5_hud1': "लाइन ड्राअर टूल चुनें।",
    's5_step1_task': "'लाइन ड्राअर' सक्रिय करें।",
    's5_step1_out': "लाइन ड्राअर सक्रिय है।",
    's5_hud2': "छोटा क्षैतिज विकर्ण खींचें।",
    's5_step2_task': "छोटा विकर्ण खींचें। 'परीक्षण' पर क्लिक करें।",
    's5_step2_out': "मोड़ विफल। हिस्से मेल नहीं खाते।",
    's5_hud3': "लंबा लंबवत विकर्ण खींचें।",
    's5_step3_task': "लंबा विकर्ण खींचें। 'परीक्षण' पर क्लिक करें।",
    's5_step3_out':
        "बहुत बढ़िया! हिस्से पूरी तरह से मेल खाते हैं। पतंग में एक सममिति रेखा होती है।",
  },
};

// --- MAIN WIDGET ---

class Cl6M_Ch9_A3_ExploringMultipleLinesofSymmetry extends StatefulWidget {
  const Cl6M_Ch9_A3_ExploringMultipleLinesofSymmetry({super.key});

  @override
  State<Cl6M_Ch9_A3_ExploringMultipleLinesofSymmetry> createState() =>
      _Cl6M_Ch9_A3_ExploringMultipleLinesofSymmetryState();
}

class _Cl6M_Ch9_A3_ExploringMultipleLinesofSymmetryState
    extends State<Cl6M_Ch9_A3_ExploringMultipleLinesofSymmetry>
    with SingleTickerProviderStateMixin {
  // --- Audio Players ---
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

  // Config
  String _lang = 'en';
  bool _showCurtain = true;
  bool _sidebarOpen = true;
  double _sidebarWidth = 300.0;

  // Game Loop
  late Ticker _ticker;
  final GlobalKey _canvasKey = GlobalKey();

  // View State
  double _zoom = 1.0;
  Offset _pan = Offset.zero;
  Offset? _lastFocalPoint;

  // Logic State
  int _scenario = 1;
  int _step = 0;
  String _activeTool = 'folder'; // 'folder' or 'drawer'

  // Shapes & Data
  final Map<int, List<Offset>> _shapes = {
    1: const [
      Offset(-100, -100),
      Offset(100, -100),
      Offset(100, 100),
      Offset(-100, 100),
    ],
    2: const [
      Offset(-150, -100),
      Offset(150, -100),
      Offset(150, 100),
      Offset(-150, 100),
    ],
    3: const [Offset(0, -115.47), Offset(-100, 57.73), Offset(100, 57.73)],
    4: const [Offset(0, -120), Offset(80, 80), Offset(-80, 80)],
    5: const [
      Offset(0, -120),
      Offset(80, -20),
      Offset(0, 120),
      Offset(-80, -20),
    ],
  };

  final Map<int, List<PolyLine>> _hotlines = {
    1: [
      PolyLine(
        id: 'v',
        p1: const Offset(0, -130),
        p2: const Offset(0, 130),
        valid: true,
        step: 1,
      ),
      PolyLine(
        id: 'h',
        p1: const Offset(-130, 0),
        p2: const Offset(130, 0),
        valid: true,
        step: 2,
      ),
      PolyLine(
        id: 'd1',
        p1: const Offset(-130, -130),
        p2: const Offset(130, 130),
        valid: true,
        step: 3,
      ),
      PolyLine(
        id: 'd2',
        p1: const Offset(-130, 130),
        p2: const Offset(130, -130),
        valid: true,
        step: 4,
      ),
    ],
    2: [
      PolyLine(
        id: 'v',
        p1: const Offset(0, -130),
        p2: const Offset(0, 130),
        valid: true,
        step: 1,
      ),
      PolyLine(
        id: 'h',
        p1: const Offset(-180, 0),
        p2: const Offset(180, 0),
        valid: true,
        step: 2,
      ),
      PolyLine(
        id: 'd1',
        p1: const Offset(-150, -100),
        p2: const Offset(150, 100),
        valid: false,
        step: 3,
      ),
    ],
    3: [
      PolyLine(
        id: 'v',
        p1: const Offset(0, -130),
        p2: const Offset(0, 70),
        valid: true,
        step: 1,
      ),
      PolyLine(
        id: 'd1',
        p1: const Offset(-115, 66),
        p2: const Offset(57, -33),
        valid: true,
        step: 2,
      ),
      PolyLine(
        id: 'd2',
        p1: const Offset(115, 66),
        p2: const Offset(-57, -33),
        valid: true,
        step: 3,
      ),
    ],
  };

  // Sim State
  final List<PolyLine> _testedLines = [];
  PolyLine? _failedLine;
  PolyLine? _activeFoldLine;
  bool _isFolded = false;
  bool _animating = false;
  double _foldProgress = 0.0;

  Offset? _dragAvatar;
  PolyLine? _drawingLine; // Temporary while drawing
  PolyLine? _drawnLine; // Finalized drawn line
  List<Offset> _snapPoints = [];

  // Progress tracking for custom tools
  bool _s4Correct = false;
  bool _s5Correct = false, _s5Wrong = false;

  bool _showPopup = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _ticker = createTicker((elapsed) {
      setState(() {}); // Drive game loop / animations
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // --- AUDIO METHODS ---

  // Clean, sequential, and robust error handling to prevent silent chain failures
  Future<void> _safePlay(AudioPlayer player, String url) async {
    try {
      // Safely attempt to interrupt any currently buffering/playing audio
      // on this specific player instance before giving it a new URL.
      try {
        await player.stop();
      } catch (_) {
        // Ignored. Throws safely if player hasn't been active yet.
      }

      // Await playback completion. Throws an explicit error if the network blocks it.
      await player.play(AssetSource(url));
    } catch (e) {
      debugPrint('Audio playback error safely caught: $e');
    }
  }

  // 1. Play general click sound
  Future<void> playClick() async {
    await _safePlay(_clickPlayer, 'audio/class6/math/codeskulptor_pop.mp3');
  }

  // 2. Play a sound when a new page/popup opens
  Future<void> playPageOpen() async {
    await _safePlay(_pagePlayer, 'audio/class6/science/page_open.mp3');
  }

  // 3. Play the Dropdown sound
  Future<void> playDropdown() async {
    await _safePlay(_dropdownPlayer, 'audio/class6/science/dropdown.mp3');
  }

  // 4. Play an error sound (Soft thud) for invalid folds
  Future<void> playError() async {
    await _safePlay(_clickPlayer, 'audio/class6/math/codeskulptor_spring.mp3');
  }

  // 5. Play startup curtain sound
  Future<void> curtainScreen() async {
    await _safePlay(_pagePlayer, 'audio/class6/math/shutter.mp3');
  }

  String t(String key) {
    return i18n[_lang]?[key] ?? i18n['en']?[key] ?? key;
  }

  void _startLab() {
    curtainScreen();
    setState(() => _showCurtain = false);
    _loadScenario(1);
    if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  void _loadScenario(int id) {
    setState(() {
      _scenario = id;
      _step = 0;
      _animating = false;
      _isFolded = false;
      _activeFoldLine = null;
      _drawnLine = null;
      _drawingLine = null;
      _testedLines.clear();
      _failedLine = null;
      _s4Correct = false;
      _s5Correct = false;
      _showPopup = false;
      _pan = Offset.zero;
      _zoom = 1.0;

      if (_scenario <= 3) {
        _activeTool = 'folder';
      } else {
        _activeTool = 'drawer';
        _snapPoints = _computeSnapPoints(_shapes[_scenario]!);
      }
    });
  }

  void _toggleLanguage() {
    playClick();
    setState(() {
      _lang = _lang == 'en' ? 'hi' : 'en';
    });
  }

  void _resetLab() {
    playClick();
    setState(() {
      _showCurtain = true;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      _loadScenario(1);
    });
  }

  ScenarioConfig _getScenarioConfig(int id) {
    int numSteps = id == 1 ? 4 : 3;
    List<ScenarioStep> steps = [];
    for (int i = 1; i <= numSteps; i++) {
      steps.add(
        ScenarioStep(
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

  // --- GEOMETRY UTILS ---

  double _distance(Offset p1, Offset p2) => (p1 - p2).distance;

  double _distToSegment(Offset p, Offset v, Offset w) {
    double l2 = pow(w.dx - v.dx, 2) + pow(w.dy - v.dy, 2).toDouble();
    if (l2 == 0) return _distance(p, v);
    double t =
        ((p.dx - v.dx) * (w.dx - v.dx) + (p.dy - v.dy) * (w.dy - v.dy)) / l2;
    t = max(0, min(1, t));
    return _distance(
      p,
      Offset(v.dx + t * (w.dx - v.dx), v.dy + t * (w.dy - v.dy)),
    );
  }

  List<Offset> _computeSnapPoints(List<Offset> poly) {
    List<Offset> pts = [];
    for (int i = 0; i < poly.length; i++) {
      pts.add(poly[i]);
      Offset next = poly[(i + 1) % poly.length];
      pts.add(Offset((poly[i].dx + next.dx) / 2, (poly[i].dy + next.dy) / 2));
    }
    return pts;
  }

  bool _checkValidLineS4S5(Offset? p1, Offset? p2) {
    if (p1 == null || p2 == null) return false;
    if (_distance(p1, p2) < 50) return false;
    bool isVertical =
        (p1.dx - p2.dx).abs() < 30 && p1.dx.abs() < 30 && p2.dx.abs() < 30;
    return isVertical;
  }

  // --- INTERACTION LOGIC ---

  void _triggerFoldAnimation(PolyLine fLine) {
    setState(() {
      _animating = true;
      _activeFoldLine = fLine;
      _foldProgress = 0.0;
      _failedLine = null;
    });

    final int durMs = 1200;
    final int startMs = DateTime.now().millisecondsSinceEpoch;

    void updateAnim() {
      int elapsed = DateTime.now().millisecondsSinceEpoch - startMs;
      if (elapsed >= durMs) {
        _finalizeFold(fLine);
      } else {
        double t = elapsed / durMs;
        // Ease in out cubic
        double progress = t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2;
        setState(() {
          _foldProgress = progress;
        });
        Future.delayed(const Duration(milliseconds: 16), updateAnim);
      }
    }

    updateAnim();
  }

  void _finalizeFold(PolyLine fLine) {
    setState(() {
      _foldProgress = 1.0;
      _animating = false;
      _isFolded = true;
    });

    bool isNewValid = false;
    if (fLine.valid) {
      if (!_testedLines.any((l) => l.id == fLine.id)) {
        _testedLines.add(fLine);
        isNewValid = true;
      }
    } else {
      _failedLine = fLine;
      playError(); // Play error tone for an invalid fold
    }

    // Step logic
    ScenarioConfig conf = _getScenarioConfig(_scenario);
    if (_scenario == 1 || _scenario == 3) {
      if (isNewValid) _advanceStep();
      if (_testedLines.length == conf.steps.length) _triggerSuccessPopup();
    } else if (_scenario == 2) {
      if (isNewValid) {
        _advanceStep();
      } else if (!fLine.valid && _step == 2) {
        _advanceStep();
        _triggerSuccessPopup();
      }
    } else if (_scenario == 4 || _scenario == 5) {
      if (fLine.valid) {
        if (_scenario == 4) _s4Correct = true;
        if (_scenario == 5) _s5Correct = true;
        if (_step < conf.steps.length) _advanceStep();
      } else {
        if (_scenario == 4) if (_scenario == 5) _s5Wrong = true;
      }

      bool isComplete = _scenario == 4 ? _s4Correct : _s5Correct;
      if (isComplete && _step >= conf.steps.length - 1) {
        setState(() => _step = conf.steps.length);
        _triggerSuccessPopup();
      }
    }
  }

  void _advanceStep() {
    setState(() => _step++);
  }

  void _triggerSuccessPopup() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        playPageOpen(); // Play page open tone upon showing the success popup
        setState(() => _showPopup = true);
      }
    });
  }

  Offset _screenToWorld(Offset screenPos, Size canvasSize) {
    return Offset(
      (screenPos.dx - canvasSize.width / 2 - _pan.dx) / _zoom,
      (screenPos.dy - canvasSize.height / 2 - _pan.dy) / _zoom,
    );
  }

  void _startTool(Offset localPos) {
    if (_animating || _isFolded) return;

    final RenderBox box =
        _canvasKey.currentContext?.findRenderObject() as RenderBox;
    final Offset worldPos = _screenToWorld(localPos, box.size);

    if (_activeTool == 'drawer' && _scenario > 3) {
      Offset sp = worldPos;
      for (var p in _snapPoints) {
        if (_distance(p, worldPos) < 20) {
          sp = p;
          break;
        }
      }
      setState(() {
        _drawingLine = PolyLine(id: 'temp', p1: sp, p2: sp, valid: false);
        _drawnLine = null;
      });
    }
  }

  void _updateTool(Offset localPos) {
    if (_animating || _isFolded) return;

    final RenderBox box =
        _canvasKey.currentContext?.findRenderObject() as RenderBox;
    final Offset worldPos = _screenToWorld(localPos, box.size);

    if (_activeTool == 'drawer' && _drawingLine != null) {
      Offset ep = worldPos;
      for (var p in _snapPoints) {
        if (_distance(p, worldPos) < 20) {
          ep = p;
          break;
        }
      }
      setState(() {
        _drawingLine = PolyLine(
          id: 'temp',
          p1: _drawingLine!.p1,
          p2: ep,
          valid: false,
        );
      });
    }
  }

  void _endTool() {
    if (_drawingLine != null) {
      if (_distance(_drawingLine!.p1, _drawingLine!.p2) > 20) {
        double dx = _drawingLine!.p2.dx - _drawingLine!.p1.dx;
        double dy = _drawingLine!.p2.dy - _drawingLine!.p1.dy;
        double len = sqrt(dx * dx + dy * dy);
        double nx = dx / len;
        double ny = dy / len;

        setState(() {
          _drawnLine = PolyLine(
            id: 'drawn',
            p1: Offset(
              _drawingLine!.p1.dx - nx * 1000,
              _drawingLine!.p1.dy - ny * 1000,
            ),
            p2: Offset(
              _drawingLine!.p2.dx + nx * 1000,
              _drawingLine!.p2.dy + ny * 1000,
            ),
            valid: false,
          );
        });
      }
      setState(() => _drawingLine = null);
    }
  }

  // Unified Scale Handler for pan, zoom, and drawing
  void _handleScaleStart(ScaleStartDetails d) {
    _lastFocalPoint = d.localFocalPoint;
    if (d.pointerCount == 1) {
      _startTool(d.localFocalPoint);
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails d) {
    if (d.pointerCount >= 2) {
      // Zoom / Pan
      setState(() {
        _pan += (d.localFocalPoint - _lastFocalPoint!);
        _zoom = (_zoom * d.scale).clamp(0.4, 3.0);
        _lastFocalPoint = d.localFocalPoint;
        _drawingLine = null; // Cancel drawing if zoomed
      });
    } else if (d.pointerCount == 1) {
      if (_drawingLine != null && _activeTool == 'drawer') {
        _updateTool(d.localFocalPoint);
      } else if (_scenario <= 3 || _activeTool != 'drawer') {
        // Allow smooth 1-finger panning if drawing is not active
        setState(() {
          _pan += (d.localFocalPoint - _lastFocalPoint!);
          _lastFocalPoint = d.localFocalPoint;
        });
      }
    }
  }

  void _handleScaleEnd(ScaleEndDetails d) {
    _lastFocalPoint = null;
    _endTool();
  }

  // --- UI BUILDERS ---

  Widget _buildCurtain() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOutCubic,
      top: _showCurtain ? 0 : -MediaQuery.of(context).size.height,
      bottom: _showCurtain ? 0 : MediaQuery.of(context).size.height,
      left: 0,
      right: 0,
      child: Container(
        color: const Color(0xFF0F172A),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dashboard_customize,
              size: 100,
              color: Colors.indigoAccent.shade200,
            ),
            const SizedBox(height: 30),
            Text(
              t('shutterTitle'),
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              t('appSubtitle'),
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white54,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton.icon(
              onPressed: _startLab,
              icon: const Icon(Icons.play_circle_fill, size: 28),
              label: Text(
                t('enterLab'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                elevation: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    ScenarioConfig conf = _getScenarioConfig(_scenario);
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      left: _sidebarOpen ? 0 : -_sidebarWidth,
      top: 0,
      bottom: 0,
      width: _sidebarWidth,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          border: Border(right: BorderSide(color: Colors.white24, width: 1)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header inside sidebar
                      Container(
                        padding: const EdgeInsets.only(
                          top: 60,
                          left: 16,
                          right: 16,
                          bottom: 16,
                        ),
                        color: const Color(0xFF0F172A),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.dashboard_customize,
                                  color: Colors.indigoAccent,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t('appTitle'),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        t('appSubtitle'),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.language, size: 16),
                                    label: Text(
                                      _lang == 'en' ? 'HI' : 'EN',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: _toggleLanguage,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white10,
                                      foregroundColor: Colors.white70,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(
                                      Icons.refresh,
                                      size: 16,
                                      color: Colors.redAccent,
                                    ),
                                    label: const Text(
                                      'Reset',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: _resetLab,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white10,
                                      foregroundColor: Colors.white70,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t('selectScenario').toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white54,
                                  letterSpacing: 1.1,
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
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _scenario,
                                    dropdownColor: const Color(0xFF1E293B),
                                    isExpanded: true,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    items: [1, 2, 3, 4, 5]
                                        .map(
                                          (id) => DropdownMenuItem(
                                            value: id,
                                            child: Text(t('s${id}_title')),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) {
                                      if (v != null) {
                                        playDropdown();
                                        _loadScenario(v);
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.flag,
                                          color: Colors.pinkAccent,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          t('learnLbl'),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      conf.objective,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Steps
                              ...conf.steps.asMap().entries.map((entry) {
                                int idx = entry.key;
                                ScenarioStep stepInfo = entry.value;
                                bool isPast = idx < _step;
                                bool isCurrent = idx == _step;
                                bool isFuture = idx > _step;

                                Color bgColor = isCurrent
                                    ? Colors.indigoAccent.withOpacity(0.15)
                                    : (isPast
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.white.withOpacity(0.05));
                                Color borderColor = isCurrent
                                    ? Colors.indigoAccent
                                    : (isPast
                                          ? Colors.green
                                          : Colors.transparent);

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: borderColor,
                                      width: isCurrent ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      isPast
                                          ? const Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              size: 24,
                                            )
                                          : Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color: isCurrent
                                                    ? Colors.indigoAccent
                                                    : Colors.white24,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${idx + 1}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
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
                                              "${t('stepLabel')} ${idx + 1}",
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white54,
                                                letterSpacing: 1.2,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "Action: ${stepInfo.task}",
                                              style: TextStyle(
                                                color: isFuture
                                                    ? Colors.white38
                                                    : Colors.white,
                                                fontSize: 13,
                                                height: 1.4,
                                                fontWeight: isCurrent
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                            if (isPast) ...[
                                              const SizedBox(height: 8),
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  stepInfo.outcome,
                                                  style: const TextStyle(
                                                    color: Colors.greenAccent,
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
                            ],
                          ),
                        ),
                      ),

                      // Footer
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        color: const Color(0xFF020617),
                        child: const Text(
                          '© ZeroScienceLab - Fall in love with math and Science',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildToolsAndHUD() {
    ScenarioConfig conf = _getScenarioConfig(_scenario);
    String? hudText = _step < conf.steps.length ? conf.steps[_step].hud : null;

    return Stack(
      children: [
        // Tools Panel (Top Right)
        Positioned(
          top: 90,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              children: [
                Text(
                  t('toolsTitle'),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 12),

                // Folder Tool (Draggable in Scenarios 1-3)
                Opacity(
                  opacity: _scenario <= 3 ? 1.0 : 0.4,
                  child: GestureDetector(
                    onPanStart: (d) {
                      if (_scenario > 3) return;
                      if (_activeTool != 'folder') playClick();
                      setState(() {
                        _activeTool = 'folder';
                      });
                    },
                    onPanUpdate: (d) {
                      if (_scenario > 3 || _isFolded || _animating) return;
                      final RenderBox box =
                          _canvasKey.currentContext?.findRenderObject()
                              as RenderBox;
                      final Offset localPos = box.globalToLocal(
                        d.globalPosition,
                      );
                      setState(() {
                        _dragAvatar = _screenToWorld(localPos, box.size);
                      });
                    },
                    onPanEnd: (d) {
                      if (_scenario > 3 || _dragAvatar == null) return;
                      // Check drops
                      bool dropped = false;
                      List<PolyLine>? lines = _hotlines[_scenario];
                      if (lines != null) {
                        for (var hl in lines) {
                          if (_distToSegment(_dragAvatar!, hl.p1, hl.p2) < 40) {
                            _triggerFoldAnimation(hl);
                            dropped = true;
                            break;
                          }
                        }
                      }
                      if (!dropped) {}
                      setState(() => _dragAvatar = null);
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _activeTool == 'folder'
                            ? Colors.indigoAccent
                            : Colors.white12,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.flip, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Drawer Tool (Clickable in Scenarios 4-5)
                Opacity(
                  opacity: _scenario > 3 ? 1.0 : 0.4,
                  child: GestureDetector(
                    onTap: () {
                      if (_scenario <= 3) return;
                      if (_activeTool != 'drawer') playClick();
                      setState(() {
                        _activeTool = 'drawer';
                      });
                      if ((_scenario == 4 || _scenario == 5) && _step == 0) {
                        _advanceStep();
                      }
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _activeTool == 'drawer'
                            ? Colors.indigoAccent
                            : Colors.white12,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.edit, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Action Buttons (Center Center)
        if (_isFolded && !_animating)
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: ElevatedButton.icon(
                onPressed: () {
                  playClick();
                  setState(() {
                    _isFolded = false;
                    _activeFoldLine = null;
                    _drawnLine = null;
                    _failedLine = null;
                  });
                },
                icon: const Icon(Icons.unfold_more),
                label: Text(
                  t('btnUnfold'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigoAccent,
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
            ),
          ),

        if (!_isFolded &&
            !_animating &&
            _drawnLine != null &&
            _activeTool == 'drawer')
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: ElevatedButton.icon(
                onPressed: () {
                  playClick();
                  bool valid = _checkValidLineS4S5(
                    _drawnLine!.p1,
                    _drawnLine!.p2,
                  );
                  PolyLine customLine = PolyLine(
                    id: 'c_${DateTime.now().millisecondsSinceEpoch}',
                    p1: _drawnLine!.p1,
                    p2: _drawnLine!.p2,
                    valid: valid,
                  );
                  _triggerFoldAnimation(customLine);
                },
                icon: const Icon(Icons.science),
                label: Text(
                  t('btnTestFold'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
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
            ),
          ),

        // Flexible HUD Instruction Card (Bottom Center)
        if (hudText != null && !_showPopup)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              constraints: const BoxConstraints(
                maxWidth: 800,
              ), // Makes HUD flexible but prevents it from stretching forever on ultra-wide screens
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                border: const Border(
                  top: BorderSide(color: Colors.indigoAccent, width: 4),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.indigoAccent,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    // Prevents text overflow if instruction is very long
                    child: Text(
                      hudText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSuccessPopup() {
    if (!_showPopup) return const SizedBox.shrink();

    bool isFinal = _scenario == 5;

    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.green, blurRadius: 20),
                      ],
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    t('summaryTitle'),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isFinal ? t('finalDesc') : t('scenarioCompleted'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.greenAccent,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      playClick();
                      if (isFinal) {
                        _resetLab();
                      } else {
                        _loadScenario(_scenario + 1);
                      }
                    },
                    icon: Icon(isFinal ? Icons.flag : Icons.arrow_forward),
                    label: Text(
                      isFinal ? t('finishLab') : t('nextScenario'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFinal
                          ? Colors.amber
                          : Colors.indigoAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
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
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: Scaffold(
        body: Stack(
          children: [
            // Background Layer
            Container(color: const Color(0xFF0F172A)),

            // Canvas Layer (Animated Bounds)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: _sidebarOpen ? _sidebarWidth : 0,
              top: 0,
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onScaleStart: _handleScaleStart,
                onScaleUpdate: _handleScaleUpdate,
                onScaleEnd: _handleScaleEnd,
                child: CustomPaint(
                  key: _canvasKey,
                  painter: LabPainter(
                    shape: _shapes[_scenario] ?? [],
                    hotlines: _hotlines[_scenario] ?? [],
                    testedLines: _testedLines,
                    failedLine: _failedLine,
                    activeFoldLine: _activeFoldLine,
                    isFolded: _isFolded,
                    animating: _animating,
                    foldProgress: _foldProgress,
                    dragAvatar: _dragAvatar,
                    activeTool: _activeTool,
                    snapPoints: _snapPoints,
                    drawingLine: _drawingLine,
                    drawnLine: _drawnLine,
                    pan: _pan,
                    zoom: _zoom,
                  ),
                  child: Container(),
                ),
              ),
            ),

            // Sidebar
            _buildSidebar(),

            // Resizer Handle
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
                  onPanUpdate: (d) {
                    setState(() {
                      _sidebarWidth = (_sidebarWidth + d.delta.dx).clamp(
                        300.0,
                        MediaQuery.of(context).size.width * 0.6,
                      );
                    });
                  },
                  child: Container(
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    child: Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Tools & HUD Layer
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: _sidebarOpen ? _sidebarWidth : 0,
              top: 0,
              bottom: 0,
              right: 0,
              child: _buildToolsAndHUD(),
            ),

            // Popups & Overlays (Includes Success Screen & Curtain)
            _buildSuccessPopup(),
            _buildCurtain(),

            // Toggle Sidebar Button (Fixed Top Left)
            if (!_showCurtain)
              Positioned(
                left: 10,
                top: 10,
                child: FloatingActionButton.small(
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: Colors.white,
                  onPressed: () {
                    playClick();
                    setState(() {
                      _sidebarOpen = !_sidebarOpen;
                    });
                  },
                  child: Icon(_sidebarOpen ? Icons.menu_open : Icons.menu),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- CANVAS PAINTER ---

class LabPainter extends CustomPainter {
  final List<Offset> shape;
  final List<PolyLine> hotlines;
  final List<PolyLine> testedLines;
  final PolyLine? failedLine;
  final PolyLine? activeFoldLine;
  final bool isFolded;
  final bool animating;
  final double foldProgress;
  final Offset? dragAvatar;
  final String activeTool;
  final List<Offset> snapPoints;
  final PolyLine? drawingLine;
  final PolyLine? drawnLine;
  final Offset pan;
  final double zoom;

  LabPainter({
    required this.shape,
    required this.hotlines,
    required this.testedLines,
    required this.failedLine,
    required this.activeFoldLine,
    required this.isFolded,
    required this.animating,
    required this.foldProgress,
    required this.dragAvatar,
    required this.activeTool,
    required this.snapPoints,
    required this.drawingLine,
    required this.drawnLine,
    required this.pan,
    required this.zoom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (shape.isEmpty) return;

    canvas.save();
    canvas.translate(size.width / 2 + pan.dx, size.height / 2 + pan.dy);
    canvas.scale(zoom, zoom);

    final Paint paperFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final Paint paperStroke = Paint()
      ..color = Colors.blueGrey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final Paint backFill = Paint()
      ..color = Colors.blueGrey.shade100
      ..style = PaintingStyle.fill;
    final Paint mismatchFill = Paint()
      ..color = Colors.yellow.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    // Draw previously verified lines (bottom layer)
    if (!isFolded && !animating) {
      _drawPath(canvas, shape, paperFill, paperStroke);

      for (var l in testedLines) {
        _drawLine(canvas, l.p1, l.p2, Colors.green, 4);
      }
      if (failedLine != null) {
        _drawLine(
          canvas,
          failedLine!.p1,
          failedLine!.p2,
          Colors.redAccent,
          4,
          dashed: true,
        );
      }
    }

    // Draw Hotlines (Dotted)
    if (!isFolded && !animating) {
      for (var hl in hotlines) {
        if (!testedLines.any((t) => t.id == hl.id)) {
          _drawLine(
            canvas,
            hl.p1,
            hl.p2,
            Colors.blueGrey.shade400,
            3,
            dashed: true,
          );
        }
      }
    }

    // Draw Snap Points
    if (activeTool == 'drawer' && !isFolded && !animating) {
      final Paint snapPaint = Paint()..color = Colors.blueGrey.shade400;
      for (var p in snapPoints) {
        canvas.drawCircle(p, 4, snapPaint);
      }
    }

    // FOLDING LOGIC
    if (isFolded || animating) {
      if (activeFoldLine != null) {
        List<List<Offset>> polys = _splitPolygon(
          shape,
          activeFoldLine!.p1,
          activeFoldLine!.p2,
        );
        if (polys.length == 2 && polys[0].isNotEmpty && polys[1].isNotEmpty) {
          List<Offset> polyStatic = polys[0];
          List<Offset> polyFold = polys[1];

          _drawPath(canvas, polyStatic, paperFill, paperStroke);

          List<Offset> transformedFold = polyFold
              .map(
                (p) => _foldPoint(
                  p,
                  activeFoldLine!.p1,
                  activeFoldLine!.p2,
                  foldProgress,
                ),
              )
              .toList();

          Paint foldColor = foldProgress > 0.5 ? backFill : paperFill;
          bool isMismatch = !activeFoldLine!.valid && foldProgress > 0.9;
          if (isMismatch) foldColor = mismatchFill;

          _drawPath(
            canvas,
            transformedFold,
            foldColor,
            Paint()
              ..color = Colors.blueGrey
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3,
          );
          _drawLine(
            canvas,
            activeFoldLine!.p1,
            activeFoldLine!.p2,
            Colors.blueGrey,
            2,
          );

          if (foldProgress == 1.0) {
            Paint glowPaint = Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4;
            if (activeFoldLine!.valid) {
              glowPaint.color = Colors.greenAccent;
              glowPaint.maskFilter = const MaskFilter.blur(BlurStyle.outer, 10);
              _drawPath(canvas, transformedFold, null, glowPaint);
            } else {
              glowPaint.color = Colors.redAccent;
              glowPaint.maskFilter = const MaskFilter.blur(BlurStyle.outer, 10);
              _drawPath(canvas, transformedFold, null, glowPaint);
            }
          }
        } else {
          _drawPath(canvas, shape, paperFill, paperStroke);
        }
      }
    }

    // Draw Custom Lines
    if (activeTool == 'drawer' && !animating && !isFolded) {
      if (drawingLine != null) {
        _drawLine(
          canvas,
          drawingLine!.p1,
          drawingLine!.p2,
          Colors.indigoAccent,
          4,
          dashed: true,
        );
      }
      if (drawnLine != null) {
        _drawLine(canvas, drawnLine!.p1, drawnLine!.p2, Colors.indigoAccent, 4);
      }
    }

    // Draw Drag Avatar
    if (dragAvatar != null) {
      canvas.save();
      canvas.translate(dragAvatar!.dx, dragAvatar!.dy);
      Path handPath = Path()
        ..moveTo(0, -10)
        ..lineTo(20, 10)
        ..lineTo(10, 10)
        ..lineTo(10, 30)
        ..lineTo(-10, 30)
        ..lineTo(-10, 10)
        ..lineTo(-20, 10)
        ..close();
      canvas.drawPath(
        handPath,
        Paint()
          ..color = Colors.indigoAccent
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        handPath,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      canvas.restore();
    }

    canvas.restore();
  }

  void _drawPath(Canvas canvas, List<Offset> poly, Paint? fill, Paint? stroke) {
    if (poly.length < 3) return;
    Path path = Path()..moveTo(poly[0].dx, poly[0].dy);
    for (int i = 1; i < poly.length; i++) {
      path.lineTo(poly[i].dx, poly[i].dy);
    }
    path.close();
    if (fill != null) canvas.drawPath(path, fill);
    if (stroke != null) canvas.drawPath(path, stroke);
  }

  void _drawLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Color color,
    double width, {
    bool dashed = false,
  }) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    if (!dashed) {
      canvas.drawLine(p1, p2, paint);
    } else {
      double distance = (p2 - p1).distance;
      double dashWidth = 8.0, dashSpace = 8.0;
      double startX = p1.dx, startY = p1.dy;
      double dx = (p2.dx - p1.dx) / distance, dy = (p2.dy - p1.dy) / distance;

      double drawn = 0.0;
      while (drawn < distance) {
        double segment = min(dashWidth, distance - drawn);
        canvas.drawLine(
          Offset(startX, startY),
          Offset(startX + dx * segment, startY + dy * segment),
          paint,
        );
        drawn += dashWidth + dashSpace;
        startX += dx * (dashWidth + dashSpace);
        startY += dy * (dashWidth + dashSpace);
      }
    }
  }

  // Geometry specific overrides for splitting polygon accurately
  double _getLineSide(Offset p, Offset a, Offset b) =>
      (b.dx - a.dx) * (p.dy - a.dy) - (b.dy - a.dy) * (p.dx - a.dx);
  Offset? _lineIntersect(Offset p1, Offset p2, Offset p3, Offset p4) {
    double denom =
        (p1.dx - p2.dx) * (p3.dy - p4.dy) - (p1.dy - p2.dy) * (p3.dx - p4.dx);
    if (denom.abs() < 0.001) return null;
    double t =
        ((p1.dx - p3.dx) * (p3.dy - p4.dy) -
            (p1.dy - p3.dy) * (p3.dx - p4.dx)) /
        denom;
    return Offset(p1.dx + t * (p2.dx - p1.dx), p1.dy + t * (p2.dy - p1.dy));
  }

  Offset _getProjection(Offset p, Offset a, Offset b) {
    double dx = b.dx - a.dx;
    double dy = b.dy - a.dy;
    double lenSq = dx * dx + dy * dy;
    if (lenSq < 0.001) return p;
    double t = ((p.dx - a.dx) * dx + (p.dy - a.dy) * dy) / lenSq;
    return Offset(a.dx + t * dx, a.dy + t * dy);
  }

  Offset _foldPoint(Offset p, Offset a, Offset b, double progress) {
    Offset proj = _getProjection(p, a, b);
    double cosP = cos(pi * progress);
    return Offset(
      proj.dx + (p.dx - proj.dx) * cosP,
      proj.dy + (p.dy - proj.dy) * cosP,
    );
  }

  List<List<Offset>> _splitPolygon(List<Offset> poly, Offset pA, Offset pB) {
    List<Offset> poly1 = [];
    List<Offset> poly2 = [];
    for (int i = 0; i < poly.length; i++) {
      Offset curr = poly[i];
      Offset next = poly[(i + 1) % poly.length];
      double sideCurr = _getLineSide(curr, pA, pB);
      double sideNext = _getLineSide(next, pA, pB);
      if (sideCurr >= -0.1) poly1.add(curr);
      if (sideCurr <= 0.1) poly2.add(curr);
      if ((sideCurr > 0.1 && sideNext < -0.1) ||
          (sideCurr < -0.1 && sideNext > 0.1)) {
        Offset? intersect = _lineIntersect(curr, next, pA, pB);
        if (intersect != null) {
          poly1.add(intersect);
          poly2.add(intersect);
        }
      }
    }
    return [poly1, poly2];
  }

  @override
  bool shouldRepaint(covariant LabPainter oldDelegate) => true; // Always repaint driven by Ticker
}
