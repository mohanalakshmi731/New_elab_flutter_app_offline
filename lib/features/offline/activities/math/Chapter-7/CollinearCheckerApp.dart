// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:elab_app/features/offline/activities/math_activity_audio.dart';

const Color bgDark = Color(0xFF020617);
const Color bgPanel = Color(0xFF0F172A);
const Color accentPink = Color(0xFFF472B6);
const Color accentBlue = Color(0xFF3B82F6);
const Color accentGreen = Color(0xFF22C55E);
const Color accentRed = Color(0xFFEF4444);
const Color accentYellow = Color(0xFFFACC15);

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CollinearCheckerApp(),
    ),
  );
}

class AppStrings {
  static const Map<String, Map<String, String>> data = {
    'en': {
      'app_title': 'THE COLLINEAR CHECKER',
      'tagline': 'Verifying Collinearity via Area',
      'init_btn': 'INITIALIZE CHECKER',
      'header_title': 'The Collinear Checker',
      'header_subtitle': 'Class 10 • Coordinate Geometry',
      'phase_label': 'VERIFICATION PHASE',
      'step_label': 'Stage',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Collinearity Verified',
      'success_desc':
          'You have successfully proven that the three points lie on a straight line.',
      'btn_restart': 'NEW VERIFICATION',
      's0': 'Initialize Grid. Calibrating system.',
      's1': 'Locate Point A at (2, 4).',
      's2': 'Locate Point B at (6, 8).',
      's3': 'Locate Point C at (10, 12).',
      's4': 'Connect Points A, B, and C.',
      's5': 'Load Triangle Area Formula.',
      's6': 'Substitute coordinates into formula.',
      's7': 'Calculate inner terms (y-differences).',
      's8': 'Sum the products.',
      's9': 'Verify Area = 0. Points are Collinear.',
      'btn_start': 'ESTABLISH ORIGIN',
      'btn_loc_a': 'LOCATE A (2,4)',
      'btn_loc_b': 'LOCATE B (6,8)',
      'btn_loc_c': 'LOCATE C (10,12)',
      'btn_draw_area': 'CONNECT POINTS',
      'btn_formula': 'LOAD FORMULA',
      'btn_substitute': 'SUBSTITUTE VALUES',
      'btn_calc_inner': 'CALCULATE INNER TERMS',
      'btn_sum': 'SUM PRODUCTS',
      'btn_complete': 'VERIFY COLLINEARITY',
      'msg_obs_ok': 'Grid active at Origin.',
      'msg_a_ok': 'Point A marked at (2,4).',
      'msg_b_ok': 'Point B marked at (6,8).',
      'msg_c_ok': 'Point C marked at (10,12).',
      'msg_area_ok': 'Points connected. A single line is formed.',
      'msg_form_ok': 'Formula loaded into memory.',
      'msg_sub_ok': 'Coordinate substitution complete.',
      'msg_calc_inner_ok': 'Inner y-differences calculated.',
      'msg_sum_ok': 'Summation complete. Net sum is 0.',
      'msg_final_ok': 'Area is 0. Points are collinear!',
      'msg_err': 'Calculation error.',
      'calc_title': 'DATA COLLECTION',
      'awaiting_data': 'Awaiting formula selection...',
      'tooltip_menu': 'Mission Controls',
      'tooltip_data': 'Calculations',
    },
    'hi': {
      'app_title': 'संरेख चेकर',
      'tagline': 'क्षेत्रफल के माध्यम से संरेखता की जाँच',
      'init_btn': 'चेकर प्रारंभ करें',
      'header_title': 'संरेख चेकर',
      'header_subtitle': 'कक्षा 10 • निर्देशांक ज्यामिति',
      'phase_label': 'सत्यापन चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'संरेखता सत्यापित',
      'success_desc':
          'आपने सफलतापूर्वक सिद्ध कर दिया है कि तीनों बिंदु एक सीधी रेखा पर स्थित हैं।',
      'btn_restart': 'नया सत्यापन',
      's0': 'ग्रिड प्रारंभ करें। सिस्टम कैलिब्रेट किया जा रहा है।',
      's1': 'बिंदु A को (2, 4) पर खोजें।',
      's2': 'बिंदु B को (6, 8) पर खोजें।',
      's3': 'बिंदु C को (10, 12) पर खोजें।',
      's4': 'बिंदु A, B और C को कनेक्ट करें।',
      's5': 'त्रिभुज क्षेत्रफल सूत्र लोड करें।',
      's6': 'सूत्र में निर्देशांकों को प्रतिस्थापित करें।',
      's7': 'आंतरिक पदों (y-अंतर) की गणना करें।',
      's8': 'गुणनफलों का योग करें।',
      's9': 'जाँचें कि क्षेत्रफल = 0. बिंदु संरेख हैं।',
      'btn_start': 'मूल बिंदु स्थापित करें',
      'btn_loc_a': 'A खोजें (2,4)',
      'btn_loc_b': 'B खोजें (6,8)',
      'btn_loc_c': 'C खोजें (10,12)',
      'btn_draw_area': 'बिंदु कनेक्ट करें',
      'btn_formula': 'सूत्र लोड करें',
      'btn_substitute': 'मान प्रतिस्थापित करें',
      'btn_calc_inner': 'आंतरिक पदों की गणना करें',
      'btn_sum': 'गुणनफलों का योग',
      'btn_complete': 'संरेखता सत्यापित करें',
      'msg_obs_ok': 'ग्रिड सक्रिय।',
      'msg_a_ok': 'बिंदु A (2,4) पर चिह्नित।',
      'msg_b_ok': 'बिंदु B (6,8) पर चिह्नित।',
      'msg_c_ok': 'बिंदु C (10,12) पर चिह्नित।',
      'msg_area_ok': 'बिंदु जुड़े हुए हैं। एक रेखा बनती है।',
      'msg_form_ok': 'सूत्र मेमोरी में लोड किया गया।',
      'msg_sub_ok': 'निर्देशांक प्रतिस्थापन पूर्ण।',
      'msg_calc_inner_ok': 'आंतरिक y-अंतरों की गणना की गई।',
      'msg_sum_ok': 'योग पूर्ण। शुद्ध योग 0 है।',
      'msg_final_ok': 'क्षेत्रफल 0 है। बिंदु संरेख हैं!',
      'msg_err': 'गणना त्रुटि।',
      'calc_title': 'डेटा संग्रह',
      'awaiting_data': 'सूत्र चयन की प्रतीक्षा में...',
      'tooltip_menu': 'मिशन नियंत्रण',
      'tooltip_data': 'गणना',
    },
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['en']![key] ?? key;
  }
}

class CollinearCheckerApp extends StatefulWidget {
  const CollinearCheckerApp({super.key});

  @override
  State<CollinearCheckerApp> createState() => _CollinearCheckerAppState();
}

class _CollinearCheckerAppState extends State<CollinearCheckerApp> {
  bool hasStarted = false;
  String lang = 'en';

  bool leftPanelOpen = true;
  bool rightPanelOpen = false;

  int currentStep = 0;
  bool showSuccessModal = false;

  void startGame() {
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

  void toggleLeftPanel() {
    playMathClick();
    setState(() {
      leftPanelOpen = !leftPanelOpen;
      if (leftPanelOpen) rightPanelOpen = false;
    });
  }

  void toggleRightPanel() {
    playMathClick();
    setState(() {
      rightPanelOpen = !rightPanelOpen;
      if (rightPanelOpen) leftPanelOpen = false;
    });
  }

  @override
  void initState() {
    super.initState();
    startGame();
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
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: bgPanel.withOpacity(0.9),
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

        if (currentStep == 5 && !rightPanelOpen) {
          leftPanelOpen = false;
          rightPanelOpen = true;
        }

        if (currentStep == 9) {
          playMathSuccess();
          Timer(const Duration(seconds: 2), () {
            if (!mounted) return;
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
      leftPanelOpen = true;
      rightPanelOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!hasStarted) {
      return Scaffold(
        backgroundColor: bgDark,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timeline, size: 80, color: accentPink),
              const SizedBox(height: 20),
              Text(
                AppStrings.get(lang, 'app_title'),
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
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: accentBlue),
                onPressed: () {
                  playMathStart();
                  startGame();
                },
                icon: const Icon(
                  Icons.play_arrow,
                  size: 28,
                  color: Colors.white,
                ),
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
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double panelWidth = screenWidth * 0.45;
    if (panelWidth < 350) panelWidth = 350;
    if (panelWidth > 500) panelWidth = 500;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: bgDark,
        body: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: leftPanelOpen ? panelWidth : 0,
              right: rightPanelOpen ? panelWidth : 0,
              top: 0,
              bottom: 0,
              child: InteractiveViewer(
                panEnabled: true,
                scaleEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                boundaryMargin: const EdgeInsets.all(500),
                child: Center(
                  child: SizedBox(
                    width: 800,
                    height: 600,
                    child: _buildSceneGraphics(),
                  ),
                ),
              ),
            ),

            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: leftPanelOpen ? 0 : -panelWidth,
              top: 0,
              bottom: 0,
              width: panelWidth,
              child: _buildLeftPanel(panelWidth),
            ),

            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              right: rightPanelOpen ? 0 : -panelWidth,
              top: 0,
              bottom: 0,
              width: panelWidth,
              child: _buildRightPanel(panelWidth),
            ),

            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 90,
              left: leftPanelOpen ? -350 : 20,
              child: IgnorePointer(
                ignoring: leftPanelOpen,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: leftPanelOpen ? 0.0 : 1.0,
                  child: _buildFloatingMissionCard(),
                ),
              ),
            ),

            if (showSuccessModal) Positioned.fill(child: _buildSuccessModal()),

            Positioned(
              top: 20,
              left: 20,
              child: _buildFloatingActionBtn(
                icon: leftPanelOpen ? Icons.close : Icons.menu,
                color: accentPink,
                tooltip: AppStrings.get(lang, 'tooltip_menu'),
                onTap: toggleLeftPanel,
              ),
            ),

            // Positioned(
            //   bottom: 20,
            //   left: 20,
            //   child: _buildFloatingActionBtn(
            //     icon: Icons.arrow_back,
            //     color: Colors.white,
            //     tooltip: 'Go Back',
            //     onTap: () {
            //       Navigator.of(context).pop();
            //     },
            //   ),
            // ),
            Positioned(
              bottom: 20,
              right: 20,
              child: _buildFloatingActionBtn(
                icon: rightPanelOpen ? Icons.close : Icons.analytics_outlined,
                color: accentYellow,
                tooltip: AppStrings.get(lang, 'tooltip_data'),
                onTap: toggleRightPanel,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---  (Left Side Panel) ---
  Widget _buildLeftPanel(double width) {
    return Container(
      width: width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: bgPanel,
        border: Border(right: BorderSide(color: Colors.white12, width: 2)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(
                top: 80,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: accentBlue.withOpacity(0.3)),
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
                        decoration: BoxDecoration(
                          color: accentPink,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.linear_scale, color: bgDark),
                      ),
                      const SizedBox(width: 15),

                      Column(
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
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
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
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.power_settings_new),
                        color: Colors.white54,
                        onPressed: resetLab,
                        tooltip: 'Reset',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.get(lang, 'phase_label'),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${AppStrings.get(lang, 'step_label')} ${currentStep + 1}/10",
                        style: const TextStyle(
                          color: accentBlue,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: (currentStep + 1) / 10,
                    backgroundColor: Colors.black38,
                    color: accentPink,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ],
              ),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 20, left: 20, bottom: 20),
              decoration: const BoxDecoration(color: Colors.white10),
              child: Text(
                AppStrings.get(lang, 'mission_log').toUpperCase(),
                style: const TextStyle(
                  color: accentPink,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Container(
              color: Colors.black26,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 10,
                itemBuilder: (context, index) {
                  bool isActive = index == currentStep;
                  bool isDone = index < currentStep;
                  return Container(
                    padding: const EdgeInsets.only(
                      top: 20,
                      left: 20,
                      right: 20,
                      bottom: 20,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? accentPink.withOpacity(0.1)
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
                            ? Colors.white54
                            : Colors.white30,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: 80,
              ),
              decoration: const BoxDecoration(
                color: Colors.black45,
                border: Border(top: BorderSide(color: Colors.white12)),
              ),
              child: _buildControlsArea(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightPanel(double width) {
    return Container(
      width: width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: bgPanel,
        border: Border(left: BorderSide(color: Colors.white12, width: 2)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 40, 80, 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: accentYellow.withOpacity(0.3)),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.analytics, color: accentYellow, size: 28),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      AppStrings.get(lang, 'calc_title'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: double.infinity,
              color: bgDark.withOpacity(0.5),
              padding: const EdgeInsets.fromLTRB(20, 20, 80, 20),
              child: currentStep >= 5
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Triangle Area Formula",
                          style: TextStyle(
                            color: accentPink,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildCalcRow(
                          "Area = ½ | x₁(y₂ - y₃) + x₂(y₃ - y₁) + x₃(y₁ - y₂) |",
                          Colors.white,
                          currentStep >= 5,
                        ),
                        const SizedBox(height: 15),

                        if (currentStep >= 6) ...[
                          _buildCalcRow(
                            "Substitute A(2,4), B(6,8), C(10,12)",
                            Colors.white54,
                            false,
                            isSub: true,
                          ),
                          _buildCalcRow(
                            "Area = ½ | 2(8 - 12) + 6(12 - 4) + 10(4 - 8) |",
                            accentBlue,
                            true,
                          ),
                          const SizedBox(height: 15),
                        ],

                        if (currentStep >= 7) ...[
                          _buildCalcRow(
                            "Calculate Differences",
                            Colors.white54,
                            false,
                            isSub: true,
                          ),
                          _buildCalcRow(
                            "Area = ½ | 2(-4) + 6(8) + 10(-4) |",
                            accentGreen,
                            true,
                          ),
                          const SizedBox(height: 15),
                        ],

                        if (currentStep >= 8) ...[
                          _buildCalcRow(
                            "Sum the Products",
                            Colors.white54,
                            false,
                            isSub: true,
                          ),
                          _buildCalcRow(
                            "Area = ½ | -8 + 48 - 40 |",
                            accentYellow,
                            true,
                          ),
                          const SizedBox(height: 15),
                        ],

                        if (currentStep >= 9) ...[
                          _buildCalcRow(
                            "Final Result",
                            Colors.white54,
                            false,
                            isSub: true,
                          ),
                          _buildCalcRow("Area = ½ | 0 |", Colors.white70, true),
                          const SizedBox(height: 5),
                          const Text(
                            "= 0",
                            style: TextStyle(
                              color: accentGreen,
                              fontSize: 36,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: accentGreen.withOpacity(0.1),
                              border: Border.all(color: accentGreen),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              AppStrings.get(lang, 'msg_final_ok'),
                              style: const TextStyle(
                                color: accentGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(vertical: 80),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.lock_clock,
                            color: Colors.white24,
                            size: 50,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            AppStrings.get(lang, 'awaiting_data'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white30,
                              fontStyle: FontStyle.italic,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalcRow(
    String text,
    Color color,
    bool isBold, {
    bool isSub = false,
  }) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: isSub ? 12 : 16,
        fontFamily: isSub ? null : 'monospace',
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildFloatingActionBtn({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgPanel.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.5)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        color: color,
        iconSize: 28,
        onPressed: onTap,
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildFloatingMissionCard() {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgPanel.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentPink.withOpacity(0.5)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.get(lang, 'active_mission').toUpperCase(),
                style: const TextStyle(
                  color: accentPink,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
          const SizedBox(height: 12),
          Text(
            AppStrings.get(lang, 's$currentStep'),
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 20),
          _buildControlsArea(),
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
          text: AppStrings.get(lang, 'btn_loc_c'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_c_ok'),
        );
      case 4:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_draw_area'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_area_ok'),
        );
      case 5:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_formula'),
          color: accentPink,
          onPressed: () => advanceStep('msg_form_ok'),
        );
      case 6:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_substitute'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_sub_ok'),
        );
      case 7:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_calc_inner'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_calc_inner_ok'),
        );
      case 8:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_sum'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_sum_ok'),
        );
      case 9:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_complete'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_final_ok'),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildSceneGraphics() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CustomPaint(
          size: const Size(800, 600),
          painter: CollinearPainter(step: currentStep),
        ),
      ],
    );
  }

  Widget _buildSuccessModal() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: bgDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentGreen, width: 2),
            boxShadow: [
              BoxShadow(color: accentGreen.withOpacity(0.3), blurRadius: 40),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: accentGreen,
                size: 80,
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.get(lang, 'badge_title').toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                AppStrings.get(lang, 'success_desc'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}

class CollinearPainter extends CustomPainter {
  final int step;
  final double ox = 150.0; // Origin X
  final double oy = 500.0; // Origin Y
  final double scale = 30.0; // पिक्सल प्रति यूनिट

  CollinearPainter({required this.step});

  Offset _mapPt(double x, double y) {
    return Offset(ox + x * scale, oy - y * scale);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (step >= 1) {
      final gridPaint = Paint()
        ..color = const Color(0xFF1E293B)
        ..strokeWidth = 1.0;

      for (int i = -2; i <= 20; i++) {
        canvas.drawLine(
          _mapPt(i.toDouble(), -2),
          _mapPt(i.toDouble(), 18),
          gridPaint,
        );
      }
      for (int i = -2; i <= 18; i++) {
        canvas.drawLine(
          _mapPt(-2, i.toDouble()),
          _mapPt(20, i.toDouble()),
          gridPaint,
        );
      }

      final axisPaint = Paint()
        ..color = Colors.white54
        ..strokeWidth = 2.0;
      canvas.drawLine(_mapPt(-2, 0), _mapPt(20, 0), axisPaint); // X
      canvas.drawLine(_mapPt(0, -2), _mapPt(0, 18), axisPaint); // Y

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
          Offset(
            pos.dx - textPainter.width / 2,
            pos.dy - textPainter.height / 2,
          ),
        );
      }

      drawText("X", _mapPt(20.5, 0), Colors.white54, 14, FontWeight.bold);
      drawText("Y", _mapPt(0, 18.5), Colors.white54, 14, FontWeight.bold);

      for (int i = 2; i <= 18; i += 2) {
        drawText(i.toString(), _mapPt(i.toDouble(), -0.8), Colors.white30, 10);
      }
      for (int i = 2; i <= 16; i += 2) {
        drawText(i.toString(), _mapPt(-1.0, i.toDouble()), Colors.white30, 10);
      }

      double x1 = 2, y1 = 4;
      double x2 = 6, y2 = 8;
      double x3 = 10, y3 = 12;

      drawText("(0,0)", _mapPt(-1.5, -1), Colors.white, 12, FontWeight.bold);
      canvas.drawCircle(_mapPt(0, 0), 4, Paint()..color = Colors.white);

      if (step >= 5) {
        final strokePaint = Paint()
          ..color = accentGreen
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;
        Path triPath = Path()
          ..moveTo(_mapPt(x1, y1).dx, _mapPt(x1, y1).dy)
          ..lineTo(_mapPt(x2, y2).dx, _mapPt(x2, y2).dy)
          ..lineTo(_mapPt(x3, y3).dx, _mapPt(x3, y3).dy);
        canvas.drawPath(triPath, strokePaint);
      }

      if (step >= 2) {
        canvas.drawCircle(_mapPt(x1, y1), 8, Paint()..color = accentPink);
        drawText(
          "A(2,4)",
          _mapPt(x1 + 1, y1 - 0.8),
          accentPink,
          14,
          FontWeight.bold,
        );
      }

      if (step >= 3) {
        canvas.drawCircle(_mapPt(x2, y2), 8, Paint()..color = accentBlue);
        drawText(
          "B(6,8)",
          _mapPt(x2 + 1, y2 - 0.8),
          accentBlue,
          14,
          FontWeight.bold,
        );
      }

      if (step >= 4) {
        canvas.drawCircle(_mapPt(x3, y3), 8, Paint()..color = accentYellow);
        drawText(
          "C(10,12)",
          _mapPt(x3 + 1.2, y3 - 0.8),
          accentYellow,
          14,
          FontWeight.bold,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CollinearPainter oldDelegate) {
    return oldDelegate.step != step;
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
