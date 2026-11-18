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
      'app_title': 'THE COMPLEMENTARY SWITCH',
      'tagline': 'Trigonometric Ratios of Complementary Angles',
      'init_btn': 'INITIALIZE SWITCH',
      'header_title': 'The Complementary Switch',
      'header_subtitle': 'Class 10 • Intro to Trigonometry',
      'phase_label': 'ANALYSIS PHASE',
      'step_label': 'Stage',
      'mission_log': 'Console Log',
      'active_mission': 'CURRENT MISSION',
      'badge_title': 'Complementary Master',
      'success_desc':
          'You have successfully mapped the complementary trigonometric ratios.',
      'btn_restart': 'NEW ANALYSIS',
      's0': 'Initialize Grid. Calibrating right triangle.',
      's1': 'Identify Reference Angle θ at vertex A.',
      's2': 'Identify Complementary Angle (90°-θ) at vertex B.',
      's3': 'Analyze Sine of θ: sin(θ) = Opp / Hyp.',
      's4': 'Analyze Cosine of (90°-θ): cos(90°-θ) = Adj / Hyp.',
      's5': 'Compare the Ratios. Notice they share the same sides.',
      's6': 'Establish Rule: sin(θ) = cos(90°-θ).',
      's7': 'Analyze Tangent & Cotangent pair.',
      's8': 'Analyze Secant & Cosecant pair.',
      's9': 'Complementary mapping complete.',
      'btn_start': 'ESTABLISH ORIGIN',
      'btn_loc_theta': 'LOCATE ANGLE θ',
      'btn_loc_comp': 'LOCATE ANGLE (90°-θ)',
      'btn_eval_sin': 'EVALUATE SIN(θ)',
      'btn_eval_cos': 'EVALUATE COS(90°-θ)',
      'btn_compare': 'COMPARE RATIOS',
      'btn_rule1': 'ESTABLISH RULE',
      'btn_rule2': 'EVALUATE TAN & COT',
      'btn_rule3': 'EVALUATE SEC & COSEC',
      'btn_complete': 'FINALIZE ANALYSIS',
      'msg_obs_ok': 'Right Triangle ABC established.',
      'msg_theta_ok': 'Reference Angle θ marked at A.',
      'msg_comp_ok': 'Complementary Angle (90°-θ) marked at B.',
      'msg_sin_ok': 'Sine of θ evaluates to BC / AB.',
      'msg_cos_ok': 'Cosine of (90°-θ) evaluates to BC / AB.',
      'msg_compare_ok': 'Ratios are identical!',
      'msg_rule1_ok': 'Primary complementary rule established.',
      'msg_rule2_ok': 'Tangent and Cotangent relationships mapped.',
      'msg_rule3_ok': 'Secant and Cosecant relationships mapped.',
      'msg_final_ok': 'All complementary pairs verified.',
      'msg_err': 'Analysis error.',

      // Data Collection Tabs Strings
      'data_collection': 'Data Collection',
      'awaiting_data': 'Awaiting system data...',
      'primary_rule': 'Primary Rule (Sin/Cos)',
      'tangent_rule': 'Tangent / Cotangent',
      'secant_rule': 'Secant / Cosecant',
      'final_summary': 'Complementary Pairs',

      // Tooltips & Labels
      'menu_tooltip': 'Main Menu',
      'reset_tooltip': 'Reset',
      'back_tooltip': 'Go Back',
    },
    'hi': {
      'app_title': 'पूरक स्विच',
      'tagline': 'पूरक कोणों के त्रिकोणमितीय अनुपात',
      'init_btn': 'स्विच प्रारंभ करें',
      'header_title': 'पूरक स्विच',
      'header_subtitle': 'कक्षा 10 • त्रिकोणमिति का परिचय',
      'phase_label': 'विश्लेषण चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'पूरक मास्टर',
      'success_desc':
          'आपने पूरक त्रिकोणमितीय अनुपातों को सफलतापूर्वक मैप कर लिया है।',
      'btn_restart': 'नया विश्लेषण',
      's0': 'ग्रिड प्रारंभ करें। समकोण त्रिभुज कैलिब्रेट किया जा रहा है।',
      's1': 'शीर्ष A पर संदर्भ कोण θ को पहचानें।',
      's2': 'शीर्ष B पर पूरक कोण (90°-θ) को पहचानें।',
      's3': 'θ के साइन का विश्लेषण करें: sin(θ) = लंब / कर्ण।',
      's4': '(90°-θ) के कोसाइन का विश्लेषण करें: cos(90°-θ) = आधार / कर्ण।',
      's5':
          'अनुपातों की तुलना करें। ध्यान दें कि वे समान भुजाएं साझा करते हैं।',
      's6': 'नियम स्थापित करें: sin(θ) = cos(90°-θ)।',
      's7': 'टैंजेंट और कोटैंजेंट जोड़ी का विश्लेषण करें।',
      's8': 'सीकेंट और कोसीकेंट जोड़ी का विश्लेषण करें।',
      's9': 'पूरक मैपिंग पूर्ण।',
      'btn_start': 'मूल बिंदु स्थापित करें',
      'btn_loc_theta': 'कोण θ खोजें',
      'btn_loc_comp': 'कोण (90°-θ) खोजें',
      'btn_eval_sin': 'SIN(θ) का मूल्यांकन करें',
      'btn_eval_cos': 'COS(90°-θ) का मूल्यांकन करें',
      'btn_compare': 'अनुपात की तुलना करें',
      'btn_rule1': 'नियम स्थापित करें',
      'btn_rule2': 'TAN और COT का मूल्यांकन करें',
      'btn_rule3': 'SEC और COSEC का मूल्यांकन करें',
      'btn_complete': 'विश्लेषण पूरा करें',
      'msg_obs_ok': 'समकोण त्रिभुज ABC स्थापित।',
      'msg_theta_ok': 'संदर्भ कोण θ A पर चिह्नित।',
      'msg_comp_ok': 'पूरक कोण (90°-θ) B पर चिह्नित।',
      'msg_sin_ok': 'θ का साइन BC / AB का मूल्यांकन करता है।',
      'msg_cos_ok': '(90°-θ) का कोसाइन BC / AB का मूल्यांकन करता है।',
      'msg_compare_ok': 'अनुपात समान हैं!',
      'msg_rule1_ok': 'प्राथमिक पूरक नियम स्थापित।',
      'msg_rule2_ok': 'टैंजेंट और कोटैंजेंट संबंध मैप किए गए।',
      'msg_rule3_ok': 'सीकेंट और कोसीकेंट संबंध मैप किए गए।',
      'msg_final_ok': 'सभी पूरक जोड़े सत्यापित।',
      'msg_err': 'विश्लेषण त्रुटि।',

      // Data Collection Tabs Strings
      'data_collection': 'डेटा संग्रह',
      'awaiting_data': 'सिस्टम डेटा की प्रतीक्षा...',
      'primary_rule': 'प्राथमिक नियम (Sin/Cos)',
      'tangent_rule': 'टैंजेंट / कोटैंजेंट',
      'secant_rule': 'सीकेंट / कोसीकेंट',
      'final_summary': 'पूरक जोड़े',

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

class ComplementarySwitchApp extends StatefulWidget {
  const ComplementarySwitchApp({super.key});

  @override
  State<ComplementarySwitchApp> createState() => _ComplementarySwitchAppState();
}

class _ComplementarySwitchAppState extends State<ComplementarySwitchApp> {
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
                  color: bgDark,
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
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void advanceStep(String msgKey) {
    if (currentStep < 9) {
      playMathClick();
      setState(() {
        currentStep++;
        if (msgKey.isNotEmpty) {
          showToast(AppStrings.get(lang, msgKey));
        }

        // Auto-open right panel during specific calculation steps if left is closed
        if (currentStep == 4 || currentStep == 5 || currentStep >= 7) {
          if (!isLeftSidebarOpen && !isRightSidebarOpen) {
            isRightSidebarOpen = true;
          }
        }

        if (currentStep == 9) {
          playMathSuccess();
          Timer(const Duration(seconds: 1), () {
            if (mounted) {
              setState(() {
                showSuccessModal = true;
              });

              Timer(const Duration(seconds: 5), () {
                if (mounted) {
                  setState(() {
                    showSuccessModal = false;
                  });
                }
              });
            }
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
                      const Icon(Icons.swap_calls, size: 80, color: accentPink),
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
                child: const Icon(Icons.compare_arrows, color: bgDark),
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
      padding: const EdgeInsets.only(top: 85, bottom: 85, left: 20, right: 20),
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

          if (currentStep < 3)
            _buildEmptyState()
          else ...[
            // Primary Rule Block (Sin / Cos)
            if (currentStep >= 3)
              _buildEquationBlock(
                AppStrings.get(lang, 'primary_rule'),
                "sin(θ) = BC / AB",
                currentStep >= 4 ? "cos(90°-θ) = BC / AB" : "cos(90°-θ) = ...",
                currentStep >= 5 ? "sin(θ) = cos(90°-θ)" : "",
                currentStep >= 5,
              ),

            const SizedBox(height: 20),

            // Tangent Rule Block
            if (currentStep >= 7)
              _buildEquationBlock(
                AppStrings.get(lang, 'tangent_rule'),
                "tan(θ) = BC / AC",
                "cot(90°-θ) = BC / AC",
                "tan(θ) = cot(90°-θ)",
                true,
              ),

            const SizedBox(height: 20),

            // Secant Rule Block
            if (currentStep >= 8)
              _buildEquationBlock(
                AppStrings.get(lang, 'secant_rule'),
                "sec(θ) = AB / AC",
                "cosec(90°-θ) = AB / AC",
                "sec(θ) = cosec(90°-θ)",
                true,
              ),

            const SizedBox(height: 20),

            // Final Summary
            if (currentStep >= 9)
              _buildSummaryBlock(AppStrings.get(lang, 'final_summary')),
          ],
        ],
      ),
    );
  }

  // Helper Widget for Data/Equation Blocks
  Widget _buildEquationBlock(
    String title,
    String eq1,
    String eq2,
    String result,
    bool isComplete,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isComplete ? accentBlue : Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isComplete ? accentBlue : accentPink,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            eq1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'monospace',
            ),
          ),
          if (eq2.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              eq2,
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

  // Helper Widget for Final Summary Block
  Widget _buildSummaryBlock(String title) {
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
          _buildEqualityLine("sin(θ)", "cos(90°-θ)"),
          const SizedBox(height: 10),
          _buildEqualityLine("tan(θ)", "cot(90°-θ)"),
          const SizedBox(height: 10),
          _buildEqualityLine("sec(θ)", "cosec(90°-θ)"),
        ],
      ),
    );
  }

  Widget _buildEqualityLine(String left, String right) {
    return Row(
      children: [
        Text(
          left,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'monospace',
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "=",
            style: TextStyle(
              color: accentYellow,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          right,
          style: const TextStyle(
            color: accentGreen,
            fontSize: 18,
            fontFamily: 'monospace',
          ),
        ),
      ],
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
            painter: ComplementaryPainter(step: currentStep),
          ),

          if (currentStep >= 0) ...[
            const Positioned(
              left: 80,
              top: 290,
              child: Text(
                "A",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Positioned(
              left: 360,
              top: 290,
              child: Text(
                "C",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Positioned(
              left: 360,
              top: 50,
              child: Text(
                "B",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],

          if (currentStep >= 1) ...[
            const Positioned(
              left: 140,
              top: 255,
              child: Text(
                "θ",
                style: TextStyle(
                  color: accentBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],

          if (currentStep >= 2) ...[
            const Positioned(
              left: 310,
              top: 120,
              child: Text(
                "90°-θ",
                style: TextStyle(
                  color: accentGreen,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],

          // Dynamic Side Labels
          if (currentStep >= 3) ...[
            Positioned(
              left: 200,
              top: 150,
              child: Transform.rotate(
                angle: -0.67,
                child: Text(
                  "Hypotenuse (AB)",
                  style: TextStyle(
                    color:
                        (currentStep >= 3 && currentStep <= 6) ||
                            currentStep == 8
                        ? accentYellow
                        : Colors.white54,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],

          if (currentStep >= 3) ...[
            Positioned(
              left: 360,
              top: 180,
              child: Text(
                currentStep == 3
                    ? "Opposite"
                    : (currentStep == 4 ? "Adjacent" : "Side BC"),
                style: TextStyle(
                  color: (currentStep >= 3 && currentStep <= 7)
                      ? accentPink
                      : Colors.white54,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],

          if (currentStep >= 7) ...[
            Positioned(
              left: 200,
              top: 290,
              child: Text(
                "Side AC",
                style: TextStyle(
                  color: currentStep >= 7 ? accentPink : Colors.white54,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
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
          text: AppStrings.get(lang, 'btn_loc_theta'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_theta_ok'),
        );
      case 2:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_loc_comp'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_comp_ok'),
        );
      case 3:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_eval_sin'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_sin_ok'),
        );
      case 4:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_eval_cos'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_cos_ok'),
        );
      case 5:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_compare'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_compare_ok'),
        );
      case 6:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_rule1'),
          color: accentPink,
          onPressed: () => advanceStep('msg_rule1_ok'),
        );
      case 7:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_rule2'),
          color: accentPink,
          onPressed: () => advanceStep('msg_rule2_ok'),
        );
      case 8:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_rule3'),
          color: accentPink,
          onPressed: () => advanceStep('msg_rule3_ok'),
        );
      case 9:
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

class ComplementaryPainter extends CustomPainter {
  final int step;

  ComplementaryPainter({required this.step});

  @override
  void paint(Canvas canvas, Size size) {
    // Triangle Coordinates
    Offset pA = const Offset(100, 280);
    Offset pC = const Offset(350, 280); // Right Angle
    Offset pB = const Offset(350, 80); // Top Vertex

    if (step >= 0) {
      // Base Triangle
      final triPaint = Paint()
        ..color = Colors.white54
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      Path pathTri = Path()
        ..moveTo(pA.dx, pA.dy)
        ..lineTo(pC.dx, pC.dy)
        ..lineTo(pB.dx, pB.dy)
        ..close();
      canvas.drawPath(pathTri, triPaint);

      // Points
      final pointPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pA, 4, pointPaint);
      canvas.drawCircle(pC, 4, pointPaint);
      canvas.drawCircle(pB, 4, pointPaint);

      // Right Angle Square at C
      _drawRightAngle(canvas, pC, -1, -1, Colors.white);
    }

    if (step >= 1) {
      // Theta Arc at A
      final arcPaintA = Paint()
        ..color = accentBlue.withOpacity(0.5)
        ..style = PaintingStyle.fill;

      double radiusA = 50.0;
      double angleA = math.atan2(pB.dy - pA.dy, pB.dx - pA.dx);

      canvas.drawArc(
        Rect.fromCircle(center: pA, radius: radiusA),
        0,
        angleA,
        true,
        arcPaintA,
      );

      canvas.drawArc(
        Rect.fromCircle(center: pA, radius: radiusA),
        0,
        angleA,
        false,
        Paint()
          ..color = accentBlue
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }

    if (step >= 2) {
      // 90-Theta Arc at B
      final arcPaintB = Paint()
        ..color = accentGreen.withOpacity(0.5)
        ..style = PaintingStyle.fill;

      double radiusB = 50.0;
      double angleBC = math.pi / 2;
      double angleBA = math.atan2(pA.dy - pB.dy, pA.dx - pB.dx);

      canvas.drawArc(
        Rect.fromCircle(center: pB, radius: radiusB),
        angleBA,
        angleBC - angleBA,
        true,
        arcPaintB,
      );

      canvas.drawArc(
        Rect.fromCircle(center: pB, radius: radiusB),
        angleBA,
        angleBC - angleBA,
        false,
        Paint()
          ..color = accentGreen
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }

    // Dynamic Side Highlighting
    if (step >= 3) {
      Paint highlightPaint = Paint()
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round;

      if (step == 3) {
        // Sin(theta) Focus: BC and AB
        highlightPaint.color = accentBlue.withOpacity(0.8);
        canvas.drawLine(pB, pC, highlightPaint);
        canvas.drawLine(pA, pB, highlightPaint);
      } else if (step == 4) {
        // Cos(90-theta) Focus: BC and AB
        highlightPaint.color = accentGreen.withOpacity(0.8);
        canvas.drawLine(pB, pC, highlightPaint);
        canvas.drawLine(pA, pB, highlightPaint);
      } else if (step == 5 || step == 6) {
        // Comparison
        highlightPaint.color = accentPink.withOpacity(0.8);
        canvas.drawLine(pB, pC, highlightPaint);
        canvas.drawLine(pA, pB, highlightPaint);
      } else if (step == 7) {
        // Tan/Cot Focus: BC and AC
        highlightPaint.color = accentPink.withOpacity(0.8);
        canvas.drawLine(pB, pC, highlightPaint);
        canvas.drawLine(pA, pC, highlightPaint);
      } else if (step == 8) {
        // Sec/Cosec Focus: AB and AC
        highlightPaint.color = accentPink.withOpacity(0.8);
        canvas.drawLine(pA, pB, highlightPaint);
        canvas.drawLine(pA, pC, highlightPaint);
      }
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

  @override
  bool shouldRepaint(covariant ComplementaryPainter oldDelegate) {
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
    // Extend grid over a large area (for panning/zooming)
    for (double i = -3000; i < 3000; i += step) {
      canvas.drawLine(Offset(i, -3000), Offset(i, 3000), paint);
    }
    for (double i = -3000; i < 3000; i += step) {
      canvas.drawLine(Offset(-3000, i), Offset(3000, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
