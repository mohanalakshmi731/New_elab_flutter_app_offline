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
      'app_title': 'THE BROKEN TREE',
      'tagline': 'Trigonometry in Nature',
      'init_btn': 'INITIALIZE SYSTEM',
      'header_title': 'The Broken Tree',
      'header_subtitle': 'Class 10 • Heights & Distances',
      'phase_label': 'SURVEY PHASE',
      'step_label': 'Stage',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Height Recovered',
      'success_desc':
          'You have successfully calculated the original height of the broken tree using trigonometry!',
      'btn_restart': 'NEW SURVEY',
      's0': 'Deploy Surveyor. Locate intact tree.',
      's1': 'Storm event. Tree breaks at point B.',
      's2': 'Broken top touches ground at point C.',
      's3': 'Measure distance from base to C (8m).',
      's4': 'Measure angle of elevation at C (30°).',
      's5': 'Set up equation for standing height (h₁).',
      's6': 'Set up equation for broken part (h₂).',
      's7': 'Calculate h₁ using Tangent ratio.',
      's8': 'Calculate h₂ using Cosine ratio.',
      's9': 'Calculate Total Original Height (h₁ + h₂).',
      'btn_start': 'LOCATE TREE',
      'btn_break': 'SIMULATE STORM',
      'btn_fall': 'OBSERVE FALL',
      'btn_meas_d': 'MEASURE DISTANCE',
      'btn_meas_ang': 'MEASURE ANGLE',
      'btn_eq_h1': 'EQUATION FOR h₁',
      'btn_eq_h2': 'EQUATION FOR h₂',
      'btn_calc_h1': 'CALCULATE h₁',
      'btn_calc_h2': 'CALCULATE h₂',
      'btn_calc_total': 'VERIFY TOTAL',
      'msg_obs_ok': 'Intact tree identified. Origin set.',
      'msg_break_ok': 'Structural failure detected at point B.',
      'msg_fall_ok': 'Tree canopy made contact with ground.',
      'msg_dist_ok': 'Distance to contact point (C): 8m.',
      'msg_ang_ok': 'Angle of elevation at contact: 30°.',
      'msg_eq1_ok': 'Equation for h₁: tan(30°) = h₁ / 8.',
      'msg_eq2_ok': 'Equation for h₂: cos(30°) = 8 / h₂.',
      'msg_h1_ok': 'h₁ calculated: 8/√3 ≈ 4.62m.',
      'msg_h2_ok': 'h₂ calculated: 16/√3 ≈ 9.24m.',
      'msg_final_ok': 'Total height verified!',
      'msg_err': 'Calculation error. Check your math.',
      'q_solve_total': 'Calculate Total (4.62 + 9.24):',

      // Data Collection Tabs Strings
      'data_collection': 'Data Collection',
      'awaiting_data': 'Awaiting storm data...',

      // Tooltips & Labels
      'menu_tooltip': 'Main Menu',
      'reset_tooltip': 'Reset',
      'back_tooltip': 'Go Back',
    },
    'hi': {
      'app_title': 'टूटा हुआ पेड़',
      'tagline': 'प्रकृति में त्रिकोणमिति',
      'init_btn': 'सिस्टम प्रारंभ करें',
      'header_title': 'टूटा हुआ पेड़',
      'header_subtitle': 'कक्षा 10 • ऊंचाई और दूरी',
      'phase_label': 'सर्वेक्षण चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'ऊंचाई प्राप्त',
      'success_desc':
          'आपने त्रिकोणमिति का उपयोग करके टूटे हुए पेड़ की मूल ऊंचाई की सफलतापूर्वक गणना की है!',
      'btn_restart': 'नया सर्वेक्षण',
      's0': 'सर्वेयर तैनात करें। अक्षुण्ण पेड़ खोजें।',
      's1': 'तूफान की घटना। पेड़ बिंदु B पर टूटता है।',
      's2': 'टूटा हुआ शीर्ष बिंदु C पर जमीन को छूता है।',
      's3': 'आधार से C तक की दूरी (8m) मापें।',
      's4': 'C पर उन्नयन कोण (30°) मापें।',
      's5': 'खड़े ऊंचाई (h₁) के लिए समीकरण सेट करें।',
      's6': 'टूटे भाग (h₂) के लिए समीकरण सेट करें।',
      's7': 'टैंजेंट अनुपात का उपयोग करके h₁ की गणना करें।',
      's8': 'कोसाइन अनुपात का उपयोग करके h₂ की गणना करें।',
      's9': 'कुल मूल ऊंचाई (h₁ + h₂) की गणना करें।',
      'btn_start': 'पेड़ का पता लगाएँ',
      'btn_break': 'तूफान का अनुकरण करें',
      'btn_fall': 'गिरना देखें',
      'btn_meas_d': 'दूरी मापें',
      'btn_meas_ang': 'कोण मापें',
      'btn_eq_h1': 'h₁ के लिए समीकरण',
      'btn_eq_h2': 'h₂ के लिए समीकरण',
      'btn_calc_h1': 'h₁ की गणना करें',
      'btn_calc_h2': 'h₂ की गणना करें',
      'btn_calc_total': 'कुल सत्यापित करें',
      'msg_obs_ok': 'अक्षुण्ण पेड़ की पहचान की गई। मूल बिंदु सेट।',
      'msg_break_ok': 'बिंदु B पर संरचनात्मक विफलता का पता चला।',
      'msg_fall_ok': 'पेड़ के छतर ने जमीन से संपर्क किया।',
      'msg_dist_ok': 'संपर्क बिंदु (C) की दूरी: 8m.',
      'msg_ang_ok': 'संपर्क पर उन्नयन कोण: 30°.',
      'msg_eq1_ok': 'h₁ के लिए समीकरण: tan(30°) = h₁ / 8.',
      'msg_eq2_ok': 'h₂ के लिए समीकरण: cos(30°) = 8 / h₂.',
      'msg_h1_ok': 'h₁ की गणना: 8/√3 ≈ 4.62m.',
      'msg_h2_ok': 'h₂ की गणना: 16/√3 ≈ 9.24m.',
      'msg_final_ok': 'कुल ऊंचाई सत्यापित!',
      'msg_err': 'गणना त्रुटि। अपनी गणित की जाँच करें।',
      'q_solve_total': 'कुल गणना करें (4.62 + 9.24):',

      // Data Collection Tabs Strings
      'data_collection': 'डेटा संग्रह',
      'awaiting_data': 'तूफान डेटा की प्रतीक्षा...',

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

class BrokenTreeApp extends StatefulWidget {
  const BrokenTreeApp({super.key});

  @override
  State<BrokenTreeApp> createState() => _BrokenTreeAppState();
}

class _BrokenTreeAppState extends State<BrokenTreeApp>
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
  double fallProgress = 0.0;
  late AnimationController _fallController;
  late Animation<double> _fallAnimation;

  // Input Controllers
  final TextEditingController _inpAns = TextEditingController();

  // Timers for Success Modal
  Timer? _successTimer;

  @override
  void initState() {
    super.initState();
    _fallController = AnimationController(
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
    _fallController.dispose();
    _inpAns.dispose();
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
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontSize: 16,
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

        // Trigger animations
        if (currentStep == 2) {
          _animateFall();
        }

        _inpAns.clear();

        // Auto-open right panel during specific calculation steps if left is closed
        if (currentStep >= 6) {
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

  void _animateFall() {
    _fallAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _fallController, curve: Curves.bounceOut),
        )..addListener(() {
          setState(() {
            fallProgress = _fallAnimation.value;
          });
        });
    _fallController.forward(from: 0.0);
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
    _successTimer?.cancel();
    setState(() {
      currentStep = 0;
      fallProgress = 0.0;
      showSuccessModal = false;
      hasStarted = false;
      isLeftSidebarOpen = true;
      isRightSidebarOpen = false;
      _inpAns.clear();
      _fallController.reset();
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
              const Icon(Icons.nature, size: 80, color: accentPink),
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
                child: const Icon(Icons.nature_people, color: bgDark),
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
            // Standing Part h1
            if (currentStep >= 6)
              _buildDataBlock(
                "1. Standing Part (h₁)",
                "tan(30°) = h₁ / 8",
                currentStep >= 8 ? "h₁ = 8 / √3 ≈ 4.62m" : "...",
                currentStep == 6 || currentStep == 8,
              ),

            const SizedBox(height: 20),

            // Broken Part h2
            if (currentStep >= 7)
              _buildDataBlock(
                "2. Broken Part (h₂)",
                "cos(30°) = 8 / h₂",
                currentStep >= 9 ? "h₂ = 16 / √3 ≈ 9.24m" : "...",
                currentStep == 7 || currentStep == 9,
              ),

            const SizedBox(height: 20),

            // Final Calculation & Result Block
            if (currentStep >= 10)
              _buildResultBlock(
                "Total Original Height",
                "Total = h₁ + h₂\n= 4.62 + 9.24",
                "13.86m",
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
                  fontSize: 20,
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
              fontSize: 18,
              fontFamily: 'monospace',
              height: 1.5,
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
                  "≈ ",
                  style: TextStyle(
                    color: accentGreen,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  result,
                  style: const TextStyle(
                    color: accentGreen,
                    fontSize: 28,
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
          CustomPaint(
            size: const Size(500, 380),
            painter: BrokenTreePainter(
              step: currentStep,
              fallProgress: fallProgress,
            ),
          ),

          // --- LABELS & MEASUREMENTS ---
          if (currentStep >= 1) ...[
            const Positioned(
              left: 100,
              top: 310,
              child: Text(
                "A (Base)",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],

          if (currentStep >= 2) ...[
            const Positioned(
              left: 95,
              top: 195,
              child: Text(
                "B",
                style: TextStyle(
                  color: accentRed,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],

          if (currentStep >= 3) ...[
            const Positioned(
              left: 275,
              top: 310,
              child: Text(
                "C (Top)",
                style: TextStyle(
                  color: accentGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],

          if (currentStep >= 4) ...[
            const Positioned(
              left: 180,
              top: 310,
              child: Text(
                "d = 8m",
                style: TextStyle(
                  color: accentYellow,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],

          if (currentStep >= 5) ...[
            const Positioned(
              left: 235,
              top: 280,
              child: Text(
                "30°",
                style: TextStyle(
                  color: accentPink,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],

          if (currentStep >= 6) ...[
            const Positioned(
              left: 80,
              top: 250,
              child: Text(
                "h₁",
                style: TextStyle(
                  color: accentBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],

          if (currentStep >= 7) ...[
            Positioned(
              left: 190,
              top: 220,
              child: Transform.rotate(
                angle: -0.5,
                child: const Text(
                  "h₂",
                  style: TextStyle(
                    color: accentPink,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
          text: AppStrings.get(lang, 'btn_break'),
          color: accentRed,
          onPressed: () => advanceStep('msg_break_ok'),
        );
      case 2:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_fall'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_fall_ok'),
        );
      case 3:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_meas_d'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_dist_ok'),
        );
      case 4:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_meas_ang'),
          color: accentPink,
          onPressed: () => advanceStep('msg_ang_ok'),
        );
      case 5:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_eq_h1'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_eq1_ok'),
        );
      case 6:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_eq_h2'),
          color: accentPink,
          onPressed: () => advanceStep('msg_eq2_ok'),
        );
      case 7:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_calc_h1'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_h1_ok'),
        );
      case 8:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_calc_h2'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_h2_ok'),
        );
      case 9:
        return _InputControlBlock(
          question: AppStrings.get(lang, 'q_solve_total'),
          hint: 'Total = ?',
          controller: _inpAns,
          btnText: AppStrings.get(lang, 'btn_calc_total'),
          onVerify: () => verifyInput('13.86', 'msg_final_ok'),
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

class BrokenTreePainter extends CustomPainter {
  final int step;
  final double fallProgress;

  BrokenTreePainter({required this.step, required this.fallProgress});

  void drawUpperPart(Canvas canvas, Offset ptB, double angle) {
    canvas.save();
    canvas.translate(ptB.dx, ptB.dy);
    canvas.rotate(angle + math.pi / 2);

    // Tree trunk upper
    Path trunk = Path()
      ..moveTo(-8, 0)
      ..lineTo(8, 0)
      ..lineTo(4, -184.7)
      ..lineTo(-4, -184.7)
      ..close();

    // Add jagged bottom to upper trunk
    if (step >= 2) {
      Path jagged = Path()
        ..moveTo(-8, 0)
        ..lineTo(-4, 5)
        ..lineTo(0, -2)
        ..lineTo(4, 6)
        ..lineTo(8, 0)
        ..close();
      canvas.drawPath(jagged, Paint()..color = const Color(0xFF6D4C41));
    }

    canvas.drawPath(trunk, Paint()..color = const Color(0xFF5D4037));
    // Bark texture lines
    canvas.drawLine(
      const Offset(-4, -20),
      const Offset(-2, -150),
      Paint()
        ..color = const Color(0xFF4E342E)
        ..strokeWidth = 1,
    );
    canvas.drawLine(
      const Offset(2, -40),
      const Offset(3, -160),
      Paint()
        ..color = const Color(0xFF4E342E)
        ..strokeWidth = 1,
    );

    // Canopy
    Paint leafDark = Paint()..color = const Color(0xFF2E7D32);
    Paint leafLight = Paint()..color = const Color(0xFF4CAF50);

    canvas.drawCircle(const Offset(0, -184.7), 45, leafDark);
    canvas.drawCircle(const Offset(-25, -160.0), 35, leafDark);
    canvas.drawCircle(const Offset(25, -160.0), 35, leafDark);
    canvas.drawCircle(const Offset(-20, -210.0), 30, leafDark);
    canvas.drawCircle(const Offset(20, -210.0), 30, leafDark);

    canvas.drawCircle(const Offset(0, -184.7), 35, leafLight);
    canvas.drawCircle(const Offset(-25, -160.0), 25, leafLight);
    canvas.drawCircle(const Offset(25, -160.0), 25, leafLight);
    canvas.drawCircle(const Offset(-20, -210.0), 20, leafLight);
    canvas.drawCircle(const Offset(20, -210.0), 20, leafLight);

    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    Offset ptA = const Offset(120, 300);
    Offset ptB = Offset(120, 300 - 92.3);
    Offset ptC = const Offset(280, 300);

    // 1. Draw Realistic Ground
    canvas.drawRect(
      const Rect.fromLTRB(-2000, 300, 2000, 2000), // Dirt
      Paint()..color = const Color(0xFF3E2723),
    );
    canvas.drawRect(
      const Rect.fromLTRB(-2000, 300, 2000, 310), // Grass layer
      Paint()..color = const Color(0xFF2E7D32),
    );

    // 2. Base Tree (Standing Part)
    if (step >= 1) {
      Path trunkBase = Path()
        ..moveTo(ptA.dx - 16, ptA.dy)
        ..lineTo(ptA.dx + 16, ptA.dy)
        ..lineTo(ptB.dx + 8, ptB.dy)
        ..lineTo(ptB.dx - 8, ptB.dy)
        ..close();
      canvas.drawPath(trunkBase, Paint()..color = const Color(0xFF5D4037));

      // Bark lines
      canvas.drawLine(
        Offset(ptA.dx - 8, ptA.dy),
        Offset(ptB.dx - 4, ptB.dy),
        Paint()
          ..color = const Color(0xFF4E342E)
          ..strokeWidth = 1.5,
      );
      canvas.drawLine(
        Offset(ptA.dx + 4, ptA.dy),
        Offset(ptB.dx + 2, ptB.dy),
        Paint()
          ..color = const Color(0xFF4E342E)
          ..strokeWidth = 1.5,
      );

      if (step >= 2) {
        // Jagged top of base
        Path jaggedBase = Path()
          ..moveTo(ptB.dx - 8, ptB.dy)
          ..lineTo(ptB.dx - 4, ptB.dy - 6)
          ..lineTo(ptB.dx, ptB.dy + 2)
          ..lineTo(ptB.dx + 4, ptB.dy - 5)
          ..lineTo(ptB.dx + 8, ptB.dy)
          ..close();
        canvas.drawPath(jaggedBase, Paint()..color = const Color(0xFF6D4C41));
      }
    }

    // 3. Unbroken Top Part
    if (step >= 1 && step < 2) {
      drawUpperPart(canvas, ptB, -math.pi / 2);
    }

    // 4. Highlight Break
    if (step >= 2) {
      canvas.drawCircle(ptB, 8, Paint()..color = accentRed.withOpacity(0.5));
      canvas.drawCircle(ptB, 4, Paint()..color = accentRed);

      // Falling Top Part
      double startAngle = -math.pi / 2;
      double endAngle = math.atan2(ptC.dy - ptB.dy, ptC.dx - ptB.dx);
      double currentAngle = startAngle + (endAngle - startAngle) * fallProgress;

      drawUpperPart(canvas, ptB, currentAngle);
    }

    // 5. Contact point C
    if (step >= 3) {
      canvas.drawCircle(ptC, 5, Paint()..color = accentGreen);
    }

    // 6. Highlight Distance
    if (step >= 4) {
      canvas.drawLine(
        ptA,
        ptC,
        Paint()
          ..color = accentYellow
          ..strokeWidth = 4,
      );
    }

    // 7. Draw Angle Arc at C
    if (step >= 5) {
      double angleRad = math.atan2(
        ptB.dy - ptC.dy,
        ptA.dx - ptC.dx,
      ); // From C towards left(A) and up(B)
      canvas.drawArc(
        Rect.fromCircle(center: ptC, radius: 40),
        math.pi, // Starts from left (-X)
        -angleRad, // Sweeps up
        true,
        Paint()
          ..color = accentPink.withOpacity(0.4)
          ..style = PaintingStyle.fill,
      );
    }

    // 8. Math Overlay Line (h1)
    if (step >= 6) {
      canvas.drawLine(
        ptA,
        ptB,
        Paint()
          ..color = accentBlue.withOpacity(0.8)
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round,
      );
    }

    // 9. Math Overlay Line (h2)
    if (step >= 7) {
      double endAngle = math.atan2(ptC.dy - ptB.dy, ptC.dx - ptB.dx);
      double lengthH2 = 184.7;
      Offset finalTop = Offset(
        ptB.dx + lengthH2 * math.cos(endAngle),
        ptB.dy + lengthH2 * math.sin(endAngle),
      );
      canvas.drawLine(
        ptB,
        finalTop,
        Paint()
          ..color = accentPink.withOpacity(0.8)
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BrokenTreePainter oldDelegate) {
    return oldDelegate.step != step || oldDelegate.fallProgress != fallProgress;
  }
}
