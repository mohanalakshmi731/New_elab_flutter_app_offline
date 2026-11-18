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

class AppStrings {
  static const Map<String, Map<String, String>> data = {
    'en': {
      'app_title': 'THE AREA SURVEYOR',
      'tagline': 'Area of a Triangle using Coordinates',
      'init_btn': 'INITIALIZE SURVEYOR',
      'header_title': 'The Area Surveyor',
      'header_subtitle': 'Class 10 • Coordinate Geometry',
      'phase_label': 'SURVEY PHASE',
      'step_label': 'Stage',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Area Secured',
      'success_desc':
          'You have successfully calculated the area of the triangular zone.',
      'btn_restart': 'NEW MISSION',
      's0': 'Establish Origin (0,0) on the grid.',
      's1': 'Plot Vertex A at coordinates (2, 4).',
      's2': 'Plot Vertex B at coordinates (8, 2).',
      's3': 'Plot Vertex C at coordinates (12, 10).',
      's4': 'Connect vertices to form Triangle ABC.',
      's5': 'Recall coordinate geometry Area Formula.',
      's6': 'Substitute (x,y) values into the formula.',
      's7': 'Simplify the inner y-coordinate differences.',
      's8': 'Multiply and sum the resulting products.',
      's9': 'Calculate final absolute area.',
      'btn_start': 'ESTABLISH ORIGIN',
      'btn_loc_a': 'LOCATE A (2,4)',
      'btn_loc_b': 'LOCATE B (8,2)',
      'btn_loc_c': 'LOCATE C (12,10)',
      'btn_draw_area': 'CONNECT BOUNDARY',
      'btn_formula': 'LOAD FORMULA',
      'btn_substitute': 'SUBSTITUTE VALUES',
      'btn_calc_inner': 'CALCULATE INNER TERMS',
      'btn_sum': 'SUM PRODUCTS',
      'btn_complete': 'FINALIZE REPORT',
      'msg_obs_ok': 'Grid active at Origin.',
      'msg_a_ok': 'Vertex A marked at (2,4).',
      'msg_b_ok': 'Vertex B marked at (8,2).',
      'msg_c_ok': 'Vertex C marked at (12,10).',
      'msg_area_ok': 'Triangular boundary established.',
      'msg_form_ok': 'Formula loaded into memory.',
      'msg_sub_ok': 'Coordinate substitution complete.',
      'msg_calc_inner_ok': 'Inner y-differences calculated.',
      'msg_sum_ok': 'Summation complete.',
      'msg_final_ok': 'Final area computed: 28 sq units.',
      'msg_err': 'Calculation error.',
      'data_title': 'CALCULATIONS',
      'msg_waiting_data': 'Waiting for coordinate data...',
    },
    'hi': {
      'app_title': 'एरिया सर्वेयर',
      'tagline': 'निर्देशांकों का उपयोग करके त्रिभुज का क्षेत्रफल',
      'init_btn': 'सर्वेयर प्रारंभ करें',
      'header_title': 'एरिया सर्वेयर',
      'header_subtitle': 'कक्षा 10 • निर्देशांक ज्यामिति',
      'phase_label': 'सर्वेक्षण चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'क्षेत्रफल सुरक्षित',
      'success_desc':
          'आपने त्रिकोणीय क्षेत्र के क्षेत्रफल की सफलतापूर्वक गणना की है।',
      'btn_restart': 'नया मिशन',
      's0': 'ग्रिड पर मूल बिंदु (0,0) स्थापित करें।',
      's1': 'शीर्ष A को निर्देशांक (2, 4) पर प्लॉट करें।',
      's2': 'शीर्ष B को निर्देशांक (8, 2) पर प्लॉट करें।',
      's3': 'शीर्ष C को निर्देशांक (12, 10) पर प्लॉट करें।',
      's4': 'त्रिभुज ABC बनाने के लिए शीर्षों को जोड़ें।',
      's5': 'निर्देशांक ज्यामिति क्षेत्रफल सूत्र याद करें।',
      's6': 'सूत्र में (x,y) मानों को प्रतिस्थापित करें।',
      's7': 'आंतरिक y-निर्देशांक अंतरों को सरल करें।',
      's8': 'गुणनफलों को गुणा करें और जोड़ें।',
      's9': 'अंतिम निरपेक्ष क्षेत्रफल की गणना करें।',
      'btn_start': 'मूल बिंदु स्थापित करें',
      'btn_loc_a': 'A खोजें (2,4)',
      'btn_loc_b': 'B खोजें (8,2)',
      'btn_loc_c': 'C खोजें (12,10)',
      'btn_draw_area': 'सीमा कनेक्ट करें',
      'btn_formula': 'सूत्र लोड करें',
      'btn_substitute': 'मान प्रतिस्थापित करें',
      'btn_calc_inner': 'आंतरिक पदों की गणना करें',
      'btn_sum': 'गुणनफलों का योग',
      'btn_complete': 'रिपोर्ट पूरी करें',
      'msg_obs_ok': 'ग्रिड सक्रिय।',
      'msg_a_ok': 'शीर्ष A (2,4) पर चिह्नित।',
      'msg_b_ok': 'शीर्ष B (8,2) पर चिह्नित।',
      'msg_c_ok': 'शीर्ष C (12,10) पर चिह्नित।',
      'msg_area_ok': 'त्रिकोणीय सीमा स्थापित।',
      'msg_form_ok': 'सूत्र मेमोरी में लोड किया गया।',
      'msg_sub_ok': 'निर्देशांक प्रतिस्थापन पूर्ण।',
      'msg_calc_inner_ok': 'आंतरिक y-अंतरों की गणना की गई।',
      'msg_sum_ok': 'योग पूर्ण।',
      'msg_final_ok': 'अंतिम क्षेत्रफल गणना: 28 वर्ग इकाई।',
      'msg_err': 'गणना त्रुटि।',
      'data_title': 'गणना',
      'msg_waiting_data': 'निर्देशांक डेटा की प्रतीक्षा है...',
    },
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['en']![key] ?? key;
  }
}

class AreaSurveyorApp extends StatefulWidget {
  const AreaSurveyorApp({super.key});

  @override
  State<AreaSurveyorApp> createState() => _AreaSurveyorAppState();
}

class _AreaSurveyorAppState extends State<AreaSurveyorApp>
    with TickerProviderStateMixin {
  bool hasStarted = false;
  String lang = 'en';

  // Sidebar Expand/Collapse States
  bool panelOpen = true;
  bool isDataPanelExpanded = false;

  // Activity State
  int currentStep = 0;
  bool showSuccessModal = false;

  // Canvas Pan/Zoom Controller
  final TransformationController _viewController = TransformationController();
  bool _isInitialPanSet = false;

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
    _viewController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void startGame() {
    playMathStart();
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
        backgroundColor: bgPanel.withOpacity(0.95),
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
      playVibration('click');
      setState(() {
        currentStep++;
        if (msgKey.isNotEmpty) {
          showToast(AppStrings.get(lang, msgKey));
        }

        // Auto open data/calculation panel when the formula step is reached
        if (currentStep == 5 && !isDataPanelExpanded) {
          isDataPanelExpanded = true;
          panelOpen = false; // Mutually exclusive
        }

        if (currentStep == 9) {
          playVibration('success');
          Timer(const Duration(seconds: 2), () {
            setState(() {
              showSuccessModal = true;
            });

            Timer(const Duration(seconds: 5), () {
              if (mounted && showSuccessModal) {
                setState(() => showSuccessModal = false);
              }
            });
          });
        }
      });
    }
  }

  void resetLab() {
    playMathStart();
    playVibration('click');
    setState(() {
      currentStep = 0;
      showSuccessModal = false;
      hasStarted = false;
      panelOpen = true;
      isDataPanelExpanded = false;
      _isInitialPanSet = false;
      _viewController.value = Matrix4.identity();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Responsive panel width
    final double panelWidth = screenWidth < 600
        ? screenWidth * 0.85
        : (screenWidth * 0.4).clamp(320.0, 450.0);

    final t = AppStrings.data[lang]!;

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
                  child: const Icon(Icons.terrain, size: 80, color: accentPink),
                ),
                const SizedBox(height: 20),
                Text(
                  t['app_title']!,
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
                  t['tagline']!,
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
                      t['init_btn']!,
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
            // Core Layout: Side Panels + Canvas
            Positioned.fill(
              child: Row(
                children: [
                  // Left Side Panel (Controls)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: panelOpen ? panelWidth : 0,
                    child: ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.centerLeft,
                        minWidth: panelWidth,
                        maxWidth: panelWidth,
                        child: _buildSidePanel(t),
                      ),
                    ),
                  ),

                  // Interactive Canvas Area
                  Expanded(
                    child: ClipRect(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (!_isInitialPanSet) {
                            _isInitialPanSet = true;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              final dx = -(3000 - constraints.maxWidth) / 2;
                              final dy = -(3000 - constraints.maxHeight) / 2;
                              _viewController.value = Matrix4.identity()
                                ..translate(dx, dy);
                            });
                          }
                          return InteractiveViewer(
                            transformationController: _viewController,
                            boundaryMargin: const EdgeInsets.all(2000),
                            minScale: 0.1,
                            maxScale: 5.0,
                            constrained: false,
                            child: Container(
                              width: 3000,
                              height: 3000,
                              alignment: Alignment.center,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: BackgroundGridPainter(),
                                    ),
                                  ),
                                  Center(child: _buildSceneGraphics()),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Right Side Panel (Calculations)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: isDataPanelExpanded ? panelWidth : 0,
                    child: ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.centerRight,
                        minWidth: panelWidth,
                        maxWidth: panelWidth,
                        child: _buildDataPanel(t),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Floating HUD (Visible when left sidebar is collapsed)
            if (!panelOpen)
              Positioned(top: 90, left: 24, child: _buildFloatingHUD(t)),

            // Top-Left Floating Button (Menu Toggle)
            Positioned(
              top: 24,
              left: 24,
              child: FloatingActionButton(
                backgroundColor: accentBlue,
                elevation: 8,
                onPressed: () {
                  playVibration('click');
                  setState(() {
                    panelOpen = !panelOpen;
                    if (panelOpen) {
                      isDataPanelExpanded = false;
                    }
                  });
                },
                child: Icon(
                  panelOpen ? Icons.menu_open : Icons.menu,
                  color: Colors.white,
                ),
              ),
            ),

            // Bottom-Left Floating Button (Back / Reset)
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

            // Bottom-Right Floating Data/Calc Toggle
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton(
                backgroundColor: accentYellow,
                elevation: 8,
                onPressed: () {
                  playVibration('click');
                  setState(() {
                    isDataPanelExpanded = !isDataPanelExpanded;
                    if (isDataPanelExpanded) {
                      panelOpen = false;
                    }
                  });
                },
                child: Icon(
                  isDataPanelExpanded ? Icons.close : Icons.functions,
                  color: bgDark,
                ),
              ),
            ),

            // Success Overlay Modal
            if (showSuccessModal) _buildSuccessModal(t),
          ],
        ),
      ),
    );
  }

  // --- UI BUILDERS ---

  Widget _buildSidePanel(Map<String, String> t) {
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
                top: 80, // Clear the top-left floating menu button visually
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
                        child: const Icon(
                          Icons.landscape,
                          color: bgDark,
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t['header_title']!.toUpperCase(),
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
                              t['header_subtitle']!,
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
                bottom: 90, // Bottom padding to clear floating back button
              ),
              child: _buildExploreContent(t),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataPanel(Map<String, String> t) {
    return Container(
      decoration: BoxDecoration(
        color: bgPanel.withOpacity(0.95),
        border: Border(left: BorderSide(color: accentYellow.withOpacity(0.3))),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(
              top: 80,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: accentYellow.withOpacity(0.3)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: accentYellow,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: accentYellow.withOpacity(0.2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.functions, color: bgDark, size: 20),
                ),
                Expanded(
                  child: Text(
                    t['data_title']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildCalculationsList(t),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationsList(Map<String, String> t) {
    if (currentStep < 5) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: Text(
            t['msg_waiting_data']!,
            style: const TextStyle(
              color: Colors.white30,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    List<Widget> cards = [];

    // General Formula
    if (currentStep >= 5) {
      cards.add(
        _buildCalcCard(
          "Area Formula",
          "½ |x₁(y₂-y₃) + x₂(y₃-y₁) + x₃(y₁-y₂)|",
          "...",
          accentPink,
          currentStep == 5,
        ),
      );
    }

    // Substitution
    if (currentStep >= 6) {
      cards.add(
        _buildCalcCard(
          "Substitute Coordinates",
          "½ | 2(2 - 10) + 8(10 - 4) + 12(4 - 2) |",
          "...",
          accentBlue,
          currentStep == 6,
        ),
      );
    }

    // Inner Calculations
    if (currentStep >= 7) {
      cards.add(
        _buildCalcCard(
          "Inner Differences",
          "½ | 2(-8) + 8(6) + 12(2) |",
          "...",
          accentGreen,
          currentStep == 7,
        ),
      );
    }

    // Products
    if (currentStep >= 8) {
      cards.add(
        _buildCalcCard(
          "Sum of Products",
          "½ | -16 + 48 + 24 |",
          "½ | 56 |",
          accentYellow,
          currentStep == 8,
        ),
      );
    }

    // Final Result
    if (currentStep >= 9) {
      cards.add(
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: accentGreen.withOpacity(0.2),
            border: Border.all(color: accentGreen),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Column(
            children: [
              Text(
                "Final Area",
                style: TextStyle(
                  color: accentGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "28 sq units",
                style: TextStyle(
                  color: accentGreen,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: cards
          .map(
            (c) =>
                Padding(padding: const EdgeInsets.only(bottom: 15), child: c),
          )
          .toList(),
    );
  }

  Widget _buildCalcCard(
    String title,
    String expression1,
    String expression2,
    Color color,
    bool isHighlighted,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isHighlighted ? color : Colors.white12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            expression1,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          if (expression2 != "...")
            Text(
              "= $expression2",
              style: TextStyle(
                color: isHighlighted ? accentYellow : Colors.white24,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'monospace',
              ),
            ),
        ],
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

  Widget _buildExploreContent(Map<String, String> t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t['phase_label']!,
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
              "${t['step_label']} ${currentStep + 1}/10",
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
            t['mission_log']!.toUpperCase(),
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
                  "${index + 1}. ${t['s$index']}",
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
          child: _buildControlsArea(t),
        ),
      ],
    );
  }

  Widget _buildFloatingHUD(Map<String, String> t) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 80,
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
                    t['active_mission']!.toUpperCase(),
                    style: const TextStyle(
                      color: accentPink,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${currentStep + 1}/10",
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
                t['s$currentStep']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
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
                child: _buildControlsArea(t),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlsArea(Map<String, String> t) {
    switch (currentStep) {
      case 0:
        return _ControlButton(
          text: t['btn_start']!,
          color: accentBlue,
          onPressed: () => advanceStep('msg_obs_ok'),
        );
      case 1:
        return _ControlButton(
          text: t['btn_loc_a']!,
          color: accentPink,
          onPressed: () => advanceStep('msg_a_ok'),
        );
      case 2:
        return _ControlButton(
          text: t['btn_loc_b']!,
          color: accentGreen,
          onPressed: () => advanceStep('msg_b_ok'),
        );
      case 3:
        return _ControlButton(
          text: t['btn_loc_c']!,
          color: accentYellow,
          onPressed: () => advanceStep('msg_c_ok'),
        );
      case 4:
        return _ControlButton(
          text: t['btn_draw_area']!,
          color: accentBlue,
          onPressed: () => advanceStep('msg_area_ok'),
        );
      case 5:
        return _ControlButton(
          text: t['btn_formula']!,
          color: accentPink,
          onPressed: () => advanceStep('msg_form_ok'),
        );
      case 6:
        return _ControlButton(
          text: t['btn_substitute']!,
          color: accentGreen,
          onPressed: () => advanceStep('msg_sub_ok'),
        );
      case 7:
        return _ControlButton(
          text: t['btn_calc_inner']!,
          color: accentYellow,
          onPressed: () => advanceStep('msg_calc_inner_ok'),
        );
      case 8:
        return _ControlButton(
          text: t['btn_sum']!,
          color: accentBlue,
          onPressed: () => advanceStep('msg_sum_ok'),
        );
      case 9:
        return _ControlButton(
          text: t['btn_complete']!,
          color: accentGreen,
          onPressed: () => advanceStep('msg_final_ok'),
        );
      default:
        return const SizedBox();
    }
  }

  // --- Graphical Scenes ---

  Widget _buildSceneGraphics() {
    return Container(
      width: 550,
      height: 420,
      decoration: BoxDecoration(
        color: const Color(
          0xFF0B1121,
        ), // Distinct dark background for the graph paper
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: CustomPaint(
          size: const Size(550, 420),
          painter: AreaPainter(step: currentStep),
        ),
      ),
    );
  }

  Widget _buildSuccessModal(Map<String, String> t) {
    return Positioned.fill(
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
                  t['badge_title']!.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  t['success_desc']!,
                  style: const TextStyle(color: Colors.white54),
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
                    t['btn_restart']!,
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
    );
  }
}

// --- SUB-WIDGETS & PAINTERS ---

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
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class AreaPainter extends CustomPainter {
  final int step;

  // Center the coordinate system nicely in the 550x420 space
  final double ox = 50.0;
  final double oy = 370.0;
  final double scale = 30.0; // Larger scale for better clarity

  AreaPainter({required this.step});

  Offset _mapPt(double x, double y) {
    return Offset(ox + x * scale, oy - y * scale);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw crisp inner grid specific to the graph paper bounds
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 15; i++) {
      canvas.drawLine(
        _mapPt(i.toDouble(), -1),
        _mapPt(i.toDouble(), 12),
        gridPaint,
      );
    }
    for (int i = -1; i <= 12; i++) {
      canvas.drawLine(
        _mapPt(-1, i.toDouble()),
        _mapPt(15, i.toDouble()),
        gridPaint,
      );
    }

    // 2. Draw prominent Axes
    final axisPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 2.0;

    canvas.drawLine(_mapPt(-1, 0), _mapPt(15, 0), axisPaint); // X-Axis
    canvas.drawLine(_mapPt(0, -1), _mapPt(0, 12), axisPaint); // Y-Axis

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    void drawText(
      String text,
      Offset pos,
      Color color, [
      double fontSize = 12,
      FontWeight weight = FontWeight.normal,
      bool drawBg = false,
    ]) {
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: weight,
          fontFamily: 'monospace',
        ),
      );
      textPainter.layout();

      final textOffset = Offset(
        pos.dx - textPainter.width / 2,
        pos.dy - textPainter.height / 2,
      );

      if (drawBg) {
        final bgRect = Rect.fromCenter(
          center: pos,
          width: textPainter.width + 12,
          height: textPainter.height + 6,
        );
        final bgRRect = RRect.fromRectAndRadius(
          bgRect,
          const Radius.circular(6),
        );
        canvas.drawRRect(bgRRect, Paint()..color = bgDark.withOpacity(0.85));
        canvas.drawRRect(
          bgRRect,
          Paint()
            ..color = color.withOpacity(0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0,
        );
      }

      textPainter.paint(canvas, textOffset);
    }

    // Axis Labels
    drawText("X", _mapPt(15.5, 0), Colors.white70, 14, FontWeight.bold);
    drawText("Y", _mapPt(0, 12.5), Colors.white70, 14, FontWeight.bold);

    // Numbering on axes
    for (int i = 2; i <= 14; i += 2) {
      drawText(i.toString(), _mapPt(i.toDouble(), -0.6), Colors.white60, 10);
    }
    for (int i = 2; i <= 10; i += 2) {
      drawText(i.toString(), _mapPt(-0.6, i.toDouble()), Colors.white60, 10);
    }

    double x1 = 2, y1 = 4;
    double x2 = 8, y2 = 2;
    double x3 = 12, y3 = 10;

    if (step >= 1) {
      // Changed from 0 to 1 to match "ESTABLISH ORIGIN" action
      drawText("(0,0)", _mapPt(-0.8, -0.6), Colors.white, 10, FontWeight.bold);
      canvas.drawCircle(_mapPt(0, 0), 4, Paint()..color = Colors.white);
    }

    if (step >= 5) {
      // Changed from 4 to 5 to match "CONNECT BOUNDARY" action
      final fillPaint = Paint()
        ..color = accentGreen.withOpacity(0.25)
        ..style = PaintingStyle.fill;
      Path triPath = Path()
        ..moveTo(_mapPt(x1, y1).dx, _mapPt(x1, y1).dy)
        ..lineTo(_mapPt(x2, y2).dx, _mapPt(x2, y2).dy)
        ..lineTo(_mapPt(x3, y3).dx, _mapPt(x3, y3).dy)
        ..close();
      canvas.drawPath(triPath, fillPaint);

      final strokePaint = Paint()
        ..color = accentGreen
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      canvas.drawPath(triPath, strokePaint);
    }

    // Drawing Points and robust labels with backgrounds
    if (step >= 2) {
      // Changed from 1 to 2 to match "LOCATE A" action
      canvas.drawCircle(_mapPt(x1, y1), 6, Paint()..color = accentPink);
      drawText(
        "A(2,4)",
        _mapPt(x1 - 1.2, y1 + 0.8),
        accentPink,
        14,
        FontWeight.bold,
        true,
      );
    }

    if (step >= 3) {
      // Changed from 2 to 3 to match "LOCATE B" action
      canvas.drawCircle(_mapPt(x2, y2), 6, Paint()..color = accentBlue);
      drawText(
        "B(8,2)",
        _mapPt(x2 + 1.8, y2 - 0.4),
        accentBlue,
        14,
        FontWeight.bold,
        true,
      );
    }

    if (step >= 4) {
      // Changed from 3 to 4 to match "LOCATE C" action
      canvas.drawCircle(_mapPt(x3, y3), 6, Paint()..color = accentYellow);
      drawText(
        "C(12,10)",
        _mapPt(x3 + 1.8, y3 + 0.6),
        accentYellow,
        14,
        FontWeight.bold,
        true,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AreaPainter oldDelegate) {
    return oldDelegate.step != step;
  }
}

// Subtle background grid for the infinite space outside the graph paper
class BackgroundGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
          .withOpacity(0.02) // Extremely faint
      ..strokeWidth = 1.0;

    const double step = 40;
    for (double i = -3000; i < size.width + 3000; i += step) {
      canvas.drawLine(Offset(i, -3000), Offset(i, size.height + 3000), paint);
    }
    for (double i = -3000; i < size.height + 3000; i += step) {
      canvas.drawLine(Offset(-3000, i), Offset(size.width + 3000, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
