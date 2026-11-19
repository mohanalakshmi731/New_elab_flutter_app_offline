// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'The Expression Factory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617), // zslDark
        primaryColor: const Color(0xFFEAB308), // zslYellow
        fontFamily: 'Roboto', // Fallback for Plus Jakarta Sans
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFEAB308),
          secondary: Color(0xFF6366F1),
          surface: Color(0xFF1E293B),
        ),
      ),
      home: const ConventionsinWritingandInterpretingAlgebraic(),
    ),
  );
}

class ConventionsinWritingandInterpretingAlgebraic extends StatefulWidget {
  const ConventionsinWritingandInterpretingAlgebraic({super.key});

  @override
  State<ConventionsinWritingandInterpretingAlgebraic> createState() =>
      _ConventionsinWritingandInterpretingAlgebraicState();
}

class _ConventionsinWritingandInterpretingAlgebraicState
    extends State<ConventionsinWritingandInterpretingAlgebraic>
    with TickerProviderStateMixin {
  // Application State
  bool _isCurtainOpen = false;
  bool _isSidebarOpen = true;
  String _currentLanguage = 'en';
  int _currentScenarioId = 1;
  int _currentStepIndex = 0;

  // Scenario 1 State
  Offset _xBoxPos = const Offset(150, 380);
  bool _s1XBoxDraggable = true;
  bool _s1XBoxOnInput = false;
  int _s1DialValue = 1;
  bool _s1MachineRunning = false;
  final List<Offset> _s1OutputBoxes = [];

  // Scenario 2 State
  List<SortItem> _s2Items = [];
  int _s2XCount = 0;
  int _s2YCount = 0;
  bool _s2Combined = false;
  String _s2BoardText = "Sorting Hub...";

  // Audio
  final AudioPlayer _audioPlayer = AudioPlayer();
  final String _sndClick =
      'audio/class7/mixkit_2568.mp3';
  final String _sndSuccess =
      'audio/class7/mixkit_2018.mp3';
  final String _sndError =
      'audio/class7/mixkit_2954.mp3';
  final String _sndCurtain =
      'audio/class7/mixkit_2574.mp3';
  final String _sndMachine =
      'audio/class7/mixkit_2733.mp3';

  // HUD Feedback
  String _feedbackMessage = '';
  Color _feedbackColor = Colors.transparent;
  Timer? _feedbackTimer;

  // Animations
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initScenario2Items();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _audioPlayer.dispose();
    _pulseController.dispose();
    _feedbackTimer?.cancel();
    super.dispose();
  }

  void _playSound(String url) async {
    try {
      await _audioPlayer.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio play error: $e");
    }
  }

  void _enterLab() {
    _playSound(_sndCurtain);
    setState(() {
      _isCurtainOpen = true;
    });
  }

  void _toggleLanguage() {
    _playSound(_sndClick);
    setState(() {
      _currentLanguage = _currentLanguage == 'en' ? 'hi' : 'en';
    });
  }

  void _resetLab() {
    _playSound(_sndCurtain);
    setState(() {
      _isCurtainOpen = false;
      _isSidebarOpen = true; // Optionally reset sidebar as well
    });
    
    // Wait for the curtain to close before resetting the scenario objects
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        _loadScenario(1);
      }
    });
  }

  void _showFeedback(String msg, Color color) {
    setState(() {
      _feedbackMessage = msg;
      _feedbackColor = color;
    });
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _feedbackColor = Colors.transparent;
        });
      }
    });
  }

  void _loadScenario(int id) {
    _playSound(_sndClick);
    setState(() {
      _currentScenarioId = id;
      _currentStepIndex = 0;
      _feedbackColor = Colors.transparent;

      if (id == 1) {
        _xBoxPos = const Offset(150, 380);
        _s1XBoxDraggable = true;
        _s1XBoxOnInput = false;
        _s1DialValue = 1;
        _s1MachineRunning = false;
        _s1OutputBoxes.clear();
      } else {
        _initScenario2Items();
        _s2XCount = 0;
        _s2YCount = 0;
        _s2Combined = false;
        _s2BoardText = t("l_sortingHub");
      }
    });
  }

  void _initScenario2Items() {
    _s2Items = [
      SortItem(id: '1', type: 'x', pos: const Offset(150, 350)),
      SortItem(id: '2', type: 'y', pos: const Offset(250, 350)),
      SortItem(id: '3', type: 'x', pos: const Offset(350, 350)),
      SortItem(id: '4', type: 'y', pos: const Offset(450, 350)),
      SortItem(id: '5', type: 'x', pos: const Offset(550, 350)),
    ];
  }

  void _validateStep() {
    _playSound(_sndSuccess);
    final reqAction = _getRequiredAction();

    if (reqAction == "validate_model") {
      _showSummaryDialog();
      return;
    }

    setState(() {
      _currentStepIndex++;

      // Auto triggers
      if (_currentScenarioId == 1 && _getRequiredAction() == "auto_anim") {
        _runScenario1Animation();
      }
    });
  }

  void _runScenario1Animation() async {
    setState(() {
      _s1MachineRunning = true;
    });
    _playSound(_sndMachine);

    // Simulate box moving inside
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _s1XBoxOnInput = false;
    }); // hide from input

    // Simulate processing
    await Future.delayed(const Duration(seconds: 1));

    // Output 4 boxes
    for (int i = 0; i < 4; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      _playSound(_sndClick);
      setState(() {
        _s1OutputBoxes.add(Offset(600.0 + (i * 60), 380.0));
      });
    }

    await Future.delayed(const Duration(milliseconds: 500));
    _validateStep();
  }

  void _runScenario2Animation() async {
    _playSound(_sndMachine);
    setState(() {
      _s2Combined = true;
      _s2BoardText = "3x + 2y";
    });
    await Future.delayed(const Duration(seconds: 1));
    _validateStep();
  }

  String _getRequiredAction() {
    if (_currentScenarioId == 1) {
      if (_currentStepIndex == 0) return "drag_x_to_in";
      if (_currentStepIndex == 1) return "set_dial_4";
      if (_currentStepIndex == 2) return "click_start";
      if (_currentStepIndex == 3) return "auto_anim";
      if (_currentStepIndex == 4) return "validate_model";
    } else {
      if (_currentStepIndex == 0) return "click_start_sort";
      if (_currentStepIndex == 1) return "sort_x";
      if (_currentStepIndex == 2) return "sort_y";
      if (_currentStepIndex == 3) return "click_combine";
      if (_currentStepIndex == 4) return "validate_model";
    }
    return "";
  }

  // Dictionary matching HTML
  final Map<String, Map<String, String>> _dict = {
    'en': {
      'appTitle': 'The Expression Factory: Visualizing Algebraic Conventions',
      'appSubtitle': 'Class 7 • EXPRESSIONS USING LETTER-NUMBERS',
      'enterLab': 'Enter Lab',
      'theory': 'Theory',
      'missionObj': 'Mission Objective:',
      'procSteps': 'Procedural Steps',
      'stepLabel': 'STEP',
      'scen1Title': '1. The Duplicator Machine',
      'scen2Title': '2. The Like-Terms Sorter',
      's1Obj':
          'To understand that a coefficient is a multiplier by visually seeing it "clone" a variable.',
      's1_1_hud':
          "Drag the blue 'Mystery Box' labeled 'x' onto the input conveyor belt.",
      's1_1_txt':
          "From the parts bin, DRAG the blue \"Mystery Box\" labeled 'x' and DROP it onto the input conveyor belt of the Duplicator Machine.",
      's1_2_hud': "Click the machine's dial to set it to '4'.",
      's1_2_txt':
          "The machine has a large dial on the side, currently set to '1'. CLICK the dial to set it to '4'.",
      's1_3_hud': "Click the large green START button on the machine.",
      's1_3_txt': "CLICK the large green \"START\" button on the machine.",
      's1_4_hud': "Observe the operation...",
      's1_4_txt': "Observe the output tray.",
      's1_5_hud': "Operation complete! Validate the model to proceed.",
      's1_5_txt': "Operation complete! Validate the model.",
      's2Obj':
          'To physically sort "like" and "unlike" terms to understand why only like terms can be combined.',
      's2_1_hud':
          "Observe the mixed items on the conveyor. Click 'Start Sorting' to begin.",
      's2_1_txt': "CLICK the \"Start Sorting\" button to start the sorting.",
      's2_2_hud': "Drag all 3 blue 'x' cubes into the blue 'x' bin.",
      's2_2_txt':
          "DRAG each blue 'x' cube from the conveyor belt and DROP it into the blue 'x' bin.",
      's2_3_hud': "Drag all 2 red 'y' spheres into the red 'y' bin.",
      's2_3_txt':
          "DRAG each red 'y' sphere from the conveyor belt and DROP it into the red 'y' bin.",
      's2_4_hud': "Click the yellow 'Combine' button on the sorting station.",
      's2_4_txt': "CLICK the \"Combine\" button.",
      's2_5_hud': "Sorting complete! Validate the model to proceed.",
      's2_5_txt': "Sorting complete! Validate the model.",
      'fb_sortXFirst': "Sort 'x' cubes first!",
      'fb_sortYNow': "Sort 'y' spheres now!",
      'fb_dialSet4': "Dial set to 4!",
      'fb_machineStarted': "Machine started!",
      'fb_combining': "Combining terms...",
      'fb_boxLoaded': "Perfect! Box loaded.",
      'fb_dropLeftConveyor': "Drop it on the left conveyor.",
      'fb_allXSorted': "All 'x' terms sorted!",
      'fb_allYSorted': "All 'y' terms sorted!",
      'fb_unlikeTerms': "Unlike terms cannot be combined!",
      'fb_sortedXKeepGoing': "Sorted x. Keep going!",
      'fb_sortedYKeepGoing': "Sorted y. Keep going!",
      'nextStep': 'Next Step',
      'validateModel': 'Validate Model',
      'startSortingBtn': 'Start Sorting',
      'proceedNext': 'Proceed to Next Step',
      'l_sortingHub': 'Sorting Hub...',
      'conclusion': 'Conclusion',
      's1_sum1':
          'Putting 1 box x into a machine set to 4 results in 4 boxes of x.',
      's1_sum2': 'This is written mathematically as 4 × x, or simply 4x.',
      's1_sum3': 'Multiplier = Coefficient',
      's2_sum1': 'The initial disorganized collection was:\nx + y + x + y + x',
      's2_sum2':
          'By grouping like terms together, the simplified expression is:\n3x + 2y',
      's2_sum3':
          'We cannot combine x and y into 5xy because they are fundamentally different objects.',
    },
    'hi': {
      'appTitle': 'व्यंजक कारखाना: बीजगणितीय मान्यताओं की कल्पना',
      'appSubtitle': 'कक्षा 7 • अक्षर-संख्याओं का उपयोग करके व्यंजक',
      'enterLab': 'प्रयोगशाला में प्रवेश करें',
      'theory': 'सिद्धांत',
      'missionObj': 'मिशन का उद्देश्य:',
      'procSteps': 'प्रक्रियात्मक कदम',
      'stepLabel': 'कदम',
      'scen1Title': '1. डुप्लिकेटर मशीन',
      'scen2Title': '2. समान-पद छँटाई मशीन',
      's1Obj':
          'यह समझना कि गुणांक एक गुणक है, इसे चर की "प्रतिकृति" बनाते हुए देखकर।',
      's1_1_hud':
          "'x' लेबल वाले नीले 'मिस्ट्री बॉक्स' को इनपुट कन्वेयर बेल्ट पर खींचें।",
      's1_1_txt':
          "पार्ट्स बिन से, 'x' लेबल वाले नीले \"मिस्ट्री बॉक्स\" को खींचें और डुप्लिकेटर मशीन के इनपुट कन्वेयर बेल्ट पर छोड़ दें।",
      's1_2_hud': "मशीन के डायल को '4' पर सेट करने के लिए क्लिक करें।",
      's1_2_txt':
          "मशीन के किनारे एक बड़ा डायल है, जो वर्तमान में '1' पर सेट है। इसे '4' पर सेट करने के लिए डायल पर क्लिक करें।",
      's1_3_hud': "मशीन पर बड़े हरे रंग के START बटन पर क्लिक करें।",
      's1_3_txt': "मशीन पर बड़े हरे रंग के \"START\" बटन पर क्लिक करें।",
      's1_4_hud': "संचालन का निरीक्षण करें...",
      's1_4_txt': "आउटपुट ट्रे का निरीक्षण करें।",
      's1_5_hud': "संचालन पूरा हुआ! आगे बढ़ने के लिए मॉडल को मान्य करें।",
      's1_5_txt': "संचालन पूरा हुआ! मॉडल को मान्य करें।",
      's2Obj':
          'शारीरिक रूप से "समान" और "असमान" पदों को छाँटना ताकि यह समझा जा सके कि केवल समान पदों को ही क्यों जोड़ा जा सकता है।',
      's2_1_hud':
          "कन्वेयर पर मिश्रित वस्तुओं का निरीक्षण करें। शुरू करने के लिए 'छँटाई शुरू करें' पर क्लिक करें।",
      's2_1_txt':
          "छँटाई शुरू करने के लिए \"छँटाई शुरू करें\" बटन पर क्लिक करें।",
      's2_2_hud': "सभी 3 नीले 'x' क्यूब्स को नीले 'x' बिन में खींचें।",
      's2_2_txt':
          "कन्वेयर बेल्ट से प्रत्येक नीले 'x' क्यूब को खींचें और इसे नीले 'x' बिन में छोड़ दें।",
      's2_3_hud': "सभी 2 लाल 'y' गोलों को लाल 'y' बिन में खींचें।",
      's2_3_txt':
          "कन्वेयर बेल्ट से प्रत्येक लाल 'y' गोले को खींचें और इसे लाल 'y' बिन में छोड़ दें।",
      's2_4_hud': "सॉर्टिंग स्टेशन पर पीले 'जोड़ें' बटन पर क्लिक करें।",
      's2_4_txt': "\"जोड़ें\" बटन पर क्लिक करें।",
      's2_5_hud': "छँटाई पूरी हुई! आगे बढ़ने के लिए मॉडल को मान्य करें।",
      's2_5_txt': "छँटाई पूरी हुई! मॉडल को मान्य करें।",
      'fb_sortXFirst': "पहले 'x' क्यूब्स छाँटें!",
      'fb_sortYNow': "अब 'y' गोलों को छाँटें!",
      'fb_dialSet4': "डायल 4 पर सेट हो गया!",
      'fb_machineStarted': "मशीन शुरू हो गई!",
      'fb_combining': "पदों को मिला रहे हैं...",
      'fb_boxLoaded': "उत्तम! बॉक्स लोड हो गया।",
      'fb_dropLeftConveyor': "इसे बाएं कन्वेयर पर छोड़ दें।",
      'fb_allXSorted': "सभी 'x' पद छाँट दिए गए!",
      'fb_allYSorted': "सभी 'y' पद छाँट दिए गए!",
      'fb_unlikeTerms': "असमान पदों को नहीं जोड़ा जा सकता!",
      'fb_sortedXKeepGoing': "x छाँट दिया। जारी रखें!",
      'fb_sortedYKeepGoing': "y छाँट दिया। जारी रखें!",
      'nextStep': 'अगला कदम',
      'validateModel': 'मॉडल को मान्य करें',
      'startSortingBtn': 'छँटाई शुरू करें',
      'proceedNext': 'अगले चरण पर जाएं',
      'l_sortingHub': 'सॉर्टिंग हब...',
      'conclusion': 'निष्कर्ष',
      's1_sum1': '4 पर सेट मशीन में 1 बॉक्स x डालने से x के 4 बॉक्स मिलते हैं।',
      's1_sum2':
          'इसे गणितीय रूप में 4 × x, या केवल 4x के रूप में लिखा जाता है।',
      's1_sum3': 'गुणक = गुणांक',
      's2_sum1': 'प्रारंभिक अव्यवस्थित संग्रह था:\nx + y + x + y + x',
      's2_sum2': 'समान पदों को एक साथ रखकर, सरलीकृत व्यंजक है:\n3x + 2y',
      's2_sum3':
          'हम x और y को 5xy में नहीं जोड़ सकते क्योंकि वे मौलिक रूप से भिन्न वस्तुएं हैं।',
    },
  };

  String t(String key) => _dict[_currentLanguage]?[key] ?? key;

  List<Map<String, String>> getSteps() {
    if (_currentScenarioId == 1) {
      return [
        {'hud': t('s1_1_hud'), 'txt': t('s1_1_txt')},
        {'hud': t('s1_2_hud'), 'txt': t('s1_2_txt')},
        {'hud': t('s1_3_hud'), 'txt': t('s1_3_txt')},
        {'hud': t('s1_4_hud'), 'txt': t('s1_4_txt')},
        {'hud': t('s1_5_hud'), 'txt': t('s1_5_txt')},
      ];
    } else {
      return [
        {'hud': t('s2_1_hud'), 'txt': t('s2_1_txt')},
        {'hud': t('s2_2_hud'), 'txt': t('s2_2_txt')},
        {'hud': t('s2_3_hud'), 'txt': t('s2_3_txt')},
        {'hud': t('s2_4_hud'), 'txt': t('s2_4_txt')},
        {'hud': t('s2_5_hud'), 'txt': t('s2_5_txt')},
      ];
    }
  }

  void _showSummaryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 400),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFEAB308).withOpacity(0.5),
                width: 2,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t('conclusion'),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEAB308),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          _playSound(_sndClick);
                          Navigator.of(context).pop();
                          _loadScenario(_currentScenarioId == 1 ? 2 : 1);
                        },
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 16),
                  if (_currentScenarioId == 1) ...[
                    Text(
                      t('s1_sum1'),
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t('s1_sum2'),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAB308).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        t('s1_sum3'),
                        style: const TextStyle(
                          fontSize: 20,
                          color: Color(0xFFEAB308),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ] else ...[
                    Text(
                      t('s2_sum1'),
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t('s2_sum2'),
                      style: const TextStyle(
                        fontSize: 22,
                        color: Color(0xFFEAB308),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        t('s2_sum3'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.redAccent,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final sidebarWidth = screenWidth * 0.35; // 30-35% of screen width

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // 1. Background Interactive Canvas
            Positioned.fill(
              child: Container(
                color: const Color(0xFF0F172A), // Dark slate bg
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 3.0,
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(500),
                  child: SizedBox(
                    width: 1200,
                    height: 800,
                    child: Center(
                      child: _currentScenarioId == 1
                          ? _buildScenario1Canvas()
                          : _buildScenario2Canvas(),
                    ),
                  ),
                ),
              ),
            ),

            // 2. HUD Action Bottom Center (When Sidebar Collapsed)
            if (!_isSidebarOpen)
              Positioned(
                width: 280,
                top: 66,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFEAB308).withOpacity(0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Aligns icon to top if text wraps
                        children: [
                          const Icon(
                            Icons.track_changes,
                            color: Color(0xFFEAB308),
                            size: 20,
                          ),
                          const SizedBox(width: 8),

                          // Wrap the Text in an Expanded widget
                          Expanded(
                            child: Text(
                              getSteps()[_currentStepIndex]['hud']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_feedbackColor != Colors.transparent) ...[
                        const SizedBox(height: 4),
                        Text(
                          _feedbackMessage,
                          style: TextStyle(
                            color: _feedbackColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      _buildDynamicActionButton(),
                    ],
                  ),
                ),
              ),

            // 3. Left Sidebar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              width: sidebarWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.95),
                  border: const Border(
                    right: BorderSide(color: Colors.white24, width: 1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              // Header inside sidebar
                              Container(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  66,
                                  16,
                                  16,
                                ),
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
                                        const Icon(
                                          Icons.science,
                                          color: Color(0xFFEAB308),
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            t('appTitle'),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            maxLines: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      t('appSubtitle'),
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 10,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        TextButton.icon(
                                          onPressed: _toggleLanguage,
                                          icon: const Icon(
                                            Icons.language,
                                            color: Color(0xFFEAB308),
                                            size: 18,
                                          ),
                                          label: Text(
                                            _currentLanguage.toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.white
                                                .withOpacity(0.1),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.refresh,
                                            color: Colors.redAccent,
                                            size: 20,
                                          ),
                                          onPressed: _resetLab,
                                          tooltip: 'Reset Lab',
                                          style: IconButton.styleFrom(
                                            backgroundColor: Colors.white
                                                .withOpacity(0.1),
                                            padding: const EdgeInsets.all(8),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Content
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Scenario Dropdown
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0F172A),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.white24,
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<int>(
                                            value: _currentScenarioId,
                                            isExpanded: true,
                                            dropdownColor: const Color(
                                              0xFF0F172A,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            items: [
                                              DropdownMenuItem(
                                                value: 1,
                                                child: Text(t('scen1Title')),
                                              ),
                                              DropdownMenuItem(
                                                value: 2,
                                                child: Text(t('scen2Title')),
                                              ),
                                            ],
                                            onChanged: (val) {
                                              if (val != null) {
                                                _loadScenario(val);
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Theory Block
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF334155,
                                          ).withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
                                                  Icons.menu_book,
                                                  color: Colors.white70,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  t('theory'),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "${t('missionObj')} ${_currentScenarioId == 1 ? t('s1Obj') : t('s2Obj')}",
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 13,
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Procedural Steps
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.format_list_numbered,
                                            color: Colors.white70,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            t('procSteps'),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      ...List.generate(getSteps().length, (
                                        index,
                                      ) {
                                        bool isPast = index < _currentStepIndex;
                                        bool isCurrent =
                                            index == _currentStepIndex;
                                        return AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          margin: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: isCurrent
                                                ? const Color(0xFFEAB308)
                                                : (isPast
                                                    ? Colors.white10
                                                    : Colors.white
                                                        .withOpacity(0.05)),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: isCurrent
                                                  ? Colors.amberAccent
                                                  : Colors.transparent,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${t('stepLabel')} ${index + 1}",
                                                style: TextStyle(
                                                  color: isCurrent
                                                      ? Colors.black87
                                                      : Colors.white54,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.2,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                getSteps()[index]['txt']!,
                                                style: TextStyle(
                                                  color: isCurrent
                                                      ? Colors.black
                                                      : (isPast
                                                          ? Colors.white38
                                                          : Colors.white60),
                                                  fontSize: 13,
                                                  decoration: isPast
                                                      ? TextDecoration
                                                          .lineThrough
                                                      : null,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),

                                      // Action Button inside sidebar
                                      const SizedBox(height: 16),
                                      Center(
                                        child: _buildDynamicActionButton(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Footer
                              Container(
                                padding: const EdgeInsets.all(12),
                                color: Colors.black26,
                                width: double.infinity,
                                child: Text(
                                  '© ZeroScienceLab - Fall in love with math and Science',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 10,
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
              ),
            ),

            // 4. Top Left Menu Icon
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: const Color(0xFFEAB308),
                iconSize: 28,
                onPressed: () {
                  _playSound(_sndClick);
                  setState(() {
                    _isSidebarOpen = !_isSidebarOpen;
                  });
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: const Color(0xFFEAB308).withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            ),

            // 5. Curtain
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeInOutCubic,
              top: _isCurtainOpen ? -screenHeight : 0,
              left: 0,
              right: 0,
              height: screenHeight,
              child: Container(
                color: const Color(0xFF020617),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          t('appTitle'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t('appSubtitle'),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 48),
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: ElevatedButton.icon(
                          onPressed: _enterLab,
                          icon: const Icon(Icons.science, color: Colors.black),
                          label: Text(
                            t('enterLab'),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEAB308),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
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
    );
  }

  Widget _buildDynamicActionButton() {
    final reqAction = _getRequiredAction();
    if (reqAction.isEmpty) return const SizedBox.shrink();

    bool isClickable = false;
    String btnText = "";
    Color btnColor = const Color(0xFFEAB308);
    Color textColor = Colors.black;
    IconData iconData = Icons.arrow_forward;

    if (reqAction == "validate_model") {
      isClickable = true;
      btnText = t('validateModel');
      btnColor = Colors.green;
      textColor = Colors.white;
      iconData = Icons.check_circle;
    } else if (reqAction == "click_start_sort") {
      isClickable = true;
      btnText = t('startSortingBtn');
      iconData = Icons.play_arrow;
    } else {
      isClickable = false;
      btnText = t('proceedNext');
      btnColor = Colors.grey.shade700;
      textColor = Colors.grey.shade400;
    }

    return ElevatedButton.icon(
      onPressed: isClickable ? _validateStep : null,
      icon: Icon(iconData, color: textColor),
      label: Text(
        btnText,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: btnColor,
        disabledBackgroundColor: Colors.grey.shade800,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  // --- Scenario 1 Canvas ---
  Widget _buildScenario1Canvas() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Machine Base Image (Vector Art equivalent)
        Container(
          width: 800,
          height: 500,
          decoration: BoxDecoration(
            color: const Color(0xFF334155),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24, width: 4),
          ),
        ),

        // Input Conveyor
        Positioned(
          left: 50,
          top: 350,
          child: Container(
            width: 300,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                "INPUT CONVEYOR",
                style: TextStyle(color: Colors.white30, letterSpacing: 2),
              ),
            ),
          ),
        ),

        // Output Conveyor
        Positioned(
          right: 50,
          top: 350,
          child: Container(
            width: 300,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                "OUTPUT CONVEYOR",
                style: TextStyle(color: Colors.white30, letterSpacing: 2),
              ),
            ),
          ),
        ),

        // Machine Dial
        Positioned(
          top: 100,
          left: 350,
          child: GestureDetector(
            onTap: () {
              if (_getRequiredAction() == "set_dial_4") {
                _playSound(_sndClick);
                setState(() {
                  _s1DialValue = _s1DialValue >= 4 ? 1 : _s1DialValue + 1;
                  if (_s1DialValue == 4) {
                    _showFeedback(t('fb_dialSet4'), Colors.greenAccent);
                    _validateStep();
                  }
                });
              }
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey, width: 4),
              ),
              child: Center(
                child: Text(
                  _s1DialValue.toString(),
                  style: const TextStyle(
                    color: Color(0xFFEAB308),
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),

        Positioned(
          top: 60,
          left: 330,
          child: Text(
            t('scen1Title'),
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),

        // Start Button
        Positioned(
          top: 250,
          left: 325,
          child: GestureDetector(
            onTap: () {
              if (_getRequiredAction() == "click_start" && !_s1MachineRunning) {
                _playSound(_sndClick);
                _showFeedback(t('fb_machineStarted'), Colors.greenAccent);
                _validateStep();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 150,
              height: 60,
              decoration: BoxDecoration(
                color: _s1MachineRunning
                    ? Colors.green.shade800
                    : Colors.green.shade500,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200, width: 2),
              ),
              child: const Center(
                child: Text(
                  "START",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Input DragTarget
        Positioned(
          left: 100,
          top: 320,
          child: DragTarget<String>(
            onWillAccept: (data) => data == 'x_box' && !_s1XBoxOnInput,
            onAccept: (data) {
              _playSound(_sndSuccess);
              setState(() {
                _s1XBoxOnInput = true;
                _s1XBoxDraggable = false;
                _xBoxPos = const Offset(200, 320); // Snapped pos
              });
              _showFeedback(t('fb_boxLoaded'), Colors.greenAccent);
              if (_getRequiredAction() == "drag_x_to_in") {
                _validateStep();
              }
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: candidateData.isNotEmpty
                        ? Colors.green
                        : Colors.white24,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  color: candidateData.isNotEmpty
                      ? Colors.green.withOpacity(0.2)
                      : Colors.transparent,
                ),
              );
            },
          ),
        ),

        // Output Boxes
        for (var pos in _s1OutputBoxes)
          Positioned(left: pos.dx - 120, top: pos.dy - 30, child: _buildXBox()),

        // Draggable X Box
        if (!_s1MachineRunning && (!_s1XBoxOnInput || _s1XBoxDraggable))
          Positioned(
            left: _xBoxPos.dx - 30,
            top: _xBoxPos.dy - 230,
            child: Draggable<String>(
              data: 'x_box',
              feedback: Material(
                color: Colors.transparent,
                child: _buildXBox(),
              ),
              childWhenDragging: Opacity(opacity: 0.3, child: _buildXBox()),
              onDragEnd: (details) {
                // If not accepted by DragTarget, snap back (simulated logic handled by drag target)
              },
              child: _buildXBox(),
            ),
          ),

        if (_s1XBoxOnInput && !_s1MachineRunning)
          Positioned(
            left: _xBoxPos.dx - 80,
            top: _xBoxPos.dy + 20,
            child: _buildXBox(),
          ),
      ],
    );
  }

  Widget _buildXBox() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          "x",
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildYSphere() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          "y",
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // --- Scenario 2 Canvas ---
  Widget _buildScenario2Canvas() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Main Board
        Container(
          width: 900,
          height: 600,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        // Display Screen
        Positioned(
          top: 50,
          left: 250,
          child: Container(
            width: 400,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade700, width: 4),
            ),
            child: Center(
              child: Text(
                _s2BoardText,
                style: const TextStyle(
                  color: Color(0xFFEAB308),
                  fontSize: 40,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),

        // Conveyor Belt
        Positioned(
          top: 250,
          left: 50,
          child: Container(
            width: 800,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        // X Bin
        Positioned(
          bottom: 50,
          left: 100,
          child: DragTarget<SortItem>(
            onWillAccept: (data) => data != null,
            onAccept: (item) {
              if (item.type == 'x') {
                if (_getRequiredAction() == "sort_x") {
                  _playSound(_sndSuccess);
                  setState(() {
                    item.isSorted = true;
                    item.pos = Offset(110.0 + (_s2XCount * 40), 100.0);
                    _s2XCount++;
                    if (_s2XCount == 3) {
                      _showFeedback(t('fb_allXSorted'), Colors.greenAccent);
                      _validateStep();
                    } else {
                      _showFeedback(t('fb_sortedXKeepGoing'), Colors.white);
                    }
                  });
                } else {
                  _playSound(_sndError);
                  _showFeedback(t('fb_sortXFirst'), Colors.redAccent);
                }
              } else {
                _playSound(_sndError);
                _showFeedback(t('fb_unlikeTerms'), Colors.redAccent);
              }
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                width: 200,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  border: Border.all(
                    color: candidateData.isNotEmpty
                        ? Colors.green
                        : const Color(0xFF6366F1),
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "${_s2XCount}x",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
        ),

        // Y Bin
        Positioned(
          bottom: 50,
          right: 100,
          child: DragTarget<SortItem>(
            onWillAccept: (data) => data != null,
            onAccept: (item) {
              if (item.type == 'y') {
                if (_getRequiredAction() == "sort_y") {
                  _playSound(_sndSuccess);
                  setState(() {
                    item.isSorted = true;
                    item.pos = Offset(610.0 + (_s2YCount * 50), 100.0);
                    _s2YCount++;
                    if (_s2YCount == 2) {
                      _showFeedback(t('fb_allYSorted'), Colors.greenAccent);
                      _validateStep();
                    } else {
                      _showFeedback(t('fb_sortedYKeepGoing'), Colors.white);
                    }
                  });
                } else {
                  _playSound(_sndError);
                  _showFeedback(t('fb_sortYNow'), Colors.redAccent);
                }
              } else {
                _playSound(_sndError);
                _showFeedback(t('fb_unlikeTerms'), Colors.redAccent);
              }
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                width: 200,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.3),
                  border: Border.all(
                    color: candidateData.isNotEmpty
                        ? Colors.green
                        : const Color(0xFFEF4444),
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "${_s2YCount}y",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
        ),

        // Combine Button
        Positioned(
          bottom: 100,
          left: 380,
          child: GestureDetector(
            onTap: () {
              if (_getRequiredAction() == "click_combine") {
                _playSound(_sndClick);
                _runScenario2Animation();
              }
            },
            child: Container(
              width: 140,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFEAB308),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  "COMBINE",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Items
        if (_currentStepIndex >= 1)
          for (var item in _s2Items)
            Positioned(
              left: item.isSorted
                  ? (item.type == 'x'
                      ? 110.0 +
                          (_s2Items
                                  .where((i) => i.type == 'x' && i.isSorted)
                                  .toList()
                                  .indexOf(item) *
                              50)
                      : 610.0 +
                          (_s2Items
                                  .where((i) => i.type == 'y' && i.isSorted)
                                  .toList()
                                  .indexOf(item) *
                              50))
                  : item.pos.dx,
              top: item.isSorted ? 430 : item.pos.dy - 90,
              child: item.isSorted || _s2Combined
                  ? (item.type == 'x' ? _buildXBox() : _buildYSphere())
                  : Draggable<SortItem>(
                      data: item,
                      feedback: Material(
                        color: Colors.transparent,
                        child: item.type == 'x'
                            ? _buildXBox()
                            : _buildYSphere(),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: item.type == 'x'
                            ? _buildXBox()
                            : _buildYSphere(),
                      ),
                      child: item.type == 'x' ? _buildXBox() : _buildYSphere(),
                    ),
            ),
      ],
    );
  }
}

class SortItem {
  final String id;
  final String type;
  Offset pos;
  bool isSorted;

  SortItem({
    required this.id,
    required this.type,
    required this.pos,
    this.isSorted = false,
  });
}