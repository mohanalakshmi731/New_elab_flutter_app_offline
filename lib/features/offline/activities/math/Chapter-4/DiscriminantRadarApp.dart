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
  final String name;
  final String latex;
  final int a;
  final int b;
  final int c;
  final int D;
  final String type;
  final String roots;

  Equation({
    required this.id,
    required this.name,
    required this.latex,
    required this.a,
    required this.b,
    required this.c,
    required this.D,
    required this.type,
    required this.roots,
  });
}

final List<Equation> equationsData = [
  Equation(
    id: 0,
    name: "Signal Alpha",
    latex: "x² - 5x + 6 = 0",
    a: 1,
    b: -5,
    c: 6,
    D: 1,
    type: "real_distinct",
    roots: "x=2, x=3",
  ),
  Equation(
    id: 1,
    name: "Signal Beta",
    latex: "x² - 4x + 4 = 0",
    a: 1,
    b: -4,
    c: 4,
    D: 0,
    type: "real_equal",
    roots: "x=2",
  ),
  Equation(
    id: 2,
    name: "Signal Gamma",
    latex: "x² + x + 1 = 0",
    a: 1,
    b: 1,
    c: 1,
    D: -3,
    type: "no_real",
    roots: "∅",
  ),
  Equation(
    id: 3,
    name: "Signal Delta",
    latex: "2x² - 7x + 3 = 0",
    a: 2,
    b: -7,
    c: 3,
    D: 25,
    type: "real_distinct",
    roots: "x=3, x=0.5",
  ),
];

const Map<String, Map<String, String>> i18n = {
  'en': {
    "app_title": "DISCRIMINANT RADAR",
    "tagline": "NATURE OF ROOTS • CLASS 10",
    "init_btn": "ACTIVATE RADAR",
    "header_title": "The Discriminant Radar",
    "header_subtitle": "CLASS 10 • QUADRATIC EQUATIONS",
    "ctx_title": "Why Learn This?",
    "post_title": "Analysis & Outcomes",
    "lbl_progress": "Detection Progress",
    "hud_status": "Radar Status",
    "lbl_select_eq": "Select Incoming Signal",
    "btn_detect": "ACQUIRE TARGET",
    "msg_params": "Extract Parameters",
    "btn_extract": "DECODE PARAMETERS",
    "btn_calc": "COMPUTE D",
    "btn_scan": "ACTIVATE RADAR SCAN",
    "msg_classify": "Classify Signal Nature",
    "opt_real_dist": "Real & Distinct",
    "opt_real_equal": "Real & Equal",
    "opt_no_real": "No Real Roots",
    "msg_success": "SIGNAL IDENTIFIED",
    "btn_next": "Scan Next Signal",
    "btn_restart": "Reboot System",
    "btn_start_lab": "Enter Radar Station",
    "step_1_t": "SEARCHING...",
    "step_1_d":
        "Select a signal from the dropdown menu and click 'ACQUIRE TARGET' to track it.",
    "step_2_t": "DECODING SIGNAL",
    "step_2_d":
        "Identify the coefficients: 'a' (x² coeff), 'b' (x coeff), and 'c' (constant). Enter them and click 'DECODE PARAMETERS'.",
    "step_3_t": "SIGNAL STRENGTH",
    "step_3_d":
        "Click 'COMPUTE D' to calculate the Discriminant using the formula D = b² - 4ac.",
    "step_4_t": "VISUALIZING",
    "step_4_d":
        "Click 'ACTIVATE RADAR SCAN' to plot the equation's trajectory on the radar.",
    "step_5_t": "CLASSIFICATION",
    "step_5_d":
        "Analyze the plotted trajectory and the value of D, then select the correct nature of the roots to classify the signal.",
    "ctx_1_t": "Bridge Safety",
    "ctx_1_d":
        "Ensuring support cables (parabolas) don't snap under tension requires discriminant analysis.",
    "ctx_2_t": "Ballistics",
    "ctx_2_d":
        "Predicting if a projectile will clear a wall or hit a target involves real roots.",
    "ctx_3_t": "Signal Processing",
    "ctx_3_d":
        "Radar systems use discriminants to filter noise (no real roots) from real objects.",
    "out_1_t": "D > 0",
    "out_1_d":
        "Two distinct real roots. The trajectory cuts the x-axis at two points.",
    "out_2_t": "D = 0",
    "out_2_d":
        "Two equal real roots. The trajectory touches the x-axis at exactly one point.",
    "out_3_t": "D < 0",
    "out_3_d":
        "No real roots. The trajectory floats above/below and never touches the axis.",
    "log_sys_online": "Radar Systems Online...",
    "log_signal_acq": "Signal Acquired: ",
    "log_extracted": "Extracted: ",
    "log_discriminant": "Discriminant D = ",
    "log_trajectory": "Trajectory Plotted on Radar.",
    "log_err_params": "Incorrect parameters. Try the hint.",
    "log_err_class": "Classification Error. Check value of D.",
    "log_sys_reset": "System Reset.",
    "log_recalibrated": "Radar Re-calibrated.",
    "lbl_hint": "Hint: a=x² coeff, b=x coeff, c=constant",
    "msg_d_pos": "D > 0 (Positive)",
    "msg_d_zero": "D = 0 (Zero)",
    "msg_d_neg": "D < 0 (Negative)",
    "msg_confirmed": "CONFIRMED!",
    "lbl_step": "Step",
    "name_0": "Signal Alpha",
    "name_1": "Signal Beta",
    "name_2": "Signal Gamma",
    "name_3": "Signal Delta",
  },
  'hi': {
    "app_title": "विविक्तकर रडार",
    "tagline": "मूलों की प्रकृति • कक्षा 10",
    "init_btn": "रडार सक्रिय करें",
    "header_title": "विविक्तकर रडार",
    "header_subtitle": "कक्षा 10 • द्विघात समीकरण",
    "ctx_title": "क्यों सीखें?",
    "post_title": "विश्लेषण और परिणाम",
    "lbl_progress": "का पता लगाने की प्रगति",
    "hud_status": "रडार स्थिति",
    "lbl_select_eq": "आने वाला संकेत चुनें",
    "btn_detect": "लक्ष्य प्राप्त करें",
    "msg_params": "संकेत से पैरामीटर निकालें",
    "btn_extract": "पैरामीटर डिकोड करें",
    "btn_calc": "D की गणना करें",
    "btn_scan": "रडार स्कैन",
    "msg_classify": "संकेत प्रकृति वर्गीकृत करें",
    "opt_real_dist": "वास्तविक और भिन्न",
    "opt_real_equal": "वास्तविक और समान",
    "opt_no_real": "कोई वास्तविक मूल नहीं",
    "msg_success": "संकेत पहचाना गया",
    "btn_next": "अगला संकेत",
    "btn_restart": "सिस्टम रीबूट करें",
    "btn_start_lab": "रडार स्टेशन",
    "step_1_t": "खोज रहा है...",
    "step_1_d":
        "ड्रॉपडाउन मेनू से एक संकेत चुनें और उसे ट्रैक करने के लिए 'लक्ष्य प्राप्त करें' पर क्लिक करें।",
    "step_2_t": "डिकोडिंग",
    "step_2_d":
        "गुणांकों को पहचानें: 'a' (x² गुणांक), 'b' (x गुणांक), और 'c' (स्थिरांक)। उन्हें दर्ज करें और 'पैरामीटर डिकोड करें' पर क्लिक करें।",
    "step_3_t": "संकेत शक्ति",
    "step_3_d":
        "सूत्र D = b² - 4ac का उपयोग करके विविक्तकर की गणना करने के लिए 'D की गणना करें' पर क्लिक करें।",
    "step_4_t": "दृश्यमान",
    "step_4_d":
        "रडार पर समीकरण का प्रक्षेपवक्र आरेखित करने के लिए 'रडार स्कैन सक्रिय करें' पर क्लिक करें।",
    "step_5_t": "वर्गीकरण",
    "step_5_d":
        "आरेखित प्रक्षेपवक्र और D के मान का विश्लेषण करें, फिर संकेत को वर्गीकृत करने के लिए मूलों की सही प्रकृति का चयन करें।",
    "ctx_1_t": "पुल सुरक्षा",
    "ctx_1_d":
        "तनाव के तहत केबल न टूटें, इसके लिए विविक्तकर विश्लेषण आवश्यक है।",
    "ctx_2_t": "प्रक्षेपिकी",
    "ctx_2_d":
        "यह अनुमान लगाना कि क्या कोई प्रक्षेप्य दीवार को पार करेगा या लक्ष्य को भेदेगा।",
    "ctx_3_t": "सिग्नल प्रोसेसिंग",
    "ctx_3_d":
        "रडार सिस्टम शोर (कोई मूल नहीं) को वास्तविक वस्तुओं से अलग करने के लिए इसका उपयोग करते हैं।",
    "out_1_t": "D > 0",
    "out_1_d": "दो भिन्न वास्तविक मूल। ग्राफ x-अक्ष को दो बिंदुओं पर काटता है।",
    "out_2_t": "D = 0",
    "out_2_d": "दो समान वास्तविक मूल। ग्राफ x-अक्ष को एक बिंदु पर छूता है।",
    "out_3_t": "D < 0",
    "out_3_d": "कोई वास्तविक मूल नहीं। ग्राफ x-अक्ष को नहीं छूता है।",
    "log_sys_online": "रडार सिस्टम ऑनलाइन...",
    "log_signal_acq": "संकेत प्राप्त: ",
    "log_extracted": "निकाला गया: ",
    "log_discriminant": "विविक्तकर D = ",
    "log_trajectory": "रडार पर प्रक्षेपवक्र आरेखित।",
    "log_err_params": "गलत पैरामीटर। संकेत (hint) आज़माएं।",
    "log_err_class": "वर्गीकरण त्रुटि। D के मान की जाँच करें।",
    "log_sys_reset": "सिस्टम रीसेट।",
    "log_recalibrated": "रडार पुनः कैलिब्रेट किया गया।",
    "lbl_hint": "संकेत: a=x² गुणांक, b=x गुणांक, c=स्थिरांक",
    "msg_d_pos": "D > 0 (धनात्मक)",
    "msg_d_zero": "D = 0 (शून्य)",
    "msg_d_neg": "D < 0 (ऋणात्मक)",
    "msg_confirmed": "पुष्टि की गई!",
    "lbl_step": "चरण",
    "name_0": "सिग्नल अल्फा",
    "name_1": "सिग्नल बीटा",
    "name_2": "सिग्नल गामा",
    "name_3": "सिग्नल डेल्टा",
  },
};

// Dedicated audio players initialized with ReleaseMode.stop
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

class DiscriminantRadarApp extends StatefulWidget {
  const DiscriminantRadarApp({super.key});

  @override
  State<DiscriminantRadarApp> createState() => _DiscriminantRadarAppState();
}

class _DiscriminantRadarAppState extends State<DiscriminantRadarApp>
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

  // User Inputs
  String inputA = "";
  String inputB = "";
  String inputC = "";

  // Animations
  late AnimationController _radarSweepController;
  late AnimationController _trajectoryDrawController;

  @override
  void initState() {
    super.initState();
    logs = [i18n['en']!['log_sys_online']!];
    _radarSweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _trajectoryDrawController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _radarSweepController.dispose();
    _trajectoryDrawController.dispose();
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
      } else if (type == 'ping' || type == 'alert') {
        HapticFeedback.mediumImpact();
        await _fxPlayer.play(AssetSource(_alertUrl));
      } else if (type == 'success') {
        HapticFeedback.heavyImpact();
        await _successPlayer.play(AssetSource(_successUrl));
      } else if (type == 'intro' || type == 'start') {
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
      if (step == 6) showCelebration = true;
    });

    if (step == 1) {
      playFeedback('ping');
      addLog("${t['log_signal_acq']}${eq.latex}");
      setState(() {
        inputA = "";
        inputB = "";
        inputC = "";
        showHint = false;
        _trajectoryDrawController.reset();
      });
    } else if (step == 2) {
      addLog("${t['log_extracted']}a=${eq.a}, b=${eq.b}, c=${eq.c}");
    } else if (step == 3) {
      addLog("${t['log_discriminant']}${eq.D}");
    } else if (step == 4) {
      playFeedback('ping');
      addLog(t['log_trajectory']!);
      _trajectoryDrawController.forward();
    }
  }

  void verifyInputs() {
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

  void classifySignal(String type) {
    if (type == eq.type) {
      playFeedback('success');
      setState(() {
        step = 6;
        showCelebration = true;
      });
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => showCelebration = false);
      });
    } else {
      playFeedback('error');
      addLog(t['log_err_class']!);
    }
  }

  void resetApp() {
    setState(() {
      step = 0;
      logs = [t['log_sys_reset']!];
      showCelebration = false;
      started = false;
      panelOpen = true;
      _trajectoryDrawController.reset();
    });
  }

  void resetLabOnly() {
    setState(() {
      step = 0;
      logs = [t['log_recalibrated']!];
      showCelebration = false;
      inputA = "";
      inputB = "";
      inputC = "";
      showHint = false;
      _trajectoryDrawController.reset();
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
        backgroundColor: const Color(0xFF020617),
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
                        alignment: Alignment.centerLeft,
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
                          _buildRadarEnvironment(t),
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
                backgroundColor: const Color(0xFFB91C1C),
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
                colors: [Color(0xFF064E3B), Color(0xFF020617)],
                radius: 1.5,
              ),
            ),
          ),
          CustomPaint(painter: RadarGridPainter(opacity: 0.1)),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.redAccent.withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.3),
                        blurRadius: 100,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: RotationTransition(
                    turns: _radarSweepController,
                    child: const Icon(
                      Icons.radar,
                      size: 80,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  t['app_title'] ?? "DISCRIMINANT RADAR",
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    fontFamily: 'monospace',
                    shadows: [Shadow(color: Colors.redAccent, blurRadius: 10)],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  t['tagline'] ?? "NATURE OF ROOTS • CLASS 10",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.redAccent[400],
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
                    Icons.power_settings_new,
                    size: 24,
                    color: Colors.white,
                  ),
                  label: Text(
                    t['init_btn'] ?? "ACTIVATE RADAR",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB91C1C), // red-600
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 20,
                    shadowColor: const Color(
                      0xFFEF4444,
                    ).withOpacity(0.5), // red-500
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
        color: Color(0xF2020617),
        border: Border(right: BorderSide(color: Color(0x3310B981))),
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
                            bottom: BorderSide(color: Color(0x3310B981)),
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
                                          fontSize: 20,
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
                                          color: Colors.redAccent,
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

                      // Footer Zone (Untranslated)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Color(0x3310B981)),
                          ),
                          color: Color(0x40020617),
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
                color: lang == l ? const Color(0xFF059669) : Colors.transparent,
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
                color: Colors.redAccent,
                letterSpacing: 1,
              ),
            ),
            Text(
              "${t['lbl_step']} $step/6",
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
            value: step / 6,
            backgroundColor: const Color(0xFF1E293B),
            color: Colors.redAccent,
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
                t['step_${step}_t'] ?? "RADAR READY",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t['step_${step}_d'] ?? "Select a signal.",
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
                color: Colors.redAccent.withOpacity(0.8),
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
                      (e) => DropdownMenuItem(
                        value: e.id,
                        child: Text("${t['name_${e.id}']}: ${e.latex}"),
                      ),
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
                backgroundColor: Colors.red[600],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                t['btn_detect']!,
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
            t['msg_params'] ?? "Extract Parameters",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInputColumn("a", inputA, (v) => setState(() => inputA = v)),
              const SizedBox(width: 8),
              _buildInputColumn("b", inputB, (v) => setState(() => inputB = v)),
              const SizedBox(width: 8),
              _buildInputColumn("c", inputC, (v) => setState(() => inputC = v)),
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
                t['lbl_hint']!,
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
                  onPressed: verifyInputs,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    t['btn_extract'] ?? "VERIFY",
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildParamBox("a", eq.a),
              _buildParamBox("b", eq.b),
              _buildParamBox("c", eq.c),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => executeStep(3),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[600],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                t['btn_calc'] ?? "COMPUTE D",
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

    if (step == 3) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "D = ",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              Text(
                "${eq.D}",
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            eq.D > 0
                ? t['msg_d_pos']!
                : eq.D == 0
                ? t['msg_d_zero']!
                : t['msg_d_neg']!,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                t['btn_scan'] ?? "ACTIVATE RADAR SCAN",
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
            t['msg_classify'] ?? "Classify Signal",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => classifySignal("real_distinct"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(t['opt_real_dist'] ?? "Real & Distinct"),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => classifySignal("real_equal"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(t['opt_real_equal'] ?? "Real & Equal"),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => classifySignal("no_real"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(t['opt_no_real'] ?? "No Real Roots"),
            ),
          ),
        ],
      );
    }

    if (step == 6) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, color: Colors.redAccent, size: 48),
          const SizedBox(height: 8),
          Text(
            t['msg_success'] ?? "SIGNAL IDENTIFIED",
            style: const TextStyle(
              color: Colors.redAccent,
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
                backgroundColor: Colors.blue[600],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                t['btn_next'] ?? "Scan Next Signal",
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
              t['btn_restart'] ?? "Reboot System",
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
    Function(String) onChanged,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
            ),
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
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildParamBox(String label, int val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "$label = $val",
        style: const TextStyle(
          color: Colors.white54,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRadarEnvironment(Map<String, String> t) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          colors: [Color(0xFF020617), Color(0xFF000000)],
          radius: 1.0,
        ),
      ),
      child: Stack(
        children: [
          // The Interactive Canvas (Pannable & Zoomable)
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return InteractiveViewer(
                  panEnabled: true,
                  scaleEnabled: true,
                  minScale: 0.2,
                  maxScale: 6.0,
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: Stack(
                      children: [
                        // The Polar Grid
                        Positioned.fill(
                          child: CustomPaint(
                            painter: RadarGridPainter(opacity: 0.4),
                          ),
                        ),

                        // The Sweeping Scanner
                        Positioned.fill(
                          child: RotationTransition(
                            turns: _radarSweepController,
                            child: CustomPaint(painter: RadarSweepPainter()),
                          ),
                        ),

                        // The Parabola Trajectory
                        if (step >= 4)
                          Positioned.fill(
                            child: AnimatedBuilder(
                              animation: _trajectoryDrawController,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: TrajectoryPainter(
                                    eq,
                                    _trajectoryDrawController.value,
                                  ),
                                );
                              },
                            ),
                          ),

                        // Central blip
                        Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.redAccent,
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Equation Display in space (Fixed overlay)
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
                  border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      t['name_${eq.id}']!,
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      eq.latex.replaceAll('^2', '²'),
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontFamily: 'monospace',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingHUD(Map<String, String> t) {
    return Positioned(
      top: 80,
      left: 24,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height - 80,
          maxWidth: 280,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xE6020617),
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
                            color: Colors.redAccent,
                          ),
                        ),
                        Text(
                          "${t['lbl_step']} $step/6",
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
                        color: Colors.redAccent,
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
                        color: Colors.redAccent,
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
            t['msg_confirmed']!,
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(color: Colors.redAccent, blurRadius: 20)],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.redAccent.withOpacity(0.8)),
            ),
            child: Text(
              eq.roots,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- CUSTOM PAINTERS ---

class RadarGridPainter extends CustomPainter {
  final double opacity;
  RadarGridPainter({this.opacity = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF10B981).withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.45;

    // Circles
    for (int i = 1; i <= 5; i++) {
      canvas.drawCircle(center, maxRadius * (i / 5), paint);
    }

    // Lines
    for (int i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      final end = Offset(
        center.dx + math.cos(angle) * maxRadius,
        center.dy + math.sin(angle) * maxRadius,
      );
      canvas.drawLine(center, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RadarSweepPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.45;

    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0.0,
        endAngle: math.pi / 2,
        colors: [Colors.transparent, const Color(0xFF10B981).withOpacity(0.5)],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    // Draw the sweep arc (rotating via RotationTransition)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      math.pi / 2,
      true,
      sweepPaint,
    );

    // Front leading edge line
    final linePaint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 2.0;

    final end = Offset(
      center.dx + math.cos(math.pi / 2) * radius,
      center.dy + math.sin(math.pi / 2) * radius,
    );
    canvas.drawLine(center, end, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TrajectoryPainter extends CustomPainter {
  final Equation eq;
  final double progress;

  TrajectoryPainter(this.eq, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // X Axis line
    final axisPaint = Paint()
      ..color = Colors.white30
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(0, center.dy),
      Offset(size.width, center.dy),
      axisPaint,
    );

    if (progress == 0) return;

    final pathPaint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2.0); // slight glow

    // Scale logic
    double unitScale = math.min(size.width, size.height) / 15;

    Path path = Path();
    bool started = false;

    // Draw from x = -5 to +5 based on progress
    double startX = -5.0;
    double endX = 5.0;
    double currentMaxX = startX + ((endX - startX) * progress);

    for (double x = startX; x <= currentMaxX; x += 0.1) {
      double y = (eq.a * x * x) + (eq.b * x) + eq.c;

      // Map to canvas (invert Y because canvas Y goes down)
      double canvasX = center.dx + (x * unitScale);
      double canvasY = center.dy - (y * unitScale);

      if (!started) {
        path.moveTo(canvasX, canvasY);
        started = true;
      } else {
        path.lineTo(canvasX, canvasY);
      }
    }

    canvas.drawPath(path, pathPaint);

    // Draw Intersection dots if progress > 0.8
    if (progress > 0.8 && eq.type != "no_real") {
      final dotPaint = Paint()..color = Colors.redAccent;
      if (eq.type == "real_equal") {
        // Find the single root (vertex x = -b/2a)
        double rootX = -eq.b / (2 * eq.a);
        canvas.drawCircle(
          Offset(center.dx + (rootX * unitScale), center.dy),
          6,
          dotPaint,
        );
      } else if (eq.type == "real_distinct") {
        // Draw both roots (using quadratic formula)
        double root1 = (-eq.b + math.sqrt(eq.D)) / (2 * eq.a);
        double root2 = (-eq.b - math.sqrt(eq.D)) / (2 * eq.a);
        canvas.drawCircle(
          Offset(center.dx + (root1 * unitScale), center.dy),
          6,
          dotPaint,
        );
        canvas.drawCircle(
          Offset(center.dx + (root2 * unitScale), center.dy),
          6,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant TrajectoryPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.eq.id != eq.id;
  }
}
