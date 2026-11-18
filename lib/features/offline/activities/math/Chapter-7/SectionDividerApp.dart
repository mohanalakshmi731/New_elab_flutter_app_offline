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
      'app_title': 'THE SECTION DIVIDER',
      'tagline': 'The Section Formula',
      'init_btn': 'INITIALIZE SYSTEM',
      'header_title': 'The Section Divider',
      'header_subtitle': 'Class 10 • Coordinate Geometry',
      'phase_label': 'DIVISION PHASE',
      'step_label': 'Stage',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Section Secured',
      'success_desc':
          'You have successfully used the Section Formula to divide the segment.',
      'btn_restart': 'NEW MISSION',
      's0': 'Initialize Grid. Calibrating system.',
      's1': 'Locate Point A at (2, 4).',
      's2': 'Locate Point B at (10, 12).',
      's3': 'Establish segment AB.',
      's4': 'Set division ratio m:n to 1:3.',
      's5': 'Calculate the X-coordinate of P.',
      's6': 'Calculate the Y-coordinate of P.',
      's7': 'Plot the dividing point P(x, y).',
      's8': 'Change ratio m:n to 3:1.',
      's9': 'Recalculate and verify new point P.',
      'btn_start': 'ESTABLISH ORIGIN',
      'btn_loc_a': 'LOCATE POINT A (2,4)',
      'btn_loc_b': 'LOCATE POINT B (10,12)',
      'btn_draw_path': 'CONNECT SEGMENT',
      'btn_set_ratio1': 'SET RATIO 1:3',
      'btn_calc_x': 'CALCULATE X',
      'btn_calc_y': 'CALCULATE Y',
      'btn_plot_p': 'PLOT POINT P',
      'btn_set_ratio2': 'CHANGE RATIO 3:1',
      'btn_complete': 'FINALIZE REPORT',
      'msg_obs_ok': 'Grid active at Origin.',
      'msg_a_ok': 'Point A marked at (2,4).',
      'msg_b_ok': 'Point B marked at (10,12).',
      'msg_path_ok': 'Segment AB established.',
      'msg_ratio1_ok': 'Ratio m:n set to 1:3.',
      'msg_calc_x_ok': 'X-coordinate calculated.',
      'msg_calc_y_ok': 'Y-coordinate calculated.',
      'msg_plot_p_ok': 'Point P plotted at (4,6).',
      'msg_ratio2_ok': 'Ratio changed. P relocated to (8,10).',
      'msg_err': 'Calculation error.',

      // Data Collection Tabs Strings
      'data_collection': 'Data Collection',
      'awaiting_data': 'Awaiting system data...',
      'ratio_label': 'Division Ratio (m:n)',
      'x_coord_label': 'X-Coordinate (x)',
      'y_coord_label': 'Y-Coordinate (y)',
      'final_point_label': 'Dividing Point P',

      // Tooltips
      'menu_tooltip': 'Main Menu',
      'reset_tooltip': 'Reset',
      'back_tooltip': 'Go Back',
    },
    'hi': {
      'app_title': 'सेक्शन डिवाइडर',
      'tagline': 'विभाजन सूत्र (Section Formula)',
      'init_btn': 'सिस्टम प्रारंभ करें',
      'header_title': 'सेक्शन डिवाइडर',
      'header_subtitle': 'कक्षा 10 • निर्देशांक ज्यामिति',
      'phase_label': 'विभाजन चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'विभाजन सुरक्षित',
      'success_desc':
          'आपने खंड को विभाजित करने के लिए विभाजन सूत्र का सफलतापूर्वक उपयोग किया है।',
      'btn_restart': 'नया मिशन',
      's0': 'ग्रिड प्रारंभ करें। सिस्टम कैलिब्रेट किया जा रहा है।',
      's1': 'बिंदु A को (2, 4) पर खोजें।',
      's2': 'बिंदु B को (10, 12) पर खोजें।',
      's3': 'खंड AB स्थापित करें।',
      's4': 'विभाजन अनुपात m:n को 1:3 पर सेट करें।',
      's5': 'P के X-निर्देशांक की गणना करें।',
      's6': 'P के Y-निर्देशांक की गणना करें।',
      's7': 'विभाजित करने वाले बिंदु P(x, y) को प्लॉट करें।',
      's8': 'अनुपात m:n को 3:1 में बदलें।',
      's9': 'नए बिंदु P की गणना और सत्यापन करें।',
      'btn_start': 'मूल बिंदु स्थापित करें',
      'btn_loc_a': 'बिंदु A खोजें (2,4)',
      'btn_loc_b': 'बिंदु B खोजें (10,12)',
      'btn_draw_path': 'खंड कनेक्ट करें',
      'btn_set_ratio1': 'अनुपात 1:3 सेट करें',
      'btn_calc_x': 'X की गणना करें',
      'btn_calc_y': 'Y की गणना करें',
      'btn_plot_p': 'बिंदु P प्लॉट करें',
      'btn_set_ratio2': 'अनुपात 3:1 बदलें',
      'btn_complete': 'रिपोर्ट पूरी करें',
      'msg_obs_ok': 'ग्रिड सक्रिय।',
      'msg_a_ok': 'बिंदु A (2,4) पर चिह्नित।',
      'msg_b_ok': 'बिंदु B (10,12) पर चिह्नित।',
      'msg_path_ok': 'खंड AB स्थापित।',
      'msg_ratio1_ok': 'अनुपात m:n 1:3 पर सेट।',
      'msg_calc_x_ok': 'X-निर्देशांक की गणना की गई।',
      'msg_calc_y_ok': 'Y-निर्देशांक की गणना की गई।',
      'msg_plot_p_ok': 'बिंदु P (4,6) पर प्लॉट किया गया।',
      'msg_ratio2_ok': 'अनुपात बदल गया। P (8,10) पर स्थानांतरित।',
      'msg_err': 'गणना त्रुटि।',

      // Data Collection Tabs Strings
      'data_collection': 'डेटा संग्रह',
      'awaiting_data': 'सिस्टम डेटा की प्रतीक्षा...',
      'ratio_label': 'विभाजन अनुपात (m:n)',
      'x_coord_label': 'X-निर्देशांक (x)',
      'y_coord_label': 'Y-निर्देशांक (y)',
      'final_point_label': 'विभाजन बिंदु P',

      // Tooltips
      'menu_tooltip': 'मुख्य मेनू',
      'reset_tooltip': 'रीसेट करें',
      'back_tooltip': 'पीछे जाएं',
    },
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['en']![key] ?? key;
  }
}

class SectionDividerApp extends StatefulWidget {
  const SectionDividerApp({super.key});

  @override
  State<SectionDividerApp> createState() => _SectionDividerAppState();
}

class _SectionDividerAppState extends State<SectionDividerApp> {
  bool hasStarted = false;
  String lang = 'en';

  // यूआई स्टेट (UI State) - Mutually Exclusive Sidebars
  bool isLeftSidebarOpen = true;
  bool isRightSidebarOpen = false;

  // गतिविधि की स्थिति (Activity State)
  int currentStep = 0;
  bool showSuccessModal = false;

  // ज्यामिति की स्थिति (Geometry State)
  int ratioM = 1;
  int ratioN = 3;

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

        if (currentStep == 8) {
          ratioM = 3;
          ratioN = 1;
        }

        // Auto-open right panel during specific calculation steps if left is closed
        if (currentStep == 5 ||
            currentStep == 6 ||
            currentStep == 7 ||
            currentStep == 9) {
          if (!isLeftSidebarOpen && !isRightSidebarOpen) {
            isRightSidebarOpen = true;
          }
        }

        if (currentStep == 9) {
          playMathSuccess();
          Timer(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                showSuccessModal = true;
              });
              // 5 सेकंड बाद पॉपअप हटाएं
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
      ratioM = 1;
      ratioN = 3;
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
                      const Icon(Icons.call_split, size: 80, color: accentPink),
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

    // स्क्रीन की चौड़ाई प्राप्त करें (Get screen width for responsiveness)
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;
    // साइडबार की चौड़ाई - मोबाइल पर 85%, डेस्कटॉप पर 40% (Sidebar width)
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
            // मुख्य लेआउट: रो में साइडबार और कैनवास (Main Layout: Row with Sidebars and Canvas)
            Row(
              children: [
                // 1. लेफ्ट साइड पैनल (Left Side Panel Structure)
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

                // 2. कैनवास एरिया (Canvas Area)
                Expanded(child: _buildCanvasArea()),

                // 3. राइट साइड पैनल (Right Side Panel Structure for Data Collection)
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

            // 4. फ्लोटिंग मेनू बटन (टॉप-लेफ्ट) (Floating Menu Button - Top Left)
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

            // 5. फ्लोटिंग डेटा कलेक्शन बटन (बॉटम-राइट) (Floating Data Menu Button - Bottom Right)
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

            // 6. फ्लोटिंग बैक बटन (बॉटम-लेफ्ट) (Floating Back Button - Bottom Left)
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

  // लेफ्ट साइड पैनल का कंटेंट (Left Side Panel Content)
  Widget _buildLeftPanelContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 85, bottom: 85, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // हेडर, भाषा टॉगल और रिस्टार्ट
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
                child: const Icon(Icons.linear_scale, color: bgDark),
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

          // प्रोग्रेस और चरण
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
            "${AppStrings.get(lang, 'step_label')} ${currentStep + 1}/10",
            style: const TextStyle(
              color: accentBlue,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 15),
          LinearProgressIndicator(
            value: (currentStep + 1) / 10,
            backgroundColor: Colors.black38,
            color: accentPink,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),

          const SizedBox(height: 25),

          // मिशन लॉग हेडर
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

          // चरणों की सूची
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

          // निचले नियंत्रण
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

  // राइट साइड पैनल का कंटेंट (Right Side Data Collection Panel)
  Widget _buildRightPanelContent() {
    int x1 = 2, y1 = 4;
    int x2 = 10, y2 = 12;
    int m = ratioM;
    int n = ratioN;
    double pX = (m * x2 + n * x1) / (m + n);
    double pY = (m * y2 + n * y1) / (m + n);

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

          // Block 1: Ratio
          if (currentStep >= 4)
            _buildDataBlock(
              AppStrings.get(lang, 'ratio_label'),
              "m : n",
              "$m : $n",
              "",
              currentStep >= 4,
            )
          else
            _buildEmptyState(),

          const SizedBox(height: 20),

          // Block 2: X-Coord
          if (currentStep >= 5)
            _buildDataBlock(
              AppStrings.get(lang, 'x_coord_label'),
              "x = (m·x₂ + n·x₁) / (m + n)",
              "x = ($m×10 + $n×2) / ($m+$n)",
              "= ${pX.toStringAsFixed(0)}",
              currentStep >= 5,
            ),

          const SizedBox(height: 20),

          // Block 3: Y-Coord
          if (currentStep >= 6)
            _buildDataBlock(
              AppStrings.get(lang, 'y_coord_label'),
              "y = (m·y₂ + n·y₁) / (m + n)",
              "y = ($m×12 + $n×4) / ($m+$n)",
              "= ${pY.toStringAsFixed(0)}",
              currentStep >= 6,
            ),

          const SizedBox(height: 20),

          // Block 4: Final Point
          if (currentStep >= 7)
            _buildResultBlock(
              AppStrings.get(lang, 'final_point_label'),
              "P(x, y)",
              "P(${pX.toStringAsFixed(0)}, ${pY.toStringAsFixed(0)})",
            ),
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
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: accentPink,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            line1,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            line2,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 18,
              fontFamily: 'monospace',
            ),
          ),
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
        border: Border.all(color: accentGreen.withOpacity(0.3)),
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

  // मुख्य कार्यक्षेत्र/कैनवास लेआउट (Main Workspace/Canvas layout)
  Widget _buildCanvasArea() {
    return Stack(
      children: [
        // 1. इंटरैक्टिव, मूवेबल कैनवास (Interactive, Movable Canvas)
        Positioned.fill(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            boundaryMargin: const EdgeInsets.all(500),
            child: Center(
              child: SizedBox(
                width: 500,
                height: 380,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CustomPaint(
                      size: const Size(500, 380),
                      painter: SectionPainter(
                        step: currentStep,
                        ratioM: ratioM,
                        ratioN: ratioN,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 2. फ्लोटिंग मिशन कार्ड (Floating Mission Card - Shown only when Left Sidebar is closed)
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
                      const Icon(
                        Icons.track_changes,
                        color: accentBlue,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${AppStrings.get(lang, 'step_label')} ${currentStep + 1}/10",
                        style: const TextStyle(
                          color: accentBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppStrings.get(lang, 's$currentStep'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildControlsArea(),
                ],
              ),
            ),
          ),

        // 3. सफलता मॉडल (Success Modal Layer) - Wrap in scroll view for small screens
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
                          Icons.content_cut,
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
          text: AppStrings.get(lang, 'btn_loc_a'),
          color: accentPink,
          onPressed: () => advanceStep('msg_a_ok'),
        );
      case 2:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_loc_b'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_b_ok'),
        );
      case 3:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_draw_path'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_path_ok'),
        );
      case 4:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_set_ratio1'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_ratio1_ok'),
        );
      case 5:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_calc_x'),
          color: accentPink,
          onPressed: () => advanceStep('msg_calc_x_ok'),
        );
      case 6:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_calc_y'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_calc_y_ok'),
        );
      case 7:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_plot_p'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_plot_p_ok'),
        );
      case 8:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_set_ratio2'),
          color: accentPink,
          onPressed: () => advanceStep('msg_ratio2_ok'),
        );
      case 9:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_complete'),
          color: accentGreen,
          onPressed: () => advanceStep(''),
        );
      default:
        return const SizedBox();
    }
  }
}

// --- सब-विजेट्स (SUB-WIDGETS) ---

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

// --- कस्टम पेंटर (CUSTOM PAINTER) ---

class SectionPainter extends CustomPainter {
  final int step;
  final int ratioM;
  final int ratioN;

  // Coordinate System Mapping
  final double ox = 50.0; // Origin X
  final double oy = 350.0; // Origin Y
  final double scale =
      20.0; // Pixels per unit. Supports X up to 20, Y up to 16.

  SectionPainter({
    required this.step,
    required this.ratioM,
    required this.ratioN,
  });

  Offset _mapPt(double x, double y) {
    return Offset(ox + x * scale, oy - y * scale);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Grid Background
    final gridPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.0;

    // Vertical lines
    for (int i = 0; i <= 20; i++) {
      canvas.drawLine(
        _mapPt(i.toDouble(), 0),
        _mapPt(i.toDouble(), 16),
        gridPaint,
      );
    }
    // Horizontal lines
    for (int i = 0; i <= 16; i++) {
      canvas.drawLine(
        _mapPt(0, i.toDouble()),
        _mapPt(20, i.toDouble()),
        gridPaint,
      );
    }

    // 2. Draw Axes
    final axisPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 2.0;
    canvas.drawLine(_mapPt(0, 0), _mapPt(20, 0), axisPaint); // X
    canvas.drawLine(_mapPt(0, 0), _mapPt(0, 16), axisPaint); // Y

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    void drawText(
      String text,
      Offset pos,
      Color color, [
      double size = 12,
      FontWeight weight = FontWeight.normal,
    ]) {
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: weight,
          fontFamily: 'monospace',
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
      );
    }

    drawText("X", _mapPt(20.5, 0), Colors.white54, 14, FontWeight.bold);
    drawText("Y", _mapPt(0, 16.5), Colors.white54, 14, FontWeight.bold);

    for (int i = 2; i <= 18; i += 2) {
      drawText(i.toString(), _mapPt(i.toDouble(), -0.8), Colors.white30, 10);
    }
    for (int i = 2; i <= 14; i += 2) {
      drawText(i.toString(), _mapPt(-1.0, i.toDouble()), Colors.white30, 10);
    }

    // Coordinates
    double x1 = 2, y1 = 4;
    double x2 = 10, y2 = 12;
    double px = (ratioM * x2 + ratioN * x1) / (ratioM + ratioN);
    double py = (ratioM * y2 + ratioN * y1) / (ratioM + ratioN);

    // Show Origin when Grid is initialized
    if (step >= 1) {
      drawText("(0,0)", _mapPt(-1.5, -1), Colors.white, 12, FontWeight.bold);
      canvas.drawCircle(_mapPt(0, 0), 4, Paint()..color = Colors.white);
    }

    if (step >= 2) {
      // Draw A
      canvas.drawCircle(_mapPt(x1, y1), 6, Paint()..color = Colors.white);
      drawText(
        "A(2,4)",
        _mapPt(x1, y1 + 1.2),
        Colors.white,
        14,
        FontWeight.bold,
      );
    }

    if (step >= 3) {
      // Draw B
      canvas.drawCircle(_mapPt(x2, y2), 6, Paint()..color = Colors.white);
      drawText(
        "B(10,12)",
        _mapPt(x2, y2 + 1.2),
        Colors.white,
        14,
        FontWeight.bold,
      );
    }

    if (step >= 4) {
      // Draw Line AB (Full)
      final pathPaint = Paint()
        ..color = Colors.white54
        ..strokeWidth = 3;
      canvas.drawLine(_mapPt(x1, y1), _mapPt(x2, y2), pathPaint);
    }

    if (step >= 7) {
      // Draw Split Segments (Pink for m, Blue for n)
      final mPaint = Paint()
        ..color = accentPink
        ..strokeWidth = 4;
      final nPaint = Paint()
        ..color = accentBlue
        ..strokeWidth = 4;

      canvas.drawLine(_mapPt(x1, y1), _mapPt(px, py), mPaint);
      canvas.drawLine(_mapPt(px, py), _mapPt(x2, y2), nPaint);

      // Draw P
      canvas.drawCircle(_mapPt(px, py), 8, Paint()..color = accentGreen);
      canvas.drawCircle(_mapPt(px, py), 4, Paint()..color = Colors.black);
      drawText(
        "P(${px.toStringAsFixed(0)},${py.toStringAsFixed(0)})",
        _mapPt(px + 1.5, py - 1),
        accentGreen,
        16,
        FontWeight.bold,
      );

      // Ratio Labels (m and n) placed slightly above the lines
      Offset midM = _mapPt((x1 + px) / 2, (y1 + py) / 2);
      Offset midN = _mapPt((px + x2) / 2, (py + y2) / 2);

      // Perpendicular offset for text
      double dx = _mapPt(x2, y2).dx - _mapPt(x1, y1).dx;
      double dy = _mapPt(x2, y2).dy - _mapPt(x1, y1).dy;
      double len = math.sqrt(dx * dx + dy * dy);
      double nx = -dy / len * 15;
      double ny = dx / len * 15;

      drawText(
        "m=$ratioM",
        Offset(midM.dx + nx, midM.dy + ny),
        accentPink,
        14,
        FontWeight.bold,
      );
      drawText(
        "n=$ratioN",
        Offset(midN.dx + nx, midN.dy + ny),
        accentBlue,
        14,
        FontWeight.bold,
      );
    }

    // Optional projections to axes to show coordinate derivation
    if (step >= 5) {
      final dashP = Paint()
        ..color = accentGreen.withOpacity(0.4)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      _drawDashedLine(canvas, _mapPt(px, py), _mapPt(px, 0), dashP);
      canvas.drawCircle(_mapPt(px, 0), 4, Paint()..color = accentGreen);
      if (step < 7) {
        drawText(
          "x=${px.toStringAsFixed(0)}",
          _mapPt(px, -1.5),
          accentGreen,
          12,
          FontWeight.bold,
        );
      }
    }
    if (step >= 6) {
      final dashP = Paint()
        ..color = accentGreen.withOpacity(0.4)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      _drawDashedLine(canvas, _mapPt(px, py), _mapPt(0, py), dashP);
      canvas.drawCircle(_mapPt(0, py), 4, Paint()..color = accentGreen);
      if (step < 7) {
        drawText(
          "y=${py.toStringAsFixed(0)}",
          _mapPt(-1.5, py),
          accentGreen,
          12,
          FontWeight.bold,
        );
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const double dashWidth = 5, dashSpace = 5;
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
  bool shouldRepaint(covariant SectionPainter oldDelegate) {
    return oldDelegate.step != step ||
        oldDelegate.ratioM != ratioM ||
        oldDelegate.ratioN != ratioN;
  }
}

// --- साइडबार बटन विजेट्स (SIDEBAR BUTTON WIDGETS) ---

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
