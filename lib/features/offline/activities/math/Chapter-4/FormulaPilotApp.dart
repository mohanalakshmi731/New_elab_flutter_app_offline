// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart'; // Added audio players
import 'dart:async';
import 'dart:math' as math;

// --- DATA & I18N ---

class Equation {
  final int id;
  final String latex;
  final int a;
  final int b;
  final int c;
  final int D;
  final String root1;
  final String root2;

  Equation({
    required this.id,
    required this.latex,
    required this.a,
    required this.b,
    required this.c,
    required this.D,
    required this.root1,
    required this.root2,
  });
}

final List<Equation> equationsData = [
  Equation(
    id: 0,
    latex: "2x² - 7x + 3 = 0",
    a: 2,
    b: -7,
    c: 3,
    D: 25,
    root1: "x=3",
    root2: "x=0.5",
  ),
  Equation(
    id: 1,
    latex: "x² - 4x + 1 = 0",
    a: 1,
    b: -4,
    c: 1,
    D: 12,
    root1: "x=3.73",
    root2: "x=0.27",
  ),
  Equation(
    id: 2,
    latex: "x² + 6x + 5 = 0",
    a: 1,
    b: 6,
    c: 5,
    D: 16,
    root1: "x=-1",
    root2: "x=-5",
  ),
  Equation(
    id: 3,
    latex: "3x² - 5x + 2 = 0",
    a: 3,
    b: -5,
    c: 2,
    D: 1,
    root1: "x=1",
    root2: "x=0.67",
  ),
];

const Map<String, Map<String, String>> i18n = {
  'en': {
    "app_title": "FORMULA PILOT",
    "tagline": "QUADRATIC FORMULA • CLASS 10",
    "init_btn": "LAUNCH MISSION",
    "header_title": "Formula Pilot",
    "header_subtitle": "CLASS 10 • QUADRATIC EQUATIONS",
    "btn_start_lab": "Enter Cockpit",
    "post_title": "Analysis & Outcomes",
    "btn_restart": "Reboot System",
    "lbl_progress": "Flight Plan",
    "hud_status": "Nav Status",
    "lbl_select_eq": "Select Flight Path",
    "btn_engage": "ENGAGE SYSTEMS",
    "msg_params": "Identify Engine Parameters",
    "btn_extract": "LOCK PARAMETERS",
    "btn_calc_d": "VERIFY FUEL (D)",
    "btn_set_coord": "SET COORDINATES",
    "msg_success": "LANDING SUCCESSFUL",
    "btn_next": "New Mission",
    "step_0_t": "AWAITING MISSION",
    "step_0_d":
        "Select a flight path from the dropdown and click 'ENGAGE SYSTEMS' to lock it.",
    "step_1_t": "PRE-FLIGHT",
    "step_1_d":
        "Identify the coefficients: 'a' (x²), 'b' (x), and 'c' (constant). Enter them and click 'LOCK PARAMETERS'.",
    "step_2_t": "DIAGNOSTICS",
    "step_2_d":
        "Calculate the Discriminant D = b² - 4ac using your parameters. Enter it and click 'VERIFY FUEL (D)'.",
    "step_3_t": "FUEL CHECK",
    "step_3_d":
        "Review the computed Quadratic Formula. Click 'SET COORDINATES' to plot the landing path.",
    "step_4_t": "NAVIGATION",
    "step_4_d":
        "Calculate the exact landing roots. Click 'Path 1 (+)' and 'Path 2 (-)' to finalize the mission.",
    "step_5_t": "APPROACH",
    "step_5_d": "Mission accomplished! Roots verified successfully.",
    "out_1_t": "Universal Tool",
    "out_1_d":
        "The Quadratic Formula works for ANY quadratic equation, unlike factoring.",
    "out_2_t": "Precision",
    "out_2_d": "It gives exact values, even for irrational roots like 2 ± √3.",
    "out_3_t": "The Logic",
    "out_3_d": "It is derived from the method of completing the square.",
    "log_sys_online": "System Online. Awaiting input...",
    "log_path_locked": "Flight Path Locked: ",
    "log_engine_core": "Engine Core: ",
    "log_fuel_check": "Fuel Check (D): ",
    "log_fuel_suff": " (Sufficient)",
    "log_coord_set": "Coordinates Set. Ready for Landing.",
    "log_err_params": "Incorrect parameters. View hint.",
    "log_err_fuel": "Incorrect fuel calculation.",
    "log_sys_reset": "System Reset.",
    "log_nav_recalibrated": "Nav-Computer Recalibrated.",
    "lbl_hint_params":
        "Hint: Find the numbers multiplied by x², x, and the constant.",
    "lbl_hint_fuel": "Hint: D = (b)² - 4(a)(c)",
    "lbl_calc_d": "Calculate Discriminant (Fuel Check)",
    "lbl_set_nav": "Nav-Computer Coordinate Settings",
    "lbl_calc_landing": "Calculate Landing Zone",
    "btn_path_1": "Path 1 (+)",
    "btn_path_2": "Path 2 (-)",
  },
  'hi': {
    "app_title": "सूत्र पायलट",
    "tagline": "द्विघात सूत्र • कक्षा 10",
    "init_btn": "मिशन शुरू करें",
    "header_title": "सूत्र पायलट",
    "header_subtitle": "कक्षा 10 • द्विघात समीकरण",
    "btn_start_lab": "कॉकपिट में प्रवेश",
    "post_title": "विश्लेषण और परिणाम",
    "btn_restart": "सिस्टम रीबूट करें",
    "lbl_progress": "उड़ान योजना",
    "hud_status": "नेविगेशन स्थिति",
    "lbl_select_eq": "उड़ान पथ चुनें",
    "btn_engage": "सिस्टम चालू करें",
    "msg_params": "इंजन पैरामीटर पहचानें",
    "btn_extract": "पैरामीटर लॉक करें",
    "btn_calc_d": "ईंधन जांचें (D)",
    "btn_set_coord": "निर्देशांक सेट करें",
    "msg_success": "सफल लैंडिंग",
    "btn_next": "नया मिशन",
    "step_0_t": "मिशन की प्रतीक्षा",
    "step_0_d":
        "ड्रॉपडाउन से एक उड़ान पथ चुनें और इसे लॉक करने के लिए 'सिस्टम चालू करें' पर क्लिक करें।",
    "step_1_t": "प्री-फ्लाइट",
    "step_1_d":
        "गुणांकों को पहचानें: 'a' (x²), 'b' (x), और 'c' (स्थिरांक)। उन्हें दर्ज करें और 'पैरामीटर लॉक करें' पर क्लिक करें।",
    "step_2_t": "निदान",
    "step_2_d":
        "अपने मापदंडों का उपयोग करके विविक्तकर D = b² - 4ac की गणना करें। इसे दर्ज करें और 'ईंधन जांचें' पर क्लिक करें।",
    "step_3_t": "ईंधन जांच",
    "step_3_d":
        "द्विघात सूत्र की समीक्षा करें। लैंडिंग पथ को आरेखित करने के लिए 'निर्देशांक सेट करें' पर क्लिक करें।",
    "step_4_t": "नेविगेशन",
    "step_4_d":
        "सटीक लैंडिंग मूल की गणना करें। मिशन को अंतिम रूप देने के लिए 'पथ 1 (+)' और 'पथ 2 (-)' पर क्लिक करें।",
    "step_5_t": "दृष्टिकोण",
    "step_5_d": "मिशन पूरा हुआ! मूल सफलतापूर्वक सत्यापित हो गए हैं।",
    "out_1_t": "सार्वभौमिक उपकरण",
    "out_1_d": "द्विघात सूत्र किसी भी द्विघात समीकरण के लिए काम करता है।",
    "out_2_t": "सटीकता",
    "out_2_d": "यह सटीक मान देता है, यहां तक कि अपरिमेय मूलों के लिए भी।",
    "out_3_t": "तर्क",
    "out_3_d": "यह वर्ग को पूरा करने की विधि से प्राप्त होता है।",
    "log_sys_online": "सिस्टम ऑनलाइन। इनपुट की प्रतीक्षा है...",
    "log_path_locked": "उड़ान पथ लॉक: ",
    "log_engine_core": "इंजन कोर: ",
    "log_fuel_check": "ईंधन जांच (D): ",
    "log_fuel_suff": " (पर्याप्त)",
    "log_coord_set": "निर्देशांक सेट। लैंडिंग के लिए तैयार।",
    "log_err_params": "गलत पैरामीटर। संकेत देखें।",
    "log_err_fuel": "गलत ईंधन गणना।",
    "log_sys_reset": "सिस्टम रीसेट।",
    "log_nav_recalibrated": "नेव-कंप्यूटर फिर से कैलिब्रेट किया गया।",
    "lbl_hint_params":
        "संकेत: x², x और स्थिरांक से गुणा होने वाली संख्याओं को खोजें।",
    "lbl_hint_fuel": "संकेत: D = (b)² - 4(a)(c)",
    "lbl_calc_d": "विविक्तकर की गणना करें (ईंधन जांच)",
    "lbl_set_nav": "नेव-कंप्यूटर निर्देशांक सेट करें",
    "lbl_calc_landing": "लैंडिंग ज़ोन की गणना करें",
    "btn_path_1": "पथ 1 (+)",
    "btn_path_2": "पथ 2 (-)",
  },
};

// Dedicated audio players initialized with ReleaseMode.stop to keep audio cached
final AudioPlayer _clickPlayer = AudioPlayer()
  ..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _successPlayer = AudioPlayer()
  ..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _errorPlayer = AudioPlayer()
  ..setReleaseMode(ReleaseMode.stop);

const String _clickUrl = 'audio/math/click.mp3';
const String _successUrl = 'audio/math/success.mp3';
const String _errorUrl = 'audio/math/error.mp3';
const String _alertUrl = 'audio/math/alert.mp3';
const String _startUrl = 'audio/math/shutter.mp3';

// --- MAIN WIDGET ---

class FormulaPilotApp extends StatefulWidget {
  const FormulaPilotApp({super.key});

  @override
  State<FormulaPilotApp> createState() => _FormulaPilotAppState();
}

class _FormulaPilotAppState extends State<FormulaPilotApp>
    with TickerProviderStateMixin {
  bool started = false;
  String lang = 'en';
  bool panelOpen = true;

  // Scroll Controller for HUD
  final ScrollController _hudScrollController = ScrollController();

  Map<String, String> get t => i18n[lang] ?? i18n['en']!;

  // Game State
  int step = 0;
  Equation eq = equationsData[0];
  List<String> logs = [];
  bool showCelebration = false;
  bool showHint = false;
  int solveCount = 0;
  bool solvedRoot1 = false;
  bool solvedRoot2 = false;

  // Canvas Pan & Zoom Controls
  Offset _panOffset = Offset.zero;
  double _zoomScale = 1.0;
  Offset _startingFocalPoint = Offset.zero;
  Offset _startingPanOffset = Offset.zero;
  double _startingZoomScale = 1.0;

  // User Inputs
  String inputA = "";
  String inputB = "";
  String inputC = "";
  String inputD = "";

  // Animations
  late AnimationController _flightPathController;
  late AnimationController _bobbingController;

  @override
  void initState() {
    super.initState();
    logs = [i18n['en']!['log_sys_online']!];

    _flightPathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _bobbingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _flightPathController.dispose();
    _bobbingController.dispose();
    _hudScrollController.dispose();
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void playFeedback(String type) async {
    try {
      if (type == 'click') {
        HapticFeedback.lightImpact();
        await _clickPlayer.play(AssetSource(_clickUrl));
      } else if (type == 'engine' || type == 'alert') {
        HapticFeedback.mediumImpact();
        await _fxPlayer.play(AssetSource(_alertUrl));
      } else if (type == 'success') {
        HapticFeedback.heavyImpact();
        await _successPlayer.play(AssetSource(_successUrl));
      } else if (type == 'start') {
        HapticFeedback.heavyImpact();
        await _fxPlayer.play(AssetSource(_startUrl));
      } else if (type == 'error') {
        HapticFeedback.vibrate();
        await _errorPlayer.play(AssetSource(_errorUrl));
      }
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  void addLog(String msg) {
    setState(() {
      logs.insert(0, msg);
      if (logs.length > 10) logs.removeLast();
    });
  }

  void setEq(Equation newEq) {
    setState(() {
      eq = newEq;
    });
  }

  void executeStep(int newStep) {
    playFeedback('click');

    setState(() {
      step = newStep;
      if (step == 5) showCelebration = true;
    });

    if (step == 1) {
      playFeedback('engine');
      addLog("${t['log_path_locked']}${eq.latex}");
      setState(() {
        inputA = "";
        inputB = "";
        inputC = "";
        inputD = "";
        showHint = false;
        solvedRoot1 = false;
        solvedRoot2 = false;
        solveCount = 0;
        _panOffset = Offset.zero;
        _zoomScale = 1.0;
        _flightPathController.reset();
      });
    } else if (step == 2) {
      addLog("${t['log_engine_core']}a=${eq.a}, b=${eq.b}, c=${eq.c}");
    } else if (step == 3) {
      addLog("${t['log_fuel_check']}${eq.D}${t['log_fuel_suff']}");
    } else if (step == 4) {
      playFeedback('engine');
      addLog(t['log_coord_set']!);
      _flightPathController.forward();
    }
  }

  void verifyParams() {
    int? parsedA = int.tryParse(inputA);
    int? parsedB = int.tryParse(inputB);
    int? parsedC = int.tryParse(inputC);

    if (parsedA == eq.a && parsedB == eq.b && parsedC == eq.c) {
      playFeedback('success');
      executeStep(2);
    } else {
      playFeedback('error');
      addLog(t['log_err_params']!);
    }
  }

  void verifyDiscriminant() {
    int? parsedD = int.tryParse(inputD);

    if (parsedD == eq.D) {
      playFeedback('success');
      executeStep(3);
    } else {
      playFeedback('error');
      addLog(t['log_err_fuel']!);
      setState(() {
        showHint = true;
      });
    }
  }

  void solveRoot(int id) {
    playFeedback('click');
    setState(() {
      if (id == 1) solvedRoot1 = true;
      if (id == 2) solvedRoot2 = true;
      solveCount++;
    });

    if (solveCount >= 2) {
      playFeedback('success');
      executeStep(5); // Adjusted to step 5 for consistent flow
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => showCelebration = false);
      });
    }
  }

  void resetApp() {
    setState(() {
      step = 0;
      logs = [t['log_sys_reset']!];
      showCelebration = false;
      started = false;
      panelOpen = true;
      _panOffset = Offset.zero;
      _zoomScale = 1.0;
      _flightPathController.reset();
    });
  }

  void resetLabOnly() {
    setState(() {
      step = 0;
      logs = [t['log_nav_recalibrated']!];
      showCelebration = false;
      inputA = "";
      inputB = "";
      inputC = "";
      inputD = "";
      showHint = false;
      solvedRoot1 = false;
      solvedRoot2 = false;
      solveCount = 0;
      _panOffset = Offset.zero;
      _zoomScale = 1.0;
      _flightPathController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double panelWidth = screenWidth * 0.4;

    if (!started) {
      return _buildStartScreen(t);
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Stack(
          children: [
            // Background Canvas & Panels
            Positioned.fill(
              child: Row(
                children: [
                  // 40% Animated Side Panel
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: panelOpen ? panelWidth : 0,
                    child: ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.topLeft,
                        minWidth: panelWidth,
                        maxWidth: panelWidth,
                        child: _buildSidePanel(t),
                      ),
                    ),
                  ),

                  // 60% (or 100%) Canvas
                  Expanded(
                    child: ClipRect(
                      child: Stack(
                        children: [
                          _buildFlightEnvironment(),
                          if (showCelebration) _buildCelebrationOverlay(t),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Floating HUD (Visible when sidebar is collapsed)
            if (!panelOpen) _buildFloatingHUD(t),

            // Bottom-Left Floating Menu Toggle
            Positioned(
              top: 24,
              left: 24,
              child: FloatingActionButton(
                backgroundColor: const Color(0xFFE11D48), // Rose 600
                elevation: 8,
                onPressed: () {
                  playFeedback('click');
                  setState(() => panelOpen = !panelOpen);
                },
                child: Icon(
                  panelOpen ? Icons.menu_open : Icons.menu,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartScreen(Map<String, String> t) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFF4C1D95), Color(0xFF0F172A)],
                radius: 1.5,
              ),
            ),
          ),
          CustomPaint(
            painter: CartesianGridPainter(
              opacity: 0.15,
              panOffset: Offset.zero,
              zoomScale: 1.0,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.pinkAccent.withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pinkAccent.withOpacity(0.3),
                        blurRadius: 100,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: AnimatedBuilder(
                    animation: _bobbingController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          0,
                          -10 + (_bobbingController.value * 20),
                        ),
                        child: const Icon(
                          Icons.rocket_launch,
                          size: 80,
                          color: Colors.pinkAccent,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  t['app_title']!,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    fontFamily: 'monospace',
                    shadows: [Shadow(color: Colors.pinkAccent, blurRadius: 10)],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  t['tagline']!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.pink[300],
                    letterSpacing: 4,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () {
                    playFeedback('start');
                    setState(() {
                      started = true;
                    });
                  },
                  icon: const Icon(
                    Icons.flight_takeoff,
                    size: 24,
                    color: Colors.white,
                  ),
                  label: Text(
                    t['init_btn']!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE11D48), // Rose 600
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 20,
                    shadowColor: const Color(0xFFF43F5E).withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidePanel(Map<String, String> t) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xF20F172A),
        border: Border(right: BorderSide(color: Color(0x33F43F5E))),
        boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20)],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Header Section
                      Container(
                        padding: const EdgeInsets.only(
                          top:
                              80, // Clear the top-left floating back button visually
                          left: 20,
                          right: 20,
                          bottom: 20,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Color(0x33F43F5E)),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t['header_title']!,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        t['header_subtitle']!,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.pinkAccent,
                                          letterSpacing: 1.5,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildLangToggles(),
                                IconButton(
                                  onPressed: resetApp,
                                  icon: const Icon(
                                    Icons.power_settings_new,
                                    size: 20,
                                  ),
                                  color: Colors.red[400],
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.red.withOpacity(
                                      0.1,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        color: Colors.red.withOpacity(0.3),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Content Section
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 20,
                            bottom: 40,
                          ),
                          child: _buildExploreTab(t),
                        ),
                      ),

                      // Permanent Footer Zone
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Color(0x33F43F5E)),
                          ),
                          color: Color(0x400F172A),
                        ),
                        width: double.infinity,
                        child: const Text(
                          "© ZEROSCIENCELAB | Fall in Love with Math and Science",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white54,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLangToggles() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0x801E293B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: ['en', 'hi'].map((l) {
          return GestureDetector(
            onTap: () {
              playFeedback('click');
              setState(() => lang = l);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: lang == l ? const Color(0xFFE11D48) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                l.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: lang == l ? Colors.white : Colors.grey[500],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExploreTab(Map<String, String> t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              t['lbl_progress']!.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
                letterSpacing: 1,
              ),
            ),
            Text(
              "Step $step/5",
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: step / 5,
            backgroundColor: const Color(0xFF1E293B),
            color: Colors.pinkAccent,
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xCC1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t['step_${step}_t'] ?? "SYSTEM READY",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t['step_${step}_d'] ?? "Awaiting commands.",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // INTERACTION ZONE
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: _buildInteractionControls(t),
        ),

        const SizedBox(height: 16),
        Container(
          height: 100,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: ListView.builder(
            reverse: true,
            itemCount: logs.length,
            itemBuilder: (ctx, i) => Text(
              "> ${logs[i]}",
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.pinkAccent.withOpacity(0.8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInteractionControls(Map<String, String> t) {
    if (step == 0) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t['lbl_select_eq']!,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: eq.id,
                isExpanded: true,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
                items: equationsData
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.id, child: Text(e.latex)),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setEq(equationsData.firstWhere((e) => e.id == val));
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => executeStep(1),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[600],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                t['btn_engage']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (step == 1) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t['msg_params']!,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInputColumn(
                  "a",
                  inputA,
                  (v) => setState(() => inputA = v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInputColumn(
                  "b",
                  inputB,
                  (v) => setState(() => inputB = v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInputColumn(
                  "c",
                  inputC,
                  (v) => setState(() => inputC = v),
                ),
              ),
            ],
          ),
          if (showHint)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber[900]!.withOpacity(0.2),
                border: Border.all(color: Colors.amber[700]!.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                t['lbl_hint_params']!,
                style: TextStyle(color: Colors.amber[300], fontSize: 10),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  playFeedback('click');
                  setState(() => showHint = !showHint);
                },
                icon: const Icon(Icons.lightbulb_outline),
                color: Colors.amber[400],
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blueGrey[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: verifyParams,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    t['btn_extract']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (step == 2) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t['lbl_calc_d']!,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.pinkAccent.withOpacity(0.3)),
            ),
            child: const Text(
              "D = b² - 4ac",
              style: TextStyle(
                color: Colors.pinkAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInputColumn(
                  "D = ?",
                  inputD,
                  (v) => setState(() => inputD = v),
                  isYellow: true,
                ),
              ),
            ],
          ),
          if (showHint)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.pink[900]!.withOpacity(0.2),
                border: Border.all(color: Colors.pink[700]!.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                t['lbl_hint_fuel']!
                    .replaceAll('{b}', eq.b.toString())
                    .replaceAll('{a}', eq.a.toString())
                    .replaceAll('{c}', eq.c.toString()),
                style: TextStyle(
                  color: Colors.pink[300],
                  fontSize: 10,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: verifyDiscriminant,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[500],
                foregroundColor: Colors.blueGrey[900],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                t['btn_calc_d']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    }

    if (step == 3) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t['lbl_set_nav']!,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[500]!.withOpacity(0.3)),
            ),
            child: const Column(
              children: [
                Text(
                  "x = (-b ± √D) / 2a",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "x = (${-eq.b} ± √${eq.D}) / ${2 * eq.a}",
            style: const TextStyle(
              color: Colors.blueAccent,
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => executeStep(4),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[600],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                t['btn_set_coord']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (step == 4) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t['lbl_calc_landing']!,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: solvedRoot1 ? null : () => solveRoot(1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: solvedRoot1
                        ? Colors.green[600]
                        : Colors.blueGrey[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(t['btn_path_1']!),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: solvedRoot2 ? null : () => solveRoot(2),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: solvedRoot2
                        ? Colors.green[600]
                        : Colors.blueGrey[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(t['btn_path_2']!),
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (step == 5) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.flag_circle, color: Colors.greenAccent, size: 48),
          const SizedBox(height: 8),
          Text(
            t['msg_success']!,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: resetLabOnly,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[600],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                t['btn_next']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: resetApp,
            child: Text(
              t['btn_restart']!,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      );
    }

    return const SizedBox();
  }

  Widget _buildInputColumn(
    String label,
    String value,
    Function(String) onChanged, {
    bool isYellow = false,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isYellow ? Colors.amberAccent : Colors.pinkAccent,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1E293B),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isYellow ? Colors.amberAccent : Colors.pinkAccent,
              ),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  // --- Interactive Canvas Environment ---
  Widget _buildFlightEnvironment() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final center = Offset(
          constraints.maxWidth / 2,
          constraints.maxHeight / 2,
        );

        return GestureDetector(
          // Gesture Handling (Pan & Zoom)
          onScaleStart: (details) {
            _startingFocalPoint = details.localFocalPoint;
            _startingPanOffset = _panOffset;
            _startingZoomScale = _zoomScale;
          },
          onScaleUpdate: (details) {
            setState(() {
              _zoomScale = (_startingZoomScale * details.scale).clamp(
                0.2,
                10.0,
              );
              double scaleRatio = _zoomScale / _startingZoomScale;

              _panOffset =
                  details.localFocalPoint -
                  center -
                  (_startingFocalPoint - center - _startingPanOffset) *
                      scaleRatio;
            });
          },
          onDoubleTap: () {
            // Double Tap to reset
            setState(() {
              _panOffset = Offset.zero;
              _zoomScale = 1.0;
            });
          },
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFF0F172A), Color(0xFF000000)],
                radius: 1.0,
              ),
            ),
            child: Stack(
              children: [
                // Dynamic Cartesian Grid (Pan & Zoom Support)
                Positioned.fill(
                  child: CustomPaint(
                    painter: CartesianGridPainter(
                      opacity: 0.4,
                      panOffset: _panOffset,
                      zoomScale: _zoomScale,
                    ),
                  ),
                ),

                // Flight Path (Parabola)
                if (step >= 4)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _flightPathController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: FlightPathPainter(
                            eq,
                            _flightPathController.value,
                            step == 5, // Shows roots when step is 5
                            _panOffset,
                            _zoomScale,
                          ),
                        );
                      },
                    ),
                  ),

                // Equation in space (Fixed overlay)
                if (step > 0)
                  Positioned(
                    top: 20,
                    right: 40,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.pinkAccent.withOpacity(0.3),
                        ),
                      ),
                      child: AnimatedBuilder(
                        animation: _bobbingController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                              0,
                              math.sin(_bobbingController.value * math.pi * 2) *
                                  5,
                            ),
                            child: Text(
                              eq.latex.replaceAll('^2', '²'),
                              style: const TextStyle(
                                color: Colors.pinkAccent,
                                fontFamily: 'monospace',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.pinkAccent,
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // Canvas Reset Button (Bottom Right)
                Positioned(
                  bottom: 24,
                  right: 24,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: const Color(0xFFE11D48), // Rose 600
                    onPressed: () {
                      playFeedback('click');
                      setState(() {
                        _panOffset = Offset.zero;
                        _zoomScale = 1.0;
                      });
                    },
                    child: const Icon(Icons.my_location, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingHUD(Map<String, String> t) {
    return Positioned(
      top: 90,
      left: 24,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.of(context).size.height - 130, // Prevents overflow
          maxWidth: 280,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xE60F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20),
            ],
          ),
          child: Scrollbar(
            controller: _hudScrollController,
            thumbVisibility: true,
            thickness: 4,
            radius: const Radius.circular(8),
            child: SingleChildScrollView(
              controller: _hudScrollController,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          t['lbl_progress']!.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.pinkAccent,
                          ),
                        ),
                        Text(
                          "Step $step/5",
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white10, height: 16),
                    Text(
                      t['step_${step}_t'] ?? "LEVEL",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.pinkAccent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t['step_${step}_d'] ?? "Analyze.",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInteractionControls(t),
                    const SizedBox(height: 12),
                    Text(
                      "> ${logs[0]}",
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: Colors.pinkAccent,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildCelebrationOverlay(Map<String, String> t) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t['msg_success']!,
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(color: Colors.greenAccent, blurRadius: 20)],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.greenAccent, width: 2),
            ),
            child: Text(
              "${eq.root1}, ${eq.root2}",
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- CUSTOM PAINTERS ---

class CartesianGridPainter extends CustomPainter {
  final double opacity;
  final Offset panOffset;
  final double zoomScale;

  CartesianGridPainter({
    this.opacity = 1.0,
    required this.panOffset,
    required this.zoomScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF334155).withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final axisPaint = Paint()
      ..color = Colors.white54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final origin = Offset(size.width / 2, size.height / 2) + panOffset;
    double unitScaleX = (math.min(size.width, size.height) / 15) * zoomScale;
    double unitScaleY = unitScaleX * 0.5; // Y-Axis flattering

    // Vertical lines
    int startLogicalX = ((0 - origin.dx) / unitScaleX).floor();
    int endLogicalX = ((size.width - origin.dx) / unitScaleX).ceil();

    for (int i = startLogicalX; i <= endLogicalX; i++) {
      double x = origin.dx + i * unitScaleX;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        i == 0 ? axisPaint : paint,
      );
    }

    // Horizontal lines
    int startLogicalY = ((origin.dy - size.height) / unitScaleY).floor();
    int endLogicalY = ((origin.dy - 0) / unitScaleY).ceil();

    for (int i = startLogicalY; i <= endLogicalY; i++) {
      double y = origin.dy - i * unitScaleY;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        i == 0 ? axisPaint : paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CartesianGridPainter oldDelegate) {
    return oldDelegate.panOffset != panOffset ||
        oldDelegate.zoomScale != zoomScale;
  }
}

class FlightPathPainter extends CustomPainter {
  final Equation eq;
  final double progress;
  final bool showRoots;
  final Offset panOffset;
  final double zoomScale;

  FlightPathPainter(
    this.eq,
    this.progress,
    this.showRoots,
    this.panOffset,
    this.zoomScale,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height / 2) + panOffset;
    double unitScaleX = (math.min(size.width, size.height) / 15) * zoomScale;
    double unitScaleY = unitScaleX * 0.5;

    if (progress == 0) return;

    final pathPaint = Paint()
      ..color =
          const Color(0xFFF43F5E) // Rose accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2.0); // Glow

    Path path = Path();
    bool started = false;

    // Visible Bounds
    double minVisibleX = (0 - origin.dx) / unitScaleX;
    double maxVisibleX = (size.width - origin.dx) / unitScaleX;

    double startX = math.min(-15.0, minVisibleX - 5);
    double endX = math.max(15.0, maxVisibleX + 5);

    double currentMaxX = startX + ((endX - startX) * progress);

    double stepSize = 0.1 / zoomScale;
    if (stepSize > 1.0) stepSize = 1.0;
    if (stepSize < 0.01) stepSize = 0.01;

    for (double x = startX; x <= currentMaxX; x += stepSize) {
      double y = (eq.a * x * x) + (eq.b * x) + eq.c;

      double canvasX = origin.dx + (x * unitScaleX);
      double canvasY = origin.dy - (y * unitScaleY);

      if (!started) {
        path.moveTo(canvasX, canvasY);
        started = true;
      } else {
        path.lineTo(canvasX, canvasY);
      }

      if (progress >= 1.0 && (x - x.round()).abs() < stepSize * 0.5) {
        final dotPaint = Paint()..color = Colors.white;
        canvas.drawCircle(Offset(canvasX, canvasY), 3, dotPaint);
      }
    }

    canvas.drawPath(path, pathPaint);

    if (showRoots) {
      final landingPaint = Paint()..color = Colors.greenAccent;

      double r1Val = double.parse(eq.root1.split('=')[1]);
      double r2Val = double.parse(eq.root2.split('=')[1]);

      canvas.drawCircle(
        Offset(origin.dx + (r1Val * unitScaleX), origin.dy),
        8,
        landingPaint,
      );
      canvas.drawCircle(
        Offset(origin.dx + (r2Val * unitScaleX), origin.dy),
        8,
        landingPaint,
      );

      final textSpan1 = TextSpan(
        text: eq.root1,
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      );
      final textPainter1 = TextPainter(
        text: textSpan1,
        textDirection: TextDirection.ltr,
      );
      textPainter1.layout();
      textPainter1.paint(
        canvas,
        Offset(
          origin.dx + (r1Val * unitScaleX) - (textPainter1.width / 2),
          origin.dy + 15,
        ),
      );

      final textSpan2 = TextSpan(
        text: eq.root2,
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      );
      final textPainter2 = TextPainter(
        text: textSpan2,
        textDirection: TextDirection.ltr,
      );
      textPainter2.layout();
      textPainter2.paint(
        canvas,
        Offset(
          origin.dx + (r2Val * unitScaleX) - (textPainter2.width / 2),
          origin.dy + 15,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant FlightPathPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.eq.id != eq.id ||
        oldDelegate.showRoots != showRoots ||
        oldDelegate.panOffset != panOffset ||
        oldDelegate.zoomScale != zoomScale;
  }
}
