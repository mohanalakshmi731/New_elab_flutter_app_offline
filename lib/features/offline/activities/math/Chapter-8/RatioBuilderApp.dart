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
      'app_title': 'THE RATIO BUILDER',
      'tagline': 'Introduction to Trigonometry',
      'init_btn': 'INITIALIZE BUILDER',
      'header_title': 'The Ratio Builder',
      'header_subtitle': 'Class 10 • Intro to Trigonometry',
      'phase_label': 'CONSTRUCTION PHASE',
      'step_label': 'Stage',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Ratios Mastered',
      'success_desc':
          'You have successfully built and identified all primary trigonometric ratios.',
      'btn_restart': 'NEW CONSTRUCTION',
      's0': 'Initialize Grid. System standing by.',
      's1': 'Construct Right Triangle ABC.',
      's2': 'Set Reference Angle (θ) at vertex B.',
      's3': 'Identify the Hypotenuse (Longest side).',
      's4': 'Identify the Opposite Side to Angle θ.',
      's5': 'Identify the Adjacent Side to Angle θ.',
      's6': 'Formulate the Sine Ratio: sin(θ).',
      's7': 'Formulate the Cosine Ratio: cos(θ).',
      's8': 'Formulate the Tangent Ratio: tan(θ).',
      's9': 'Derive Reciprocal Ratios. Process Complete.',
      'btn_start': 'ESTABLISH ORIGIN',
      'btn_draw_tri': 'CONSTRUCT TRIANGLE',
      'btn_set_theta': 'SET REFERENCE ANGLE',
      'btn_id_hyp': 'IDENTIFY HYPOTENUSE',
      'btn_id_opp': 'IDENTIFY OPPOSITE',
      'btn_id_adj': 'IDENTIFY ADJACENT',
      'btn_ratio_sin': 'BUILD SINE RATIO',
      'btn_ratio_cos': 'BUILD COSINE RATIO',
      'btn_ratio_tan': 'BUILD TANGENT RATIO',
      'btn_complete': 'DERIVE RECIPROCALS',
      'msg_obs_ok': 'Grid active at Origin.',
      'msg_tri_ok': 'Right Triangle ABC constructed.',
      'msg_theta_ok': 'Reference Angle θ set at vertex B.',
      'msg_hyp_ok': 'Hypotenuse identified (opposite to 90°).',
      'msg_opp_ok': 'Opposite side identified.',
      'msg_adj_ok': 'Adjacent side identified.',
      'msg_sin_ok': 'Sine Ratio = Opposite / Hypotenuse.',
      'msg_cos_ok': 'Cosine Ratio = Adjacent / Hypotenuse.',
      'msg_tan_ok': 'Tangent Ratio = Opposite / Adjacent.',
      'msg_final_ok': 'Reciprocals derived. System Complete.',
      'msg_err': 'Calculation error.',

      // Interactive Canvas Instructions
      'tap_inst': 'Tap the correct location directly on the graph!',
      'wrong_line': 'Incorrect! Try again.',

      // Data Collection Tabs Strings
      'data_collection': 'Data Collection',
      'awaiting_data': 'Awaiting construction data...',
      'primary_ratios': 'Primary Ratios',
      'reciprocal_ratios': 'Reciprocal Ratios',
      'sin_ratio': 'Sine Ratio (sin)',
      'cos_ratio': 'Cosine Ratio (cos)',
      'tan_ratio': 'Tangent Ratio (tan)',

      // Tooltips & Labels
      'menu_tooltip': 'Main Menu',
      'reset_tooltip': 'Reset',
      'back_tooltip': 'Go Back',
    },
    'hi': {
      'app_title': 'रेशियो बिल्डर',
      'tagline': 'त्रिकोणमिति का परिचय',
      'init_btn': 'बिल्डर प्रारंभ करें',
      'header_title': 'रेशियो बिल्डर',
      'header_subtitle': 'कक्षा 10 • त्रिकोणमिति का परिचय',
      'phase_label': 'निर्माण चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'अनुपात मास्टर',
      'success_desc':
          'आपने सफलतापूर्वक सभी प्राथमिक त्रिकोणमितीय अनुपातों का निर्माण और पहचान की है।',
      'btn_restart': 'नया निर्माण',
      's0': 'ग्रिड प्रारंभ करें। सिस्टम तैयार है।',
      's1': 'समकोण त्रिभुज ABC बनाएँ।',
      's2': 'शीर्ष B पर संदर्भ कोण (θ) सेट करें।',
      's3': 'कर्ण (सबसे लंबी भुजा) की पहचान करें।',
      's4': 'कोण θ के विपरीत (लंब) भुजा की पहचान करें।',
      's5': 'कोण θ के संलग्न (आधार) भुजा की पहचान करें।',
      's6': 'साइन अनुपात बनाएँ: sin(θ)।',
      's7': 'कोसाइन अनुपात बनाएँ: cos(θ)।',
      's8': 'टैंजेंट अनुपात बनाएँ: tan(θ)।',
      's9': 'व्युत्क्रम अनुपात प्राप्त करें। प्रक्रिया पूर्ण।',
      'btn_start': 'मूल बिंदु स्थापित करें',
      'btn_draw_tri': 'त्रिभुज बनाएँ',
      'btn_set_theta': 'संदर्भ कोण सेट करें',
      'btn_id_hyp': 'कर्ण पहचानें',
      'btn_id_opp': 'विपरीत (लंब) पहचानें',
      'btn_id_adj': 'संलग्न (आधार) पहचानें',
      'btn_ratio_sin': 'साइन अनुपात बनाएँ',
      'btn_ratio_cos': 'कोसाइन अनुपात बनाएँ',
      'btn_ratio_tan': 'टैंजेंट अनुपात बनाएँ',
      'btn_complete': 'व्युत्क्रम प्राप्त करें',
      'msg_obs_ok': 'ग्रिड सक्रिय।',
      'msg_tri_ok': 'समकोण त्रिभुज ABC बनाया गया।',
      'msg_theta_ok': 'संदर्भ कोण θ शीर्ष B पर सेट।',
      'msg_hyp_ok': 'कर्ण पहचाना गया (90° के विपरीत)।',
      'msg_opp_ok': 'विपरीत भुजा पहचानी गई।',
      'msg_adj_ok': 'संलग्न भुजा पहचानी गई।',
      'msg_sin_ok': 'साइन अनुपात = विपरीत / कर्ण।',
      'msg_cos_ok': 'कोसाइन अनुपात = संलग्न / कर्ण।',
      'msg_tan_ok': 'टैंजेंट अनुपात = विपरीत / संलग्न।',
      'msg_final_ok': 'व्युत्क्रम प्राप्त किए गए। सिस्टम पूर्ण।',
      'msg_err': 'गणना त्रुटि।',

      // Interactive Canvas Instructions
      'tap_inst': 'ग्राफ पर सही स्थान पर सीधे टैप करें!',
      'wrong_line': 'गलत! पुनः प्रयास करें।',

      // Data Collection Tabs Strings
      'data_collection': 'डेटा संग्रह',
      'awaiting_data': 'निर्माण डेटा की प्रतीक्षा...',
      'primary_ratios': 'प्राथमिक अनुपात',
      'reciprocal_ratios': 'व्युत्क्रम अनुपात',
      'sin_ratio': 'साइन अनुपात (sin)',
      'cos_ratio': 'कोसाइन अनुपात (cos)',
      'tan_ratio': 'टैंजेंट अनुपात (tan)',

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

class RatioBuilderApp extends StatefulWidget {
  const RatioBuilderApp({super.key});

  @override
  State<RatioBuilderApp> createState() => _RatioBuilderAppState();
}

class _RatioBuilderAppState extends State<RatioBuilderApp> {
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
    if (isError) playMathError();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.warning_amber_rounded
                  : (isSuccess ? Icons.check_circle : Icons.info_outline),
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
        if (currentStep >= 7) {
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

  // --- Interactive Canvas Tap Logic ---
  void _handleCanvasTap(Offset position) {
    if (currentStep < 2 || currentStep > 5)
      return; // Only active in these identifying steps

    Offset pA = const Offset(150, 260); // Right Angle
    Offset pB = const Offset(350, 260); // Theta Angle
    Offset pC = const Offset(150, 100); // Top Vertex

    double distAB = _pointToLineDist(position, pA, pB);
    double distAC = _pointToLineDist(position, pA, pC);
    double distBC = _pointToLineDist(position, pB, pC);

    double threshold = 30.0; // Generous tap hitbox for lines
    double pointThreshold = 45.0; // Hitbox for tapping vertex B

    if (currentStep == 2) {
      // Step 2 expects Vertex B
      if ((position - pB).distance < pointThreshold) {
        advanceStep('msg_theta_ok');
      } else {
        showToast(
          AppStrings.get(lang, 'wrong_line'),
          isError: true,
          isSuccess: false,
        );
      }
    } else if (currentStep == 3) {
      // Step 3 expects Hypotenuse (BC)
      if (distBC < threshold && distBC < distAB && distBC < distAC) {
        advanceStep('msg_hyp_ok');
      } else {
        showToast(
          AppStrings.get(lang, 'wrong_line'),
          isError: true,
          isSuccess: false,
        );
      }
    } else if (currentStep == 4) {
      // Step 4 expects Opposite (AC)
      if (distAC < threshold && distAC < distAB && distAC < distBC) {
        advanceStep('msg_opp_ok');
      } else {
        showToast(
          AppStrings.get(lang, 'wrong_line'),
          isError: true,
          isSuccess: false,
        );
      }
    } else if (currentStep == 5) {
      // Step 5 expects Adjacent (AB)
      if (distAB < threshold && distAB < distAC && distAB < distBC) {
        advanceStep('msg_adj_ok');
      } else {
        showToast(
          AppStrings.get(lang, 'wrong_line'),
          isError: true,
          isSuccess: false,
        );
      }
    }
  }

  double _pointToLineDist(Offset p, Offset v, Offset w) {
    double l2 = (v.dx - w.dx) * (v.dx - w.dx) + (v.dy - w.dy) * (v.dy - w.dy);
    if (l2 == 0) return (p - v).distance;
    double t =
        ((p.dx - v.dx) * (w.dx - v.dx) + (p.dy - v.dy) * (w.dy - v.dy)) / l2;
    t = math.max(0, math.min(1, t));
    Offset proj = Offset(v.dx + t * (w.dx - v.dx), v.dy + t * (w.dy - v.dy));
    return (p - proj).distance;
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
                      const Icon(Icons.category, size: 80, color: accentPink),
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
                child: const Icon(Icons.architecture, color: bgDark),
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

          if (currentStep < 7)
            _buildEmptyState()
          else ...[
            Text(
              AppStrings.get(lang, 'primary_ratios').toUpperCase(),
              style: const TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),

            // Sine Ratio
            if (currentStep >= 7)
              _buildDataBlock(
                AppStrings.get(lang, 'sin_ratio'),
                "sin(θ) = Opposite / Hypotenuse",
                "",
                currentStep == 7,
              ),

            const SizedBox(height: 15),

            // Cosine Ratio
            if (currentStep >= 8)
              _buildDataBlock(
                AppStrings.get(lang, 'cos_ratio'),
                "cos(θ) = Adjacent / Hypotenuse",
                "",
                currentStep == 8,
              ),

            const SizedBox(height: 15),

            // Tangent Ratio
            if (currentStep >= 9)
              _buildDataBlock(
                AppStrings.get(lang, 'tan_ratio'),
                "tan(θ) = Opposite / Adjacent",
                "",
                currentStep == 9,
              ),

            const SizedBox(height: 30),

            // Reciprocals Summary Block
            if (currentStep >= 10) ...[
              Text(
                AppStrings.get(lang, 'reciprocal_ratios').toUpperCase(),
                style: const TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              _buildResultBlock(
                "cosec(θ) = Hypotenuse / Opposite",
                "sec(θ) = Hypotenuse / Adjacent",
                "cot(θ) = Adjacent / Opposite",
              ),
            ],
          ],
        ],
      ),
    );
  }

  // Helper Widget for Data Blocks
  Widget _buildDataBlock(
    String title,
    String line1,
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

  // Helper Widget for Result/Summary Blocks
  Widget _buildResultBlock(String eq1, String eq2, String eq3) {
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
            eq1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 15),
          Text(
            eq2,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 15),
          Text(
            eq3,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'monospace',
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
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) => _handleCanvasTap(details.localPosition),
                child: SizedBox(
                  width: 500,
                  height: 380,
                  child: _buildSceneGraphics(),
                ),
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
            painter: TrigPainter(step: currentStep),
          ),
          if (currentStep >= 2) ...[
            const Positioned(
              left: 125,
              top: 240,
              child: Text(
                "A",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            const Positioned(
              left: 360,
              top: 265,
              child: Text(
                "B",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            const Positioned(
              left: 135,
              top: 80,
              child: Text(
                "C",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
          if (currentStep >= 3) ...[
            const Positioned(
              left: 310,
              top: 245,
              child: Text(
                "θ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: accentYellow,
                ),
              ),
            ),
          ],
          if (currentStep >= 4) ...[
            Positioned(
              left: 230,
              top: 150,
              child: Transform.rotate(
                angle: -0.73, // rough angle for hypotenuse text
                child: const Text(
                  "Hypotenuse",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: accentRed,
                  ),
                ),
              ),
            ),
          ],
          if (currentStep >= 5) ...[
            const Positioned(
              left: 40,
              top: 170,
              child: Text(
                "Opposite",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: accentBlue,
                ),
              ),
            ),
          ],
          if (currentStep >= 6) ...[
            const Positioned(
              left: 220,
              top: 300,
              child: Text(
                "Adjacent",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: accentGreen,
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
          text: AppStrings.get(lang, 'btn_draw_tri'),
          color: accentPink,
          onPressed: () => advanceStep('msg_tri_ok'),
        );
      case 2:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_set_theta') + " 👆",
          color: accentYellow,
          onPressed: () {
            playMathClick();
            showToast(
              AppStrings.get(lang, 'tap_inst'),
              isError: false,
              isSuccess: false,
            );
          },
        );
      case 3:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_id_hyp') + " 👆",
          color: accentRed,
          onPressed: () {
            playMathClick();
            showToast(
              AppStrings.get(lang, 'tap_inst'),
              isError: false,
              isSuccess: false,
            );
          },
        );
      case 4:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_id_opp') + " 👆",
          color: accentBlue,
          onPressed: () {
            playMathClick();
            showToast(
              AppStrings.get(lang, 'tap_inst'),
              isError: false,
              isSuccess: false,
            );
          },
        );
      case 5:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_id_adj') + " 👆",
          color: accentGreen,
          onPressed: () {
            playMathClick();
            showToast(
              AppStrings.get(lang, 'tap_inst'),
              isError: false,
              isSuccess: false,
            );
          },
        );
      case 6:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_ratio_sin'),
          color: accentPink,
          onPressed: () => advanceStep('msg_sin_ok'),
        );
      case 7:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_ratio_cos'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_cos_ok'),
        );
      case 8:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_ratio_tan'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_tan_ok'),
        );
      case 9:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_complete'),
          color: accentYellow,
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

// --- CUSTOM PAINTER ---

class TrigPainter extends CustomPainter {
  final int step;

  TrigPainter({required this.step});

  @override
  void paint(Canvas canvas, Size size) {
    // Triangle Coordinates
    Offset pA = const Offset(150, 260); // Right Angle (Also Origin)
    Offset pB = const Offset(350, 260); // Theta Angle
    Offset pC = const Offset(150, 100); // Top Vertex

    if (step >= 1) {
      // Shows origin on start
      // Origin indicator (faint grid intersection)
      canvas.drawCircle(pA, 4, Paint()..color = Colors.white54);
      final textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = const TextSpan(
        text: "(0,0)",
        style: TextStyle(
          color: Colors.white54,
          fontSize: 12,
          fontFamily: 'monospace',
        ),
      );
      textPainter.layout();
      // Offset text slightly below A to avoid overlap once A appears
      textPainter.paint(canvas, Offset(pA.dx - 15, pA.dy + 10));
    }

    if (step >= 2) {
      // Base Triangle Outline
      final triPaint = Paint()
        ..color = Colors.white54
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      Path pathTri = Path()
        ..moveTo(pA.dx, pA.dy)
        ..lineTo(pB.dx, pB.dy)
        ..lineTo(pC.dx, pC.dy)
        ..close();
      canvas.drawPath(pathTri, triPaint);

      // Points
      final pointPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pA, 4, pointPaint);
      canvas.drawCircle(pB, 4, pointPaint);
      canvas.drawCircle(pC, 4, pointPaint);

      // Right Angle Square
      _drawRightAngle(canvas, pA, 1, -1, Colors.white);
    }

    if (step >= 3) {
      // Draw Theta Arc at B
      final arcPaint = Paint()
        ..color = accentYellow.withOpacity(0.5)
        ..style = PaintingStyle.fill;

      double radius = 40.0;
      double angle = math.atan2(
        pA.dy - pC.dy,
        pB.dx - pA.dx,
      ); // angle of hypotenuse

      canvas.drawArc(
        Rect.fromCircle(center: pB, radius: radius),
        math.pi, // starts horizontally left
        angle, // sweeps up to hypotenuse
        true,
        arcPaint,
      );

      canvas.drawArc(
        Rect.fromCircle(center: pB, radius: radius),
        math.pi,
        angle,
        false,
        Paint()
          ..color = accentYellow
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }

    if (step >= 4) {
      // Highlight Hypotenuse (BC)
      canvas.drawLine(
        pC,
        pB,
        Paint()
          ..color = accentRed
          ..strokeWidth = 5,
      );
    }

    if (step >= 5) {
      // Highlight Opposite (AC)
      canvas.drawLine(
        pA,
        pC,
        Paint()
          ..color = accentBlue
          ..strokeWidth = 5,
      );
    }

    if (step >= 6) {
      // Highlight Adjacent (AB)
      canvas.drawLine(
        pA,
        pB,
        Paint()
          ..color = accentGreen
          ..strokeWidth = 5,
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

  @override
  bool shouldRepaint(covariant TrigPainter oldDelegate) {
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
