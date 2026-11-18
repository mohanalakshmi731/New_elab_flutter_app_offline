// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:elab_app/features/offline/activities/math_activity_audio.dart';

// --- CONSTANTS & STRINGS ---

const Color bgDark = Color(0xFF020617);
const Color bgPanel = Color(0xFF0F172A);
const Color accentPink = Color(0xFFF472B6);
const Color accentBlue = Color(0xFF3B82F6);
const Color accentGreen = Color(0xFF22C55E);
const Color accentRed = Color(0xFFEF4444);

class AppStrings {
  static const Map<String, Map<String, String>> data = {
    'en': {
      'app_title': 'THE PATTERN SPOTTER',
      'tagline': 'Definition of Arithmetic Progression',
      'init_btn': 'ENTER SPACE ACADEMY',
      'header_title': 'The Pattern Spotter',
      'header_subtitle': 'Class 10 • AP',
      'phase_label': 'SCANNING PHASE',
      'step_label': 'Step',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Pattern Master',
      'success_desc': 'All patterns identified correctly.',
      'btn_restart': 'RESTART LAB',
      's0': 'Activate Scanner: Initialize detection tool.',
      's1': 'Scan Subject 1: The Ladder.',
      's2': 'Calculate Differences: Click gaps.',
      's3': 'Classification Decision.',
      's4': 'Scan Subject 2: Bacteria Growth.',
      's5': 'Verify Consistency: Click gaps.',
      's6': 'Rejection Protocol: Non-AP.',
      's7': 'Scan Subject 3: Unit Squares.',
      's8': 'Scan Subject 4: Savings Jar.',
      's9': 'Final Analysis: The Fence (d=0).',
      'btn_scan': 'OPEN SCANNER',
      'btn_calc': 'CALCULATE DIFF',
      'btn_yes': 'YES',
      'btn_no': 'NO',
      'btn_input_50': 'INPUT: 50',
      'btn_input_100': 'INPUT: 100',
      'lbl_target': 'Target:',
      'lbl_ladder': 'LADDER',
      'lbl_bac': 'BACTERIA',
      'lbl_sq': 'UNIT SQUARES',
      'lbl_sav': 'SAVINGS',
      'lbl_fence': 'FENCE',
      'lbl_q_const': 'Is difference constant?',
      'lbl_q_zero': 'Is 0 a valid difference?',
      'lbl_bal': 'Bal',
      'msg_scan_ok': 'Sequence Loaded.',
      'msg_ap_conf': 'AP CONFIRMED!',
      'msg_non_ap': 'NON-AP DETECTED.',
      'msg_try': 'Try Again.',
      'msg_done': 'Mission Complete.',
      'msg_click_gap': 'Click on the glowing gaps between the numbers.',
      'msg_diff_calc': 'Difference Calculated',
      'tip_doubling': 'Doubling is not adding.',
      'val_correct': 'Correct classification.',
      'val_err': 'ERROR: Inconsistent Difference.',
    },
    'hi': {
      'app_title': 'पैटर्न स्पॉट',
      'tagline': 'समान्तर श्रेढ़ी की परिभाषा',
      'init_btn': 'स्पेस अकादमी में प्रवेश',
      'header_title': 'पैटर्न स्पॉट',
      'header_subtitle': 'कक्षा 10 • AP',
      'phase_label': 'स्कैनिंग चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'पैटर्न मास्टर',
      'success_desc': 'सभी पैटर्न सही पहचाने गए।',
      'btn_restart': 'पुनः आरंभ करें',
      's0': 'स्कैनर सक्रिय करें: टूल शुरू करें।',
      's1': 'विषय 1 स्कैन करें: सीढ़ी।',
      's2': 'अंतर जाँचें: अंतरालों पर क्लिक करें।',
      's3': 'वर्गीकरण निर्णय।',
      's4': 'विषय 2 स्कैन करें: बैक्टीरिया।',
      's5': 'स्थिरता जाँचें: अंतरालों पर क्लिक करें।',
      's6': 'अस्वीकृति प्रोटोकॉल: Non-AP।',
      's7': 'विषय 3 स्कैन करें: इकाई वर्ग।',
      's8': 'विषय 4 स्कैन करें: बचत जार।',
      's9': 'अंतिम विश्लेषण: बाड़ (d=0)।',
      'btn_scan': 'स्कैनर खोलें',
      'btn_calc': 'अंतर गणना',
      'btn_yes': 'हाँ',
      'btn_no': 'नहीं',
      'btn_input_50': 'इनपुट: 50',
      'btn_input_100': 'इनपुट: 100',
      'lbl_target': 'लक्ष्य:',
      'lbl_ladder': 'सीढ़ी',
      'lbl_bac': 'बैक्टीरिया',
      'lbl_sq': 'इकाई वर्ग',
      'lbl_sav': 'बचत',
      'lbl_fence': 'बाड़',
      'lbl_q_const': 'क्या अंतर स्थिर है?',
      'lbl_q_zero': 'क्या 0 एक मान्य अंतर है?',
      'lbl_bal': 'शेष',
      'msg_scan_ok': 'अनुक्रम लोड किया गया।',
      'msg_ap_conf': 'AP की पुष्टि हुई!',
      'msg_non_ap': 'Non-AP का पता चला।',
      'msg_try': 'पुनः प्रयास करें।',
      'msg_done': 'मिशन पूरा।',
      'msg_click_gap': 'संख्याओं के बीच चमकते अंतराल पर क्लिक करें।',
      'msg_diff_calc': 'अंतर की गणना की गई',
      'tip_doubling': 'दोगुना करना जोड़ना नहीं है।',
      'val_correct': 'सही वर्गीकरण।',
      'val_err': 'त्रुटि: असंगत अंतर।',
    },
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['en']![key] ?? key;
  }
}

class PatternSpotterApp extends StatefulWidget {
  const PatternSpotterApp({super.key});

  @override
  State<PatternSpotterApp> createState() => _PatternSpotterAppState();
}

class _PatternSpotterAppState extends State<PatternSpotterApp> {
  bool hasStarted = false;
  String lang = 'en';
  bool panelOpen = true;

  // Activity State
  int currentStep = 0;
  int gapClicks = 0;
  List<bool> gapClickedState = [false, false, false, false];
  bool isScanning = false;
  bool showSuccessModal = false;

  void startGame() {
    playVibration('click');
    setState(() {
      hasStarted = true;
    });
  }

  void switchLang(String newLang) {
    playVibration('click');
    setState(() {
      lang = newLang;
    });
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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

  void playVibration(String type) {
    if (type == 'click') {
      HapticFeedback.lightImpact();
      playMathClick();
    } else if (type == 'success' || type == 'intro') {
      HapticFeedback.mediumImpact();
      if (type == 'success') {
        playMathSuccess();
      } else {
        playMathStart();
      }
    } else if (type == 'error') {
      HapticFeedback.vibrate();
    }
  }

  void showToast(
    String message, {
    bool isError = false,
    bool isSuccess = true,
  }) {
    if (isError) playMathError();
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
        backgroundColor: bgPanel,
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

  void advanceStep() {
    if (currentStep < 9) {
      playVibration('click');
      setState(() {
        currentStep++;
        gapClicks = 0;
        gapClickedState = [false, false, false, false];
        isScanning = false;
      });

      // Handle auto-scanning phases
      if (currentStep == 1 || currentStep == 4) {
        setState(() => isScanning = true);
        Timer(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() => isScanning = false);
            showToast(AppStrings.get(lang, 'msg_scan_ok'), isSuccess: true);
            advanceStep();
          }
        });
      }
    }
  }

  void onGapClicked(int index, String label, bool isErrorGap) {
    if (!gapClickedState[index]) {
      playVibration('click');
      setState(() {
        gapClickedState[index] = true;
        gapClicks++;
      });

      if (isErrorGap) {
        playVibration('error');
        showToast("$label - ${AppStrings.get(lang, 'val_err')}", isError: true);
      } else {
        showToast(AppStrings.get(lang, 'msg_diff_calc'), isSuccess: true);
      }

      // Auto-advance logic for gap clicking
      if (currentStep == 2 && gapClicks >= 3) {
        Timer(const Duration(seconds: 1), advanceStep);
      } else if (currentStep == 5 && gapClicks >= 2) {
        Timer(const Duration(seconds: 1), advanceStep);
      } else if (currentStep == 7 && gapClicks >= 3) {
        Timer(const Duration(seconds: 1), advanceStep);
      }
    }
  }

  void makeDecision(bool userSaysYes, bool isActuallyAP) {
    if (userSaysYes == isActuallyAP) {
      playVibration('success');
      showToast(
        isActuallyAP
            ? AppStrings.get(lang, 'msg_ap_conf')
            : AppStrings.get(lang, 'val_correct'),
        isSuccess: true,
      );
      Timer(const Duration(seconds: 2), advanceStep);
    } else {
      playVibration('error');
      showToast(AppStrings.get(lang, 'msg_try'), isError: true);
    }
  }

  void finishActivity() {
    playVibration('success');
    showToast(AppStrings.get(lang, 'msg_done'), isSuccess: true);
    Timer(const Duration(seconds: 1), () {
      setState(() {
        showSuccessModal = true;
      });
    });
  }

  void resetLab() {
    playMathStart();
    playVibration('click');
    setState(() {
      currentStep = 0;
      gapClicks = 0;
      gapClickedState = [false, false, false, false];
      isScanning = false;
      showSuccessModal = false;
      hasStarted = false;
      panelOpen = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Responsive side panel width
    final double panelWidth = screenWidth < 600
        ? screenWidth * 0.85
        : (screenWidth * 0.4).clamp(320.0, 450.0);

    if (!hasStarted) {
      return Scaffold(
        backgroundColor: bgDark,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentPink.withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(
                        color: accentPink.withOpacity(0.3),
                        blurRadius: 100,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.layers, size: 80, color: accentPink),
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
                  onPressed: () {
                    playVibration('intro');
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 10,
                    shadowColor: accentPink.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: bgDark,
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
                        child: _buildSidePanel(),
                      ),
                    ),
                  ),

                  // Interactive Canvas Area
                  Expanded(
                    child: Stack(
                      children: [
                        // Zoom and Pan Canvas
                        InteractiveViewer(
                          boundaryMargin: const EdgeInsets.all(2000),
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: Stack(
                            children: [
                              // Background Grid
                              Positioned.fill(
                                child: CustomPaint(painter: GridPainter()),
                              ),
                              // Dynamic Scene Graphics
                              Positioned.fill(
                                child: SceneRenderer(
                                  step: currentStep,
                                  gapClickedState: gapClickedState,
                                  onGapClicked: onGapClicked,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Scanner Overlay
                        if (isScanning)
                          Positioned.fill(child: const AnimatedScanner()),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Floating HUD (Visible when sidebar is collapsed)
            if (!panelOpen)
              Positioned(top: 90, left: 24, child: _buildFloatingHUD()),

            // Top-Left Floating Button (Back / Reset)
            // Positioned(
            //   bottom: 24,
            //   left: 24,
            //   child: Material(
            //     color: Colors.white.withOpacity(0.1),
            //     shape: const CircleBorder(),
            //     clipBehavior: Clip.antiAlias,
            //     child: InkWell(
            //       onTap: () {
            //         playVibration('click');
            //         if (Navigator.of(context).canPop()) {
            //           Navigator.of(context).pop();
            //         } else {
            //           resetLab();
            //         }
            //       },
            //       child: const Padding(
            //         padding: EdgeInsets.all(12),
            //         child: Icon(Icons.arrow_back, color: Colors.white),
            //       ),
            //     ),
            //   ),
            // ),

            // Bottom-Left Floating Menu Toggle
            Positioned(
              top: 24,
              left: 24,
              child: FloatingActionButton(
                backgroundColor: accentBlue,
                elevation: 8,
                onPressed: () {
                  playVibration('click');
                  setState(() => panelOpen = !panelOpen);
                },
                child: Icon(
                  panelOpen ? Icons.menu_open : Icons.menu,
                  color: Colors.white,
                ),
              ),
            ),

            // Success Overlay
            if (showSuccessModal) _buildSuccessModal(),
          ],
        ),
      ),
    );
  }

  // --- UI BUILDERS ---

  Widget _buildSidePanel() {
    return Container(
      decoration: BoxDecoration(
        color: bgPanel.withOpacity(0.95),
        border: Border(right: BorderSide(color: accentPink.withOpacity(0.3))),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.only(
                top: 80, // Clear the top-left floating back button visually
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
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [accentPink, Color(0xFFF43F5E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: accentPink.withOpacity(0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.radar, color: bgDark, size: 20),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.get(lang, 'header_title'),
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
                              AppStrings.get(lang, 'header_subtitle'),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: accentPink,
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
                        onPressed: resetLab,
                        icon: const Icon(Icons.power_settings_new, size: 20),
                        color: accentRed,
                        style: IconButton.styleFrom(
                          backgroundColor: accentRed.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: accentRed.withOpacity(0.3)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 90, // Clear the menu toggle button
              ),
              child: _buildExploreContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangToggles() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: ['en', 'hi'].map((l) {
          bool isActive = lang == l;
          return GestureDetector(
            onTap: () => switchLang(l),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? Colors.white24 : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                l.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : Colors.white54,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExploreContent() {
    return Column(
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
        const SizedBox(height: 20),

        // Console Log (Mission Steps)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          ),
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
          child: Column(
            children: List.generate(10, (index) {
              bool isActive = index == currentStep;
              bool isDone = index < currentStep;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
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
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 20),

        // Controls Area
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: const BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
            border: Border(top: BorderSide(color: Colors.white12)),
          ),
          child: _buildControlsArea(),
        ),
      ],
    );
  }

  Widget _buildFloatingHUD() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 50,
        maxWidth: 280,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgPanel.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentBlue.withOpacity(0.4), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    "${currentStep + 1}/10",
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: _buildControlsArea(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlsArea() {
    switch (currentStep) {
      case 0: // Scan
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentBlue,
            foregroundColor: Colors.white,
          ),
          onPressed: advanceStep,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              AppStrings.get(lang, 'btn_scan'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      case 1: // Ladder scan info
        return Text(
          "${AppStrings.get(lang, 'lbl_target')} ${AppStrings.get(lang, 'lbl_ladder')}",
          style: const TextStyle(
            color: accentPink,
            fontWeight: FontWeight.bold,
          ),
        );
      case 2: // Calc Diff
        return Text(
          AppStrings.get(lang, 'msg_click_gap'),
          style: const TextStyle(color: accentPink),
        );
      case 3: // Classify
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Prevents expanding to infinity
          children: [
            Text(
              AppStrings.get(lang, 'lbl_q_const'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentGreen,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () => makeDecision(true, true),
                    child: Text(
                      AppStrings.get(lang, 'btn_yes'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentRed,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => makeDecision(false, true),
                    child: Text(
                      AppStrings.get(lang, 'btn_no'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      case 4: // Bacteria info
        return Text(
          "${AppStrings.get(lang, 'lbl_target')} ${AppStrings.get(lang, 'lbl_bac')}",
          style: const TextStyle(
            color: accentPink,
            fontWeight: FontWeight.bold,
          ),
        );
      case 5: // Bacteria gaps
        return Text(
          AppStrings.get(lang, 'msg_click_gap'),
          style: const TextStyle(color: accentPink),
        );
      case 6: // Classify Bacteria
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Prevents expanding to infinity
          children: [
            Text(
              AppStrings.get(lang, 'lbl_q_const'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentGreen,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () => makeDecision(true, false),
                    child: Text(
                      AppStrings.get(lang, 'btn_yes'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentRed,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => makeDecision(false, false),
                    child: Text(
                      AppStrings.get(lang, 'btn_no'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      case 7: // Squares gaps
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Prevents expanding to infinity
          children: [
            Text(
              "${AppStrings.get(lang, 'lbl_target')} ${AppStrings.get(lang, 'lbl_sq')}",
              style: const TextStyle(
                color: accentPink,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              AppStrings.get(lang, 'msg_click_gap'),
              style: const TextStyle(color: accentBlue, fontSize: 12),
            ),
          ],
        );
      case 8: // Savings Input
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Prevents expanding to infinity
          children: [
            Text(
              "${AppStrings.get(lang, 'lbl_target')} ${AppStrings.get(lang, 'lbl_sav')}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "${AppStrings.get(lang, 'lbl_bal')}: 50, 100, 150...",
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentBlue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => makeDecision(true, true),
                    child: Text(
                      AppStrings.get(lang, 'btn_input_50'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white24,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => makeDecision(false, true),
                    child: Text(
                      AppStrings.get(lang, 'btn_input_100'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      case 9: // Fence
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Prevents expanding to infinity
          children: [
            Text(
              "${AppStrings.get(lang, 'lbl_target')} ${AppStrings.get(lang, 'lbl_fence')}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "3, 3, 3, 3",
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
            const SizedBox(height: 10),
            gapClickedState[0]
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.get(lang, 'lbl_q_zero'),
                        style: const TextStyle(
                          color: accentPink,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentGreen,
                                foregroundColor: Colors.black,
                              ),
                              onPressed: finishActivity,
                              child: Text(
                                AppStrings.get(lang, 'btn_yes'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentRed,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                playVibration('error');
                                showToast(
                                  AppStrings.get(lang, 'msg_try'),
                                  isError: true,
                                );
                              },
                              child: Text(
                                AppStrings.get(lang, 'btn_no'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentBlue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        playVibration('click');
                        setState(() => gapClickedState[0] = true);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          AppStrings.get(lang, 'btn_calc'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildSuccessModal() {
    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(40),
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
                  const Icon(Icons.verified, color: accentGreen, size: 80),
                  const SizedBox(height: 20),
                  Text(
                    AppStrings.get(lang, 'badge_title').toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppStrings.get(lang, 'success_desc'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentGreen,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                    ),
                    onPressed: resetLab,
                    child: Text(
                      AppStrings.get(lang, 'btn_restart'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
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
}

// --- GRAPHICS & SCENE RENDERING ---

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.0;

    const double step = 40;

    for (double i = -3000; i < 3000; i += step) {
      canvas.drawLine(Offset(i, -3000), Offset(i, 3000), paint);
      canvas.drawLine(Offset(-3000, i), Offset(3000, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AnimatedScanner extends StatefulWidget {
  const AnimatedScanner({super.key});

  @override
  State<AnimatedScanner> createState() => _AnimatedScannerState();
}

class _AnimatedScannerState extends State<AnimatedScanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: _ctrl.value * MediaQuery.of(context).size.height,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                decoration: const BoxDecoration(
                  color: accentGreen,
                  boxShadow: [
                    BoxShadow(
                      color: accentGreen,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white30, width: 2),
                ),
                child: Center(
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// --- Scene Renderer ---

class SceneRenderer extends StatelessWidget {
  final int step;
  final List<bool> gapClickedState;
  final Function(int, String, bool) onGapClicked;

  const SceneRenderer({
    super.key,
    required this.step,
    required this.gapClickedState,
    required this.onGapClicked,
  });

  @override
  Widget build(BuildContext context) {
    if (step >= 1 && step <= 3) return _buildLadderScene();
    if (step >= 4 && step <= 6) return _buildBacteriaScene();
    if (step == 7) return _buildSquaresScene();
    if (step == 8) return _buildSavingsScene();
    if (step == 9) return _buildFenceScene();

    return const SizedBox(); // Empty for step 0
  }

  // Ladder (Constant difference -2)
  Widget _buildLadderScene() {
    List<int> rungs = [45, 43, 41, 39, 37];
    double spacing = 60;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: -50,
                top: 20,
                bottom: 20,
                child: Container(width: 10, color: Colors.blueGrey),
              ),
              Positioned(
                right: -50,
                top: 20,
                bottom: 20,
                child: Container(width: 10, color: Colors.blueGrey),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(rungs.length, (i) {
                  return Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 110, height: 12, color: accentPink),
                          const SizedBox(width: 15),
                          Text(
                            rungs[i].toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      if (i < rungs.length - 1)
                        SizedBox(
                          height: spacing,
                          child: Center(
                            child: (step >= 2 && i < 3)
                                ? _buildGapNode(
                                    index: i,
                                    label: "${rungs[i + 1]} - ${rungs[i]} = -2",
                                    isError: false,
                                  )
                                : const SizedBox(),
                          ),
                        ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Bacteria (Doubling, not constant difference)
  Widget _buildBacteriaScene() {
    List<int> bacs = [1, 2, 4, 8, 16];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(bacs.length, (i) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20.0 + (i * 15),
                        height: 20.0 + (i * 15),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentGreen.withOpacity(0.5),
                          border: Border.all(color: accentGreen, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: accentGreen.withOpacity(0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        bacs[i].toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  if (i < bacs.length - 1)
                    Container(
                      width: 50,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(bottom: 30),
                      child: (step >= 5 && i < 2)
                          ? _buildGapNode(
                              index: i,
                              label:
                                  "${bacs[i + 1]} - ${bacs[i]} = ${bacs[i + 1] - bacs[i]}",
                              isError: true,
                            )
                          : const SizedBox(),
                    ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  // Squares
  Widget _buildSquaresScene() {
    List<int> sizes = [1, 2, 3, 4];
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(sizes.length, (i) {
              double s = sizes[i] * 30.0;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: s,
                        height: s,
                        decoration: BoxDecoration(
                          color: accentBlue.withOpacity(0.8),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        sizes[i].toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  if (i < sizes.length - 1)
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(bottom: 20),
                      child: _buildGapNode(
                        index: i,
                        label: "${sizes[i + 1]} - ${sizes[i]} = 1",
                        isError: false,
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  // Savings
  Widget _buildSavingsScene() {
    List<int> stacks = [1, 2, 3, 4];
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(stacks.length, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        stacks[i],
                        (j) => Container(
                          width: 50,
                          height: 15,
                          margin: const EdgeInsets.only(bottom: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.orange),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      (stacks[i] * 50).toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // Fence
  Widget _buildFenceScene() {
    List<int> heights = [3, 3, 3, 3];
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(height: 10, width: 350, color: Colors.brown[700]),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(heights.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20,
                          height: 150,
                          decoration: const BoxDecoration(
                            color: Colors.brown,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          heights[i].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              if (step == 9 && gapClickedState[0])
                Positioned(
                  top: 50,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    decoration: const BoxDecoration(
                      color: accentBlue,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: const Text(
                      "3 - 3 = 0",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Interactive Gap Node Helper
  Widget _buildGapNode({
    required int index,
    required String label,
    required bool isError,
  }) {
    bool isClicked = gapClickedState[index];

    if (isClicked) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isError ? accentRed : accentBlue,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => onGapClicked(index, label, isError),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accentGreen.withOpacity(0.3),
          border: Border.all(color: accentGreen, width: 2),
        ),
        child: const Center(
          child: Icon(Icons.touch_app, size: 16, color: accentGreen),
        ),
      ),
    );
  }
}
