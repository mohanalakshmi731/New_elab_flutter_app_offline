// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:elab_app/features/offline/activities/math_activity_audio.dart';

const Color bgDark = Color(0xFF020617);
const Color bgPanel = Color(0xFF0F172A);
const Color accentPink = Color(0xFFF472B6);
const Color accentBlue = Color(0xFF3B82F6);
const Color accentGreen = Color(0xFF22C55E);
const Color accentRed = Color(0xFFEF4444);
const Color accentYellow = Color(0xFFFACC15);

class AppStrings {
  static const Map<String, Map<String, String>> data = {
    'en': {
      'app_title': 'THE HEIGHT ESTIMATOR',
      'tagline': 'Applications of Trigonometry',
      'init_btn': 'INITIALIZE ESTIMATOR',
      'header_title': 'The Height Estimator',
      'header_subtitle': 'Class 10 • Heights & Distances',
      'phase_label': 'SURVEY PHASE',
      'step_label': 'Stage',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Height Confirmed',
      'success_desc':
          'You have successfully used trigonometry to calculate an inaccessible height!',
      'btn_restart': 'NEW ESTIMATION',
      's0': 'Initialize Surveyor System.',
      's1': 'Locate Target Base (Building).',
      's2': 'Establish horizontal distance (Walk 50m away).',
      's3': 'Establish Line of Sight to the top of the target.',
      's4': 'Measure Angle of Elevation with Clinometer (60°).',
      's5': 'Identify required Trigonometric Ratio (Tangent).',
      's6': 'Set up the Equation: tan(θ) = Opp / Adj.',
      's7': 'Substitute known values: tan(60°) = h / 50.',
      's8': 'Solve for h: h = 50 × tan(60°).',
      's9': 'Finalize Calculation: h ≈ 86.6m.',
      'btn_start': 'ESTABLISH ORIGIN',
      'btn_loc_base': 'LOCATE TARGET BASE',
      'btn_walk_dist': 'ESTABLISH DISTANCE (50m)',
      'btn_line_sight': 'DRAW LINE OF SIGHT',
      'btn_meas_angle': 'MEASURE ELEVATION (60°)',
      'btn_id_ratio': 'IDENTIFY RATIO (TAN)',
      'btn_setup_eq': 'SET UP EQUATION',
      'btn_sub_vals': 'SUBSTITUTE VALUES',
      'btn_solve_h': 'SOLVE FOR HEIGHT (h)',
      'btn_complete': 'FINALIZE CALCULATION',
      'msg_obs_ok': 'Surveyor System Online. Origin Established.',
      'msg_base_ok': 'Target building base locked.',
      'msg_dist_ok': 'Horizontal distance set: Adjacent = 50m.',
      'msg_sight_ok': 'Line of sight to apex established. Hypotenuse formed.',
      'msg_angle_ok': 'Angle of Elevation measured: 60°.',
      'msg_ratio_ok': 'Tangent selected (Opposite and Adjacent involved).',
      'msg_eq_ok': 'Equation established: tan(60°) = h / 50.',
      'msg_sub_ok': 'Values substituted: 1.732 = h / 50.',
      'msg_solve_ok': 'Isolating h: h = 50 × 1.732.',
      'msg_final_ok': 'Target Height calculated: 86.6m.',
      'msg_err': 'Calculation error.',

      // Data Collection Tabs Strings
      'data_collection': 'Data Collection',
      'awaiting_data': 'Awaiting survey data...',
      'eq_setup': 'Equation Setup',
      'substitution': 'Substitution',
      'solution': 'Final Solution',

      // Tooltips & Labels
      'menu_tooltip': 'Main Menu',
      'reset_tooltip': 'Reset',
      'back_tooltip': 'Go Back',
    },
    'hi': {
      'app_title': 'ऊंचाई अनुमानक',
      'tagline': 'त्रिकोणमिति के अनुप्रयोग',
      'init_btn': 'अनुमानक प्रारंभ करें',
      'header_title': 'ऊंचाई अनुमानक',
      'header_subtitle': 'कक्षा 10 • ऊंचाई और दूरी',
      'phase_label': 'सर्वेक्षण चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'ऊंचाई की पुष्टि',
      'success_desc':
          'आपने दुर्गम ऊंचाई की गणना करने के लिए त्रिकोणमिति का सफलतापूर्वक उपयोग किया है!',
      'btn_restart': 'नया अनुमान',
      's0': 'सर्वेक्षक प्रणाली प्रारंभ करें।',
      's1': 'लक्ष्य आधार (भवन) खोजें।',
      's2': 'क्षैतिज दूरी स्थापित करें (50 मीटर दूर चलें)।',
      's3': 'लक्ष्य के शीर्ष तक दृष्टि रेखा स्थापित करें।',
      's4': 'क्लिनोमीटर से उन्नयन कोण मापें (60°)।',
      's5': 'आवश्यक त्रिकोणमितीय अनुपात (टैंजेंट) को पहचानें।',
      's6': 'समीकरण सेट करें: tan(θ) = लंब / आधार।',
      's7': 'ज्ञात मानों को प्रतिस्थापित करें: tan(60°) = h / 50।',
      's8': 'h के लिए हल करें: h = 50 × tan(60°)।',
      's9': 'गणना पूरी करें: h ≈ 86.6m।',
      'btn_start': 'प्रणाली प्रारंभ करें',
      'btn_loc_base': 'लक्ष्य आधार खोजें',
      'btn_walk_dist': 'दूरी स्थापित करें (50m)',
      'btn_line_sight': 'दृष्टि रेखा खींचें',
      'btn_meas_angle': 'उन्नयन मापें (60°)',
      'btn_id_ratio': 'अनुपात पहचानें (TAN)',
      'btn_setup_eq': 'समीकरण सेट करें',
      'btn_sub_vals': 'मान प्रतिस्थापित करें',
      'btn_solve_h': 'ऊंचाई (h) के लिए हल करें',
      'btn_complete': 'गणना पूरी करें',
      'msg_obs_ok': 'सर्वेक्षक प्रणाली ऑनलाइन।',
      'msg_base_ok': 'लक्ष्य भवन का आधार लॉक हो गया।',
      'msg_dist_ok': 'क्षैतिज दूरी सेट: आधार = 50m।',
      'msg_sight_ok': 'शीर्ष तक दृष्टि रेखा स्थापित। कर्ण बन गया।',
      'msg_angle_ok': 'उन्नयन कोण मापा गया: 60°।',
      'msg_ratio_ok': 'टैंजेंट चुना गया (विपरीत और संलग्न शामिल)।',
      'msg_eq_ok': 'समीकरण स्थापित: tan(60°) = h / 50।',
      'msg_sub_ok': 'मान प्रतिस्थापित: 1.732 = h / 50।',
      'msg_solve_ok': 'h को अलग करना: h = 50 × 1.732।',
      'msg_final_ok': 'लक्ष्य की ऊंचाई की गणना की गई: 86.6m।',
      'msg_err': 'गणना त्रुटि।',

      // Data Collection Tabs Strings
      'data_collection': 'डेटा संग्रह',
      'awaiting_data': 'सर्वेक्षण डेटा की प्रतीक्षा...',
      'eq_setup': 'समीकरण सेटअप',
      'substitution': 'प्रतिस्थापन',
      'solution': 'अंतिम समाधान',

      // Tooltips & Labels
      'menu_tooltip': 'मुख्य मेनू',
      'reset_tooltip': 'रीसेट करें',
      'back_tooltip': 'पीछे जाएं',
    },
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['en']![key] ?? key;
  }
}

class HeightEstimatorApp extends StatefulWidget {
  const HeightEstimatorApp({super.key});

  @override
  State<HeightEstimatorApp> createState() => _HeightEstimatorAppState();
}

class _HeightEstimatorAppState extends State<HeightEstimatorApp> {
  bool hasStarted = false;
  String lang = 'en';

  // UI State - Mutually Exclusive Sidebars
  bool isLeftSidebarOpen = true;
  bool isRightSidebarOpen = false;

  // Activity State
  int currentStep = 0;
  bool showSuccessModal = false;
  Timer? _successTimer;

  void startGame() {
    playMathStart();
    setState(() {
      hasStarted = true;
    });
  }

  void switchLang(String newLang) {
    playMathClick();
    setState(() {
      lang = newLang;
    });
  }

  // Sidebar Toggles
  void toggleLeftSidebar() {
    playMathClick();
    setState(() {
      isLeftSidebarOpen = !isLeftSidebarOpen;
      if (isLeftSidebarOpen) {
        isRightSidebarOpen = false;
      }
    });
  }

  void toggleRightSidebar() {
    playMathClick();
    setState(() {
      isRightSidebarOpen = !isRightSidebarOpen;
      if (isRightSidebarOpen) {
        isLeftSidebarOpen = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _successTimer?.cancel();
    super.dispose();
  }

  void showToast(
    String message, {
    bool isError = false,
    bool isSuccess = true,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.warning_amber_rounded : Icons.check_circle,
              color: isError
                  ? accentRed
                  : (isSuccess ? accentGreen : accentBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isError ? accentRed : (isSuccess ? accentGreen : accentBlue),
            width: 2,
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void advanceStep(String msgKey) {
    if (currentStep < 10) {
      playMathClick();
      setState(() {
        currentStep++;
        if (msgKey.isNotEmpty) {
          showToast(AppStrings.get(lang, msgKey));
        }

        // Auto-open right panel during specific calculation steps if left is closed
        if (currentStep >= 6) {
          if (!isLeftSidebarOpen && !isRightSidebarOpen) {
            isRightSidebarOpen = true;
          }
        }

        if (currentStep == 10) {
          playMathSuccess();
          Timer(const Duration(seconds: 1), () {
            if (!mounted) return;
            setState(() {
              showSuccessModal = true;
            });
            // Auto hide success modal after 5 seconds
            _successTimer = Timer(const Duration(seconds: 5), () {
              if (mounted) {
                setState(() {
                  showSuccessModal = false;
                });
              }
            });
          });
        }
      });
    }
  }

  void resetLab() {
    playMathStart();
    _successTimer?.cancel();
    setState(() {
      currentStep = 0;
      showSuccessModal = false;
      hasStarted = false;
      isLeftSidebarOpen = true;
      isRightSidebarOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!hasStarted) {
      return Scaffold(
        backgroundColor: bgDark,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.architecture,
                        size: 80,
                        color: accentPink,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppStrings.get(lang, 'app_title'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: accentPink,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppStrings.get(lang, 'tagline'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        onPressed: startGame,
                        icon: const Icon(Icons.play_arrow, size: 28),
                        label: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          child: Text(
                            AppStrings.get(lang, 'init_btn'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
      );
    }

    // Screen width for responsiveness
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;
    // Sidebar width: 85% mobile, 40% desktop
    double targetPanelWidth = isMobile
        ? screenWidth * 0.85
        : screenWidth * 0.40;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: bgDark,
        body: Stack(
          children: [
            // Main Layout: Row with Sidebars and Canvas
            Row(
              children: [
                // 1. LEFT SIDE PANEL
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: isLeftSidebarOpen
                      ? Container(
                          width: targetPanelWidth,
                          height: double.infinity,
                          decoration: const BoxDecoration(
                            color: bgPanel,
                            border: Border(
                              right: BorderSide(
                                color: Colors.white12,
                                width: 2,
                              ),
                            ),
                          ),
                          child: _buildLeftPanelContent(),
                        )
                      : const SizedBox(width: 0, height: double.infinity),
                ),

                // 2. CANVAS AREA
                Expanded(child: _buildCanvasArea()),

                // 3. RIGHT SIDE PANEL (Data Collection)
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: isRightSidebarOpen
                      ? Container(
                          width: targetPanelWidth,
                          height: double.infinity,
                          decoration: const BoxDecoration(
                            color: bgPanel,
                            border: Border(
                              left: BorderSide(color: Colors.white12, width: 2),
                            ),
                          ),
                          child: _buildRightPanelContent(),
                        )
                      : const SizedBox(width: 0, height: double.infinity),
                ),
              ],
            ),

            // 4. Floating Menu Button (Top-Left)
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: bgDark.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: IconButton(
                  icon: Icon(
                    isLeftSidebarOpen ? Icons.menu_open : Icons.menu,
                    color: Colors.white,
                  ),
                  tooltip: AppStrings.get(lang, 'menu_tooltip'),
                  onPressed: toggleLeftSidebar,
                ),
              ),
            ),

            // 5. Floating Data Collection Button (Bottom-Right)
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: bgDark.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: IconButton(
                  icon: Icon(
                    isRightSidebarOpen ? Icons.close : Icons.calculate,
                    color: accentPink,
                  ),
                  tooltip: AppStrings.get(lang, 'data_collection'),
                  onPressed: toggleRightSidebar,
                ),
              ),
            ),

            // 6. Floating Back Button (Bottom-Left)
            // Positioned(
            //   bottom: 20,
            //   left: 20,
            //   child: Container(
            //     decoration: BoxDecoration(
            //       color: bgDark.withOpacity(0.8),
            //       borderRadius: BorderRadius.circular(12),
            //       border: Border.all(color: Colors.white24),
            //     ),
            //     child: IconButton(
            //       icon: const Icon(Icons.arrow_back, color: Colors.white),
            //       tooltip: AppStrings.get(lang, 'back_tooltip'),
            //       onPressed: () => Navigator.of(context).pop(),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // Left Side Panel Content
  Widget _buildLeftPanelContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 85, bottom: 85, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header, Lang Toggle & Restart
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: accentPink,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.straighten, color: bgDark),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.get(lang, 'header_title').toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.get(lang, 'header_subtitle'),
                      style: const TextStyle(
                        color: accentPink,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _LangBtn(
                          title: 'EN',
                          isActive: lang == 'en',
                          onTap: () => switchLang('en'),
                        ),
                        _LangBtn(
                          title: 'HI',
                          isActive: lang == 'hi',
                          onTap: () => switchLang('hi'),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    color: Colors.white54,
                    onPressed: resetLab,
                    tooltip: AppStrings.get(lang, 'reset_tooltip'),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white10,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Divider(color: Colors.white24, height: 40, thickness: 1),

          // Progress and Stage
          Text(
            AppStrings.get(lang, 'phase_label'),
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "${AppStrings.get(lang, 'step_label')} ${currentStep > 9 ? 10 : currentStep + 1}/10",
            style: const TextStyle(
              color: accentBlue,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 15),
          LinearProgressIndicator(
            value: (currentStep > 9 ? 10 : currentStep + 1) / 10,
            backgroundColor: Colors.black38,
            color: accentPink,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),

          const SizedBox(height: 25),

          // Mission Log Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Text(
              AppStrings.get(lang, 'mission_log').toUpperCase(),
              style: const TextStyle(
                color: accentPink,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Steps List
          Container(
            color: Colors.black26,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 10,
              itemBuilder: (context, index) {
                bool isActive = index == currentStep;
                bool isDone = index < currentStep;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? accentPink.withOpacity(0.15)
                        : Colors.transparent,
                    border: Border(
                      left: BorderSide(
                        color: isActive
                            ? accentPink
                            : isDone
                            ? accentGreen
                            : Colors.transparent,
                        width: 4,
                      ),
                    ),
                  ),
                  child: Text(
                    "${index + 1}. ${AppStrings.get(lang, 's$index')}",
                    style: TextStyle(
                      color: isActive
                          ? accentPink
                          : isDone
                          ? Colors.white70
                          : Colors.white30,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Bottom Controls
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: _buildControlsArea(),
          ),
        ],
      ),
    );
  }

  // Right Side Data Collection Panel Content
  Widget _buildRightPanelContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 25, bottom: 85, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate, color: accentPink, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppStrings.get(lang, 'data_collection').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 40, thickness: 1),

          if (currentStep < 6)
            _buildEmptyState()
          else ...[
            // Ratio Identification & Equation Setup
            if (currentStep >= 6)
              _buildDataBlock(
                AppStrings.get(lang, 'eq_setup'),
                "SOH CAH TOA",
                "tan(θ) = Opp / Adj",
                "",
                currentStep == 6,
              ),

            const SizedBox(height: 20),

            // Substitution Block
            if (currentStep >= 7)
              _buildDataBlock(
                AppStrings.get(lang, 'substitution'),
                "tan(60°) = h / 50",
                currentStep >= 8 ? "1.732 = h / 50" : "...",
                "",
                currentStep == 7 || currentStep == 8,
              ),

            const SizedBox(height: 20),

            // Final Calculation & Result Block
            if (currentStep >= 9)
              _buildResultBlock(
                AppStrings.get(lang, 'solution'),
                "h = 50 × 1.732",
                currentStep >= 10 ? "86.6m" : "...",
              ),
          ],
        ],
      ),
    );
  }

  // Helper Widget for Data Blocks
  Widget _buildDataBlock(
    String title,
    String line1,
    String line2,
    String result,
    bool highlight,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: highlight ? accentBlue : Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: highlight ? accentBlue : accentPink,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            line1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'monospace',
            ),
          ),
          if (line2.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              line2,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'monospace',
              ),
            ),
          ],
          if (result.isNotEmpty) ...[
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: accentBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                result,
                style: const TextStyle(
                  color: accentBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Helper Widget for Result Blocks
  Widget _buildResultBlock(String title, String equation, String result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentGreen.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 15),
          Text(
            equation,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: accentGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "h = ",
                  style: TextStyle(
                    color: accentGreen,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  result,
                  style: const TextStyle(
                    color: accentGreen,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper for empty data state
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.hourglass_empty, color: Colors.white24, size: 40),
            const SizedBox(height: 15),
            Text(
              AppStrings.get(lang, 'awaiting_data'),
              style: const TextStyle(
                color: Colors.white30,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Main Workspace/Canvas layout
  Widget _buildCanvasArea() {
    return ClipRect(
      child: Stack(
        children: [
          // Background (Static or Pan/Zoom layer)
          Positioned.fill(child: Container(color: bgDark)),

          // Interactive View (Move, Zoom in/out)
          Positioned.fill(
            child: InteractiveViewer(
              panEnabled: true,
              scaleEnabled: true,
              minScale: 0.2,
              maxScale: 4.0,
              boundaryMargin: const EdgeInsets.all(1000),
              constrained: false,
              child: Container(
                width: 1000,
                height: 700,
                alignment: Alignment.center,
                child: _buildSceneGraphics(),
              ),
            ),
          ),

          // Floating Mission Card (Shown only when Left Sidebar is closed)
          if (!isLeftSidebarOpen && currentStep < 10 && !showSuccessModal)
            Positioned(
              top: 90, // Positioned below the menu button
              left: 20,
              child: Container(
                width: 280,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: bgPanel.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: accentPink.withOpacity(0.5),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.flag, color: accentYellow, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.get(lang, 'active_mission').toUpperCase(),
                          style: const TextStyle(
                            color: accentYellow,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${currentStep + 1}. ${AppStrings.get(lang, 's$currentStep')}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildControlsArea(),
                  ],
                ),
              ),
            ),

          // Success Modal Layer
          if (showSuccessModal)
            Positioned.fill(
              child: Container(
                color: Colors.black87,
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: bgDark,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: accentGreen, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: accentGreen.withOpacity(0.3),
                            blurRadius: 40,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified,
                            color: accentGreen,
                            size: 80,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            AppStrings.get(lang, 'badge_title').toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            AppStrings.get(lang, 'success_desc'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSceneGraphics() {
    return SizedBox(
      width: 500,
      height: 380,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: const Size(500, 380),
            painter: EstimatorPainter(step: currentStep),
          ),
          if (currentStep >= 2) ...[
            const Positioned(
              left: 315,
              top: 310,
              child: Text(
                "Base",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
          ],
          if (currentStep >= 1) ...[
            const Positioned(
              left: 100,
              top: 310,
              child: Text(
                "Observer",
                style: TextStyle(
                  color: accentGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          if (currentStep >= 3) ...[
            const Positioned(
              left: 215,
              top: 310,
              child: Text(
                "50m",
                style: TextStyle(
                  color: accentGreen,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          if (currentStep >= 4) ...[
            Positioned(
              left: 170,
              top: 160,
              child: Transform.rotate(
                angle: -0.9,
                child: const Text(
                  "Line of Sight",
                  style: TextStyle(
                    color: accentYellow,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
          if (currentStep >= 5) ...[
            const Positioned(
              left: 160,
              top: 275,
              child: Text(
                "60°",
                style: TextStyle(
                  color: accentPink,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          if (currentStep >= 7) ...[
            Positioned(
              left: 360,
              top: 160,
              child: Text(
                currentStep >= 10 ? "h = 86.6m" : "h = ?",
                style: const TextStyle(
                  color: accentBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlsArea() {
    switch (currentStep) {
      case 0:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_start'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_obs_ok'),
        );
      case 1:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_loc_base'),
          color: accentPink,
          onPressed: () => advanceStep('msg_base_ok'),
        );
      case 2:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_walk_dist'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_dist_ok'),
        );
      case 3:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_line_sight'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_sight_ok'),
        );
      case 4:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_meas_angle'),
          color: accentPink,
          onPressed: () => advanceStep('msg_angle_ok'),
        );
      case 5:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_id_ratio'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_ratio_ok'),
        );
      case 6:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_setup_eq'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_eq_ok'),
        );
      case 7:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_sub_vals'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_sub_ok'),
        );
      case 8:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_solve_h'),
          color: accentPink,
          onPressed: () => advanceStep('msg_solve_ok'),
        );
      case 9:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_complete'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_final_ok'),
        );
      case 10:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_restart'),
          color: accentRed,
          onPressed: resetLab,
        );
      default:
        return const SizedBox();
    }
  }
}

// --- SUB-WIDGETS ---

class _ControlButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: color == accentYellow ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class _LangBtn extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _LangBtn({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white24 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.white54,
          ),
        ),
      ),
    );
  }
}

// --- CUSTOM PAINTERS ---

class EstimatorPainter extends CustomPainter {
  final int step;

  EstimatorPainter({required this.step});

  @override
  void paint(Canvas canvas, Size size) {
    Offset origin = const Offset(120, 300); // Observer Location
    Offset bBase = const Offset(340, 300); // Building Base
    Offset bTop = const Offset(340, 40); // Building Top (visually)

    // 1. Draw Ground
    if (step >= 0) {
      canvas.drawLine(
        const Offset(50, 300),
        const Offset(450, 300),
        Paint()
          ..color = Colors.white30
          ..strokeWidth = 2,
      );
    }

    // 2. Draw Observer Location
    if (step >= 1) {
      canvas.drawCircle(origin, 6, Paint()..color = accentGreen);
    }

    // 3. Draw Building Base
    if (step >= 2) {
      final buildingPaint = Paint()
        ..color = accentBlue.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      final buildingStroke = Paint()
        ..color = accentBlue
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      Rect buildingRect = Rect.fromLTRB(
        bTop.dx - 20,
        bTop.dy,
        bBase.dx + 20,
        bBase.dy,
      );

      canvas.drawRect(buildingRect, buildingPaint);
      canvas.drawRect(buildingRect, buildingStroke);

      _drawRightAngle(canvas, bBase, -1, -1, accentBlue);
    }

    // 4. Draw Distance
    if (step >= 3) {
      canvas.drawLine(
        origin,
        bBase,
        Paint()
          ..color = accentGreen
          ..strokeWidth = 4,
      );
    }

    // 5. Draw Line of Sight
    if (step >= 4) {
      final pathPaint = Paint()
        ..color = accentYellow.withOpacity(0.8)
        ..strokeWidth = 3;
      _drawDashedLine(canvas, origin, bTop, pathPaint);
    }

    // 6. Draw Angle of Elevation
    if (step >= 5) {
      final arcPaint = Paint()
        ..color = accentPink.withOpacity(0.5)
        ..style = PaintingStyle.fill;

      double radius = 50.0;
      double angle = math.atan2(origin.dy - bTop.dy, bBase.dx - origin.dx);

      canvas.drawArc(
        Rect.fromCircle(center: origin, radius: radius),
        0,
        -angle,
        true,
        arcPaint,
      );

      canvas.drawArc(
        Rect.fromCircle(center: origin, radius: radius),
        0,
        -angle,
        false,
        Paint()
          ..color = accentPink
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }

    // 7. Highlight Opposite Side (Height)
    if (step >= 7) {
      canvas.drawLine(
        bBase,
        bTop,
        Paint()
          ..color = accentBlue
          ..strokeWidth = 6,
      );
    }
  }

  void _drawRightAngle(
    Canvas canvas,
    Offset corner,
    double dirX,
    double dirY,
    Color color,
  ) {
    const double size = 15;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    Path path = Path();
    path.moveTo(corner.dx + size * dirX, corner.dy);
    path.lineTo(corner.dx + size * dirX, corner.dy + size * dirY);
    path.lineTo(corner.dx, corner.dy + size * dirY);

    canvas.drawPath(path, paint);
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const double dashWidth = 10, dashSpace = 5;
    double startX = p1.dx, startY = p1.dy;
    final double dx = p2.dx - p1.dx, dy = p2.dy - p1.dy;
    final double distance = (Offset(dx, dy)).distance;
    final double angle = (Offset(dx, dy)).direction;

    double drawnLength = 0;
    while (drawnLength < distance) {
      canvas.drawLine(
        Offset(startX, startY),
        Offset(
          startX + dashWidth * math.cos(angle),
          startY + dashWidth * math.sin(angle),
        ),
        paint,
      );
      startX += (dashWidth + dashSpace) * math.cos(angle);
      startY += (dashWidth + dashSpace) * math.sin(angle);
      drawnLength += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant EstimatorPainter oldDelegate) {
    return oldDelegate.step != step;
  }
}
