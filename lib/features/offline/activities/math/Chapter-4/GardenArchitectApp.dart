// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart'; // Added audio players
import 'dart:async';

// --- DATA & I18N ---

const Map<String, dynamic> missionData = {
  'perimeter': 80,
  'area': 400,
  'semi_p': 40,
  'roots': 20,
};

const Map<String, Map<String, String>> i18n = {
  'en': {
    "app_title": "THE GARDEN ARCHITECT",
    "tagline": "QUADRATIC APPLICATIONS • CLASS 10",
    "init_btn": "OPEN BLUEPRINT",
    "header_title": "The Garden Architect",
    "header_subtitle": "CLASS 10 • QUADRATIC EQUATIONS",
    "post_title": "Analysis & Outcomes",
    "btn_restart": "Reset Simulation",
    "lbl_progress": "Workflow",
    "hud_status": "Build Status",
    "step_1_t": "COMMISSION",
    "step_1_d":
        "Review the client's garden specifications. Click 'OPEN BLUEPRINT' to start.",
    "step_2_t": "ANALYSIS",
    "step_2_d":
        "Simplify the perimeter formula 2(L + B) = 80 by dividing both sides. Click 'DIVIDE BY 2'.",
    "step_3_t": "VARIABLES",
    "step_3_d":
        "Express Breadth (B) in terms of Length (L). Click 'B = 40 - L' to set the relation.",
    "step_4_t": "FORMULATION",
    "step_4_d":
        "Construct the area model by substituting B into Area = L × B. Click 'SUBSTITUTE (40 - L)'.",
    "step_5_t": "STANDARD FORM",
    "step_5_d":
        "Convert the equation to a standard quadratic form (ax² + bx + c = 0). Click 'EXPAND & REARRANGE'.",
    "step_6_t": "FEASIBILITY",
    "step_6_d":
        "Identify coefficients a, b, c and compute Discriminant D = b² - 4ac. Enter values and click 'CHECK FEASIBILITY'.",
    "step_7_t": "SOLVING",
    "step_7_d":
        "Solve (L - 20)² = 0 for the exact Length (L). Enter your answer and click 'CALCULATE L'.",
    "step_8_t": "DIMENSIONS",
    "step_8_d":
        "Determine the Breadth (B) using B = 40 - L. Enter the value and click 'CALCULATE B'.",
    "step_9_t": "CONSTRUCTION",
    "step_9_d":
        "Review the final calculated dimensions. Click 'BUILD PARK' to visualize the final construction.",
    "step_10_t": "APPROVED",
    "step_10_d":
        "A square shape provides maximum area for a fixed perimeter. Click 'SUBMIT DESIGN' to complete.",
    "lbl_perimeter": "Perimeter",
    "lbl_area": "Area",
    "btn_open_blueprint": "OPEN BLUEPRINT",
    "instr_step2": "Simplify Perimeter Formula",
    "btn_divide": "DIVIDE BY 2",
    "instr_step3": "Express B in terms of L",
    "instr_step4": "Substitute B into Area Formula",
    "btn_substitute": "SUBSTITUTE (40 - L)",
    "instr_step5": "Convert to Standard Form",
    "btn_expand": "EXPAND & REARRANGE",
    "instr_step6": "Identify Coefficients & Calculate Discriminant (b² - 4ac)",
    "btn_check_feasibility": "CHECK FEASIBILITY",
    "instr_step7": "Solve for Length (L)",
    "btn_calc_l": "CALCULATE L",
    "instr_step8": "Calculate Breadth (B = 40 - L)",
    "btn_calc_b": "CALCULATE B",
    "instr_step9": "Final Design Review",
    "btn_build_park": "BUILD PARK",
    "msg_approved": "PROJECT APPROVED",
    "msg_tip_square":
        "\"A SQUARE IS THE RECTANGLE WITH MAXIMUM AREA FOR A FIXED PERIMETER.\"",
    "btn_submit": "SUBMIT DESIGN",
    "msg_completed": "ACTIVITY COMPLETED",
    "btn_new_comm": "NEW COMMISSION",
    "btn_start_lab": "Open Blueprint",
  },
  'hi': {
    "app_title": "गार्डन आर्किटेक्ट",
    "tagline": "द्विघात अनुप्रयोग • कक्षा 10",
    "init_btn": "ब्लूप्रिंट खोलें",
    "header_title": "गार्डन आर्किटेक्ट",
    "header_subtitle": "कक्षा 10 • द्विघात समीकरण",
    "post_title": "विश्लेषण और परिणाम",
    "btn_restart": "सिमुलेशन रीसेट करें",
    "lbl_progress": "डिज़ाइन चरण",
    "hud_status": "निर्माण स्थिति",
    "step_1_t": "योजना",
    "step_1_d":
        "क्लाइंट के विनिर्देशों की समीक्षा करें। शुरू करने के लिए 'ब्लूप्रिंट खोलें' पर क्लिक करें।",
    "step_2_t": "विश्लेषण",
    "step_2_d":
        "परिधि सूत्र 2(L + B) = 80 को सरल करें। '2 से विभाजित करें' पर क्लिक करें।",
    "step_3_t": "चर",
    "step_3_d":
        "चौड़ाई (B) को लंबाई (L) के रूप में व्यक्त करें। संबंध सेट करने के लिए 'B = 40 - L' पर क्लिक करें।",
    "step_4_t": "सूत्रीकरण",
    "step_4_d":
        "क्षेत्रफल सूत्र में B को प्रतिस्थापित करें। 'प्रतिस्थापित करें (40 - L)' पर क्लिक करें।",
    "step_5_t": "मानक रूप",
    "step_5_d":
        "समीकरण को द्विघात रूप (ax² + bx + c = 0) में बदलें। 'विस्तार और पुनर्व्यवस्थित करें' पर क्लिक करें।",
    "step_6_t": "व्यवहार्यता",
    "step_6_d":
        "गुणांक a, b, c पहचानें और D = b² - 4ac की गणना करें। मान दर्ज करें और 'व्यवहार्यता की जाँच करें' पर क्लिक करें।",
    "step_7_t": "समाधान",
    "step_7_d":
        "(L - 20)² = 0 को हल करें। L का मान दर्ज करें और 'L की गणना करें' पर क्लिक करें।",
    "step_8_t": "आयाम",
    "step_8_d":
        "B = 40 - L का उपयोग करके चौड़ाई (B) निर्धारित करें। मान दर्ज करें और 'B की गणना करें' पर क्लिक करें।",
    "step_9_t": "निर्माण",
    "step_9_d":
        "अंतिम आयामों की समीक्षा करें। निर्माण देखने के लिए 'पार्क का निर्माण करें' पर क्लिक करें।",
    "step_10_t": "स्वीकृत",
    "step_10_d":
        "एक निश्चित परिधि के लिए, वर्ग का क्षेत्रफल अधिकतम होता है। 'डिज़ाइन जमा करें' पर क्लिक करें।",
    "lbl_perimeter": "परिधि",
    "lbl_area": "क्षेत्रफल",
    "btn_open_blueprint": "ब्लूप्रिंट खोलें",
    "instr_step2": "परिधि सूत्र को सरल करें",
    "btn_divide": "2 से विभाजित करें",
    "instr_step3": "चौड़ाई (B) को लंबाई (L) के रूप में व्यक्त करें",
    "instr_step4": "क्षेत्रफल सूत्र में B का मान रखें",
    "btn_substitute": "प्रतिस्थापित करें (40 - L)",
    "instr_step5": "मानक रूप में बदलें",
    "btn_expand": "विस्तार और पुनर्व्यवस्थित करें",
    "instr_step6": "गुणांक पहचानें और विविक्तकर (b² - 4ac) की गणना करें",
    "btn_check_feasibility": "व्यवहार्यता की जाँच करें",
    "instr_step7": "लंबाई (L) के लिए हल करें",
    "btn_calc_l": "L की गणना करें",
    "instr_step8": "चौड़ाई की गणना करें (B = 40 - L)",
    "btn_calc_b": "B की गणना करें",
    "instr_step9": "अंतिम डिज़ाइन समीक्षा",
    "btn_build_park": "पार्क का निर्माण करें",
    "msg_approved": "प्रोजेक्ट स्वीकृत",
    "msg_tip_square":
        "\"एक निश्चित परिधि के लिए, वर्ग वह आयत है जिसका क्षेत्रफल अधिकतम होता है।\"",
    "btn_submit": "डिज़ाइन जमा करें",
    "msg_completed": "गतिविधि पूर्ण",
    "btn_new_comm": "नया कमीशन",
    "btn_start_lab": "ब्लूप्रिंट खोलें",
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

class GardenArchitectApp extends StatefulWidget {
  const GardenArchitectApp({super.key});

  @override
  State<GardenArchitectApp> createState() => _GardenArchitectAppState();
}

class _GardenArchitectAppState extends State<GardenArchitectApp>
    with TickerProviderStateMixin {
  bool started = false;
  String lang = 'en';
  bool panelOpen = true;

  // Scroll Controller for HUD
  final ScrollController _hudScrollController = ScrollController();

  // Game State
  int step = 0;
  List<String> logs = ['Systems Online. Awaiting Commission...'];
  bool showCelebration = false;

  // User Inputs
  String inputA = "";
  String inputB = "";
  String inputC = "";
  String inputD = "";
  String inputL = "";
  String inputBreadth = "";

  // Animations
  late AnimationController _gardenBuildController;

  @override
  void initState() {
    super.initState();
    _gardenBuildController = AnimationController(
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
    _gardenBuildController.dispose();
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
      } else if (type == 'build' || type == 'alert') {
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

  void executeStep(int newStep) {
    playFeedback('click');
    setState(() {
      step = newStep;
      if (step == 11) showCelebration = true;
    });

    if (step == 1) {
      addLog("Commission Received. Loading Blueprint...");
    } else if (step == 2) {
      addLog("Perimeter Simplified: L + B = 40");
    } else if (step == 3) {
      addLog("Relation Set: B = 40 - L");
    } else if (step == 4) {
      addLog("Area Equation: L(40-L) = 400");
    } else if (step == 5) {
      addLog("Standard Form: L² - 40L + 400 = 0");
    } else if (step == 9) {
      playFeedback('build');
      addLog("Square Park Constructed: 20m x 20m");
      _gardenBuildController.forward();
    } else if (step == 10) {
      playFeedback('success');
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => showCelebration = false);
      });
    }
  }

  void checkDiscriminant() {
    int? a = int.tryParse(inputA);
    int? b = int.tryParse(inputB);
    int? c = int.tryParse(inputC);
    int? d = int.tryParse(inputD);

    if (a == 1 && b == -40 && c == 400) {
      if (d == 0) {
        playFeedback('success');
        addLog("Feasible! D = 0 (Real & Equal Roots)");
        executeStep(7);
      } else {
        playFeedback('error');
        addLog(
          "Coefficients Correct. But D is wrong. Hint: (-40)² - 4(1)(400)",
        );
      }
    } else {
      playFeedback('error');
      addLog("Incorrect Coefficients. Compare with L² - 40L + 400 = 0");
    }
  }

  void checkLength() {
    int? l = int.tryParse(inputL);
    if (l == 20) {
      playFeedback('success');
      addLog("Length Found: L = 20m");
      executeStep(8);
    } else {
      playFeedback('error');
      addLog("Incorrect Length. Solve (L-20)² = 0");
    }
  }

  void checkBreadth() {
    int? b = int.tryParse(inputBreadth);
    if (b == 20) {
      playFeedback('success');
      addLog("Breadth Found: B = 20m");
      executeStep(9);
    } else {
      playFeedback('error');
      addLog("Incorrect Breadth. B = 40 - 20");
    }
  }

  void resetApp() {
    setState(() {
      step = 0;
      logs = ['System Reset. Awaiting Commission...'];
      showCelebration = false;
      started = false;
      panelOpen = true;
      _gardenBuildController.reset();
      inputA = "";
      inputB = "";
      inputC = "";
      inputD = "";
      inputL = "";
      inputBreadth = "";
    });
  }

  void resetLabOnly() {
    setState(() {
      step = 0;
      logs = ['System Reset. Awaiting Commission...'];
      showCelebration = false;
      _gardenBuildController.reset();
      inputA = "";
      inputB = "";
      inputC = "";
      inputD = "";
      inputL = "";
      inputBreadth = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = i18n[lang] ?? i18n['en']!;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive panel width: 40% on large screens, larger on smaller screens
    final double panelWidth = screenWidth < 600
        ? screenWidth * 0.85
        : (screenWidth * 0.4).clamp(320.0, 450.0);

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
            // Core Layout: Responsive Side Panel + Canvas
            Positioned.fill(
              child: Row(
                children: [
                  // Animated Side Panel
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

                  // Interactive Canvas
                  Expanded(
                    child: ClipRect(
                      child: Stack(
                        children: [
                          _buildArchitectEnvironment(),
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
                backgroundColor: const Color(0xFF059669),
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
                colors: [Color(0xFF047857), Color(0xFF020617)], // Emerald/slate
                radius: 1.5,
              ),
            ),
          ),
          CustomPaint(painter: GridPainter(opacity: 0.1)),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        blurRadius: 100,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.eco,
                    size: 80,
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  t['app_title'] ?? "THE GARDEN ARCHITECT",
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    fontFamily: 'monospace',
                    shadows: [Shadow(color: Color(0xFF10B981), blurRadius: 10)],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  t['tagline'] ?? "QUADRATIC APPLICATIONS • CLASS 10",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6EE7B7),
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
                    Icons.architecture,
                    size: 24,
                    color: Colors.white,
                  ),
                  label: Text(
                    t['init_btn'] ?? "OPEN BLUEPRINT",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669), // Emerald 600
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 20,
                    shadowColor: const Color(0xFF10B981).withOpacity(0.5),
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
        color: Color(0xF2022C22),
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
                                Container(
                                  width: 40,
                                  height: 40,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF10B981),
                                        Color(0xFF059669),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF10B981,
                                        ).withOpacity(0.2),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.design_services,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
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
                                          color: Color(0xFF10B981),
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
                            top: BorderSide(color: Color(0x3310B981)),
                          ),
                          color: Color(0x40022C22),
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
        color: const Color(0x80064E3B),
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
                  color: lang == l ? Colors.white : const Color(0xFF047857),
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
                color: Color(0xFF10B981),
                letterSpacing: 1,
              ),
            ),
            Text(
              "Step ${step == 0 ? 1 : step}/10",
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
            value: (step == 0 ? 1 : step) / 10,
            backgroundColor: const Color(0xFF064E3B),
            color: const Color(0xFF10B981),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xCC064E3B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t['step_${step == 0 ? 1 : step}_t'] ?? "READY",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10B981),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t['step_${step == 0 ? 1 : step}_d'] ?? "Awaiting commands.",
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
          constraints: const BoxConstraints(minHeight: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Center(
            child: SingleChildScrollView(child: _buildInteractionControls(t)),
          ),
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
                color: const Color(0xFF10B981).withOpacity(0.8),
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
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF022C22),
                    border: Border.all(
                      color: const Color(0xFF10B981).withOpacity(0.5),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        (t['lbl_perimeter'] ?? "Perimeter").toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 10,
                        ),
                      ),
                      const Text(
                        "80 m",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF022C22),
                    border: Border.all(
                      color: const Color(0xFF10B981).withOpacity(0.5),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        (t['lbl_area'] ?? "Area").toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 10,
                        ),
                      ),
                      const Text(
                        "400 m²",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => executeStep(1),
              icon: const Icon(
                Icons.folder_open,
                size: 16,
                color: Colors.white,
              ),
              label: Text(
                t['btn_open_blueprint'] ?? "OPEN BLUEPRINT",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                padding: const EdgeInsets.symmetric(vertical: 16),
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
            t['instr_step2'] ?? "Simplify Perimeter Formula",
            style: const TextStyle(color: Color(0xFFA7F3D0), fontSize: 12),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF022C22),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "2(L + B) = 80",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => executeStep(2),
              icon: const Icon(
                Icons.content_cut,
                size: 16,
                color: Colors.white,
              ),
              label: Text(
                t['btn_divide'] ?? "DIVIDE BY 2",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      );
    }

    if (step == 2) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t['instr_step3'] ?? "Express B in terms of L",
            style: const TextStyle(color: Color(0xFFA7F3D0), fontSize: 12),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF022C22),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "L + B = 40",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => executeStep(3),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF064E3B),
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFF10B981)),
              ),
              child: const Text(
                "B = 40 - L",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
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
          Text(
            t['instr_step4'] ?? "Substitute B into Area",
            style: const TextStyle(color: Color(0xFFA7F3D0), fontSize: 12),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF022C22),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "Area = L × B = 400",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => executeStep(4),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[600],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                t['btn_substitute'] ?? "SUBSTITUTE (40 - L)",
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
            t['instr_step5'] ?? "Convert to Standard Form",
            style: const TextStyle(color: Color(0xFFA7F3D0), fontSize: 12),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF022C22),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "L(40 - L) = 400",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => executeStep(5),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                t['btn_expand'] ?? "EXPAND & REARRANGE",
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

    if (step == 5) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t['instr_step6'] ?? "Calculate Discriminant",
            style: const TextStyle(color: Color(0xFFA7F3D0), fontSize: 12),
          ),
          const SizedBox(height: 8),
          const Text(
            "L² - 40L + 400 = 0",
            style: TextStyle(
              color: Color(0xFF10B981),
              fontFamily: 'monospace',
              fontSize: 14,
            ),
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
          const SizedBox(height: 12),
          TextField(
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF064E3B),
              hintText: "D = ?",
              hintStyle: const TextStyle(color: Color(0xFF059669)),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF10B981)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF10B981)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF10B981)),
              ),
            ),
            onChanged: (v) => setState(() => inputD = v),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: checkDiscriminant,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                t['btn_check_feasibility'] ?? "CHECK FEASIBILITY",
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

    if (step == 7) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t['instr_step7'] ?? "Solve for Length (L)",
            style: const TextStyle(color: Color(0xFFA7F3D0), fontSize: 12),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF022C22),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "(L - 20)² = 0",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF064E3B),
              hintText: "L = ?",
              hintStyle: const TextStyle(color: Color(0xFF059669)),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF10B981)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF10B981)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF10B981)),
              ),
            ),
            onChanged: (v) => setState(() => inputL = v),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: checkLength,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                t['btn_calc_l'] ?? "CALCULATE L",
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

    if (step == 8) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t['instr_step8'] ?? "Calculate Breadth",
            style: const TextStyle(color: Color(0xFFA7F3D0), fontSize: 12),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF022C22),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "L = 20 m",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF064E3B),
              hintText: "B = ?",
              hintStyle: const TextStyle(color: Color(0xFF059669)),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF10B981)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF10B981)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF10B981)),
              ),
            ),
            onChanged: (v) => setState(() => inputBreadth = v),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: checkBreadth,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                t['btn_calc_b'] ?? "CALCULATE B",
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

    if (step == 9) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t['instr_step9'] ?? "Final Design Review",
            style: const TextStyle(color: Color(0xFFA7F3D0), fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: const Color(0xFF064E3B),
                  alignment: Alignment.center,
                  child: const Text(
                    "L = 20m",
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: const Color(0xFF064E3B),
                  alignment: Alignment.center,
                  child: const Text(
                    "B = 20m",
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => executeStep(10),
              icon: const Icon(
                Icons.architecture,
                size: 16,
                color: Colors.white,
              ),
              label: Text(
                t['btn_build_park'] ?? "BUILD PARK",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      );
    }

    if (step == 10) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, color: Colors.amberAccent, size: 48),
          const SizedBox(height: 8),
          Text(
            t['msg_approved'] ?? "PROJECT APPROVED",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            t['msg_tip_square'] ?? "Tip...",
            style: const TextStyle(
              color: Color(0xFF10B981),
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => executeStep(11),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF047857),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                t['btn_submit'] ?? "SUBMIT DESIGN",
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

    if (step == 11) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t['msg_completed'] ?? "ACTIVITY COMPLETED",
            style: const TextStyle(
              color: Color(0xFF10B981),
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
                backgroundColor: Colors.blueGrey[800],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                t['btn_new_comm'] ?? "NEW COMMISSION",
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

    return const SizedBox();
  }

  Widget _buildInputColumn(
    String label,
    String value,
    Function(String) onChanged,
  ) {
    return Expanded(
      child: TextField(
        keyboardType: const TextInputType.numberWithOptions(signed: true),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'monospace',
          fontSize: 12,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFF064E3B),
          hintText: "$label=?",
          hintStyle: const TextStyle(color: Color(0xFF059669)),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFF10B981)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFF10B981)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFF10B981)),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildArchitectEnvironment() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          colors: [Color(0xFF064E3B), Color(0xFF000000)],
          radius: 1.0,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return InteractiveViewer(
            panEnabled: true,
            scaleEnabled: true,
            minScale: 0.1,
            maxScale: 5.0,
            boundaryMargin: const EdgeInsets.all(2000),
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: GridPainter(opacity: 0.2)),
                  ),
                  if (step > 0)
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _gardenBuildController,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: BlueprintGardenPainter(
                              step,
                              _gardenBuildController.value,
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
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
          maxWidth: 320,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xE6022C22),
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
                            color: Color(0xFF10B981),
                          ),
                        ),
                        Text(
                          "Step ${step == 0 ? 1 : step}/10",
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
                      t['step_${step == 0 ? 1 : step}_t'] ?? "LEVEL",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t['step_${step == 0 ? 1 : step}_d'] ?? "Analyze.",
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
                        color: Color(0xFF10B981),
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
          const Text(
            "BUILT!",
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(color: Color(0xFF10B981), blurRadius: 20)],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF022C22),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.8),
              ),
            ),
            child: const Text(
              "Area Verified",
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10B981),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- CUSTOM PAINTERS ---

class GridPainter extends CustomPainter {
  final double opacity;
  GridPainter({this.opacity = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF10B981).withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw an extended grid for InteractiveViewer bounds
    for (double i = -2000; i < size.width + 2000; i += 40) {
      canvas.drawLine(Offset(i, -2000), Offset(i, size.height + 2000), paint);
    }
    for (double i = -2000; i < size.height + 2000; i += 40) {
      canvas.drawLine(Offset(-2000, i), Offset(size.width + 2000, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BlueprintGardenPainter extends CustomPainter {
  final int step;
  final double buildProgress; // For 3D garden animation

  BlueprintGardenPainter(this.step, this.buildProgress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Dimensions mapping (20x20 in math logic is mapped to pixels)
    // To show evolution, let's use an arbitrary rectangle early on (e.g. 25x15),
    // then square at the end (20x20). We'll scale to about 200px.
    double width = step >= 8 ? 200.0 : 250.0;
    double height = step >= 8 ? 200.0 : 150.0;

    final rect = Rect.fromCenter(center: center, width: width, height: height);

    // 1. Draw Blueprint (Steps 1 to 9)
    if (step >= 1 && buildProgress == 0.0) {
      final bpPaint = Paint()
        ..color =
            const Color(0xFF34D399) // Emerald 400
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3.0); // Neon glow

      canvas.drawRect(rect, bpPaint);

      // Labels
      final textPainter = TextPainter(textDirection: TextDirection.ltr);

      if (step >= 3) {
        // Draw 'L' at bottom
        textPainter.text = const TextSpan(
          text: "L",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            center.dx - (textPainter.width / 2),
            center.dy + (height / 2) + 10,
          ),
        );

        // Draw '40 - L' at right
        textPainter.text = const TextSpan(
          text: "40 - L",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            center.dx + (width / 2) + 15,
            center.dy - (textPainter.height / 2),
          ),
        );
      }

      if (step >= 1) {
        // Area label inside
        textPainter.text = const TextSpan(
          text: "A = 400 m²",
          style: TextStyle(
            color: Color(0x8034D399),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            center.dx - (textPainter.width / 2),
            center.dy - (textPainter.height / 2),
          ),
        );
      }
    }

    // 2. Build 3D Garden (Animated at Step 10+)
    if (buildProgress > 0.0) {
      // Base Platform
      final basePaint = Paint()
        ..color =
            const Color(0xFF10B981) // Solid Emerald
        ..style = PaintingStyle.fill;

      // Shrink width to target square (200x200) based on progress if it wasn't already
      double currentW = 250.0 - (50.0 * buildProgress);
      double currentH = 150.0 + (50.0 * buildProgress);

      // Simulate 3D raising by offsetting Y
      double popUpOffset = 20.0 * buildProgress;
      final gardenRect = Rect.fromCenter(
        center: Offset(center.dx, center.dy - popUpOffset),
        width: currentW,
        height: currentH,
      );

      // Draw 3D sides (thickness)
      if (buildProgress > 0) {
        final sidePaint = Paint()
          ..color = const Color(0xFF064E3B); // Darker side
        Path sidePath = Path()
          ..moveTo(gardenRect.left, gardenRect.bottom)
          ..lineTo(gardenRect.right, gardenRect.bottom)
          ..lineTo(gardenRect.right, gardenRect.bottom + popUpOffset)
          ..lineTo(gardenRect.left, gardenRect.bottom + popUpOffset)
          ..close();
        canvas.drawPath(sidePath, sidePaint);

        final rightSidePaint = Paint()..color = const Color(0xFF047857);
        // Basic straight drop for simplicity in 2.5D
        canvas.drawRect(
          Rect.fromLTRB(
            gardenRect.right,
            gardenRect.top,
            gardenRect.right + 10 * buildProgress,
            gardenRect.bottom + popUpOffset,
          ),
          rightSidePaint,
        );
      }

      canvas.drawRect(gardenRect, basePaint);

      // Draw grid on top of garden
      final gridPaint = Paint()
        ..color = Colors.white.withOpacity(0.3 * buildProgress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      for (double i = gardenRect.left; i <= gardenRect.right; i += 20) {
        canvas.drawLine(
          Offset(i, gardenRect.top),
          Offset(i, gardenRect.bottom),
          gridPaint,
        );
      }
      for (double i = gardenRect.top; i <= gardenRect.bottom; i += 20) {
        canvas.drawLine(
          Offset(gardenRect.left, i),
          Offset(gardenRect.right, i),
          gridPaint,
        );
      }

      // Draw Trees (Scale up with progress)
      final trunkPaint = Paint()
        ..color = const Color(0xFF8B4513)
        ..style = PaintingStyle.fill;
      final leafPaint = Paint()
        ..color = const Color(0xFF22C55E)
        ..style = PaintingStyle.fill;

      for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
          double tx = gardenRect.left + 25 + (i * 50);
          double ty = gardenRect.top + 25 + (j * 50);

          double treeScale = buildProgress * 15.0; // Max radius 15

          // Trunk
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset(tx, ty + (treeScale * 0.5)),
              width: treeScale * 0.4,
              height: treeScale,
            ),
            trunkPaint,
          );
          // Leaves
          canvas.drawCircle(
            Offset(tx, ty - (treeScale * 0.3)),
            treeScale,
            leafPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant BlueprintGardenPainter oldDelegate) {
    return oldDelegate.step != step ||
        oldDelegate.buildProgress != buildProgress;
  }
}
