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
      'app_title': 'THE TOWER SCALER',
      'tagline': 'Dual-Angle Height Estimation',
      'init_btn': 'INITIALIZE SCALER',
      'header_title': 'The Tower Scaler',
      'header_subtitle': 'Class 10 • Heights & Distances',
      'phase_label': 'SURVEY PHASE',
      'step_label': 'Stage',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Tower Scaled',
      'success_desc':
          'You have successfully calculated the tower\'s height using multiple angles of elevation.',
      'btn_restart': 'NEW MISSION',
      's0': 'Deploy Surveyor. Locate Target Tower.',
      's1': 'Establish Observation Point A.',
      's2': 'Measure Angle of Elevation from Point A (30°).',
      's3': 'Advance 20m towards the tower to Point B.',
      's4': 'Measure new Angle of Elevation from Point B (60°).',
      's5': 'Identify the two right-angled triangles.',
      's6': 'Set up Equation 1 (Inner Triangle).',
      's7': 'Set up Equation 2 (Outer Triangle).',
      's8': 'Substitute and solve for distance d.',
      's9': 'Calculate final tower height (h).',
      'btn_loc_tower': 'LOCATE TOWER',
      'btn_pt_a': 'ESTABLISH POINT A',
      'btn_ang_a': 'MEASURE ANGLE A (30°)',
      'btn_advance': 'ADVANCE 20m TO POINT B',
      'btn_ang_b': 'MEASURE ANGLE B (60°)',
      'btn_id_tri': 'IDENTIFY TRIANGLES',
      'btn_eq1': 'SETUP EQUATION 1',
      'btn_eq2': 'SETUP EQUATION 2',
      'btn_solve_d': 'SOLVE FOR d',
      'btn_solve_h': 'SOLVE FOR h',
      'msg_tower_ok': 'Target Tower locked in view.',
      'msg_pta_ok': 'Point A established at distance (d + 20m).',
      'msg_anga_ok': 'Angle at A measured: 30°.',
      'msg_adv_ok': 'Observer advanced 20m. Now at distance d.',
      'msg_angb_ok': 'Angle at B measured: 60°.',
      'msg_tri_ok': 'Inner and outer right-angled triangles identified.',
      'msg_eq1_ok': 'Eq 1: tan(60°) = h / d  =>  h = d√3',
      'msg_eq2_ok': 'Eq 2: tan(30°) = h / (d + 20)',
      'msg_sol_d_ok': 'Correct! Distance d = 10m.',
      'msg_sol_h_ok': 'Correct! Height h = 17.32m.',
      'msg_err': 'Incorrect value. Check the equations.',
      'q_solve_d': 'Substitute h = d√3 into Eq 2. Solve for d:',
      'q_solve_h': 'Calculate h = 10 × √3 (Use 1.732):',
    },
    'hi': {
      'app_title': 'टॉवर स्केलर',
      'tagline': 'दोहरे कोण से ऊंचाई का अनुमान',
      'init_btn': 'स्केलर प्रारंभ करें',
      'header_title': 'टॉवर स्केलर',
      'header_subtitle': 'कक्षा 10 • ऊंचाई और दूरी',
      'phase_label': 'सर्वेक्षण चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'टॉवर मापा गया',
      'success_desc':
          'आपने उन्नयन के कई कोणों का उपयोग करके टॉवर की ऊंचाई की सफलतापूर्वक गणना की है।',
      'btn_restart': 'नया मिशन',
      's0': 'सर्वेयर तैनात करें। लक्ष्य टॉवर खोजें।',
      's1': 'अवलोकन बिंदु A स्थापित करें।',
      's2': 'बिंदु A (30°) से उन्नयन कोण मापें।',
      's3': 'टॉवर की ओर 20m आगे बढ़कर बिंदु B पर जाएँ।',
      's4': 'बिंदु B (60°) से नया उन्नयन कोण मापें।',
      's5': 'दो समकोण त्रिभुजों की पहचान करें।',
      's6': 'समीकरण 1 (आंतरिक त्रिभुज) सेट करें।',
      's7': 'समीकरण 2 (बाहरी त्रिभुज) सेट करें।',
      's8': 'दूरी d के लिए प्रतिस्थापित और हल करें।',
      's9': 'अंतिम टॉवर ऊंचाई (h) की गणना करें।',
      'btn_loc_tower': 'टॉवर खोजें',
      'btn_pt_a': 'बिंदु A स्थापित करें',
      'btn_ang_a': 'कोण A मापें (30°)',
      'btn_advance': 'बिंदु B तक 20m आगे बढ़ें',
      'btn_ang_b': 'कोण B मापें (60°)',
      'btn_id_tri': 'त्रिभुज पहचानें',
      'btn_eq1': 'समीकरण 1 सेट करें',
      'btn_eq2': 'समीकरण 2 सेट करें',
      'btn_solve_d': 'd के लिए हल करें',
      'btn_solve_h': 'h के लिए हल करें',
      'msg_tower_ok': 'लक्ष्य टॉवर देखा गया।',
      'msg_pta_ok': 'बिंदु A दूरी (d + 20m) पर स्थापित।',
      'msg_anga_ok': 'A पर कोण मापा गया: 30°।',
      'msg_adv_ok': 'पर्यवेक्षक 20m आगे बढ़ा। अब दूरी d पर।',
      'msg_angb_ok': 'B पर कोण मापा गया: 60°।',
      'msg_tri_ok': 'आंतरिक और बाहरी समकोण त्रिभुज पहचाने गए।',
      'msg_eq1_ok': 'समीकरण 1: tan(60°) = h / d  =>  h = d√3',
      'msg_eq2_ok': 'समीकरण 2: tan(30°) = h / (d + 20)',
      'msg_sol_d_ok': 'सही! दूरी d = 10m.',
      'msg_sol_h_ok': 'सही! ऊंचाई h = 17.32m.',
      'msg_err': 'गलत मान। समीकरणों की जाँच करें।',
      'q_solve_d': 'समीकरण 2 में h = d√3 प्रतिस्थापित करें। d खोजें:',
      'q_solve_h': 'h = 10 × √3 की गणना करें (1.732 का उपयोग करें):',
    },
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['en']![key] ?? key;
  }
}

class TowerScalerApp extends StatefulWidget {
  const TowerScalerApp({super.key});

  @override
  State<TowerScalerApp> createState() => _TowerScalerAppState();
}

class _TowerScalerAppState extends State<TowerScalerApp>
    with TickerProviderStateMixin {
  bool hasStarted = false;
  String lang = 'en';

  // Panels State (पैनल की स्थिति)
  bool isLeftPanelOpen = true;
  bool isRightPanelOpen = false;

  // गतिविधि की स्थिति (Activity State)
  int currentStep = 0;
  bool showSuccessModal = false;

  // पर्यवेक्षक के लिए एनीमेशन स्थिति (Animation State for Observer)
  double obsX = 100.0;
  late AnimationController _moveController;
  late Animation<double> _moveAnimation;

  // कैनवस ट्रांसफ़ॉर्मेशन कंट्रोलर (Canvas Transformation Controller)
  final TransformationController _canvasTransformCtrl =
      TransformationController();

  // इनपुट नियंत्रक (Input Controllers)
  final TextEditingController _inpAns = TextEditingController();
  final ScrollController _stepsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _moveController = AnimationController(
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
    _moveController.dispose();
    _canvasTransformCtrl.dispose();
    _inpAns.dispose();
    _stepsScrollController.dispose();
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

  // Toast संदेश दिखाएं (Show Toast Message)
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

        // ट्रिगर एनिमेशन (Trigger animations)
        if (currentStep == 4) {
          _animateObserver(250.0); // A(100) से B(250) तक ले जाएं
        }

        // जब समीकरण सेट हो जाए, तो कैलकुलेशन दिखाने के लिए स्वतः दायां पैनल खोलें
        if (currentStep == 7) {
          isRightPanelOpen = true;
          isLeftPanelOpen = false;
        }

        _inpAns.clear();

        // 5 सेकंड के बाद मॉडल छिपाएं (Hide modal after 5 seconds)
        if (currentStep == 10) {
          playMathSuccess();
          Timer(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                showSuccessModal = true;
              });
              // 5 सेकंड बाद हटाएं
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

  void _animateObserver(double targetX) {
    _moveAnimation =
        Tween<double>(begin: obsX, end: targetX).animate(
          CurvedAnimation(parent: _moveController, curve: Curves.easeInOut),
        )..addListener(() {
          setState(() {
            obsX = _moveAnimation.value;
          });
        });
    _moveController.forward(from: 0.0);
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
      obsX = 100.0;
      showSuccessModal = false;
      hasStarted = false;
      isLeftPanelOpen = true;
      isRightPanelOpen = false;
      _inpAns.clear();
      _moveController.reset();
      _resetZoom();
    });
  }

  // --- Canvas Control Functions ---
  void _zoom(double factor) {
    final currentScale = _canvasTransformCtrl.value.getMaxScaleOnAxis();
    final newScale = currentScale * factor;
    if (newScale < 0.2 || newScale > 4.0) return;

    final Matrix4 matrix = _canvasTransformCtrl.value.clone();
    matrix.scale(factor, factor);
    _canvasTransformCtrl.value = matrix;
  }

  void _resetZoom() {
    _canvasTransformCtrl.value = Matrix4.identity();
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
              const Icon(Icons.apartment, size: 80, color: accentPink),
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
            // Positioned(bottom: 20, left: 20, child: _buildBackButton()),

            // कैनवस ज़ूम नियंत्रण (कैनवस के ऊपर)
            if (!isRightPanelOpen)
              Positioned(bottom: 80, right: 20, child: _buildCanvasControls()),

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
        padding: const EdgeInsets.only(
          top: 20.0,
          left: 20.0,
          right: 20.0,
          bottom: 100.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
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

            if (currentStep >= 6) ...[
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
                "tan(60°) = h / d",
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'monospace',
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "√3 = h / d",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "h = d√3",
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

            if (currentStep >= 7) ...[
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
                "tan(30°) = h / (d + 20)",
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'monospace',
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "1/√3 = h / (d + 20)",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 18,
                ),
              ),
              if (currentStep >= 8) ...[
                const SizedBox(height: 5),
                const Text(
                  "1/√3 = d√3 / (d + 20)",
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
                "d + 20 = 3d  =>  2d = 20",
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'monospace',
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "d = 10m",
                style: TextStyle(
                  color: accentBlue,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "h = 10 × 1.732",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 5),
              if (currentStep >= 10 || showSuccessModal)
                const Text(
                  "h = 17.32m",
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

  Widget _buildCanvasControls() {
    return Container(
      decoration: BoxDecoration(
        color: bgPanel.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.zoom_in, color: Colors.white),
            onPressed: () {
              playMathClick();
              _zoom(1.2);
            },
            tooltip: 'Zoom In',
          ),
          Container(height: 1, width: 30, color: Colors.white24),
          IconButton(
            icon: const Icon(Icons.zoom_out, color: Colors.white),
            onPressed: () {
              playMathClick();
              _zoom(1 / 1.2);
            },
            tooltip: 'Zoom Out',
          ),
          Container(height: 1, width: 30, color: Colors.white24),
          IconButton(
            icon: const Icon(Icons.center_focus_strong, color: Colors.white),
            onPressed: () {
              playMathClick();
              _resetZoom();
            },
            tooltip: 'Reset Canvas',
          ),
        ],
      ),
    );
  }

  Widget _buildCanvasArea() {
    return Stack(
      children: [
        // ज़ूम और मूव के लिए इंटरएक्टिव कैनवस
        Positioned.fill(
          child: InteractiveViewer(
            transformationController: _canvasTransformCtrl,
            panEnabled: true,
            scaleEnabled: true,
            minScale: 0.2,
            maxScale: 4.0,
            boundaryMargin: const EdgeInsets.all(2000),
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
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 250,
        decoration: BoxDecoration(
          color: bgPanel.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.flag, color: accentBlue, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.get(lang, 'active_mission').toUpperCase(),
                    style: const TextStyle(
                      color: accentBlue,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (currentStep < 10) ...[
                Text(
                  "${AppStrings.get(lang, 'step_label')} ${currentStep + 1}/10",
                  style: const TextStyle(
                    color: accentPink,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  AppStrings.get(lang, 's$currentStep'),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
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
      ),
    );
  }

  Widget _buildControlsArea() {
    switch (currentStep) {
      case 0:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_loc_tower'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_tower_ok'),
        );
      case 1:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_pt_a'),
          color: accentPink,
          onPressed: () => advanceStep('msg_pta_ok'),
        );
      case 2:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_ang_a'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_anga_ok'),
        );
      case 3:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_advance'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_adv_ok'),
        );
      case 4:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_ang_b'),
          color: accentPink,
          onPressed: () => advanceStep('msg_angb_ok'),
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
          color: accentYellow,
          onPressed: () => advanceStep('msg_eq1_ok'),
        );
      case 7:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_eq2'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_eq2_ok'),
        );
      case 8:
        return _InputControlBlock(
          question: AppStrings.get(lang, 'q_solve_d'),
          hint: 'd = ?',
          controller: _inpAns,
          btnText: AppStrings.get(lang, 'btn_solve_d'),
          onVerify: () => verifyInput('10', 'msg_sol_d_ok'),
        );
      case 9:
        return _InputControlBlock(
          question: AppStrings.get(lang, 'q_solve_h'),
          hint: 'h = ?',
          controller: _inpAns,
          btnText: AppStrings.get(lang, 'btn_solve_h'),
          onVerify: () => verifyInput('17.32', 'msg_sol_h_ok'),
        );
      default:
        return const SizedBox();
    }
  }

  // --- ग्राफिकल दृश्य (Graphical Scenes) ---

  Widget _buildSceneGraphics() {
    return SizedBox(
      width: 500,
      height: 380,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: const Size(500, 380),
            painter: TowerSurveyPainter(step: currentStep, obsX: obsX),
          ),

          // --- LABELS & MEASUREMENTS ---
          if (currentStep >= 1) ...[
            const Positioned(
              left: 85,
              top: 310,
              child: Text(
                "A",
                style: TextStyle(
                  color: accentPink,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (currentStep < 4)
              const Positioned(
                left: 230,
                top: 310,
                child: Text(
                  "Distance = d + 20m",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
          ],

          if (currentStep >= 3 && currentStep < 4) ...[
            const Positioned(
              left: 130,
              top: 275,
              child: Text(
                "30°",
                style: TextStyle(
                  color: accentYellow,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],

          if (currentStep >= 4) ...[
            const Positioned(
              left: 235,
              top: 310,
              child: Text(
                "B",
                style: TextStyle(
                  color: accentBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Positioned(
              left: 150,
              top: 310,
              child: Text(
                "20m",
                style: TextStyle(
                  color: accentGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              left: 315,
              top: 310,
              child: Text(
                currentStep >= 9 ? "d = 10m" : "d",
                style: const TextStyle(
                  color: accentBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],

          if (currentStep >= 5) ...[
            const Positioned(
              left: 260,
              top: 265,
              child: Text(
                "60°",
                style: TextStyle(
                  color: accentYellow,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // A का कोण फिर से जोड़ें (Re-add A's angle)
            const Positioned(
              left: 130,
              top: 275,
              child: Text(
                "30°",
                style: TextStyle(
                  color: accentPink,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],

          if (currentStep >= 1) ...[
            Positioned(
              left: 410,
              top: 150,
              child: Text(
                currentStep == 10 && showSuccessModal ? "h = 17.32m" : "h",
                style: const TextStyle(
                  color: accentGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// --- उप-विजेट (SUB-WIDGETS) ---

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
      mainAxisSize: MainAxisSize.min,
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
          ),
        ),
      ),
    );
  }
}

// --- कस्टम पेंटर (CUSTOM PAINTERS) ---

class TowerSurveyPainter extends CustomPainter {
  final int step;
  final double obsX;

  TowerSurveyPainter({required this.step, required this.obsX});

  @override
  void paint(Canvas canvas, Size size) {
    // समन्वय प्रणाली (Coordinate system)
    Offset bBase = const Offset(400, 300); // इमारत का आधार (Building Base)
    Offset bTop = const Offset(400, 100); // इमारत का शीर्ष (Building Top)

    // यथार्थवादी ज़मीन बनाएं (Draw Realistic Ground)
    Rect groundRect = Rect.fromLTRB(-1000, 300, 2000, 1000);
    Paint groundPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 300),
        const Offset(0, 600),
        [const Color(0xFF1B2E26), const Color(0xFF0A120E)], // Grass/Dirt vibe
      );
    canvas.drawRect(groundRect, groundPaint);

    // Depth Line for the Ground (Surface level)
    canvas.drawLine(
      const Offset(-1000, 300),
      const Offset(2000, 300),
      Paint()
        ..color = Colors.green.shade800.withOpacity(0.8)
        ..strokeWidth = 4,
    );

    // टावर बनाएं (Draw Tower)
    if (step >= 1) {
      canvas.drawRect(
        Rect.fromLTWH(380, 100, 40, 200),
        Paint()..color = Colors.grey.shade800,
      );
      // विवरण (details)
      for (int i = 0; i < 5; i++) {
        canvas.drawRect(
          Rect.fromLTWH(385, 120 + i * 35, 10, 15),
          Paint()..color = Colors.yellow.withOpacity(0.3),
        );
        canvas.drawRect(
          Rect.fromLTWH(405, 120 + i * 35, 10, 15),
          Paint()..color = Colors.yellow.withOpacity(0.3),
        );
      }
      // समकोण (Right angle)
      _drawRightAngle(canvas, bBase, -1, -1, Colors.white54);
    }

    Offset obsPos = Offset(obsX, 300); // पर्यवेक्षक की स्थिति

    // बिंदु A (100) बनाएं (Draw Point A)
    if (step >= 2) {
      canvas.drawCircle(const Offset(100, 300), 5, Paint()..color = accentPink);
    }

    // बिंदु B (250) बनाएं (Draw Point B)
    if (step >= 4) {
      canvas.drawCircle(const Offset(250, 300), 5, Paint()..color = accentBlue);
      // 20m खंड को हाइलाइट करें (Highlight the 20m segment)
      canvas.drawLine(
        const Offset(100, 300),
        const Offset(250, 300),
        Paint()
          ..color = accentGreen
          ..strokeWidth = 4,
      );
    }

    // दृष्टि रेखा A बनाएं (Draw Line of Sight A)
    if (step >= 3) {
      _drawDashedLine(
        canvas,
        const Offset(100, 300),
        bTop,
        Paint()
          ..color = accentPink.withOpacity(0.7)
          ..strokeWidth = 2,
      );
      // कोण A (Angle A)
      _drawAngleArc(
        canvas,
        const Offset(100, 300),
        bTop,
        bBase,
        accentYellow,
        50,
      );
    }

    // दृष्टि रेखा B बनाएं (Draw Line of Sight B)
    if (step >= 5) {
      _drawDashedLine(
        canvas,
        const Offset(250, 300),
        bTop,
        Paint()
          ..color = accentBlue.withOpacity(0.7)
          ..strokeWidth = 2,
      );
      // कोण B (Angle B)
      _drawAngleArc(
        canvas,
        const Offset(250, 300),
        bTop,
        bBase,
        accentYellow,
        40,
      );
    }

    // त्रिभुजों को हाइलाइट करें (Highlight Triangles)
    if (step >= 6) {
      // आंतरिक त्रिभुज भरें (Inner Triangle Fill)
      Path innerTri = Path()
        ..moveTo(250, 300)
        ..lineTo(400, 300)
        ..lineTo(400, 100)
        ..close();
      canvas.drawPath(
        innerTri,
        Paint()
          ..color = accentBlue.withOpacity(0.1)
          ..style = PaintingStyle.fill,
      );

      // बाहरी त्रिभुज भरें (Outer Triangle Fill)
      Path outerTri = Path()
        ..moveTo(100, 300)
        ..lineTo(250, 300)
        ..lineTo(400, 100)
        ..close();
      canvas.drawPath(
        outerTri,
        Paint()
          ..color = accentPink.withOpacity(0.1)
          ..style = PaintingStyle.fill,
      );
    }

    // पर्यवेक्षक बनाएं (एनिमेटेड) (Draw Observer)
    if (step >= 2) {
      canvas.drawCircle(obsPos, 8, Paint()..color = accentYellow);
      canvas.drawCircle(obsPos, 4, Paint()..color = bgDark);
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

  void _drawAngleArc(
    Canvas canvas,
    Offset center,
    Offset top,
    Offset base,
    Color color,
    double radius,
  ) {
    double angleRad = math.atan2(center.dy - top.dy, base.dx - center.dx);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      -angleRad,
      true,
      Paint()
        ..color = color.withOpacity(0.4)
        ..style = PaintingStyle.fill,
    );
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
  bool shouldRepaint(covariant TowerSurveyPainter oldDelegate) {
    return oldDelegate.step != step || oldDelegate.obsX != obsX;
  }
}

// --- उप-विजेट (SUB-WIDGETS) ---

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
