// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:elab_app/features/offline/activities/math_activity_audio.dart';

// चौथाई चाप के लिए सन्निकटन
void _drawDashedArc(
  Canvas canvas,
  Rect rect,
  double startAngle,
  double sweepAngle,
  Paint paint, {
  double dashLength = 5,
  double gapLength = 5,
}) {
  final arcRadius = rect.width / 2;
  final numDashes = (arcRadius * sweepAngle.abs() / (dashLength + gapLength))
      .floor();
  double angle = startAngle;
  final angleStep = sweepAngle / numDashes;
  for (int i = 0; i < numDashes; i++) {
    final from = Offset(
      rect.center.dx + arcRadius * math.cos(angle),
      rect.center.dy + arcRadius * math.sin(angle),
    );
    final to = Offset(
      rect.center.dx +
          arcRadius *
              math.cos(
                angle + angleStep * dashLength / (dashLength + gapLength),
              ),
      rect.center.dy +
          arcRadius *
              math.sin(
                angle + angleStep * dashLength / (dashLength + gapLength),
              ),
    );
    canvas.drawLine(from, to, paint);
    angle += angleStep;
  }
}

// --- स्थिरांक और स्ट्रिंग्स (Constants & Strings) ---

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
      'app_title': 'THE SPECIAL ANGLE DIAL',
      'tagline': 'Trigonometric Ratios of Specific Angles',
      'init_btn': 'INITIALIZE DIAL',
      'header_title': 'The Special Angle Dial',
      'header_subtitle': 'Class 10 • Intro to Trigonometry',
      'phase_label': 'CALIBRATION PHASE',
      'step_label': 'Stage',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Dial Calibrated',
      'success_desc':
          'You have successfully mapped the trigonometric ratios of all special angles.',
      'btn_restart': 'NEW CALIBRATION',
      's0': 'Initialize Dial. Calibrating unit circle.',
      's1': 'Adjust dial to 30° (π/6 radians).',
      's2': 'Adjust dial to 45° (π/4 radians).',
      's3': 'Adjust dial to 60° (π/3 radians).',
      's4': 'Observe extreme: Drop to 0°.',
      's5': 'Observe extreme: Raise to 90°.',
      's6': 'Analyze the Sine Pattern (√n / 2).',
      's7': 'Analyze the Cosine Pattern (Reversed).',
      's8': 'Analyze Tangent (Sin / Cos).',
      's9': 'Calibration and Pattern Analysis Complete.',
      'btn_start': 'ESTABLISH ORIGIN',
      'btn_dial_30': 'CALIBRATE TO 30°',
      'btn_dial_45': 'CALIBRATE TO 45°',
      'btn_dial_60': 'CALIBRATE TO 60°',
      'btn_dial_0': 'DROP TO 0°',
      'btn_dial_90': 'RAISE TO 90°',
      'btn_pat_sin': 'REVEAL SINE PATTERN',
      'btn_pat_cos': 'REVEAL COSINE PATTERN',
      'btn_pat_tan': 'REVEAL TANGENT LOGIC',
      'btn_complete': 'FINALIZE CALIBRATION',
      'msg_obs_ok': 'Unit circle established. Radius = 1.',
      'msg_30_ok': 'Dial set to 30°. Sin=1/2, Cos=√3/2.',
      'msg_45_ok': 'Dial set to 45°. Isosceles right triangle formed.',
      'msg_60_ok': 'Dial set to 60°. Sin=√3/2, Cos=1/2.',
      'msg_0_ok': 'Collapsed to 0°. Opposite height is 0.',
      'msg_90_ok': 'Collapsed to 90°. Adjacent base is 0.',
      'msg_sin_pat': 'Sine pattern isolated: √0, √1, √2, √3, √4 over 2.',
      'msg_cos_pat': 'Cosine pattern isolated: Reversed Sine.',
      'msg_tan_pat': 'Tangent ratio evaluated.',
      'msg_final_ok': 'All special angles verified.',
      'msg_err': 'Calibration error.',

      // Interactive Canvas Instructions
      'drag_inst': 'Drag the dial or use the slider to hit the target angle!',
      'btn_drag': 'ADJUST DIAL TO',

      // Data Collection Tabs Strings
      'data_collection': 'Data Collection',
      'awaiting_data': 'Awaiting dial data...',
      'current_values': 'Current Values',
      'pattern_analysis': 'Pattern Analysis',
      'angle_label': 'Angle (θ)',

      // Tooltips & Labels
      'menu_tooltip': 'Main Menu',
      'reset_tooltip': 'Reset',
      'back_tooltip': 'Go Back',
    },
    'hi': {
      'app_title': 'विशेष कोण डायल',
      'tagline': 'विशिष्ट कोणों के त्रिकोणमितीय अनुपात',
      'init_btn': 'डायल प्रारंभ करें',
      'header_title': 'विशेष कोण डायल',
      'header_subtitle': 'कक्षा 10 • त्रिकोणमिति का परिचय',
      'phase_label': 'अंशांकन चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'डायल कैलिब्रेटेड',
      'success_desc':
          'आपने सभी विशेष कोणों के त्रिकोणमितीय अनुपातों को सफलतापूर्वक मैप कर लिया है।',
      'btn_restart': 'नया अंशांकन',
      's0': 'डायल प्रारंभ करें। इकाई वृत्त कैलिब्रेट किया जा रहा है।',
      's1': 'डायल को 30° पर सेट करें।',
      's2': 'डायल को 45° पर सेट करें।',
      's3': 'डायल को 60° पर सेट करें।',
      's4': 'चरम सीमा देखें: 0° पर गिराएं।',
      's5': 'चरम सीमा देखें: 90° पर उठाएं।',
      's6': 'साइन पैटर्न (√n / 2) का विश्लेषण करें।',
      's7': 'कोसाइन पैटर्न (उल्टा) का विश्लेषण करें।',
      's8': 'टैंजेंट (Sin / Cos) का विश्लेषण करें।',
      's9': 'अंशांकन और पैटर्न विश्लेषण पूर्ण।',
      'btn_start': 'मूल बिंदु स्थापित करें',
      'btn_dial_30': '30° पर कैलिब्रेट करें',
      'btn_dial_45': '45° पर कैलिब्रेट करें',
      'btn_dial_60': '60° पर कैलिब्रेट करें',
      'btn_dial_0': '0° पर गिराएं',
      'btn_dial_90': '90° पर उठाएं',
      'btn_pat_sin': 'साइन पैटर्न दिखाएं',
      'btn_pat_cos': 'कोसाइन पैटर्न दिखाएं',
      'btn_pat_tan': 'टैंजेंट तर्क दिखाएं',
      'btn_complete': 'अंशांकन पूरा करें',
      'msg_obs_ok': 'इकाई वृत्त स्थापित। त्रिज्या = 1.',
      'msg_30_ok': 'डायल 30° पर सेट। Sin=1/2, Cos=√3/2.',
      'msg_45_ok': 'डायल 45° पर सेट। समद्विबाहु समकोण त्रिभुज बना।',
      'msg_60_ok': 'डायल 60° पर सेट। Sin=√3/2, Cos=1/2.',
      'msg_0_ok': '0° पर ढह गया। लंब ऊंचाई 0 है।',
      'msg_90_ok': '90° पर ढह गया। आधार 0 है।',
      'msg_sin_pat': 'साइन पैटर्न: 2 के ऊपर √0, √1, √2, √3, √4.',
      'msg_cos_pat': 'कोसाइन पैटर्न: उल्टा साइन।',
      'msg_tan_pat': 'टैंजेंट अनुपात का मूल्यांकन किया गया।',
      'msg_final_ok': 'सभी विशेष कोण सत्यापित।',
      'msg_err': 'अंशांकन त्रुटि।',

      // Interactive Canvas Instructions
      'drag_inst': 'लक्ष्य कोण तक पहुँचने के लिए स्लाइडर या डायल को खींचें!',
      'btn_drag': 'डायल सेट करें',

      // Data Collection Tabs Strings
      'data_collection': 'डेटा संग्रह',
      'awaiting_data': 'डायल डेटा की प्रतीक्षा...',
      'current_values': 'वर्तमान मान',
      'pattern_analysis': 'पैटर्न विश्लेषण',
      'angle_label': 'कोण (θ)',

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

class SpecialAngleDialApp extends StatefulWidget {
  const SpecialAngleDialApp({super.key});

  @override
  State<SpecialAngleDialApp> createState() => _SpecialAngleDialAppState();
}

class _SpecialAngleDialAppState extends State<SpecialAngleDialApp> {
  bool hasStarted = false;
  String lang = 'en';

  // UI State - Mutually Exclusive Sidebars
  bool isLeftSidebarOpen = true;
  bool isRightSidebarOpen = false;

  int currentStep = 0;
  bool showSuccessModal = false;

  double currentAngle = 0.0; // Start dial at 0 initially
  late TransformationController _canvasTransformController;
  Timer? _successTimer;

  // Drag logic state variable
  bool _isDraggingDial = false;

  @override
  void initState() {
    super.initState();
    _canvasTransformController = TransformationController();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _canvasTransformController.dispose();
    _successTimer?.cancel();
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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

        // Auto-open right panel during pattern reveal steps if left is closed
        if (currentStep >= 7) {
          if (!isLeftSidebarOpen && !isRightSidebarOpen) {
            isRightSidebarOpen = true;
          }
        }

        if (currentStep == 10) {
          playMathSuccess();
          Timer(const Duration(seconds: 1), () {
            if (mounted) {
              setState(() {
                showSuccessModal = true;
              });
              _successTimer = Timer(const Duration(seconds: 5), () {
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

  void _checkAngleMatch() {
    double? expectedAngle;
    String msg = '';

    if (currentStep == 1) {
      expectedAngle = 30.0;
      msg = 'msg_30_ok';
    } else if (currentStep == 2) {
      expectedAngle = 45.0;
      msg = 'msg_45_ok';
    } else if (currentStep == 3) {
      expectedAngle = 60.0;
      msg = 'msg_60_ok';
    } else if (currentStep == 4) {
      expectedAngle = 0.0;
      msg = 'msg_0_ok';
    } else if (currentStep == 5) {
      expectedAngle = 90.0;
      msg = 'msg_90_ok';
    }

    if (expectedAngle != null && (currentAngle - expectedAngle).abs() <= 1.0) {
      setState(() {
        currentAngle = expectedAngle!; // Snap perfectly to the target
        _isDraggingDial = false; // release drag hold
      });
      advanceStep(msg);
    }
  }

  void resetLab() {
    playMathStart();
    _successTimer?.cancel();
    setState(() {
      currentStep = 0;
      currentAngle = 0.0;
      showSuccessModal = false;
      hasStarted = false;
      isLeftSidebarOpen = true;
      isRightSidebarOpen = false;
      _isDraggingDial = false;
      _canvasTransformController.value = Matrix4.identity(); // Reset view
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
                      const Icon(Icons.speed, size: 80, color: accentPink),
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
                child: const Icon(Icons.speed, color: bgDark),
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
    String angleStr = currentAngle.round().toString();
    String sinStr = "?";
    String cosStr = "?";
    String tanStr = "?";

    if (angleStr == "0") {
      sinStr = "0";
      cosStr = "1";
      tanStr = "0";
    } else if (angleStr == "30") {
      sinStr = "1/2";
      cosStr = "√3/2";
      tanStr = "1/√3";
    } else if (angleStr == "45") {
      sinStr = "1/√2";
      cosStr = "1/√2";
      tanStr = "1";
    } else if (angleStr == "60") {
      sinStr = "√3/2";
      cosStr = "1/2";
      tanStr = "√3";
    } else if (angleStr == "90") {
      sinStr = "1";
      cosStr = "0";
      tanStr = "∞";
    } else {
      // Dynamic decimal calculation for non-special angles
      sinStr = math.sin(currentAngle * math.pi / 180).toStringAsFixed(2);
      cosStr = math.cos(currentAngle * math.pi / 180).toStringAsFixed(2);
      tanStr = (currentAngle == 90)
          ? "∞"
          : math.tan(currentAngle * math.pi / 180).toStringAsFixed(2);
    }

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

          if (currentStep < 1)
            _buildEmptyState()
          else ...[
            // Current Exact Values Block
            Text(
              AppStrings.get(lang, 'current_values').toUpperCase(),
              style: const TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        AppStrings.get(lang, 'angle_label'),
                        style: const TextStyle(
                          color: accentYellow,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "$angleStr°",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 40, color: Colors.white24),
                  _ExactValue(
                    title: "sin(θ)",
                    valueStr: sinStr,
                    color: accentBlue,
                  ),
                  _ExactValue(
                    title: "cos(θ)",
                    valueStr: cosStr,
                    color: accentGreen,
                  ),
                  _ExactValue(
                    title: "tan(θ)",
                    valueStr: tanStr,
                    color: accentPink,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Pattern Analysis Tables
            if (currentStep >= 7) ...[
              Text(
                AppStrings.get(lang, 'pattern_analysis').toUpperCase(),
                style: const TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accentGreen.withOpacity(0.5)),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildPatternCol(
                        "θ",
                        "0°",
                        "30°",
                        "45°",
                        "60°",
                        "90°",
                        Colors.white,
                      ),
                      const SizedBox(width: 20),
                      if (currentStep >= 7)
                        _buildPatternCol(
                          "sin(θ)",
                          "0",
                          "1/2",
                          "1/√2",
                          "√3/2",
                          "1",
                          accentBlue,
                        ),
                      const SizedBox(width: 20),
                      if (currentStep >= 8)
                        _buildPatternCol(
                          "cos(θ)",
                          "1",
                          "√3/2",
                          "1/√2",
                          "1/2",
                          "0",
                          accentGreen,
                        ),
                      const SizedBox(width: 20),
                      if (currentStep >= 9)
                        _buildPatternCol(
                          "tan(θ)",
                          "0",
                          "1/√3",
                          "1",
                          "√3",
                          "∞",
                          accentYellow,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildPatternCol(
    String title,
    String v0,
    String v30,
    String v45,
    String v60,
    String v90,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: 'monospace',
          ),
        ),
        Container(
          width: 50,
          height: 1,
          color: color.withOpacity(0.5),
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        _MiniVal(v0),
        const SizedBox(height: 8),
        _MiniVal(v30),
        const SizedBox(height: 8),
        _MiniVal(v45),
        const SizedBox(height: 8),
        _MiniVal(v60),
        const SizedBox(height: 8),
        _MiniVal(v90),
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
          // Background Color
          Positioned.fill(child: Container(color: bgDark)),

          // Interactive View (Move, Zoom in/out)
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _canvasTransformController,
              panEnabled: !_isDraggingDial, // Smooth panning when not dragging
              scaleEnabled: true,
              minScale: 0.2,
              maxScale: 4.0,
              boundaryMargin: const EdgeInsets.all(
                3000,
              ), // generous bounds for panning
              constrained: false,
              child: Container(
                width: 1000,
                height: 700,
                alignment: Alignment.center,
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (event) {
                    if (currentStep < 1 || currentStep > 5) return;

                    Offset origin = const Offset(100, 300);
                    double radius = 180.0;
                    double rad = currentAngle * math.pi / 180;
                    Offset handle = Offset(
                      origin.dx + radius * math.cos(rad),
                      origin.dy - radius * math.sin(rad),
                    );

                    // Allow drag anytime if hit near handle
                    if ((event.localPosition - handle).distance < 60.0) {
                      setState(() {
                        _isDraggingDial = true;
                      });
                    } else {
                      showToast(
                        AppStrings.get(lang, 'drag_inst'),
                        isError: false,
                        isSuccess: false,
                      );
                    }
                  },
                  onPointerMove: (event) {
                    if (!_isDraggingDial) return;
                    Offset origin = const Offset(100, 300);
                    double dx = event.localPosition.dx - origin.dx;
                    double dy = origin.dy - event.localPosition.dy;

                    double newAngle = math.atan2(dy, dx) * 180 / math.pi;

                    // Clamp strictly between 0 and 90
                    if (newAngle < 0) {
                      if (newAngle > -90)
                        newAngle = 0;
                      else
                        newAngle =
                            90; // dragging leftwards below axis, snap to 90
                    }
                    if (newAngle > 90) newAngle = 90;

                    setState(() {
                      currentAngle = newAngle;
                    });

                    _checkAngleMatch();
                  },
                  onPointerUp: (event) {
                    setState(() {
                      _isDraggingDial = false;
                    });
                  },
                  child: _buildSceneGraphics(),
                ),
              ),
            ),
          ),

          // Adjustable Slider Overlay (Visible after origin established)
          if (currentStep >= 1 && currentStep <= 5)
            Positioned(
              bottom: 40,
              left: 90,
              right: 90,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: bgPanel.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    const Text(
                      "0°",
                      style: TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: currentAngle,
                        min: 0,
                        max: 90,
                        divisions: 90,
                        activeColor: accentYellow,
                        inactiveColor: Colors.white24,
                        onChanged: (val) {
                          setState(() {
                            currentAngle = val;
                          });
                          _checkAngleMatch();
                        },
                      ),
                    ),
                    const Text(
                      "90°",
                      style: TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 15),
                    SizedBox(
                      width: 45,
                      child: Text(
                        "${currentAngle.round()}°",
                        style: const TextStyle(
                          color: accentYellow,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // (Reset View Button) - Positioned above the canvas
          Positioned(
            top: 20,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: bgPanel.withOpacity(0.8),
              foregroundColor: Colors.white,
              tooltip: 'Reset Canvas View',
              onPressed: () {
                playMathClick();
                _canvasTransformController.value = Matrix4.identity();
              },
              child: const Icon(Icons.center_focus_strong),
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
          CustomPaint(painter: GridPainter()),
          CustomPaint(
            size: const Size(500, 380),
            painter: AngleDialPainter(step: currentStep, angle: currentAngle),
          ),
          if (currentStep >= 1) ...[
            const Positioned(
              left: 80,
              top: 315,
              child: Text(
                "Origin (0,0)",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontFamily: 'monospace',
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
          text: "${AppStrings.get(lang, 'btn_drag')} 30° 👆",
          color: accentPink,
          onPressed: () {
            playMathClick();
            showToast(
              AppStrings.get(lang, 'drag_inst'),
              isError: false,
              isSuccess: false,
            );
          },
        );
      case 2:
        return _ControlButton(
          text: "${AppStrings.get(lang, 'btn_drag')} 45° 👆",
          color: accentYellow,
          onPressed: () {
            playMathClick();
            showToast(
              AppStrings.get(lang, 'drag_inst'),
              isError: false,
              isSuccess: false,
            );
          },
        );
      case 3:
        return _ControlButton(
          text: "${AppStrings.get(lang, 'btn_drag')} 60° 👆",
          color: accentGreen,
          onPressed: () {
            playMathClick();
            showToast(
              AppStrings.get(lang, 'drag_inst'),
              isError: false,
              isSuccess: false,
            );
          },
        );
      case 4:
        return _ControlButton(
          text: "${AppStrings.get(lang, 'btn_drag')} 0° 👆",
          color: accentRed,
          onPressed: () {
            playMathClick();
            showToast(
              AppStrings.get(lang, 'drag_inst'),
              isError: false,
              isSuccess: false,
            );
          },
        );
      case 5:
        return _ControlButton(
          text: "${AppStrings.get(lang, 'btn_drag')} 90° 👆",
          color: accentBlue,
          onPressed: () {
            playMathClick();
            showToast(
              AppStrings.get(lang, 'drag_inst'),
              isError: false,
              isSuccess: false,
            );
          },
        );
      case 6:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_pat_sin'),
          color: accentPink,
          onPressed: () => advanceStep('msg_sin_pat'),
        );
      case 7:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_pat_cos'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_cos_pat'),
        );
      case 8:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_pat_tan'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_tan_pat'),
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

// --- (SUB-WIDGETS) ---

class _MiniVal extends StatelessWidget {
  final String val;
  const _MiniVal(this.val);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      alignment: Alignment.center,
      child: Text(
        val,
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'monospace',
          color: Colors.white70,
        ),
      ),
    );
  }
}

class _ExactValue extends StatelessWidget {
  final String title;
  final String valueStr;
  final Color color;

  const _ExactValue({
    required this.title,
    required this.valueStr,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    Widget valueWidget;
    if (valueStr.contains('/')) {
      List<String> parts = valueStr.split('/');
      valueWidget = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            parts[0],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          Container(width: 25, height: 2, color: Colors.white),
          Text(
            parts[1],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      );
    } else {
      valueWidget = Text(
        valueStr,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(height: 50, child: Center(child: valueWidget)),
      ],
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

// --- (CUSTOM PAINTER) ---

class AngleDialPainter extends CustomPainter {
  final int step;
  final double angle;

  AngleDialPainter({required this.step, required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    Offset origin = const Offset(100, 300);
    double radius = 180.0;

    // 1. Draw Axis and Unit Circle Quadrant
    final axisPaint = Paint()
      ..color = Colors.white30
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(origin.dx - 20, origin.dy),
      Offset(origin.dx + radius + 40, origin.dy),
      axisPaint,
    ); // X
    canvas.drawLine(
      Offset(origin.dx, origin.dy + 20),
      Offset(origin.dx, origin.dy - radius - 40),
      axisPaint,
    ); // Y

    if (step >= 1) {
      final arcPaint = Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      _drawDashedArc(
        canvas,
        Rect.fromCircle(center: origin, radius: radius),
        0,
        -math.pi / 2,
        arcPaint,
        dashLength: 5,
        gapLength: 5,
      );
      canvas.drawCircle(origin, 4, Paint()..color = Colors.white);
    }

    double rad = angle * math.pi / 180;
    double dx = radius * math.cos(rad);
    double dy = radius * math.sin(rad);
    Offset pCircle = Offset(origin.dx + dx, origin.dy - dy);
    Offset pBase = Offset(pCircle.dx, origin.dy);

    if (step >= 1) {
      // Hypotenuse (Radius = 1)
      canvas.drawLine(
        origin,
        pCircle,
        Paint()
          ..color = accentRed
          ..strokeWidth = 4,
      );

      // Adjacent (Cosine)
      if (angle != 90) {
        canvas.drawLine(
          origin,
          pBase,
          Paint()
            ..color = accentGreen
            ..strokeWidth = 4,
        );
      }

      // Opposite (Sine)
      if (angle != 0) {
        canvas.drawLine(
          pBase,
          pCircle,
          Paint()
            ..color = accentBlue
            ..strokeWidth = 4,
        );
      }

      // Point on circle (Interactive Handle)
      canvas.drawCircle(
        pCircle,
        12,
        Paint()..color = accentYellow.withOpacity(0.5),
      );
      canvas.drawCircle(pCircle, 6, Paint()..color = accentYellow);

      // Draw Angle Arc
      if (angle > 0) {
        canvas.drawArc(
          Rect.fromCircle(center: origin, radius: 30),
          0,
          -rad,
          true,
          Paint()
            ..color = accentYellow.withOpacity(0.5)
            ..style = PaintingStyle.fill,
        );
      }

      //(Labels near lines)
      final textPainter = TextPainter(textDirection: TextDirection.ltr);

      void drawText(String text, Offset pos, Color color) {
        textPainter.text = TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        );
        textPainter.layout();
        canvas.drawRect(
          Rect.fromLTWH(
            pos.dx - textPainter.width / 2 - 2,
            pos.dy - textPainter.height / 2 - 2,
            textPainter.width + 4,
            textPainter.height + 4,
          ),
          Paint()..color = bgDark.withOpacity(0.7),
        );
        textPainter.paint(
          canvas,
          Offset(
            pos.dx - textPainter.width / 2,
            pos.dy - textPainter.height / 2,
          ),
        );
      }

      if (angle > 10 && angle < 80) {
        drawText(
          "1",
          Offset(origin.dx + dx / 2 - 15, origin.dy - dy / 2 - 15),
          accentRed,
        );
      }

      // Sine
      if (angle > 5) {
        String sinStr = _getSinLabel(angle.round());
        drawText(sinStr, Offset(pBase.dx + 20, origin.dy - dy / 2), accentBlue);
      }

      // Cosine
      if (angle < 85) {
        String cosStr = _getCosLabel(angle.round());
        drawText(
          cosStr,
          Offset(origin.dx + dx / 2, origin.dy + 20),
          accentGreen,
        );
      }
    }
  }

  String _getSinLabel(int ang) {
    if (ang == 0) return "0";
    if (ang == 30) return "1/2";
    if (ang == 45) return "1/√2";
    if (ang == 60) return "√3/2";
    if (ang == 90) return "1";
    return "sin";
  }

  String _getCosLabel(int ang) {
    if (ang == 0) return "1";
    if (ang == 30) return "√3/2";
    if (ang == 45) return "1/√2";
    if (ang == 60) return "1/2";
    if (ang == 90) return "0";
    return "cos";
  }

  @override
  bool shouldRepaint(covariant AngleDialPainter oldDelegate) {
    return oldDelegate.step != step || oldDelegate.angle != angle;
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.0;

    const double step = 30;
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
