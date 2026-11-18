// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
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
      'app_title': 'THE SHADOW SHIFTER',
      'tagline': 'Dynamic Shadows & Trigonometry',
      'init_btn': 'INITIALIZE SYSTEM',
      'header_title': 'The Shadow Shifter',
      'header_subtitle': 'Class 10 • Heights & Distances',
      'phase_label': 'SURVEY PHASE',
      'step_label': 'Stage',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Height Verified',
      'success_desc':
          'You have successfully calculated the tower height using changing shadow lengths!',
      'btn_restart': 'NEW MISSION',
      's0': 'Deploy Surveyor. Establish vertical tower.',
      's1': 'Sun altitude at 60°. Observe shadow.',
      's2': 'Label initial shadow length as x.',
      's3': 'Sun altitude drops to 30°.',
      's4': 'Observe new shadow. Extended by 40m.',
      's5': 'Identify the two right-angled triangles.',
      's6': 'Set up Equation 1 (for 60°).',
      's7': 'Set up Equation 2 (for 30°).',
      's8': 'Solve for base shadow length (x).',
      's9': 'Calculate final tower height (h).',
      'btn_start': 'DEPLOY TOWER',
      'btn_sun_60': 'SET SUN TO 60°',
      'btn_label_x': 'MEASURE INITIAL SHADOW',
      'btn_sun_30': 'LOWER SUN TO 30°',
      'btn_label_40': 'MEASURE EXTENSION (40m)',
      'btn_id_tri': 'IDENTIFY TRIANGLES',
      'btn_eq1': 'EQUATION 1 (60°)',
      'btn_eq2': 'EQUATION 2 (30°)',
      'btn_calc_x': 'SOLVE FOR x',
      'btn_calc_h': 'CALCULATE HEIGHT (h)',
      'msg_obs_ok': 'Tower established. Origin set.',
      'msg_sun60_ok': 'Sun at 60°. Short shadow cast.',
      'msg_lbl_x_ok': 'Initial shadow length denoted as x.',
      'msg_sun30_ok': 'Sun lowered to 30°. Shadow extends.',
      'msg_lbl_40_ok': 'Shadow extension measured: 40m. Total = (x + 40)m.',
      'msg_tri_ok': 'Two right-angled triangles identified.',
      'msg_eq1_ok': 'Eq 1: tan(60°) = h / x  =>  h = x√3.',
      'msg_eq2_ok': 'Eq 2: tan(30°) = h / (x + 40).',
      'msg_x_ok': 'Base shadow calculated: x = 20m.',
      'msg_final_ok': 'Tower height verified: 34.64m!',
      'msg_err': 'Calculation error. Check your math.',
      'q_solve_x': 'Solve: 1/√3 = (x√3)/(x+40). x = ?',
      'q_solve_h': 'Calculate h = 20 × √3 (Use 1.732):',
    },
    'hi': {
      'app_title': 'शैडो शिफ्टर',
      'tagline': 'गतिशील छाया और त्रिकोणमिति',
      'init_btn': 'सिस्टम प्रारंभ करें',
      'header_title': 'शैडो शिफ्टर',
      'header_subtitle': 'कक्षा 10 • ऊंचाई और दूरी',
      'phase_label': 'सर्वेक्षण चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'ऊंचाई सत्यापित',
      'success_desc':
          'आपने बदलती छाया की लंबाई का उपयोग करके टावर की ऊंचाई की सफलतापूर्वक गणना की है!',
      'btn_restart': 'नया मिशन',
      's0': 'सर्वेयर तैनात करें। ऊर्ध्वाधर टावर स्थापित करें।',
      's1': 'सूर्य का उन्नतांश 60° पर। छाया का निरीक्षण करें।',
      's2': 'प्रारंभिक छाया की लंबाई को x के रूप में लेबल करें।',
      's3': 'सूर्य का उन्नतांश 30° तक गिरता है।',
      's4': 'नई छाया का निरीक्षण करें। 40m द्वारा विस्तारित।',
      's5': 'दो समकोण त्रिभुजों की पहचान करें।',
      's6': 'समीकरण 1 (60° के लिए) सेट करें।',
      's7': 'समीकरण 2 (30° के लिए) सेट करें।',
      's8': 'आधार छाया लंबाई (x) के लिए हल करें।',
      's9': 'अंतिम टावर ऊंचाई (h) की गणना करें।',
      'btn_start': 'टावर तैनात करें',
      'btn_sun_60': 'सूर्य को 60° पर सेट करें',
      'btn_label_x': 'प्रारंभिक छाया मापें',
      'btn_sun_30': 'सूर्य को 30° तक नीचे करें',
      'btn_label_40': 'विस्तार (40m) मापें',
      'btn_id_tri': 'त्रिभुज पहचानें',
      'btn_eq1': 'समीकरण 1 (60°)',
      'btn_eq2': 'समीकरण 2 (30°)',
      'btn_calc_x': 'x के लिए हल करें',
      'btn_calc_h': 'ऊंचाई (h) की गणना करें',
      'msg_obs_ok': 'टावर स्थापित। मूल बिंदु सेट।',
      'msg_sun60_ok': 'सूर्य 60° पर। छोटी छाया पड़ी।',
      'msg_lbl_x_ok': 'प्रारंभिक छाया की लंबाई x के रूप में दर्शाई गई है।',
      'msg_sun30_ok': 'सूर्य 30° तक नीचे हो गया। छाया फैलती है।',
      'msg_lbl_40_ok': 'छाया विस्तार मापा गया: 40m। कुल = (x + 40)m.',
      'msg_tri_ok': 'दो समकोण त्रिभुज पहचाने गए।',
      'msg_eq1_ok': 'समीकरण 1: tan(60°) = h / x  =>  h = x√3.',
      'msg_eq2_ok': 'समीकरण 2: tan(30°) = h / (x + 40).',
      'msg_x_ok': 'आधार छाया की गणना: x = 20m.',
      'msg_final_ok': 'टावर ऊंचाई सत्यापित: 34.64m!',
      'msg_err': 'गणना त्रुटि। अपनी गणित की जाँच करें।',
      'q_solve_x': 'हल करें: 1/√3 = (x√3)/(x+40). x = ?',
      'q_solve_h': 'h = 20 × √3 की गणना करें (1.732 का उपयोग करें):',
    },
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['en']![key] ?? key;
  }
}

class ShadowShifterApp extends StatefulWidget {
  const ShadowShifterApp({super.key});

  @override
  State<ShadowShifterApp> createState() => _ShadowShifterAppState();
}

class _ShadowShifterAppState extends State<ShadowShifterApp>
    with TickerProviderStateMixin {
  bool hasStarted = false;
  String lang = 'en';

  // Panels State (पैनल की स्थिति)
  bool isLeftPanelOpen = true;
  bool isRightPanelOpen = false;

  // गतिविधि की स्थिति (Activity State)
  int currentStep = 0;
  bool showSuccessModal = false;

  // एनीमेशन की स्थिति (Animation State)
  double sunAngle = 90.0;
  late AnimationController _sunController;
  late Animation<double> _sunAnimation;

  // इनपुट नियंत्रक (Input Controllers)
  final TextEditingController _inpAns = TextEditingController();
  final ScrollController _stepsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _sunController = AnimationController(
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
    _sunController.dispose();
    _inpAns.dispose();
    _stepsScrollController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
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

        // एनीमेशन ट्रिगर्स
        if (currentStep == 2) {
          _animateSun(60.0);
        } else if (currentStep == 4) {
          _animateSun(30.0);
        }

        // जब समीकरण सेट हो जाए, तो कैलकुलेशन दिखाने के लिए स्वतः दायां पैनल खोलें
        if (currentStep == 6) {
          isRightPanelOpen = true;
          isLeftPanelOpen = false;
        }

        _inpAns.clear();

        if (currentStep == 10) {
          playMathSuccess();
          // सफलता पॉपअप दिखाएं
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

  void _animateSun(double targetAngle) {
    _sunAnimation =
        Tween<double>(begin: sunAngle, end: targetAngle).animate(
          CurvedAnimation(parent: _sunController, curve: Curves.easeInOut),
        )..addListener(() {
          setState(() {
            sunAngle = _sunAnimation.value;
          });
        });
    _sunController.forward(from: 0.0);
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
      sunAngle = 90.0;
      showSuccessModal = false;
      hasStarted = false;
      isLeftPanelOpen = true;
      isRightPanelOpen = false;
      _inpAns.clear();
      _sunController.reset();
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
              const Icon(Icons.wb_twilight, size: 80, color: accentPink),
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

    // 40% साइड पैनल चौड़ाई की गणना
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
                  color: bgPanel.withOpacity(0.95),
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
                Expanded(child: _buildCanvasArea()),

                // दायां साइड पैनल (Right Side Panel - Calculations)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: isRightPanelOpen ? panelWidth : 0,
                  color: bgPanel.withOpacity(0.95),
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

            // स्क्रीन के टॉप-लेफ्ट में लेफ्ट पैनल फ्लोटिंग मेनू
            Positioned(top: 20, left: 20, child: _buildLeftFloatingMenu()),

            // स्क्रीन के बॉटम-राइट में राइट पैनल फ्लोटिंग मेनू
            Positioned(bottom: 20, right: 20, child: _buildRightFloatingMenu()),

            // स्क्रीन के बॉटम-लेफ्ट में बैक बटन
            //Positioned(bottom: 20, left: 20, child: _buildBackButton()),

            // सफलता मोडल
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
              left: 80, // बैक बटन के लिए पैडिंग
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

            if (currentStep >= 7) ...[
              const Text(
                "1. Inner Triangle (60°)",
                style: TextStyle(
                  color: accentBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "tan(60°) = h / x",
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'monospace',
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "√3 = h / x",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "h = x√3",
                style: TextStyle(
                  color: accentYellow,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 30),
            ] else ...[
              const Text(
                "Awaiting survey data...",
                style: TextStyle(
                  color: Colors.white30,
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                ),
              ),
            ],

            if (currentStep >= 8) ...[
              const Text(
                "2. Outer Triangle (30°)",
                style: TextStyle(
                  color: accentPink,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "tan(30°) = h / (x + 40)",
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'monospace',
                  fontSize: 18,
                ),
              ),
              if (currentStep >= 9) ...[
                const SizedBox(height: 5),
                const Text(
                  "1/√3 = (x√3) / (x + 40)",
                  style: TextStyle(
                    color: accentGreen,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    fontSize: 18,
                  ),
                ),
              ],
              const SizedBox(height: 30),
            ],

            if (currentStep >= 9) ...[
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 30),
              const Text(
                "Solution",
                style: TextStyle(
                  color: accentGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "x + 40 = 3x  =>  2x = 40",
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'monospace',
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "x = 20m",
                style: TextStyle(
                  color: accentBlue,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "h = 20 × 1.732",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 5),
              if (currentStep >= 10 || showSuccessModal)
                const Text(
                  "h ≈ 34.64m",
                  style: TextStyle(
                    color: accentGreen,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    fontSize: 28,
                  ),
                ),
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
              ),
              child: const Icon(Icons.architecture, color: bgDark),
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
                size: 16,
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
            boundaryMargin: const EdgeInsets.all(500.0),
            minScale: 0.5,
            maxScale: 4.0,
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
      width: 250,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bgPanel.withOpacity(0.95),
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
          text: AppStrings.get(lang, 'btn_sun_60'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_sun60_ok'),
        );
      case 2:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_label_x'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_lbl_x_ok'),
        );
      case 3:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_sun_30'),
          color: accentPink,
          onPressed: () => advanceStep('msg_sun30_ok'),
        );
      case 4:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_label_40'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_lbl_40_ok'),
        );
      case 5:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_id_tri'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_tri_ok'),
        );
      case 6:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_eq1'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_eq1_ok'),
        );
      case 7:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_eq2'),
          color: accentPink,
          onPressed: () => advanceStep('msg_eq2_ok'),
        );
      case 8:
        return _InputControlBlock(
          question: AppStrings.get(lang, 'q_solve_x'),
          hint: 'x = ?',
          controller: _inpAns,
          btnText: AppStrings.get(lang, 'btn_calc_x'),
          onVerify: () => verifyInput('20', 'msg_x_ok'),
        );
      case 9:
        return _InputControlBlock(
          question: AppStrings.get(lang, 'q_solve_h'),
          hint: 'h = ?',
          controller: _inpAns,
          btnText: AppStrings.get(lang, 'btn_calc_h'),
          onVerify: () => verifyInput('34.64', 'msg_final_ok'),
        );
      default:
        return const SizedBox();
    }
  }

  // --- ग्राफिक्स और सीन (SCENE GRAPHICS) ---

  Widget _buildSceneGraphics() {
    double poleX = 100;
    double groundY = 300;
    double poleH = 200;

    double shadow60X = poleX + poleH / math.tan(60 * math.pi / 180);
    double shadow30X = poleX + poleH / math.tan(30 * math.pi / 180);

    return SizedBox(
      width: 500,
      height: 380,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: const Size(500, 380),
            painter: ShadowPainter(step: currentStep, sunAngle: sunAngle),
          ),

          // --- लेबल्स (LABELS) ---
          if (currentStep >= 1) ...[
            const Positioned(
              left: 60,
              top: 180,
              child: Text(
                "h",
                style: TextStyle(
                  color: accentPink,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ),
            ),
          ],

          if (currentStep >= 2) ...[
            Positioned(
              left: shadow60X + 10,
              top: groundY - 25,
              child: const Text(
                "60°",
                style: TextStyle(
                  color: accentYellow,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ),
            ),
          ],

          if (currentStep >= 3) ...[
            Positioned(
              left: poleX + (shadow60X - poleX) / 2 - 5,
              top: groundY + 10,
              child: const Text(
                "x",
                style: TextStyle(
                  color: accentBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ),
            ),
          ],

          if (currentStep >= 4 && currentStep < 6) ...[
            Positioned(
              left: shadow30X + 15,
              top: groundY - 20,
              child: const Text(
                "30°",
                style: TextStyle(
                  color: accentYellow,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ),
            ),
          ],

          if (currentStep >= 6) ...[
            Positioned(
              left: shadow30X + 15,
              top: groundY - 20,
              child: const Text(
                "30°",
                style: TextStyle(
                  color: accentPink,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ),
            ),
          ],

          if (currentStep >= 5) ...[
            Positioned(
              left: shadow60X + (shadow30X - shadow60X) / 2 - 15,
              top: groundY + 10,
              child: const Text(
                "40m",
                style: TextStyle(
                  color: accentGreen,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
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

// --- कस्टम चित्रकार (CUSTOM PAINTER) ---

class ShadowPainter extends CustomPainter {
  final int step;
  final double sunAngle; // Degrees

  ShadowPainter({required this.step, required this.sunAngle});

  @override
  void paint(Canvas canvas, Size size) {
    Offset poleBase = const Offset(100, 300);
    Offset poleTop = const Offset(100, 100); // Height = 200

    // 1. यथार्थवादी ज़मीन बनाएं (Draw Realistic Ground)
    Rect groundRect = Rect.fromLTRB(-1000, 300, 2000, 1000);
    Paint groundPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 300),
        const Offset(0, 600),
        [const Color(0xFF1B2E26), const Color(0xFF0A120E)], // Grass/Dirt vibe
      );
    canvas.drawRect(groundRect, groundPaint);

    // Depth Line for the Ground
    canvas.drawLine(
      const Offset(-1000, 300),
      const Offset(2000, 300),
      Paint()
        ..color = Colors.green.shade800.withOpacity(0.8)
        ..strokeWidth = 4,
    );

    // 2. छाया का गणित और यथार्थवादी छाया (Realistic Shadow)
    if (step >= 2) {
      double angleRad = sunAngle * math.pi / 180;
      double shadowLen = 200 / math.tan(angleRad);
      Offset shadowTip = Offset(poleBase.dx + shadowLen, 300);

      // We draw the shadow BEFORE the building so it emerges naturally from beneath
      Path shadowPath = Path()
        ..moveTo(poleBase.dx, 300)
        ..lineTo(shadowTip.dx, 300)
        ..lineTo(shadowTip.dx - 10, 310) // slight perspective distortion
        ..lineTo(poleBase.dx - 15, 310)
        ..close();

      canvas.drawPath(
        shadowPath,
        Paint()
          ..color = Colors.black.withOpacity(0.7)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }

    // 3. यथार्थवादी टावर/इमारत (Draw Realistic Tower/Building)
    if (step >= 1) {
      double bWidth = 40;
      Rect buildingRect = Rect.fromLTRB(
        poleBase.dx - bWidth / 2,
        poleTop.dy,
        poleBase.dx + bWidth / 2,
        poleBase.dy,
      );

      // Building body gradient
      Paint bPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(poleBase.dx, poleTop.dy),
          Offset(poleBase.dx, poleBase.dy),
          [const Color(0xFF334155), const Color(0xFF0F172A)],
        );
      canvas.drawRect(buildingRect, bPaint);

      // Building Outline
      canvas.drawRect(
        buildingRect,
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Windows logic for realistic look
      Paint wPaint = Paint()..color = accentYellow.withOpacity(0.8);
      Paint wDarkPaint = Paint()..color = Colors.black38;

      for (double y = poleTop.dy + 15; y < poleBase.dy - 15; y += 25) {
        for (double x = poleBase.dx - 12; x <= poleBase.dx + 12; x += 16) {
          // pseudo-random effect for lit windows
          bool isLit = ((y + x).toInt() % 3) != 0;
          canvas.drawRect(
            Rect.fromLTWH(x - 4, y, 8, 12),
            isLit ? wPaint : wDarkPaint,
          );
        }
      }

      // Roof details
      canvas.drawRect(
        Rect.fromLTRB(
          poleBase.dx - bWidth / 2 - 2,
          poleTop.dy,
          poleBase.dx + bWidth / 2 + 2,
          poleTop.dy + 5,
        ),
        Paint()..color = Colors.blueGrey.shade800,
      );

      // Small antenna on top to indicate precise height tip
      canvas.drawLine(
        Offset(poleBase.dx, poleTop.dy),
        Offset(poleBase.dx, poleTop.dy - 15),
        Paint()
          ..color = Colors.redAccent
          ..strokeWidth = 2,
      );

      _drawRightAngle(canvas, poleBase, 1, -1, Colors.white54);
    }

    // 4. सूर्य और उसकी रेखाएँ (Sun & Lines)
    if (step >= 2) {
      double angleRad = sunAngle * math.pi / 180;
      double shadowLen = 200 / math.tan(angleRad);
      Offset shadowTip = Offset(poleBase.dx + shadowLen, 300);

      double sunDist = 200;
      // सूर्य बाईं ओर (पीछे) होना चाहिए
      Offset sunPos = Offset(
        poleTop.dx - sunDist * math.cos(angleRad),
        poleTop.dy - sunDist * math.sin(angleRad),
      );

      _drawDashedLine(
        canvas,
        shadowTip,
        sunPos,
        Paint()
          ..color = accentYellow.withOpacity(0.6)
          ..strokeWidth = 2,
      );

      // यथार्थवादी चमकता हुआ सूर्य (Draw glowing Sun)
      canvas.drawCircle(
        sunPos,
        25,
        Paint()
          ..color = accentYellow.withOpacity(0.8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
      );
      canvas.drawCircle(sunPos, 15, Paint()..color = Colors.white);

      // कोण का चाप बनाएं (Draw Angle Arc)
      canvas.drawArc(
        Rect.fromCircle(center: shadowTip, radius: 40),
        math.pi, // बाएं क्षैतिज से (From horizontal left)
        angleRad, // ऊपर की ओर स्वीप करें (Sweep up)
        true,
        Paint()
          ..color = accentYellow.withOpacity(0.4)
          ..style = PaintingStyle.fill,
      );
    }

    // 5. त्रिकोणों की पहचान (Identify Triangles)
    if (step >= 6) {
      // 60 डिग्री त्रिकोण की रूपरेखा बनाएं
      double sh60 = 200 / math.tan(60 * math.pi / 180);
      Path tri60 = Path()
        ..moveTo(100, 300)
        ..lineTo(100 + sh60, 300)
        ..lineTo(100, 100)
        ..close();
      canvas.drawPath(
        tri60,
        Paint()
          ..color = accentBlue.withOpacity(0.1)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        tri60,
        Paint()
          ..color = accentBlue
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );

      // 30 डिग्री त्रिकोण की रूपरेखा बनाएं
      double sh30 = 200 / math.tan(30 * math.pi / 180);
      Path tri30 = Path()
        ..moveTo(100, 300)
        ..lineTo(100 + sh30, 300)
        ..lineTo(100, 100)
        ..close();
      canvas.drawPath(
        tri30,
        Paint()
          ..color = accentPink.withOpacity(0.1)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        tri30,
        Paint()
          ..color = accentPink
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );

      // 30 डिग्री चाप बनाएं (Draw 30 deg Arc)
      canvas.drawArc(
        Rect.fromCircle(center: Offset(100 + sh30, 300), radius: 40),
        math.pi,
        30 * math.pi / 180,
        true,
        Paint()
          ..color = accentPink.withOpacity(0.4)
          ..style = PaintingStyle.fill,
      );
    }

    if (step >= 3) {
      // आधार x को हाइलाइट करें (Highlight x base)
      double sh60 = 200 / math.tan(60 * math.pi / 180);
      canvas.drawLine(
        const Offset(100, 310),
        Offset(100 + sh60, 310),
        Paint()
          ..color = accentBlue
          ..strokeWidth = 2,
      );
    }

    if (step >= 5) {
      // 40m आधार को हाइलाइट करें (Highlight 40m base)
      double sh60 = 200 / math.tan(60 * math.pi / 180);
      double sh30 = 200 / math.tan(30 * math.pi / 180);
      canvas.drawLine(
        Offset(100 + sh60, 310),
        Offset(100 + sh30, 310),
        Paint()
          ..color = accentGreen
          ..strokeWidth = 2,
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

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const double dashWidth = 10, dashSpace = 5;
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
  bool shouldRepaint(covariant ShadowPainter oldDelegate) {
    return oldDelegate.step != step || oldDelegate.sunAngle != sunAngle;
  }
}

// --- भाषा टॉगल बटन (LANG BUTTON) ---

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
