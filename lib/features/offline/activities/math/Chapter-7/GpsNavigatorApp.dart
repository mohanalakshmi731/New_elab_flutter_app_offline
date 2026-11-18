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
      'app_title': 'THE GPS NAVIGATOR',
      'tagline': 'The Distance Formula',
      'init_btn': 'INITIALIZE GPS',
      'header_title': 'The GPS Navigator',
      'header_subtitle': 'Class 10 • Coordinate Geometry',
      'phase_label': 'NAVIGATION PHASE',
      'step_label': 'Stage',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Navigation Complete',
      'success_desc':
          'You have successfully applied the Distance Formula to navigate the grid.',
      'btn_restart': 'NEW MISSION',
      's0': 'Initialize Grid. Drone at Origin (0,0).',
      's1': 'Locate Base Alpha at (3, 4).',
      's2': 'Determine horizontal & vertical shifts (Δx, Δy).',
      's3': 'Apply Pythagorean Theorem.',
      's4': 'Calculate distance & navigate to Alpha.',
      's5': 'Locate Base Beta at (8, 16).',
      's6': 'Determine shifts from Alpha (Δx, Δy).',
      's7': 'Apply Generalized Distance Formula.',
      's8': 'Calculate distance & navigate to Beta.',
      's9': 'Navigation Sequence Complete.',
      'btn_start': 'ESTABLISH ORIGIN',
      'btn_loc_alpha': 'LOCATE ALPHA (3,4)',
      'btn_show_deltas1': 'SHOW Δx & Δy',
      'btn_apply_pyth': 'APPLY PYTHAGORAS',
      'btn_calc_nav1': 'CALCULATE & NAVIGATE',
      'btn_loc_beta': 'LOCATE BETA (8,16)',
      'btn_show_deltas2': 'SHOW SHIFTS',
      'btn_apply_dist': 'APPLY FORMULA',
      'btn_calc_nav2': 'CALCULATE & NAVIGATE',
      'btn_complete': 'FINALIZE REPORT',
      'msg_obs_ok': 'Grid initialized at (0,0).',
      'msg_alpha_ok': 'Base Alpha marked at (3,4).',
      'msg_d1_ok': 'Δx = 3, Δy = 4 established.',
      'msg_pyth_ok': 'Formula ready: d = √(3² + 4²).',
      'msg_nav1_ok': 'Distance = 5. Drone arrived at Alpha.',
      'msg_beta_ok': 'Base Beta marked at (8,16).',
      'msg_d2_ok': 'Δx = 8-3=5, Δy = 16-4=12.',
      'msg_form_ok': 'Formula ready: d = √(5² + 12²).',
      'msg_nav2_ok': 'Distance = 13. Drone arrived at Beta.',
      'msg_err': 'Navigation error.',

      // Data Collection Tabs Strings
      'data_collection': 'Data Collection',
      'awaiting_data': 'Awaiting flight data...',
      'pyth_base': 'Pythagorean Base',
      'dist_form': 'Distance Formula',
      'dist_alpha': 'Distance to Alpha',
      'dist_beta': 'Distance to Beta',

      // Tooltips & Labels
      'menu_tooltip': 'Main Menu',
      'reset_tooltip': 'Reset',
      'back_tooltip': 'Go Back',
      'alpha_label': 'Alpha',
      'beta_label': 'Beta',
    },
    'hi': {
      'app_title': 'GPS नेविगेटर',
      'tagline': 'दूरी सूत्र (Distance Formula)',
      'init_btn': 'GPS प्रारंभ करें',
      'header_title': 'GPS नेविगेटर',
      'header_subtitle': 'कक्षा 10 • निर्देशांक ज्यामिति',
      'phase_label': 'नेविगेशन चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'नेविगेशन पूर्ण',
      'success_desc':
          'आपने ग्रिड को नेविगेट करने के लिए सफलतापूर्वक दूरी सूत्र लागू किया है।',
      'btn_restart': 'नया मिशन',
      's0': 'ग्रिड प्रारंभ करें। ड्रोन मूल बिंदु (0,0) पर है।',
      's1': 'बेस अल्फा को (3, 4) पर खोजें।',
      's2': 'क्षैतिज और ऊर्ध्वाधर बदलाव निर्धारित करें (Δx, Δy)।',
      's3': 'पाइथागोरस प्रमेय लागू करें।',
      's4': 'दूरी की गणना करें और अल्फा पर जाएँ।',
      's5': 'बेस बीटा को (8, 16) पर खोजें।',
      's6': 'अल्फा से बदलाव निर्धारित करें (Δx, Δy)।',
      's7': 'सामान्यीकृत दूरी सूत्र लागू करें।',
      's8': 'दूरी की गणना करें और बीटा पर जाएँ।',
      's9': 'नेविगेशन अनुक्रम पूर्ण।',
      'btn_start': 'मूल बिंदु स्थापित करें',
      'btn_loc_alpha': 'अल्फा खोजें (3,4)',
      'btn_show_deltas1': 'Δx और Δy दिखाएं',
      'btn_apply_pyth': 'पाइथागोरस लागू करें',
      'btn_calc_nav1': 'गणना और नेविगेट करें',
      'btn_loc_beta': 'बीटा खोजें (8,16)',
      'btn_show_deltas2': 'बदलाव दिखाएं',
      'btn_apply_dist': 'सूत्र लागू करें',
      'btn_calc_nav2': 'गणना और नेविगेट करें',
      'btn_complete': 'रिपोर्ट पूरी करें',
      'msg_obs_ok': 'ग्रिड (0,0) पर प्रारंभ हुआ।',
      'msg_alpha_ok': 'बेस अल्फा (3,4) पर चिह्नित।',
      'msg_d1_ok': 'Δx = 3, Δy = 4 स्थापित।',
      'msg_pyth_ok': 'सूत्र तैयार: d = √(3² + 4²)।',
      'msg_nav1_ok': 'दूरी = 5. ड्रोन अल्फा पर पहुंचा।',
      'msg_beta_ok': 'बेस बीटा (8,16) पर चिह्नित।',
      'msg_d2_ok': 'Δx = 8-3=5, Δy = 16-4=12.',
      'msg_form_ok': 'सूत्र तैयार: d = √(5² + 12²)।',
      'msg_nav2_ok': 'दूरी = 13. ड्रोन बीटा पर पहुंचा।',
      'msg_err': 'नेविगेशन त्रुटि।',

      // Data Collection Tabs Strings
      'data_collection': 'डेटा संग्रह',
      'awaiting_data': 'उड़ान डेटा की प्रतीक्षा...',
      'pyth_base': 'पाइथागोरस आधार',
      'dist_form': 'दूरी सूत्र',
      'dist_alpha': 'अल्फा की दूरी',
      'dist_beta': 'बीटा की दूरी',

      // Tooltips & Labels
      'menu_tooltip': 'मुख्य मेनू',
      'reset_tooltip': 'रीसेट करें',
      'back_tooltip': 'पीछे जाएं',
      'alpha_label': 'अल्फा',
      'beta_label': 'बीटा',
    },
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['en']![key] ?? key;
  }
}

class GpsNavigatorApp extends StatefulWidget {
  const GpsNavigatorApp({super.key});

  @override
  State<GpsNavigatorApp> createState() => _GpsNavigatorAppState();
}

class _GpsNavigatorAppState extends State<GpsNavigatorApp>
    with TickerProviderStateMixin {
  bool hasStarted = false;
  String lang = 'en';

  // यूआई स्टेट (UI State) - Mutually Exclusive Sidebars
  bool isLeftSidebarOpen = true;
  bool isRightSidebarOpen = false;

  // गतिविधि स्टेट (Activity State)
  int currentStep = 0;
  bool showSuccessModal = false;

  // ड्रोन स्टेट (Drone State)
  double droneX = 0.0;
  double droneY = 0.0;

  late AnimationController _droneAnimController;
  late Animation<double> _droneXAnim;
  late Animation<double> _droneYAnim;

  @override
  void initState() {
    super.initState();
    _droneAnimController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..addListener(() {
            setState(() {
              droneX = _droneXAnim.value;
              droneY = _droneYAnim.value;
            });
          });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _droneAnimController.dispose();
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
        backgroundColor: Colors.grey[200],
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
    if (currentStep < 9) {
      playMathClick();
      setState(() {
        currentStep++;
        if (msgKey.isNotEmpty) {
          showToast(AppStrings.get(lang, msgKey));
        }

        // एनिमेशन ट्रिगर करें (Trigger animations)
        // Drone moves AFTER Calculate & Navigate button is clicked
        if (currentStep == 5) {
          _animateDrone(0, 0, 3, 4);
          // Auto-open right panel to show math resolving if left is closed
          if (!isLeftSidebarOpen && !isRightSidebarOpen)
            isRightSidebarOpen = true;
        } else if (currentStep == 9) {
          _animateDrone(3, 4, 8, 16);
          if (!isLeftSidebarOpen && !isRightSidebarOpen)
            isRightSidebarOpen = true;
        }

        // मिशन पूरा होने को संभालें (Handle mission completion)
        if (currentStep == 9) {
          playMathSuccess();
          Timer(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                showSuccessModal = true;
              });
              // 5 सेकंड के बाद पॉपअप स्वतः छिपाएं (Auto hide popup)
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

  void _animateDrone(double startX, double startY, double endX, double endY) {
    _droneXAnim = Tween<double>(begin: startX, end: endX).animate(
      CurvedAnimation(parent: _droneAnimController, curve: Curves.easeInOut),
    );
    _droneYAnim = Tween<double>(begin: startY, end: endY).animate(
      CurvedAnimation(parent: _droneAnimController, curve: Curves.easeInOut),
    );
    _droneAnimController.forward(from: 0.0);
  }

  void resetLab() {
    playMathStart();
    setState(() {
      currentStep = 0;
      droneX = 0.0;
      droneY = 0.0;
      showSuccessModal = false;
      hasStarted = false;
      isLeftSidebarOpen = true; // रीसेट पर बायां साइडबार खोलें
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
                      const Icon(Icons.gps_fixed, size: 80, color: accentPink),
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
                child: const Icon(Icons.map, color: bgDark),
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

  //  (Right Side Data Collection Panel)
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

          // Equation Block 1
          if (currentStep >= 3 && currentStep < 7)
            _buildDataBlock(
              AppStrings.get(lang, 'pyth_base'),
              "d = √(Δx² + Δy²)",
              "d = √(3² + 4²)",
              currentStep >= 3,
            )
          else if (currentStep >= 7)
            _buildDataBlock(
              AppStrings.get(lang, 'dist_form'),
              "d = √((x₂-x₁)² + (y₂-y₁)²)",
              "d = √((8-3)² + (16-4)²)",
              currentStep >= 7,
            )
          else
            _buildEmptyState(), // "Awaiting data..."

          const SizedBox(height: 30),

          // Equation Block 2
          if (currentStep >= 4 && currentStep < 7)
            _buildResultBlock(
              AppStrings.get(lang, 'dist_alpha'),
              "d = √(9 + 16)",
              "d = 5",
            )
          else if (currentStep >= 8)
            _buildResultBlock(
              AppStrings.get(lang, 'dist_beta'),
              "d = √(5² + 12²)",
              "d = 13",
            ),
        ],
      ),
    );
  }

  // Helper Widget for Data Blocks
  Widget _buildDataBlock(
    String title,
    String equation1,
    String equation2,
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
            equation1,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 20,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            equation2,
            style: TextStyle(
              color: highlight ? accentBlue : Colors.white24,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              fontFamily: 'monospace',
            ),
          ),
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
  // Removed the bottom _buildEquationPanel entirely from here.
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
                      painter: GpsPainter(
                        step: currentStep,
                        droneX: droneX,
                        droneY: droneY,
                        lang: lang,
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
                          Icons.gps_fixed,
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
          text: AppStrings.get(lang, 'btn_loc_alpha'),
          color: accentPink,
          onPressed: () => advanceStep('msg_alpha_ok'),
        );
      case 2:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_show_deltas1'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_d1_ok'),
        );
      case 3:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_apply_pyth'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_pyth_ok'),
        );
      case 4:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_calc_nav1'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_nav1_ok'),
        );
      case 5:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_loc_beta'),
          color: accentPink,
          onPressed: () => advanceStep('msg_beta_ok'),
        );
      case 6:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_show_deltas2'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_d2_ok'),
        );
      case 7:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_apply_dist'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_form_ok'),
        );
      case 8:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_calc_nav2'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_nav2_ok'),
        );
      case 9:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_complete'),
          color: accentYellow,
          onPressed: () => advanceStep(''),
        );
      default:
        return const SizedBox();
    }
  }
}

// --- उप-विजेट (SUB-WIDGETS) ---

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

class GpsPainter extends CustomPainter {
  final int step;
  final double droneX;
  final double droneY;
  final String lang;

  // समन्वय प्रणाली मैपिंग (Coordinate System Mapping)
  final double ox = 50.0; // Origin X
  final double oy = 350.0; // Origin Y
  final double scale = 18.0; // पिक्सल प्रति यूनिट (Pixels per unit)

  GpsPainter({
    required this.step,
    required this.droneX,
    required this.droneY,
    required this.lang,
  });

  Offset _mapPt(double x, double y) {
    return Offset(ox + x * scale, oy - y * scale);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. (Draw Grid Background)
    final gridPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.0;

    // ऊर्ध्वाधर रेखाएं (Vertical lines)
    for (int i = 0; i <= 22; i++) {
      canvas.drawLine(
        _mapPt(i.toDouble(), 0),
        _mapPt(i.toDouble(), 18),
        gridPaint,
      );
    }
    // क्षैतिज रेखाएं (Horizontal lines)
    for (int i = 0; i <= 18; i++) {
      canvas.drawLine(
        _mapPt(0, i.toDouble()),
        _mapPt(22, i.toDouble()),
        gridPaint,
      );
    }

    // 2. अक्ष बनाएं (Draw Axes)
    final axisPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 2.0;
    canvas.drawLine(_mapPt(0, 0), _mapPt(22, 0), axisPaint); // X
    canvas.drawLine(_mapPt(0, 0), _mapPt(0, 18), axisPaint); // Y

    // अक्षों के लिए लेबल (Labels for axes)
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

    drawText("X", _mapPt(22.5, 0), Colors.white54, 14, FontWeight.bold);
    drawText("Y", _mapPt(0, 18.5), Colors.white54, 14, FontWeight.bold);

    // टिक मार्क (Tick marks)
    for (int i = 2; i <= 20; i += 2) {
      drawText(i.toString(), _mapPt(i.toDouble(), -1), Colors.white30, 10);
    }
    for (int i = 2; i <= 16; i += 2) {
      drawText(i.toString(), _mapPt(-1.5, i.toDouble()), Colors.white30, 10);
    }

    // 3. चरणों के आधार पर तत्व बनाएं (Draw Elements based on Steps)
    if (step >= 1) {
      // मूल बिंदु (Origin) - SHIFTED TO STEP 1
      drawText("(0,0)", _mapPt(-2, -1.5), Colors.white, 12, FontWeight.bold);
      canvas.drawCircle(_mapPt(0, 0), 4, Paint()..color = Colors.white);
    }

    if (step >= 2) {
      // अल्फा (Alpha) - SHIFTED TO STEP 2
      drawText(
        "${AppStrings.get(lang, 'alpha_label')} (3,4)",
        _mapPt(3, 5),
        accentPink,
        12,
        FontWeight.bold,
      );
      canvas.drawCircle(_mapPt(3, 4), 6, Paint()..color = accentPink);
    }

    if (step >= 3) {
      // अल्फा के लिए डेल्टा X, Y (Delta X, Y for Alpha) - SHIFTED TO STEP 3
      final dashPaint = Paint()
        ..color = Colors.white30
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      _drawDashedLine(canvas, _mapPt(0, 0), _mapPt(3, 0), dashPaint);
      _drawDashedLine(canvas, _mapPt(3, 0), _mapPt(3, 4), dashPaint);

      drawText("Δx=3", _mapPt(1.5, -1), accentBlue);
      drawText("Δy=4", _mapPt(4, 2), accentBlue);
    }

    if (step >= 4) {
      // अल्फा का सीधा रास्ता (Direct path to Alpha) - SHIFTED TO STEP 4
      final pathPaint = Paint()
        ..color = accentPink.withOpacity(0.5)
        ..strokeWidth = 3;
      canvas.drawLine(_mapPt(0, 0), _mapPt(3, 4), pathPaint);
    }

    if (step >= 4 && step < 8) {
      // दूरी लेबल (Distance label) - SHIFTED TO STEP 4
      drawText("d=5", _mapPt(1, 2.5), accentGreen, 14, FontWeight.bold);
    }

    if (step >= 6) {
      // बीटा (Beta) - SHIFTED TO STEP 6
      drawText(
        "${AppStrings.get(lang, 'beta_label')} (8,16)",
        _mapPt(8, 17),
        accentPink,
        12,
        FontWeight.bold,
      );
      canvas.drawCircle(_mapPt(8, 16), 6, Paint()..color = accentPink);
    }

    if (step >= 7) {
      // बीटा के लिए डेल्टा X, Y (Delta X, Y for Beta) - SHIFTED TO STEP 7
      final dashPaint = Paint()
        ..color = Colors.white30
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      _drawDashedLine(canvas, _mapPt(3, 4), _mapPt(8, 4), dashPaint);
      _drawDashedLine(canvas, _mapPt(8, 4), _mapPt(8, 16), dashPaint);

      drawText("Δx=5", _mapPt(5.5, 3), accentBlue);
      drawText("Δy=12", _mapPt(9, 10), accentBlue);
    }

    if (step >= 8) {
      // बीटा का सीधा रास्ता (Direct path to Beta) - SHIFTED TO STEP 8
      final pathPaint = Paint()
        ..color = accentPink.withOpacity(0.5)
        ..strokeWidth = 3;
      canvas.drawLine(_mapPt(3, 4), _mapPt(8, 16), pathPaint);
    }

    if (step >= 8) {
      // Beta distance label - SHIFTED TO STEP 8
      drawText("d=13", _mapPt(5, 10.5), accentGreen, 14, FontWeight.bold);
    }

    // 4. ड्रोन बनाएं (Draw Drone)
    Offset dronePt = _mapPt(droneX, droneY);
    // ड्रोन आइकन बनाएं (Draw drone icon)
    canvas.drawCircle(dronePt, 8, Paint()..color = accentYellow);
    canvas.drawLine(
      Offset(dronePt.dx - 10, dronePt.dy),
      Offset(dronePt.dx + 10, dronePt.dy),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(dronePt.dx, dronePt.dy - 10),
      Offset(dronePt.dx, dronePt.dy + 10),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 2,
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
  bool shouldRepaint(covariant GpsPainter oldDelegate) {
    return oldDelegate.step != step ||
        oldDelegate.droneX != droneX ||
        oldDelegate.droneY != droneY ||
        oldDelegate.lang != lang;
  }
}

// भाषा टॉगल बटन (Language Toggle Button)
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
