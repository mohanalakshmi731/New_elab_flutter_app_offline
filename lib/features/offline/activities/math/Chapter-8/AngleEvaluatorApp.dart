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
      'app_title': 'THE ANGLE EVALUATOR',
      'tagline': 'Evaluating Trigonometric Expressions',
      'init_btn': 'INITIALIZE EVALUATOR',
      'header_title': 'The Angle Evaluator',
      'header_subtitle': 'Class 10 • Intro to Trigonometry',
      'phase_label': 'EVALUATION PHASE',
      'step_label': 'Stage',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Expression Evaluated',
      'success_desc':
          'You have successfully evaluated the compound trigonometric expression!',
      'btn_restart': 'NEW EVALUATION',
      's0': 'Initialize Expression: sin(60°)cos(30°) + sin(30°)cos(60°)',
      's1': 'Target Angle 1: Isolate 60° reference triangle.',
      's2': 'Evaluate: sin(60°) = √3 / 2.',
      's3': 'Evaluate: cos(60°) = 1 / 2.',
      's4': 'Target Angle 2: Isolate 30° reference triangle.',
      's5': 'Evaluate: sin(30°) = 1 / 2.',
      's6': 'Evaluate: cos(30°) = √3 / 2.',
      's7': 'Substitute values into the main expression.',
      's8': 'Multiply the substituted fractional terms.',
      's9': 'Sum the fractions to calculate final result.',
      'btn_start': 'LOAD EXPRESSION',
      'btn_target_60': 'TARGET 60° ANGLE',
      'btn_eval_sin60': 'EVALUATE SIN(60°)',
      'btn_eval_cos60': 'EVALUATE COS(60°)',
      'btn_target_30': 'TARGET 30° ANGLE',
      'btn_eval_sin30': 'EVALUATE SIN(30°)',
      'btn_eval_cos30': 'EVALUATE COS(30°)',
      'btn_substitute': 'SUBSTITUTE ALL',
      'btn_multiply': 'MULTIPLY TERMS',
      'btn_sum': 'CALCULATE SUM',
      'msg_obs_ok': 'Expression loaded into memory.',
      'msg_t60_ok': '60° Reference Triangle established.',
      'msg_sin60_ok': 'sin(60°) resolved to √3/2.',
      'msg_cos60_ok': 'cos(60°) resolved to 1/2.',
      'msg_t30_ok': '30° Reference Triangle established.',
      'msg_sin30_ok': 'sin(30°) resolved to 1/2.',
      'msg_cos30_ok': 'cos(30°) resolved to √3/2.',
      'msg_sub_ok': 'All trigonometric terms substituted.',
      'msg_mult_ok': 'Multiplication: 3/4 and 1/4.',
      'msg_final_ok': 'Final Sum: 4/4 = 1. Evaluation Complete.',
      'msg_err': 'Calculation error.',

      // Data Collection Tabs Strings
      'data_collection': 'Data Collection',
      'awaiting_data': 'Awaiting evaluation data...',
      'base_expr': 'Base Expression',
      'eval_60': 'Evaluating 60° Terms',
      'eval_30': 'Evaluating 30° Terms',
      'substitution': 'Substitution',
      'multiplication': 'Multiplication',
      'final_result': 'Final Result',

      // Tooltips & Labels
      'menu_tooltip': 'Main Menu',
      'reset_tooltip': 'Reset',
      'back_tooltip': 'Go Back',
    },
    'hi': {
      'app_title': 'कोण मूल्यांकक',
      'tagline': 'त्रिकोणमितीय व्यंजकों का मूल्यांकन',
      'init_btn': 'मूल्यांकक प्रारंभ करें',
      'header_title': 'कोण मूल्यांकक',
      'header_subtitle': 'कक्षा 10 • त्रिकोणमिति का परिचय',
      'phase_label': 'मूल्यांकन चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'मूल्यांकन पूर्ण',
      'success_desc':
          'आपने सफलतापूर्वक त्रिकोणमितीय व्यंजक का मूल्यांकन किया है!',
      'btn_restart': 'नया मूल्यांकन',
      's0': 'व्यंजक प्रारंभ करें: sin(60°)cos(30°) + sin(30°)cos(60°)',
      's1': 'लक्ष्य कोण 1: 60° संदर्भ त्रिभुज को अलग करें।',
      's2': 'मूल्यांकन करें: sin(60°) = √3 / 2.',
      's3': 'मूल्यांकन करें: cos(60°) = 1 / 2.',
      's4': 'लक्ष्य कोण 2: 30° संदर्भ त्रिभुज को अलग करें।',
      's5': 'मूल्यांकन करें: sin(30°) = 1 / 2.',
      's6': 'मूल्यांकन करें: cos(30°) = √3 / 2.',
      's7': 'मुख्य व्यंजक में मानों को प्रतिस्थापित करें।',
      's8': 'प्रतिस्थापित भिन्नात्मक पदों को गुणा करें।',
      's9': 'अंतिम परिणाम की गणना करने के लिए भिन्नों को जोड़ें।',
      'btn_start': 'व्यंजक लोड करें',
      'btn_target_60': '60° कोण को लक्षित करें',
      'btn_eval_sin60': 'SIN(60°) का मूल्यांकन करें',
      'btn_eval_cos60': 'COS(60°) का मूल्यांकन करें',
      'btn_target_30': '30° कोण को लक्षित करें',
      'btn_eval_sin30': 'SIN(30°) का मूल्यांकन करें',
      'btn_eval_cos30': 'COS(30°) का मूल्यांकन करें',
      'btn_substitute': 'सभी प्रतिस्थापित करें',
      'btn_multiply': 'पदों को गुणा करें',
      'btn_sum': 'योग की गणना करें',
      'msg_obs_ok': 'व्यंजक मेमोरी में लोड हो गया।',
      'msg_t60_ok': '60° संदर्भ त्रिभुज स्थापित।',
      'msg_sin60_ok': 'sin(60°) का मान √3/2 है।',
      'msg_cos60_ok': 'cos(60°) का मान 1/2 है।',
      'msg_t30_ok': '30° संदर्भ त्रिभुज स्थापित।',
      'msg_sin30_ok': 'sin(30°) का मान 1/2 है।',
      'msg_cos30_ok': 'cos(30°) का मान √3/2 है।',
      'msg_sub_ok': 'सभी त्रिकोणमितीय पद प्रतिस्थापित किए गए।',
      'msg_mult_ok': 'गुणा: 3/4 और 1/4.',
      'msg_final_ok': 'अंतिम योग: 4/4 = 1. मूल्यांकन पूर्ण।',
      'msg_err': 'गणना त्रुटि।',

      // Data Collection Tabs Strings
      'data_collection': 'डेटा संग्रह',
      'awaiting_data': 'मूल्यांकन डेटा की प्रतीक्षा...',
      'base_expr': 'मूल व्यंजक',
      'eval_60': '60° पदों का मूल्यांकन',
      'eval_30': '30° पदों का मूल्यांकन',
      'substitution': 'प्रतिस्थापन',
      'multiplication': 'गुणा',
      'final_result': 'अंतिम परिणाम',

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

class AngleEvaluatorApp extends StatefulWidget {
  const AngleEvaluatorApp({super.key});

  @override
  State<AngleEvaluatorApp> createState() => _AngleEvaluatorAppState();
}

class _AngleEvaluatorAppState extends State<AngleEvaluatorApp> {
  bool hasStarted = false;
  String lang = 'en';

  // UI State - Mutually Exclusive Sidebars
  bool isLeftSidebarOpen = true;
  bool isRightSidebarOpen = false;

  // Activity State
  int currentStep = 0;
  bool showSuccessModal = false;

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
    // Lock orientation to landscape for better experience
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
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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
                  color: bgDark, // Light theme text color
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white, // Light background
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
      // Allows advancing up to step 10
      setState(() {
        currentStep++;
        if (msgKey.isNotEmpty) {
          showToast(AppStrings.get(lang, msgKey));
        }

        // Auto-open right panel to show math resolving if left is closed
        if (currentStep >= 2) {
          if (!isLeftSidebarOpen && !isRightSidebarOpen) {
            isRightSidebarOpen = true;
          }
        }

        // Complete!
        if (currentStep == 10) {
          playMathSuccess();
          Timer(const Duration(seconds: 1), () {
            if (!mounted) return;
            setState(() {
              showSuccessModal = true;
            });
            // Auto-dismiss popup after 5 seconds
            Timer(const Duration(seconds: 5), () {
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
                        Icons.query_stats,
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
                child: const Icon(Icons.calculate, color: bgDark),
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
      padding: const EdgeInsets.only(top: 25, bottom: 60, left: 20, right: 20),
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

          if (currentStep == 0)
            _buildEmptyState()
          else ...[
            // Base Expression Block
            _buildDataBlock(
              AppStrings.get(lang, 'base_expr'),
              "sin(60°)cos(30°) + sin(30°)cos(60°)",
              "",
              "",
              currentStep == 1,
            ),
            const SizedBox(height: 20),

            // 60° Evaluations
            if (currentStep >= 2)
              _buildDataBlock(
                AppStrings.get(lang, 'eval_60'),
                currentStep >= 3 ? "sin(60°) = √3/2" : "sin(60°) = ...",
                currentStep >= 4
                    ? "cos(60°) = 1/2"
                    : (currentStep >= 3 ? "cos(60°) = ..." : ""),
                "",
                currentStep == 2 || currentStep == 3 || currentStep == 4,
              ),
            const SizedBox(height: 20),

            // 30° Evaluations
            if (currentStep >= 5)
              _buildDataBlock(
                AppStrings.get(lang, 'eval_30'),
                currentStep >= 6 ? "sin(30°) = 1/2" : "sin(30°) = ...",
                currentStep >= 7
                    ? "cos(30°) = √3/2"
                    : (currentStep >= 6 ? "cos(30°) = ..." : ""),
                "",
                currentStep == 5 || currentStep == 6 || currentStep == 7,
              ),
            const SizedBox(height: 20),

            // Substitution
            if (currentStep >= 8)
              _buildDataBlock(
                AppStrings.get(lang, 'substitution'),
                "(√3/2) × (√3/2) + (1/2) × (1/2)",
                "",
                "",
                currentStep == 8,
              ),
            const SizedBox(height: 20),

            // Multiplication
            if (currentStep >= 9)
              _buildDataBlock(
                AppStrings.get(lang, 'multiplication'),
                "3/4 + 1/4",
                "",
                "",
                currentStep == 9,
              ),
            const SizedBox(height: 20),

            // Final Result
            if (currentStep >= 10)
              _buildResultBlock(
                AppStrings.get(lang, 'final_result'),
                "4/4",
                "1",
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
            const SizedBox(height: 10),
            Text(
              result,
              style: TextStyle(
                color: highlight ? accentBlue : Colors.white24,
                fontWeight: FontWeight.bold,
                fontSize: 26,
                fontFamily: 'monospace',
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
            child: Text(
              result,
              style: const TextStyle(
                color: accentGreen,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
              ),
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

  // Main Workspace/Canvas layout (No bottom equation card)
  Widget _buildCanvasArea() {
    return Stack(
      children: [
        // Background Grid (Static)
        Positioned.fill(child: CustomPaint(painter: GridPainter())),

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

        // Success Modal Layer - Wrap in scroll view for small screens
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
    );
  }

  Widget _buildSceneGraphics() {
    return SizedBox(
      width: 500,
      height: 300,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: const Size(500, 300),
            painter: AnglePainter(step: currentStep),
          ),
          // 60° Triangle Labels
          if ((currentStep >= 2 && currentStep <= 4) || currentStep >= 7) ...[
            const Positioned(
              left: 310,
              top: 120,
              child: Text(
                "1",
                style: TextStyle(
                  color: accentRed,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (currentStep >= 3 || currentStep >= 7)
              const Positioned(
                left: 360,
                top: 200,
                child: Text(
                  "√3/2",
                  style: TextStyle(
                    color: accentBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (currentStep >= 4 || currentStep >= 7)
              const Positioned(
                left: 280,
                top: 270,
                child: Text(
                  "1/2",
                  style: TextStyle(
                    color: accentGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
          // 30° Triangle Labels
          if ((currentStep >= 5 && currentStep <= 6) || currentStep >= 7) ...[
            const Positioned(
              left: 170,
              top: 150,
              child: Text(
                "1",
                style: TextStyle(
                  color: accentRed,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (currentStep >= 6 || currentStep >= 7)
              const Positioned(
                left: 235,
                top: 210,
                child: Text(
                  "1/2",
                  style: TextStyle(
                    color: accentBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (currentStep >= 7)
              const Positioned(
                left: 150,
                top: 270,
                child: Text(
                  "√3/2",
                  style: TextStyle(
                    color: accentGreen,
                    fontSize: 16,
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
          text: AppStrings.get(lang, 'btn_target_60'),
          color: accentPink,
          onPressed: () => advanceStep('msg_t60_ok'),
        );
      case 2:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_eval_sin60'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_sin60_ok'),
        );
      case 3:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_eval_cos60'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_cos60_ok'),
        );
      case 4:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_target_30'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_t30_ok'),
        );
      case 5:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_eval_sin30'),
          color: accentPink,
          onPressed: () => advanceStep('msg_sin30_ok'),
        );
      case 6:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_eval_cos30'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_cos30_ok'),
        );
      case 7:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_substitute'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_sub_ok'),
        );
      case 8:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_multiply'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_mult_ok'),
        );
      case 9:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_sum'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_final_ok'),
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

class AnglePainter extends CustomPainter {
  final int step;

  AnglePainter({required this.step});

  @override
  void paint(Canvas canvas, Size size) {
    Offset origin = const Offset(
      100,
      260,
    ); // Common origin for unit circle arcs
    double radius = 150.0;

    // 1. Draw Axis
    if (step >= 1) {
      final axisPaint = Paint()
        ..color = Colors.white30
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(origin.dx - 20, origin.dy),
        Offset(origin.dx + 350, origin.dy),
        axisPaint,
      ); // X
      canvas.drawLine(
        Offset(origin.dx, origin.dy + 20),
        Offset(origin.dx, origin.dy - 200),
        axisPaint,
      ); // Y

      final arcPaint = Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawArc(
        Rect.fromCircle(center: origin, radius: radius),
        0,
        -math.pi / 2,
        false,
        arcPaint,
      );
      canvas.drawCircle(origin, 4, Paint()..color = Colors.white);
    }

    // Helper to draw triangle

    // Logic for 60° Triangle (Steps 2-4, 7+)
    if ((step >= 2 && step <= 4) || step >= 7) {
      bool hlOpp = step == 3;
      bool hlAdj = step == 4;
      Offset shiftOrigin = step >= 7 ? const Offset(250, 260) : origin;

      if (step >= 7) {
        // Draw isolated axis for 60
        canvas.drawLine(
          Offset(shiftOrigin.dx, shiftOrigin.dy),
          Offset(shiftOrigin.dx + 150, shiftOrigin.dy),
          Paint()..color = Colors.white30,
        );
        canvas.drawLine(
          Offset(shiftOrigin.dx, shiftOrigin.dy),
          Offset(shiftOrigin.dx, shiftOrigin.dy - 150),
          Paint()..color = Colors.white30,
        );
      }

      double rad = 60 * math.pi / 180;
      double dx = radius * math.cos(rad);
      double dy = radius * math.sin(rad);
      Offset pCircle = Offset(shiftOrigin.dx + dx, shiftOrigin.dy - dy);
      Offset pBase = Offset(pCircle.dx, shiftOrigin.dy);

      Path path = Path()
        ..moveTo(shiftOrigin.dx, shiftOrigin.dy)
        ..lineTo(pBase.dx, pBase.dy)
        ..lineTo(pCircle.dx, pCircle.dy)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = accentPink.withOpacity(0.1)
          ..style = PaintingStyle.fill,
      );

      canvas.drawLine(
        shiftOrigin,
        pCircle,
        Paint()
          ..color = accentRed
          ..strokeWidth = 2,
      );
      canvas.drawLine(
        shiftOrigin,
        pBase,
        Paint()
          ..color = hlAdj ? accentGreen : Colors.white54
          ..strokeWidth = hlAdj ? 5 : 2,
      );
      canvas.drawLine(
        pBase,
        pCircle,
        Paint()
          ..color = hlOpp ? accentBlue : Colors.white54
          ..strokeWidth = hlOpp ? 5 : 2,
      );

      canvas.drawCircle(pCircle, 5, Paint()..color = accentPink);
      canvas.drawArc(
        Rect.fromCircle(center: shiftOrigin, radius: 30),
        0,
        -rad,
        true,
        Paint()
          ..color = accentPink.withOpacity(0.4)
          ..style = PaintingStyle.fill,
      );

      final textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = const TextSpan(
        text: "60°",
        style: TextStyle(
          color: accentPink,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          shiftOrigin.dx + 35 * math.cos(rad / 2) - 8,
          shiftOrigin.dy - 35 * math.sin(rad / 2) - 8,
        ),
      );
    }

    // Logic for 30° Triangle (Steps 5-6, 7+)
    if ((step >= 5 && step <= 6) || step >= 7) {
      bool hlOpp = step == 6;
      bool hlAdj = step == 7;

      Offset shiftOrigin = origin; // Keep at original origin

      double rad = 30 * math.pi / 180;
      double dx = radius * math.cos(rad);
      double dy = radius * math.sin(rad);
      Offset pCircle = Offset(shiftOrigin.dx + dx, shiftOrigin.dy - dy);
      Offset pBase = Offset(pCircle.dx, shiftOrigin.dy);

      Path path = Path()
        ..moveTo(shiftOrigin.dx, shiftOrigin.dy)
        ..lineTo(pBase.dx, pBase.dy)
        ..lineTo(pCircle.dx, pCircle.dy)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = accentYellow.withOpacity(0.1)
          ..style = PaintingStyle.fill,
      );

      canvas.drawLine(
        shiftOrigin,
        pCircle,
        Paint()
          ..color = accentRed
          ..strokeWidth = 2,
      );
      canvas.drawLine(
        shiftOrigin,
        pBase,
        Paint()
          ..color = hlAdj ? accentGreen : Colors.white54
          ..strokeWidth = hlAdj ? 5 : 2,
      );
      canvas.drawLine(
        pBase,
        pCircle,
        Paint()
          ..color = hlOpp ? accentBlue : Colors.white54
          ..strokeWidth = hlOpp ? 5 : 2,
      );

      canvas.drawCircle(pCircle, 5, Paint()..color = accentYellow);
      canvas.drawArc(
        Rect.fromCircle(center: shiftOrigin, radius: 40),
        0,
        -rad,
        true,
        Paint()
          ..color = accentYellow.withOpacity(0.4)
          ..style = PaintingStyle.fill,
      );

      final textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = const TextSpan(
        text: "30°",
        style: TextStyle(
          color: accentYellow,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          shiftOrigin.dx + 45 * math.cos(rad / 2) - 8,
          shiftOrigin.dy - 45 * math.sin(rad / 2) - 8,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant AnglePainter oldDelegate) {
    return oldDelegate.step != step;
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.0;

    const double step = 30;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
