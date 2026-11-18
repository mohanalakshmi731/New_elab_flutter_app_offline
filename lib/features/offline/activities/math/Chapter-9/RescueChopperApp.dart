// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:elab_app/features/offline/activities/math/Chapter-7/AreaSurveyorApp.dart';
import 'package:elab_app/features/offline/activities/math_activity_audio.dart';

const Color bgDark = Color(0xFF020617);
const Color bgPanelStart = Color(0xFF1E293B);
const Color bgPanelEnd = Color(0xFF0F172A);
const Color accentPink = Color(0xFFF472B6);
const Color accentBlue = Color(0xFF3B82F6);
const Color accentGreen = Color(0xFF22C55E);
const Color accentRed = Color(0xFFEF4444);
const Color accentYellow = Color(0xFFFACC15);

class AppStrings {
  static const Map<String, Map<String, String>> data = {
    'en': {
      'app_title': 'THE RESCUE CHOPPER',
      'tagline': 'Angle of Depression Estimation',
      'init_btn': 'INITIALIZE CHOPPER',
      'header_title': 'The Rescue Chopper',
      'header_subtitle': 'Class 10 • Heights & Distances',
      'phase_label': 'RESCUE PHASE',
      'step_label': 'Stage',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Target Secured',
      'success_desc':
          'You have successfully calculated the distance using the angle of depression!',
      'btn_restart': 'NEW MISSION',
      's0': 'Deploy Rescue Chopper from base.',
      's1': 'Ascend to cruising altitude (h = 100m).',
      's2': 'Scan water surface. Locate Lifeboat.',
      's3': 'Establish Chopper\'s horizontal line of sight.',
      's4': 'Establish direct line of sight to the Lifeboat.',
      's5': 'Measure Angle of Depression (45°).',
      's6': 'Apply Alternate Interior Angles rule (Boat Angle = 45°).',
      's7': 'Set up Trigonometric Ratio (Tangent).',
      's8': 'Substitute known values into tan(45°) = h / d.',
      's9': 'Solve for horizontal distance (d) to commence rescue.',
      'btn_start': 'DEPLOY CHOPPER',
      'btn_ascend': 'ASCEND TO 100m',
      'btn_locate_boat': 'LOCATE LIFEBOAT',
      'btn_draw_horiz': 'DRAW HORIZONTAL LINE',
      'btn_sight_boat': 'SIGHT TARGET',
      'btn_meas_dep': 'MEASURE DEPRESSION ANGLE',
      'btn_alt_int': 'TRANSFER ANGLE TO GROUND',
      'btn_setup_eq': 'SET UP EQUATION',
      'btn_sub_vals': 'SUBSTITUTE VALUES',
      'btn_solve_d': 'SOLVE FOR DISTANCE (d)',
      'btn_complete': 'COMMENCE RESCUE',
      'msg_obs_ok': 'Chopper deployed on surface.',
      'msg_ascend_ok': 'Cruising altitude of 100m reached.',
      'msg_boat_ok': 'Target Lifeboat locked on radar.',
      'msg_horiz_ok': 'Horizontal reference plane established.',
      'msg_sight_ok': 'Line of sight to target acquired.',
      'msg_dep_ok': 'Angle of Depression measured: 45°.',
      'msg_alt_ok': 'Alternate Interior Angle verified: 45°.',
      'msg_eq_ok': 'Equation established: tan(θ) = h / d.',
      'msg_sub_ok': 'Values substituted: 1 = 100 / d.',
      'msg_calc_ok': 'Distance calculated: 100m.',
      'msg_err': 'Calculation error. Check your math.',
      'q_solve_d': 'Solve for d: 1 = 100 / d',
    },
    'hi': {
      'app_title': 'रेस्क्यू चॉपर',
      'tagline': 'अवनमन कोण का अनुमान',
      'init_btn': 'चॉपर प्रारंभ करें',
      'header_title': 'रेस्क्यू चॉपर',
      'header_subtitle': 'कक्षा 10 • ऊंचाई और दूरी',
      'phase_label': 'बचाव चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'लक्ष्य सुरक्षित',
      'success_desc':
          'आपने अवनमन कोण का उपयोग करके सफलतापूर्वक दूरी की गणना की है!',
      'btn_restart': 'नया मिशन',
      's0': 'बेस से रेस्क्यू चॉपर तैनात करें।',
      's1': 'परिभ्रमण ऊंचाई तक चढ़ें (h = 100m)।',
      's2': 'पानी की सतह को स्कैन करें। लाइफबोट खोजें।',
      's3': 'चॉपर की क्षैतिज दृष्टि रेखा स्थापित करें।',
      's4': 'लाइफबोट के लिए सीधी दृष्टि रेखा स्थापित करें।',
      's5': 'अवनमन कोण मापें (45°)।',
      's6': 'एकांतर अंतःकोण नियम लागू करें (नाव का कोण = 45°)।',
      's7': 'त्रिकोणमितीय अनुपात (टैंजेंट) सेट करें।',
      's8': 'tan(45°) = h / d में ज्ञात मानों को प्रतिस्थापित करें।',
      's9': 'बचाव शुरू करने के लिए क्षैतिज दूरी (d) हल करें।',
      'btn_start': 'चॉपर तैनात करें',
      'btn_ascend': '100m तक चढ़ें',
      'btn_locate_boat': 'लाइफबोट खोजें',
      'btn_draw_horiz': 'क्षैतिज रेखा खींचें',
      'btn_sight_boat': 'लक्ष्य देखें',
      'btn_meas_dep': 'अवनमन कोण मापें',
      'btn_alt_int': 'कोण को जमीन पर स्थानांतरित करें',
      'btn_setup_eq': 'समीकरण सेट करें',
      'btn_sub_vals': 'मान प्रतिस्थापित करें',
      'btn_solve_d': 'दूरी (d) के लिए हल करें',
      'btn_complete': 'बचाव शुरू करें',
      'msg_obs_ok': 'चॉपर सतह पर तैनात।',
      'msg_ascend_ok': '100m की परिभ्रमण ऊंचाई तक पहुंच गया।',
      'msg_boat_ok': 'लक्ष्य लाइफबोट रडार पर लॉक हो गई।',
      'msg_horiz_ok': 'क्षैतिज संदर्भ विमान स्थापित।',
      'msg_sight_ok': 'लक्ष्य की दृष्टि रेखा प्राप्त की।',
      'msg_dep_ok': 'अवनमन कोण मापा गया: 45°।',
      'msg_alt_ok': 'एकांतर अंतःकोण सत्यापित: 45°।',
      'msg_eq_ok': 'समीकरण स्थापित: tan(θ) = h / d.',
      'msg_sub_ok': 'मान प्रतिस्थापित: 1 = 100 / d.',
      'msg_calc_ok': 'दूरी की गणना: 100m.',
      'msg_err': 'गणना त्रुटि। अपनी गणित की जाँच करें।',
      'q_solve_d': 'd के लिए हल करें: 1 = 100 / d',
    },
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['en']![key] ?? key;
  }
}

class RescueChopperApp extends StatefulWidget {
  const RescueChopperApp({super.key});

  @override
  State<RescueChopperApp> createState() => _RescueChopperAppState();
}

class _RescueChopperAppState extends State<RescueChopperApp>
    with TickerProviderStateMixin {
  bool hasStarted = false;
  String lang = 'en';

  // Panels State (साइड पैनल की स्थिति)
  bool isLeftPanelOpen = true;
  bool isRightPanelOpen = false;

  // गतिविधि की स्थिति
  int currentStep = 0;
  bool showSuccessModal = false;

  // एनीमेशन और कैनवस की स्थिति
  double chopperY = 300.0; // पानी पर शुरू होता है
  late AnimationController _ascentController;
  late Animation<double> _ascentAnimation;

  // नियंत्रक
  final TransformationController _transformationController =
      TransformationController();
  final ScrollController _stepsScrollController = ScrollController();
  final TextEditingController _inpAns = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ascentController = AnimationController(
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
    _transformationController.dispose();
    _stepsScrollController.dispose();
    _ascentController.dispose();
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

  // बायां पैनल टॉगल करने पर दायां पैनल स्वतः बंद करें
  void toggleLeftPanel() {
    playMathClick();
    setState(() {
      isLeftPanelOpen = !isLeftPanelOpen;
      if (isLeftPanelOpen) isRightPanelOpen = false;
    });
  }

  // दायां पैनल टॉगल करने पर बायां पैनल स्वतः बंद करें
  void toggleRightPanel() {
    playMathClick();
    setState(() {
      isRightPanelOpen = !isRightPanelOpen;
      if (isRightPanelOpen) isLeftPanelOpen = false;
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
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
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

        // 100m ऊंचाई तक चढ़ने का एनीमेशन (Step 1 -> 2 के बाद)
        if (currentStep == 2) {
          _animateAscent(100.0);
        }

        // जब समीकरण सेट हो जाए, तो कैलकुलेशन दिखाने के लिए स्वतः दायां पैनल खोलें
        if (currentStep == 8) {
          isRightPanelOpen = true;
          isLeftPanelOpen = false;
        }

        _inpAns.clear();

        if (currentStep == 10) {
          playMathSuccess();
          Timer(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                showSuccessModal = true;
              });

              Timer(const Duration(seconds: 5), () {
                if (mounted && showSuccessModal) {
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

  void _animateAscent(double targetY) {
    _ascentAnimation =
        Tween<double>(begin: chopperY, end: targetY).animate(
          CurvedAnimation(parent: _ascentController, curve: Curves.easeInOut),
        )..addListener(() {
          setState(() {
            chopperY = _ascentAnimation.value;
          });
        });
    _ascentController.forward(from: 0.0);
  }

  void verifyInput(String expectedValue, String successMsgKey) {
    if (_inpAns.text.trim() == expectedValue) {
      advanceStep(successMsgKey);
    } else {
      showToast(AppStrings.get(lang, 'msg_err'), isError: true);
    }
  }

  void resetLab() {
    playMathStart();
    setState(() {
      currentStep = 0;
      chopperY = 300.0;
      showSuccessModal = false;
      hasStarted = false;
      isLeftPanelOpen = true;
      isRightPanelOpen = false;
      _inpAns.clear();
      _ascentController.reset();
      _transformationController.value = Matrix4.identity();
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
              const Icon(Icons.flight_takeoff, size: 80, color: accentPink),
              const SizedBox(height: 20),
              Text(
                AppStrings.get(lang, 'app_title'),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: accentPink,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                AppStrings.get(lang, 'tagline'),
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  letterSpacing: 4,
                ),
                textAlign: TextAlign.center,
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

    double screenWidth = MediaQuery.of(context).size.width;
    double panelWidth = (screenWidth * 0.4).clamp(300.0, 450.0);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: bgDark,
        body: Stack(
          children: [
            Row(
              children: [
                // बायां साइड पैनल (Left Side Panel)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: isLeftPanelOpen ? panelWidth : 0,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [bgPanelStart, bgPanelEnd],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 15,
                        offset: Offset(5, 0),
                      ),
                    ],
                  ),
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.topLeft,
                      maxWidth: panelWidth,
                      minWidth: panelWidth,
                      child: _buildSidePanelContent(),
                    ),
                  ),
                ),

                // मध्य कैनवस क्षेत्र (Middle Canvas Area)
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0, -0.6),
                        radius: 1.2,
                        colors: [Color(0xFF1E3A8A), bgDark],
                      ),
                    ),
                    child: _buildCanvasArea(),
                  ),
                ),

                // दायां साइड पैनल (Right Side Panel - Calculations)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: isRightPanelOpen ? panelWidth : 0,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [bgPanelStart, bgPanelEnd],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 15,
                        offset: Offset(-5, 0),
                      ),
                    ],
                  ),
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.topRight,
                      maxWidth: panelWidth,
                      minWidth: panelWidth,
                      child: _buildRightPanelContent(),
                    ),
                  ),
                ),
              ],
            ),

            Positioned(top: 20, left: 20, child: _buildLeftFloatingMenu()),

            Positioned(bottom: 20, right: 20, child: _buildRightFloatingMenu()),

            // Positioned(bottom: 20, left: 20, child: _buildBackButton()),
            if (showSuccessModal)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(
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
                          const Icon(
                            Icons.verified,
                            color: accentGreen,
                            size: 80,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            AppStrings.get(lang, 'badge_title').toUpperCase(),
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            AppStrings.get(lang, 'success_desc'),
                            style: const TextStyle(color: Colors.white54),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- मुख्य लेआउट विजेट्स (MAIN LAYOUT WIDGETS) ---

  Widget _buildSidePanelContent() {
    return SingleChildScrollView(
      controller: _stepsScrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildPanelHeader(),
          ),

          const Divider(color: Colors.white24, height: 30),

          // प्रगति और मिशन लॉग
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildPanelLog(),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.only(
              left: 80,
              right: 20,
              top: 20,
              bottom: 20,
            ),
            decoration: const BoxDecoration(
              color: Colors.black45,
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: _buildControlsArea(),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanelContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "DATA & CALCULATIONS",
              style: TextStyle(
                color: accentPink,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const Divider(color: Colors.white24, height: 30),

            if (currentStep >= 8) ...[
              const Text(
                "Trigonometric Ratio",
                style: TextStyle(
                  color: accentBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "tan(θ) = Opp / Adj",
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'monospace',
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "tan(θ) = h / d",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              if (currentStep >= 9)
                const Text(
                  "tan(45°) = 100 / d",
                  style: TextStyle(
                    color: accentYellow,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    fontSize: 20,
                  ),
                ),
            ] else ...[
              const Text(
                "Awaiting aerial survey data...",
                style: TextStyle(
                  color: Colors.white30,
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                ),
              ),
            ],

            if (currentStep >= 9) ...[
              const SizedBox(height: 40),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 40),
              const Text(
                "Solution",
                style: TextStyle(
                  color: accentGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "1 = 100 / d",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 15),
              if (currentStep >= 10) ...[
                const Text(
                  "d = 100m",
                  style: TextStyle(
                    color: accentGreen,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    fontSize: 28,
                    shadows: [Shadow(color: accentGreen, blurRadius: 10)],
                  ),
                ),
              ] else ...[
                const Text(
                  "d = ?",
                  style: TextStyle(
                    color: Colors.white54,
                    fontFamily: 'monospace',
                    fontSize: 28,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPanelHeader() {
    return Column(
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
                boxShadow: [
                  BoxShadow(
                    color: accentPink.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.flight, color: bgDark),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.get(lang, 'header_title').toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    AppStrings.get(lang, 'header_subtitle'),
                    style: const TextStyle(
                      color: accentPink,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // भाषा टॉगल
            Container(
              decoration: BoxDecoration(
                color: Colors.black26,
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
            // नया मिशन / रीसेट बटन
            IconButton(
              icon: const Icon(
                Icons.power_settings_new,
                color: Colors.white,
                size: 20,
              ),
              onPressed: resetLab,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                backgroundColor: Colors.white.withOpacity(0.10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPanelLog() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.get(lang, 'phase_label'),
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "${AppStrings.get(lang, 'step_label')} ${math.min(currentStep + 1, 10)}/10",
              style: const TextStyle(
                color: accentBlue,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: currentStep / 10,
          backgroundColor: Colors.black38,
          color: accentPink,
          minHeight: 6,
          borderRadius: BorderRadius.circular(10),
        ),
        const SizedBox(height: 20),
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
      ],
    );
  }

  Widget _buildLeftFloatingMenu() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: bgPanel.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: IconButton(
        icon: Icon(
          isLeftPanelOpen ? Icons.menu_open : Icons.menu,
          color: accentPink,
        ),
        tooltip: 'Toggle Left Panel',
        onPressed: toggleLeftPanel,
      ),
    );
  }

  Widget _buildRightFloatingMenu() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: bgPanel.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: IconButton(
        icon: Icon(
          isRightPanelOpen ? Icons.close : Icons.calculate,
          color: accentPink,
        ),
        tooltip: 'Toggle Calculations Data',
        onPressed: toggleRightPanel,
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: bgPanel.withOpacity(0.9),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        tooltip: 'Exit',
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildCanvasArea() {
    return Stack(
      children: [
        // ज़ूम और मूव के लिए इंटरएक्टिव कैनवस
        Positioned.fill(
          child: InteractiveViewer(
            transformationController: _transformationController,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            minScale: 0.1,
            maxScale: 10.0,
            child: Center(child: _buildSceneGraphics()),
          ),
        ),

        // फ़्लोटिंग मिशन कार्ड (जब बायां साइड पैनल छिपा हो)
        if (!isLeftPanelOpen)
          Positioned(
            top: 80, // फ्लोटिंग मेनू से बचने के लिए
            left: 20,
            child: _buildFloatingCard(),
          ),
      ],
    );
  }

  Widget _buildFloatingCard() {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bgPanelStart, bgPanelEnd],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentPink.withOpacity(0.5)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.get(lang, 'active_mission').toUpperCase(),
              style: const TextStyle(
                color: accentPink,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            if (currentStep < 10) ...[
              Text(
                "${currentStep + 1}. ${AppStrings.get(lang, 's$currentStep')}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              _buildControlsArea(),
            ] else ...[
              Text(
                AppStrings.get(lang, 'badge_title'),
                style: const TextStyle(
                  color: accentGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
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
          text: AppStrings.get(lang, 'btn_ascend'),
          color: accentPink,
          onPressed: () => advanceStep('msg_ascend_ok'),
        );
      case 2:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_locate_boat'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_boat_ok'),
        );
      case 3:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_draw_horiz'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_horiz_ok'),
        );
      case 4:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_sight_boat'),
          color: accentPink,
          onPressed: () => advanceStep('msg_sight_ok'),
        );
      case 5:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_meas_dep'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_dep_ok'),
        );
      case 6:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_alt_int'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_alt_ok'),
        );
      case 7:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_setup_eq'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_eq_ok'),
        );
      case 8:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_sub_vals'),
          color: accentPink,
          onPressed: () => advanceStep('msg_sub_ok'),
        );
      case 9:
        return _InputControlBlock(
          question: AppStrings.get(lang, 'q_solve_d'),
          hint: 'd = ?',
          controller: _inpAns,
          btnText: AppStrings.get(lang, 'btn_solve_d'),
          onVerify: () => verifyInput('100', 'msg_calc_ok'),
        );
      default:
        return const SizedBox();
    }
  }

  // --- ग्राफिक्स और सीन (SCENE GRAPHICS) ---

  Widget _buildSceneGraphics() {
    return SizedBox(
      width: 500,
      height: 380,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: const Size(500, 380),
            painter: ChopperPainter(step: currentStep, chopperY: chopperY),
          ),

          // --- लेबल्स (LABELS) - क्रिया पूरी होने के बाद दिखेंगे ---
          if (currentStep >= 2) ...[
            const Positioned(
              left: 50,
              top: 190,
              child: Text(
                "h = 100m",
                style: TextStyle(
                  color: accentPink,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                ),
              ),
            ),
          ],

          if (currentStep >= 3) ...[
            const Positioned(
              left: 310,
              top: 315,
              child: Text(
                "Lifeboat",
                style: TextStyle(
                  color: accentGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                ),
              ),
            ),
          ],

          if (currentStep >= 4) ...[
            const Positioned(
              left: 200,
              top: 75,
              child: Text(
                "Horizontal Line of Sight",
                style: TextStyle(
                  color: accentYellow,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                ),
              ),
            ),
          ],

          if (currentStep >= 6) ...[
            const Positioned(
              left: 175,
              top: 105,
              child: Text(
                "45°",
                style: TextStyle(
                  color: accentYellow,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: accentYellow, blurRadius: 8)],
                ),
              ),
            ),
            const Positioned(
              left: 250,
              top: 105,
              child: Text(
                "Angle of Depression",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                ),
              ),
            ),
          ],

          if (currentStep >= 7) ...[
            const Positioned(
              left: 240,
              top: 270,
              child: Text(
                "45°",
                style: TextStyle(
                  color: accentGreen,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: accentGreen, blurRadius: 8)],
                ),
              ),
            ),
            const Positioned(
              left: 200,
              top: 305,
              child: Text(
                "Angle of Elevation",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                ),
              ),
            ),
          ],

          if (currentStep >= 8) ...[
            Positioned(
              left: 200,
              top: 285,
              child: Text(
                currentStep >= 10 ? "d = 100m" : "d = ?",
                style: const TextStyle(
                  color: accentBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: accentBlue, blurRadius: 8)],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// --- उप-विजेट्स (SUB-WIDGETS) ---

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
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.white,
          ),
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
            color: Colors.white,
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
          shadowColor: color.withOpacity(0.5),
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// --- कस्टम पेंटर (CUSTOM PAINTER) ---

class ChopperPainter extends CustomPainter {
  final int step;
  final double chopperY;

  ChopperPainter({required this.step, required this.chopperY});

  @override
  void paint(Canvas canvas, Size size) {
    Offset chopperPos = Offset(100, chopperY);
    Offset boatPos = const Offset(300, 300);

    // Glowing Neon Paints for HUD elements
    final glowPink = Paint()
      ..color = accentPink
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3);
    final glowYellow = Paint()
      ..color = accentYellow
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3);
    final glowBlue = Paint()
      ..color = accentBlue
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3);

    // 1. Draw Night Environment
    _drawEnvironment(canvas, size);

    // 2. HUD: Height Line (Step 2)
    if (step >= 2) {
      _drawDashedLine(canvas, const Offset(100, 300), chopperPos, glowPink);
    }

    // 3. Right Angle Marker (Step 8)
    if (step >= 8) {
      _drawRightAngle(canvas, const Offset(100, 300), 1, -1, Colors.white);
    }

    // 4. Boat (Step 3)
    if (step >= 3) {
      _drawRealisticBoat(canvas, boatPos);
    }

    // 5. Helicopter (Step 1)
    if (step >= 1) {
      _drawRealisticChopper(canvas, chopperPos);
    }

    // 6. HUD: Horizontal Line (Step 4)
    if (step >= 4) {
      _drawDashedLine(
        canvas,
        chopperPos,
        Offset(420, chopperPos.dy),
        glowYellow,
      );
    }

    // 7. HUD: Line of Sight (Step 5)
    if (step >= 5) {
      canvas.drawLine(chopperPos, boatPos, glowBlue);
    }

    // 8. HUD: Angle of Depression Arc (Step 6)
    if (step >= 6) {
      double angleRad = math.atan2(
        boatPos.dy - chopperPos.dy,
        boatPos.dx - chopperPos.dx,
      );
      canvas.drawArc(
        Rect.fromCircle(center: chopperPos, radius: 50),
        0,
        angleRad,
        true,
        Paint()
          ..color = accentYellow.withOpacity(0.3)
          ..style = PaintingStyle.fill,
      );
    }

    // 9. HUD: Alternate Interior Angle Arc (Step 7)
    if (step >= 7) {
      double angleRad = math.atan2(
        chopperPos.dy - boatPos.dy,
        chopperPos.dx - boatPos.dx,
      );
      canvas.drawArc(
        Rect.fromCircle(center: boatPos, radius: 50),
        math.pi,
        angleRad - math.pi,
        true,
        Paint()
          ..color = accentGreen.withOpacity(0.3)
          ..style = PaintingStyle.fill,
      );
    }

    // 10. HUD: Triangle & Distance (Step 8)
    if (step >= 8) {
      Path trianglePath = Path()
        ..moveTo(100, 300)
        ..lineTo(100, 100)
        ..lineTo(300, 300)
        ..close();
      canvas.drawPath(
        trianglePath,
        Paint()
          ..color = accentBlue.withOpacity(0.1)
          ..style = PaintingStyle.fill,
      );

      // Distance Base Line
      canvas.drawLine(
        const Offset(100, 300),
        boatPos,
        Paint()
          ..color = accentBlue
          ..strokeWidth = 4
          ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4),
      );
    }
  }

  void _drawEnvironment(Canvas canvas, Size size) {
    // Glowing Moon
    canvas.drawCircle(
      const Offset(420, 60),
      25,
      Paint()
        ..color = Colors.white.withOpacity(0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
    );
    canvas.drawCircle(const Offset(420, 60), 18, Paint()..color = Colors.white);

    // Realistic Water Waves with Gradient
    Path wavePath = Path();
    wavePath.moveTo(-2500, 300);
    // Draw wavy line for water surface extended to +/- 2500 for infinite pan feel
    for (double x = -2500; x <= 2500; x += 15) {
      double y = 300 + math.sin((x + chopperY) * 0.05) * 3;
      wavePath.lineTo(x, y);
    }
    wavePath.lineTo(2500, 1500); // deep water base
    wavePath.lineTo(-2500, 1500);
    wavePath.close();

    final waterGradient = ui.Gradient.linear(
      const Offset(0, 300),
      const Offset(0, 1000),
      [Colors.cyan.withOpacity(0.8), Colors.blue.shade900.withOpacity(0.9)],
    );

    canvas.drawPath(wavePath, Paint()..shader = waterGradient);

    // Currents in the water
    final currentPaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    for (double cy = 320; cy < 600; cy += 40) {
      Path currentPath = Path();
      // Draw segmented currents so they look like flowing water ripples
      for (double x = -2500; x <= 2500; x += 100) {
        if (math.sin(x * 0.01 + cy) > 0) {
          // random natural gaps
          double startX = x;
          double endX = x + 60 + math.sin(cy) * 20;
          currentPath.moveTo(startX, cy + math.sin(startX * 0.05) * 5);
          for (double j = startX; j <= endX; j += 10) {
            currentPath.lineTo(j, cy + math.sin(j * 0.05) * 5);
          }
        }
      }
      canvas.drawPath(currentPath, currentPaint);
    }

    // Add a light reflection on water
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(420, 310), width: 100, height: 10),
      Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  void _drawRealisticChopper(Canvas canvas, Offset pos) {
    // Chopper Body (Rounded)
    final bodyRect = Rect.fromCenter(center: pos, width: 45, height: 26);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(12)),
      Paint()..color = accentPink,
    );

    // Chopper Cockpit Glass
    final glassRect = Rect.fromLTWH(pos.dx, pos.dy - 10, 18, 14);
    canvas.drawRRect(
      RRect.fromRectAndRadius(glassRect, const Radius.circular(6)),
      Paint()..color = Colors.lightBlueAccent.withOpacity(0.8),
    );

    // Tail Boom
    canvas.drawLine(
      Offset(pos.dx - 20, pos.dy - 4),
      Offset(pos.dx - 55, pos.dy - 8),
      Paint()
        ..color = accentPink
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );

    // Tail Fin
    canvas.drawLine(
      Offset(pos.dx - 55, pos.dy - 8),
      Offset(pos.dx - 55, pos.dy - 22),
      Paint()
        ..color = accentPink
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // Tail Rotor
    canvas.drawCircle(
      Offset(pos.dx - 55, pos.dy - 22),
      6,
      Paint()..color = Colors.white.withOpacity(0.7),
    );

    // Skids (Landing Gear)
    final skidPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    // Struts
    canvas.drawLine(
      Offset(pos.dx - 12, pos.dy + 12),
      Offset(pos.dx - 12, pos.dy + 18),
      skidPaint,
    );
    canvas.drawLine(
      Offset(pos.dx + 12, pos.dy + 12),
      Offset(pos.dx + 12, pos.dy + 18),
      skidPaint,
    );
    // Bottom Skids
    canvas.drawLine(
      Offset(pos.dx - 22, pos.dy + 18),
      Offset(pos.dx + 22, pos.dy + 18),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Main Rotor Engine
    canvas.drawLine(
      Offset(pos.dx, pos.dy - 13),
      Offset(pos.dx, pos.dy - 18),
      skidPaint..strokeWidth = 4,
    );
    // Main Rotor Blades (Blurred for motion effect)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(pos.dx, pos.dy - 18),
        width: 80,
        height: 4,
      ),
      Paint()
        ..color = Colors.white.withOpacity(0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }

  void _drawRealisticBoat(Canvas canvas, Offset pos) {
    // Add small glow under boat
    canvas.drawOval(
      Rect.fromCenter(center: pos, width: 60, height: 10),
      Paint()
        ..color = accentGreen.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Boat Hull
    Path hullPath = Path();
    hullPath.moveTo(pos.dx - 25, pos.dy - 6);
    hullPath.lineTo(pos.dx + 25, pos.dy - 6);
    hullPath.quadraticBezierTo(
      pos.dx + 20,
      pos.dy + 8,
      pos.dx + 12,
      pos.dy + 8,
    );
    hullPath.lineTo(pos.dx - 12, pos.dy + 8);
    hullPath.quadraticBezierTo(
      pos.dx - 20,
      pos.dy + 8,
      pos.dx - 25,
      pos.dy - 6,
    );
    hullPath.close();

    canvas.drawPath(hullPath, Paint()..color = Colors.deepOrange);

    // Boat Top/Cabin
    final cabinRect = Rect.fromLTRB(
      pos.dx - 12,
      pos.dy - 14,
      pos.dx + 12,
      pos.dy - 6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(cabinRect, const Radius.circular(4)),
      Paint()..color = Colors.white,
    );

    // Cross / Medic Detail
    final redPaint = Paint()
      ..color = accentRed
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(pos.dx, pos.dy - 12),
      Offset(pos.dx, pos.dy - 8),
      redPaint,
    );
    canvas.drawLine(
      Offset(pos.dx - 2, pos.dy - 10),
      Offset(pos.dx + 2, pos.dy - 10),
      redPaint,
    );
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
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);

    Path path = Path();
    path.moveTo(corner.dx + size * dirX, corner.dy);
    path.lineTo(corner.dx + size * dirX, corner.dy + size * dirY);
    path.lineTo(corner.dx, corner.dy + size * dirY);

    canvas.drawPath(path, paint);
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const double dashWidth = 8, dashSpace = 4;
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
  bool shouldRepaint(covariant ChopperPainter oldDelegate) {
    return oldDelegate.step != step || oldDelegate.chopperY != chopperY;
  }
}

// --- नेविगेशन और भाषा बटन (LANG BUTTON) ---

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
