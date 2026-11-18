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
      'app_title': 'CLINOMETER CONSTRUCTOR',
      'tagline': 'Building & Using a Clinometer',
      'init_btn': 'INITIALIZE WORKSHOP',
      'header_title': 'Clinometer Constructor',
      'header_subtitle': 'Class 10 • Heights & Distances',
      'phase_label': 'CONSTRUCTION & SURVEY',
      'step_label': 'Stage',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Survey Complete',
      'success_desc':
          'You have successfully constructed a clinometer and measured the target height!',
      'btn_restart': 'NEW SURVEY',
      's0': 'Procure Protractor Base.',
      's1': 'Attach Viewing Tube to straight edge.',
      's2': 'Suspend Plumb Line from center.',
      's3': 'Attach Plumb Bob (Weight) for tension.',
      's4': 'System Calibrated. Deploy to Field.',
      's5': 'Locate Target (Tree). Set Distance = 10m.',
      's6': 'Tilt Clinometer to sight the tree\'s apex.',
      's7': 'Read Angle of Elevation (θ) from the plumb line.',
      's8': 'Calculate opposite triangle height (h).',
      's9': 'Add eye-level (1.5m) for Total Height.',
      'btn_start': 'PROCURE PROTRACTOR',
      'btn_add_tube': 'ATTACH VIEWING TUBE',
      'btn_add_string': 'SUSPEND PLUMB LINE',
      'btn_add_bob': 'ATTACH PLUMB BOB',
      'btn_calibrate': 'CALIBRATE SYSTEM',
      'btn_field_deploy': 'DEPLOY TO FIELD',
      'btn_sight_apex': 'SIGHT TARGET APEX',
      'btn_verify_angle': 'VERIFY ANGLE',
      'btn_calc_h': 'CALCULATE HEIGHT (h)',
      'btn_calc_total': 'CALCULATE TOTAL HEIGHT',
      'msg_base_ok': 'Protractor base established.',
      'msg_tube_ok': 'Viewing tube attached.',
      'msg_string_ok': 'Plumb line suspended.',
      'msg_bob_ok': 'Weight attached. Gravity active.',
      'msg_cal_ok': 'Clinometer calibrated and ready.',
      'msg_field_ok': 'Field deployed. Distance to target: 10m.',
      'msg_sight_ok': 'Clinometer tilted. Apex sighted.',
      'msg_ang_ok': 'Angle verified: 45°.',
      'msg_h_ok': 'Triangle height calculated: 10m.',
      'msg_total_ok': 'Total height confirmed: 11.5m.',
      'msg_err': 'Incorrect value. Please try again.',
      'q_angle': 'What is the angle of elevation? (Read protractor)',
      'q_height': 'Solve for h: h = 10 × tan(45°)',
      'q_total': 'Total Height = h + Eye Level (1.5m)',

      // Data Collection Tabs Strings
      'data_collection': 'Data Collection',
      'awaiting_data': 'Awaiting construction data...',
      'components': 'Clinometer Components',
      'calc_h': '1. Triangle Height (h)',
      'calc_total': '2. Total Height (H)',

      // Tooltips & Labels
      'menu_tooltip': 'Main Menu',
      'reset_tooltip': 'Reset',
      'back_tooltip': 'Go Back',
    },
    'hi': {
      'app_title': 'क्लिनोमीटर कंस्ट्रक्टर',
      'tagline': 'क्लिनोमीटर का निर्माण और उपयोग',
      'init_btn': 'वर्कशॉप प्रारंभ करें',
      'header_title': 'क्लिनोमीटर कंस्ट्रक्टर',
      'header_subtitle': 'कक्षा 10 • ऊंचाई और दूरी',
      'phase_label': 'निर्माण और सर्वेक्षण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'सर्वेक्षण पूर्ण',
      'success_desc':
          'आपने सफलतापूर्वक एक क्लिनोमीटर बनाया है और लक्ष्य की ऊंचाई मापी है!',
      'btn_restart': 'नया सर्वेक्षण',
      's0': 'चांदा (Protractor) आधार प्राप्त करें।',
      's1': 'सीधे किनारे पर व्यूइंग ट्यूब संलग्न करें।',
      's2': 'केंद्र से साहुल रेखा (Plumb Line) लटकाएं।',
      's3': 'तनाव के लिए प्लंब बॉब (वजन) संलग्न करें।',
      's4': 'सिस्टम कैलिब्रेटेड। फील्ड में तैनात करें।',
      's5': 'लक्ष्य (पेड़) का पता लगाएँ। दूरी = 10m सेट करें।',
      's6': 'पेड़ के शीर्ष को देखने के लिए क्लिनोमीटर को झुकाएं।',
      's7': 'साहुल रेखा से उन्नयन कोण (θ) पढ़ें।',
      's8': 'विपरीत त्रिभुज ऊंचाई (h) की गणना करें।',
      's9': 'कुल ऊंचाई के लिए आंख-स्तर (1.5m) जोड़ें।',
      'btn_start': 'चांदा प्राप्त करें',
      'btn_add_tube': 'व्यूइंग ट्यूब संलग्न करें',
      'btn_add_string': 'साहुल रेखा लटकाएं',
      'btn_add_bob': 'प्लंब बॉब संलग्न करें',
      'btn_calibrate': 'सिस्टम कैलिब्रेट करें',
      'btn_field_deploy': 'फील्ड में तैनात करें',
      'btn_sight_apex': 'लक्ष्य का शीर्ष देखें',
      'btn_verify_angle': 'कोण सत्यापित करें',
      'btn_calc_h': 'ऊंचाई (h) की गणना करें',
      'btn_calc_total': 'कुल ऊंचाई की गणना करें',
      'msg_base_ok': 'चांदा आधार स्थापित।',
      'msg_tube_ok': 'व्यूइंग ट्यूब संलग्न।',
      'msg_string_ok': 'साहुल रेखा लटकाई गई।',
      'msg_bob_ok': 'वजन संलग्न। गुरुत्वाकर्षण सक्रिय।',
      'msg_cal_ok': 'क्लिनोमीटर कैलिब्रेटेड और तैयार है।',
      'msg_field_ok': 'फील्ड में तैनात। लक्ष्य से दूरी: 10m।',
      'msg_sight_ok': 'क्लिनोमीटर झुका हुआ। शीर्ष देखा गया।',
      'msg_ang_ok': 'कोण सत्यापित: 45°।',
      'msg_h_ok': 'त्रिभुज ऊंचाई की गणना: 10m।',
      'msg_total_ok': 'कुल ऊंचाई की पुष्टि: 11.5m।',
      'msg_err': 'गलत मान। कृपया पुनः प्रयास करें।',
      'q_angle': 'उन्नयन कोण क्या है? (चांदा पढ़ें)',
      'q_height': 'h के लिए हल करें: h = 10 × tan(45°)',
      'q_total': 'कुल ऊंचाई = h + आँख का स्तर (1.5m)',

      // Data Collection Tabs Strings
      'data_collection': 'डेटा संग्रह',
      'awaiting_data': 'निर्माण डेटा की प्रतीक्षा...',
      'components': 'क्लिनोमीटर घटक',
      'calc_h': '1. त्रिभुज ऊंचाई (h)',
      'calc_total': '2. कुल ऊंचाई (H)',

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

class ClinometerConstructorApp extends StatefulWidget {
  const ClinometerConstructorApp({super.key});

  @override
  State<ClinometerConstructorApp> createState() =>
      _ClinometerConstructorAppState();
}

class _ClinometerConstructorAppState extends State<ClinometerConstructorApp>
    with TickerProviderStateMixin {
  bool hasStarted = false;
  String lang = 'en';

  // UI State - Mutually Exclusive Sidebars
  bool isLeftSidebarOpen = true;
  bool isRightSidebarOpen = false;

  // Activity State
  int currentStep = 0;
  bool showSuccessModal = false;

  // Animation State
  double tiltAngle = 0.0;
  late AnimationController _tiltController;
  late Animation<double> _tiltAnimation;

  // Input Controllers
  final TextEditingController _inpAns = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tiltController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _tiltController.dispose();
    _inpAns.dispose();
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
    if (currentStep < 10) {
      playMathClick();
      setState(() {
        currentStep++;
        if (msgKey.isNotEmpty) {
          showToast(AppStrings.get(lang, msgKey));
        }

        // Trigger tilt animation when transitioning to the angle verification step
        if (currentStep == 7) {
          _animateTilt(45.0);
        }

        _inpAns.clear();

        // Auto-open right panel during specific calculation steps if left is closed
        if (currentStep >= 8) {
          if (!isLeftSidebarOpen && !isRightSidebarOpen) {
            isRightSidebarOpen = true;
          }
        }

        if (currentStep == 10) {
          playMathSuccess();
          Timer(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                showSuccessModal = true;
              });
              // Remove popup after 5 seconds
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

  void _animateTilt(double targetAngle) {
    _tiltAnimation =
        Tween<double>(begin: tiltAngle, end: targetAngle).animate(
          CurvedAnimation(parent: _tiltController, curve: Curves.easeInOut),
        )..addListener(() {
          setState(() {
            tiltAngle = _tiltAnimation.value;
          });
        });
    _tiltController.forward(from: 0.0);
  }

  void verifyInput(String expectedValue, String successMsgKey) {
    if (_inpAns.text.trim() == expectedValue) {
      advanceStep(successMsgKey);
    } else {
      showToast(
        AppStrings.get(lang, 'msg_err'),
        isError: true,
        isSuccess: false,
      );
    }
  }

  void resetLab() {
    playMathStart();
    setState(() {
      currentStep = 0;
      tiltAngle = 0.0;
      showSuccessModal = false;
      hasStarted = false;
      isLeftSidebarOpen = true;
      isRightSidebarOpen = false;
      _inpAns.clear();
      _tiltController.reset();
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
                        Icons.build_circle,
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

          // Dynamic Content based on Phase
          if (currentStep < 6) ...[
            Text(
              AppStrings.get(lang, 'components').toUpperCase(),
              style: const TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 15),
            Container(
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
                  _ChecklistItem(
                    text: "Protractor Base",
                    isChecked: currentStep >= 1,
                  ),
                  const SizedBox(height: 10),
                  _ChecklistItem(
                    text: "Viewing Tube",
                    isChecked: currentStep >= 2,
                  ),
                  const SizedBox(height: 10),
                  _ChecklistItem(
                    text: "Plumb Line",
                    isChecked: currentStep >= 3,
                  ),
                  const SizedBox(height: 10),
                  _ChecklistItem(
                    text: "Plumb Bob (Weight)",
                    isChecked: currentStep >= 4,
                  ),
                ],
              ),
            ),
          ] else ...[
            // Calculation of Triangle Height (h)
            if (currentStep >= 8)
              _buildDataBlock(
                AppStrings.get(lang, 'calc_h'),
                "tan(45°) = h / 10",
                currentStep >= 9 ? "h = 10 × tan(45°)" : "...",
                currentStep >= 9 ? "h = 10m" : "",
                currentStep == 8,
              ),

            const SizedBox(height: 20),

            // Calculation of Total Height (H)
            if (currentStep >= 9)
              _buildDataBlock(
                AppStrings.get(lang, 'calc_total'),
                "H = h + Eye Level",
                currentStep >= 10 ? "H = 10 + 1.5" : "...",
                currentStep >= 10 ? "H = 11.5m" : "",
                currentStep == 9,
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
          if (currentStep < 6)
            // Construction Phase - Big Clinometer
            CustomPaint(
              size: const Size(500, 380),
              painter: ClinometerBuilderPainter(step: currentStep),
            )
          else
            // Survey Phase - Field View
            CustomPaint(
              size: const Size(500, 380),
              painter: FieldSurveyPainter(
                step: currentStep,
                tiltAngle: tiltAngle,
              ),
            ),

          // --- LABELS & MEASUREMENTS FOR FIELD VIEW ---
          if (currentStep >= 6) ...[
            const Positioned(
              left: 290,
              top: 310,
              child: Text(
                "Tree",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
            const Positioned(
              left: 60,
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
            const Positioned(
              left: 165,
              top: 310,
              child: Text(
                "d = 10m",
                style: TextStyle(
                  color: accentYellow,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Positioned(
              left: 10,
              top: 220,
              child: Text(
                "Eye: 1.5m",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
          ],

          if (currentStep >= 7) ...[
            const Positioned(
              left: 150,
              top: 170,
              child: Text(
                "Line of Sight",
                style: TextStyle(color: accentPink, fontSize: 12),
              ),
            ),
          ],

          if (currentStep >= 8) ...[
            const Positioned(
              left: 130,
              top: 230,
              child: Text(
                "45°",
                style: TextStyle(
                  color: accentYellow,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],

          if (currentStep >= 9) ...[
            Positioned(
              left: 310,
              top: 150,
              child: Text(
                "h = ${currentStep >= 10 ? '10m' : '?'}",
                style: const TextStyle(
                  color: accentBlue,
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
          onPressed: () => advanceStep('msg_base_ok'),
        );
      case 1:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_add_tube'),
          color: accentPink,
          onPressed: () => advanceStep('msg_tube_ok'),
        );
      case 2:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_add_string'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_string_ok'),
        );
      case 3:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_add_bob'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_bob_ok'),
        );
      case 4:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_calibrate'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_cal_ok'),
        );
      case 5:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_field_deploy'),
          color: accentPink,
          onPressed: () => advanceStep('msg_field_ok'),
        );
      case 6:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_sight_apex'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_sight_ok'),
        );
      case 7:
        return _InputControlBlock(
          question: AppStrings.get(lang, 'q_angle'),
          hint: 'θ = ?',
          controller: _inpAns,
          btnText: AppStrings.get(lang, 'btn_verify_angle'),
          onVerify: () => verifyInput('45', 'msg_ang_ok'),
        );
      case 8:
        return _InputControlBlock(
          question: AppStrings.get(lang, 'q_height'),
          hint: 'h = ?',
          controller: _inpAns,
          btnText: AppStrings.get(lang, 'btn_calc_h'),
          onVerify: () => verifyInput('10', 'msg_h_ok'),
        );
      case 9:
        return _InputControlBlock(
          question: AppStrings.get(lang, 'q_total'),
          hint: 'Total = ?',
          controller: _inpAns,
          btnText: AppStrings.get(lang, 'btn_calc_total'),
          onVerify: () => verifyInput('11.5', 'msg_total_ok'),
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

class _ChecklistItem extends StatelessWidget {
  final String text;
  final bool isChecked;

  const _ChecklistItem({required this.text, required this.isChecked});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isChecked ? accentGreen : Colors.white30,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isChecked ? Colors.white : Colors.white54,
              fontSize: 16,
              fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _InputControlBlock extends StatelessWidget {
  final String question;
  final String hint;
  final TextEditingController controller;
  final String btnText;
  final VoidCallback onVerify;

  const _InputControlBlock({
    required this.question,
    required this.hint,
    required this.controller,
    required this.btnText,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
            filled: true,
            fillColor: Colors.black45,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: accentBlue.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: accentPink),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _ControlButton(text: btnText, color: accentGreen, onPressed: onVerify),
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

// --- CUSTOM PAINTERS ---

class ClinometerBuilderPainter extends CustomPainter {
  final int step;

  ClinometerBuilderPainter({required this.step});

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = const Offset(250, 150); // Top center of protractor
    double radius = 120;

    // 0. Base Protractor
    if (step >= 1) {
      final pPaint = Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.fill;
      final pStroke = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        0,
        math.pi,
        true,
        pPaint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        0,
        math.pi,
        true,
        pStroke,
      );

      // Draw Ticks
      for (int i = 0; i <= 18; i++) {
        double angle = i * 10 * math.pi / 180;
        double rStart = i % 9 == 0 ? radius - 20 : radius - 10;
        Offset start = Offset(
          center.dx + rStart * math.cos(angle),
          center.dy + rStart * math.sin(angle),
        );
        Offset end = Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        );
        canvas.drawLine(
          start,
          end,
          Paint()
            ..color = Colors.white
            ..strokeWidth = 1,
        );

        // 90 degree mark label
        if (i == 9) {
          final tp = TextPainter(
            text: const TextSpan(
              text: "90°",
              style: TextStyle(
                color: accentYellow,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(
            canvas,
            Offset(center.dx - tp.width / 2, center.dy + radius - 35),
          );
        }
      }
    }

    // 1. Viewing Tube
    if (step >= 2) {
      final tPaint = Paint()
        ..color = accentBlue
        ..strokeWidth = 15
        ..strokeCap = StrokeCap.square;
      canvas.drawLine(
        Offset(center.dx - radius - 20, center.dy - 10),
        Offset(center.dx + radius + 20, center.dy - 10),
        tPaint,
      );
      // Tube hole
      canvas.drawLine(
        Offset(center.dx - radius - 20, center.dy - 10),
        Offset(center.dx + radius + 20, center.dy - 10),
        Paint()
          ..color = bgDark
          ..strokeWidth = 5,
      );
    }

    // 2. Plumb Line
    if (step >= 3) {
      canvas.drawLine(
        center,
        Offset(center.dx, center.dy + radius + 40),
        Paint()
          ..color = accentPink
          ..strokeWidth = 2,
      );
    }

    // 3. Plumb Bob
    if (step >= 4) {
      canvas.drawCircle(
        Offset(center.dx, center.dy + radius + 40),
        10,
        Paint()..color = accentYellow,
      );
    }

    // 4. Calibration Flash
    if (step >= 5) {
      canvas.drawCircle(center, 4, Paint()..color = accentGreen);
    }
  }

  @override
  bool shouldRepaint(covariant ClinometerBuilderPainter oldDelegate) =>
      oldDelegate.step != step;
}

class FieldSurveyPainter extends CustomPainter {
  final int step;
  final double tiltAngle;

  FieldSurveyPainter({required this.step, required this.tiltAngle});

  @override
  void paint(Canvas canvas, Size size) {
    // Coordinate system
    Offset obsEye = const Offset(100, 260); // Observer's eye
    Offset obsBase = const Offset(100, 300); // Observer's feet
    Offset treeBase = const Offset(300, 300);
    Offset treeTop = const Offset(
      300,
      60,
    ); // Height diff = 200, dist = 200 -> exact 45 degrees

    // Draw Realistic Ground
    canvas.drawRect(
      const Rect.fromLTRB(-2000, 300, 2000, 2000), // Dirt
      Paint()..color = const Color(0xFF3E2723),
    );
    canvas.drawRect(
      const Rect.fromLTRB(-2000, 300, 2000, 310), // Grass layer
      Paint()..color = const Color(0xFF2E7D32),
    );

    // Draw Realistic Tree Trunk
    Path trunk = Path()
      ..moveTo(treeBase.dx - 12, treeBase.dy)
      ..lineTo(treeBase.dx - 18, treeBase.dy + 10) // Left root
      ..lineTo(treeBase.dx + 18, treeBase.dy + 10) // Right root
      ..lineTo(treeBase.dx + 12, treeBase.dy)
      ..lineTo(treeTop.dx + 6, treeTop.dy + 20)
      ..lineTo(treeTop.dx - 6, treeTop.dy + 20)
      ..close();
    canvas.drawPath(trunk, Paint()..color = const Color(0xFF5D4037));

    // Bark details
    canvas.drawLine(
      Offset(treeBase.dx - 5, treeBase.dy),
      Offset(treeTop.dx - 2, treeTop.dy + 40),
      Paint()
        ..color = const Color(0xFF4E342E)
        ..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(treeBase.dx + 5, treeBase.dy - 20),
      Offset(treeTop.dx + 2, treeTop.dy + 60),
      Paint()
        ..color = const Color(0xFF4E342E)
        ..strokeWidth = 1.5,
    );

    // Draw Realistic Tree Canopy
    Paint leafDark = Paint()..color = const Color(0xFF2E7D32);
    Paint leafLight = Paint()..color = const Color(0xFF4CAF50);

    // Dark background leaves
    canvas.drawCircle(treeTop, 50, leafDark);
    canvas.drawCircle(Offset(treeTop.dx - 30, treeTop.dy + 30), 45, leafDark);
    canvas.drawCircle(Offset(treeTop.dx + 30, treeTop.dy + 30), 45, leafDark);
    canvas.drawCircle(Offset(treeTop.dx - 25, treeTop.dy - 20), 40, leafDark);
    canvas.drawCircle(Offset(treeTop.dx + 25, treeTop.dy - 20), 40, leafDark);

    // Light foreground leaves
    canvas.drawCircle(treeTop, 40, leafLight);
    canvas.drawCircle(Offset(treeTop.dx - 30, treeTop.dy + 30), 35, leafLight);
    canvas.drawCircle(Offset(treeTop.dx + 30, treeTop.dy + 30), 35, leafLight);
    canvas.drawCircle(Offset(treeTop.dx - 25, treeTop.dy - 20), 30, leafLight);
    canvas.drawCircle(Offset(treeTop.dx + 25, treeTop.dy - 20), 30, leafLight);

    // Draw Observer
    final pLine = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    canvas.drawLine(obsEye, obsBase, pLine); // body
    canvas.drawCircle(
      const Offset(100, 250),
      10,
      Paint()..color = Colors.white,
    ); // head

    // Draw Horizontal Line
    if (step >= 6) {
      _drawDashedLine(
        canvas,
        obsEye,
        Offset(treeBase.dx, obsEye.dy),
        Paint()
          ..color = Colors.white30
          ..strokeWidth = 1,
      );
    }

    // Draw Line of Sight
    if (step >= 7) {
      _drawDashedLine(
        canvas,
        obsEye,
        treeTop,
        Paint()
          ..color = accentPink
          ..strokeWidth = 2,
      );
    }

    // Draw Angle Arc
    if (step >= 8) {
      double angleRad = math.atan2(
        obsEye.dy - treeTop.dy,
        treeBase.dx - obsEye.dx,
      );
      canvas.drawArc(
        Rect.fromCircle(center: obsEye, radius: 40),
        0,
        -angleRad,
        true,
        Paint()
          ..color = accentYellow.withOpacity(0.5)
          ..style = PaintingStyle.fill,
      );
    }

    // --- Draw Mini Clinometer ---
    canvas.save();
    canvas.translate(obsEye.dx, obsEye.dy);

    // Rotate the clinometer body
    canvas.rotate(-tiltAngle * math.pi / 180);

    double cRad = 30;
    final cPaint = Paint()
      ..color = accentBlue.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    final cStroke = Paint()
      ..color = accentBlue
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: cRad),
      0,
      math.pi,
      true,
      cPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: cRad),
      0,
      math.pi,
      true,
      cStroke,
    );

    // Tube
    canvas.drawLine(
      Offset(-cRad - 10, 0),
      Offset(cRad + 10, 0),
      Paint()
        ..color = accentPink
        ..strokeWidth = 4,
    );

    canvas.restore(); // Undo rotation so string drops straight down

    // Draw String straight down from obsEye
    double stringLen = 45;
    canvas.drawLine(
      obsEye,
      Offset(obsEye.dx, obsEye.dy + stringLen),
      Paint()
        ..color = accentYellow
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(
      Offset(obsEye.dx, obsEye.dy + stringLen),
      3,
      Paint()..color = accentYellow,
    );
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
  bool shouldRepaint(covariant FieldSurveyPainter oldDelegate) {
    return oldDelegate.step != step || oldDelegate.tiltAngle != tiltAngle;
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
