// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as dartMath;
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
      'app_title': 'THE AREA RATIO CUTTER',
      'tagline': 'Areas of Similar Triangles',
      'init_btn': 'INITIALIZE CUTTER',
      'header_title': 'The Area Ratio Cutter',
      'header_subtitle': 'Class 10 • Triangles & Area Ratio',
      'phase_label': 'ANALYSIS PHASE',
      'step_label': 'Stage',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Theorem Verified',
      'success_desc': 'The Area Ratio theorem has been successfully proven!',
      'btn_restart': 'NEW ANALYSIS',
      's0': 'Instantiate Base Triangle (T1).',
      's1': 'Measure T1: Base & Height.',
      's2': 'Calculate Area of T1.',
      's3': 'Clone and Scale T1 by factor of 2 (T2).',
      's4': 'Measure T2: Base & Height.',
      's5': 'Calculate Area of T2.',
      's6': 'Determine Ratio of Corresponding Sides.',
      's7': 'Determine Ratio of Areas.',
      's8': 'Compare: Area Ratio vs (Side Ratio)²',
      's9': 'Verify Theorem.',
      'btn_create_t1': 'CREATE T1',
      'btn_meas_t1': 'MEASURE T1',
      'btn_calc_a1': 'CALCULATE T1 AREA',
      'btn_scale_t2': 'SCALE T2 (x2)',
      'btn_meas_t2': 'MEASURE T2',
      'btn_calc_a2': 'CALCULATE T2 AREA',
      'btn_ratio_sides': 'RATIO OF SIDES',
      'btn_ratio_areas': 'RATIO OF AREAS',
      'btn_compare': 'COMPARE RATIOS',
      'btn_verify': 'VERIFY THEOREM',
      'msg_t1_ok': 'Base Triangle T1 instantiated.',
      'msg_meas1_ok': 'T1 Dimensions: b=3, h=4.',
      'msg_a1_ok': 'Area of T1 = 6 sq units.',
      'msg_t2_ok': 'T2 instantiated (Scale Factor = 2).',
      'msg_meas2_ok': 'T2 Dimensions: b=6, h=8.',
      'msg_a2_ok': 'Area of T2 = 24 sq units.',
      'msg_rs_ok': 'Side Ratio = 2 / 1.',
      'msg_ra_ok': 'Area Ratio = 4 / 1.',
      'msg_comp_ok': '4 = 2². Relationship holds.',
      'data_title': 'CALCULATIONS',
      'msg_waiting_data': 'Waiting for measurements...',
    },
    'hi': {
      'app_title': 'क्षेत्रफल अनुपात कटर',
      'tagline': 'समरूप त्रिभुजों का क्षेत्रफल',
      'init_btn': 'कटर प्रारंभ करें',
      'header_title': 'क्षेत्रफल अनुपात कटर',
      'header_subtitle': 'कक्षा 10 • त्रिभुज और क्षेत्रफल अनुपात',
      'phase_label': 'विश्लेषण चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'प्रमेय सत्यापित',
      'success_desc': 'क्षेत्रफल अनुपात प्रमेय सफलतापूर्वक सिद्ध हो गया है!',
      'btn_restart': 'नया विश्लेषण',
      's0': 'आधार त्रिभुज (T1) बनाएँ।',
      's1': 'T1 मापें: आधार और ऊंचाई।',
      's2': 'T1 के क्षेत्रफल की गणना करें।',
      's3': '2 के कारक द्वारा T1 का क्लोन और स्केल (T2)।',
      's4': 'T2 मापें: आधार और ऊंचाई।',
      's5': 'T2 के क्षेत्रफल की गणना करें।',
      's6': 'संगत भुजाओं का अनुपात निर्धारित करें।',
      's7': 'क्षेत्रफलों का अनुपात निर्धारित करें।',
      's8': 'तुलना करें: क्षेत्रफल अनुपात बनाम (भुजा अनुपात)²',
      's9': 'प्रमेय सत्यापित करें।',
      'btn_create_t1': 'T1 बनाएँ',
      'btn_meas_t1': 'T1 मापें',
      'btn_calc_a1': 'T1 क्षेत्रफल गणना',
      'btn_scale_t2': 'T2 (x2) स्केल करें',
      'btn_meas_t2': 'T2 मापें',
      'btn_calc_a2': 'T2 क्षेत्रफल गणना',
      'btn_ratio_sides': 'भुजाओं का अनुपात',
      'btn_ratio_areas': 'क्षेत्रफलों का अनुपात',
      'btn_compare': 'अनुपातों की तुलना',
      'btn_verify': 'प्रमेय जांचें',
      'msg_t1_ok': 'आधार त्रिभुज T1 बनाया गया।',
      'msg_meas1_ok': 'T1 आयाम: b=3, h=4.',
      'msg_a1_ok': 'T1 का क्षेत्रफल = 6 वर्ग इकाई।',
      'msg_t2_ok': 'T2 बनाया गया (स्केल फैक्टर = 2)।',
      'msg_meas2_ok': 'T2 आयाम: b=6, h=8.',
      'msg_a2_ok': 'T2 का क्षेत्रफल = 24 वर्ग इकाई।',
      'msg_rs_ok': 'भुजा अनुपात = 2 / 1.',
      'msg_ra_ok': 'क्षेत्रफल अनुपात = 4 / 1.',
      'msg_comp_ok': '4 = 2². संबंध सही है।',
      'data_title': 'गणना',
      'msg_waiting_data': 'माप की प्रतीक्षा है...',
    },
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['en']![key] ?? key;
  }
}

class AreaRatioCutterApp extends StatefulWidget {
  const AreaRatioCutterApp({super.key});

  @override
  State<AreaRatioCutterApp> createState() => _AreaRatioCutterAppState();
}

class _AreaRatioCutterAppState extends State<AreaRatioCutterApp>
    with TickerProviderStateMixin {
  bool hasStarted = false;
  String lang = 'en';

  // Sidebar Expand/Collapse State
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

        // Auto open data panel when calculations begin
        if (currentStep == 2 && !isDataPanelExpanded) {
          isDataPanelExpanded = true;
          panelOpen = false; // Mutually exclusive
        }

        if (currentStep == 9) {
          playVibration('success');
          Timer(const Duration(seconds: 2), () {
            setState(() {
              showSuccessModal = true;
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
                child: const Icon(
                  Icons.content_cut,
                  size: 80,
                  color: accentPink,
                ),
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
                  // Left Side Panel
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
                                    child: CustomPaint(painter: GridPainter()),
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

                  // Right Side Panel (Data Collection / Calculations)
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

            // Floating HUD (Visible when sidebar is collapsed)
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

            // // Bottom-Left Floating Button (Back / Reset)
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

            // Bottom-Right Floating Data Toggle
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
                  isDataPanelExpanded ? Icons.close : Icons.analytics,
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
                          Icons.content_cut,
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
                  child: const Icon(Icons.analytics, color: bgDark, size: 20),
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
    if (currentStep < 2) {
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

    // T1 Area
    if (currentStep >= 2) {
      cards.add(
        _buildCalcCard(
          "Area of T1",
          "½ × 3 × 4",
          "6",
          accentBlue,
          currentStep >= 2 && currentStep < 6,
        ),
      );
    }

    // T2 Area
    if (currentStep >= 5) {
      cards.add(
        _buildCalcCard(
          "Area of T2",
          "½ × 6 × 8",
          "24",
          accentPink,
          currentStep >= 5 && currentStep < 6,
        ),
      );
    }

    // Side Ratio
    if (currentStep >= 6) {
      cards.add(
        _buildCalcCard(
          "Side Ratio (T2/T1)",
          "6 / 3",
          "2",
          accentBlue,
          currentStep == 6,
        ),
      );
    }

    // Area Ratio
    if (currentStep >= 7) {
      cards.add(
        _buildCalcCard(
          "Area Ratio (T2/T1)",
          "24 / 6",
          "4",
          accentPink,
          currentStep == 7,
        ),
      );
    }

    // Conclusion
    if (currentStep >= 8) {
      cards.add(
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: accentGreen.withOpacity(0.2),
            border: Border.all(color: accentGreen),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              const Text(
                "Theorem Holds",
                style: TextStyle(
                  color: accentGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "4 = 2",
                    style: TextStyle(
                      color: accentPink,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -10),
                    child: const Text(
                      "2",
                      style: TextStyle(
                        color: accentPink,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
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
    String formula,
    String result,
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
          Text(title, style: TextStyle(color: color, fontSize: 12)),
          const SizedBox(height: 5),
          Text(
            "= $formula",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "= $result",
            style: TextStyle(
              color: isHighlighted ? accentYellow : Colors.white24,
              fontWeight: FontWeight.bold,
              fontSize: 20,
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
                t['s$currentStep']!,
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
          text: t['btn_create_t1']!,
          color: accentBlue,
          onPressed: () => advanceStep('msg_t1_ok'),
        );
      case 1:
        return _ControlButton(
          text: t['btn_meas_t1']!,
          color: accentGreen,
          onPressed: () => advanceStep('msg_meas1_ok'),
        );
      case 2:
        return _ControlButton(
          text: t['btn_calc_a1']!,
          color: accentYellow,
          onPressed: () => advanceStep('msg_a1_ok'),
        );
      case 3:
        return _ControlButton(
          text: t['btn_scale_t2']!,
          color: accentPink,
          onPressed: () => advanceStep('msg_t2_ok'),
        );
      case 4:
        return _ControlButton(
          text: t['btn_meas_t2']!,
          color: accentGreen,
          onPressed: () => advanceStep('msg_meas2_ok'),
        );
      case 5:
        return _ControlButton(
          text: t['btn_calc_a2']!,
          color: accentYellow,
          onPressed: () => advanceStep('msg_a2_ok'),
        );
      case 6:
        return _ControlButton(
          text: t['btn_ratio_sides']!,
          color: accentBlue,
          onPressed: () => advanceStep('msg_rs_ok'),
        );
      case 7:
        return _ControlButton(
          text: t['btn_ratio_areas']!,
          color: accentPink,
          onPressed: () => advanceStep('msg_ra_ok'),
        );
      case 8:
        return _ControlButton(
          text: t['btn_compare']!,
          color: accentYellow,
          onPressed: () => advanceStep('msg_comp_ok'),
        );
      case 9:
        return _ControlButton(
          text: t['btn_verify']!,
          color: accentGreen,
          onPressed: () => advanceStep(''),
        );
      default:
        return const SizedBox();
    }
  }

  // --- Graphical Scenes ---

  Widget _buildSceneGraphics() {
    return SizedBox(
      width: 500,
      height: 320,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: const Size(500, 320),
            painter: AreaRatioPainter(step: currentStep),
          ),

          // T1 Labels
          if (currentStep >= 0)
            const Positioned(
              left: 110,
              top: 160,
              child: Text(
                "T1",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: accentBlue,
                  fontSize: 14,
                ),
              ),
            ),

          if (currentStep >= 1) ...[
            const Positioned(
              left: 120,
              top: 270,
              child: _MeasurementBadge(label: "b=3", color: accentBlue),
            ),
            const Positioned(
              left: 50,
              top: 210,
              child: _MeasurementBadge(label: "h=4", color: accentBlue),
            ),
          ],

          if (currentStep >= 2 && currentStep < 6)
            const Positioned(
              left: 100,
              top: 130,
              child: _MeasurementBadge(label: "Area = 6", color: accentYellow),
            ),

          // T2 Labels
          if (currentStep >= 3)
            const Positioned(
              left: 270,
              top: 80,
              child: Text(
                "T2",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: accentPink,
                  fontSize: 18,
                ),
              ),
            ),

          if (currentStep >= 4) ...[
            const Positioned(
              left: 260,
              top: 270,
              child: _MeasurementBadge(label: "B=6", color: accentPink),
            ),
            const Positioned(
              left: 170,
              top: 160,
              child: _MeasurementBadge(label: "H=8", color: accentPink),
            ),
          ],

          if (currentStep >= 5 && currentStep < 6)
            const Positioned(
              left: 250,
              top: 50,
              child: _MeasurementBadge(label: "Area = 24", color: accentYellow),
            ),
        ],
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
                const Icon(Icons.content_cut, color: accentGreen, size: 80),
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

class _MeasurementBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _MeasurementBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bgDark.withOpacity(0.9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1.5),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 4)],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
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
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class AreaRatioPainter extends CustomPainter {
  final int step;

  AreaRatioPainter({required this.step});

  @override
  void paint(Canvas canvas, Size size) {
    // Coordinate system: 500x320
    Offset t1A = const Offset(100, 180); // Top
    Offset t1B = const Offset(100, 260); // Bottom Left
    Offset t1C = const Offset(160, 260); // Bottom Right

    Offset t2A = const Offset(220, 100); // Top
    Offset t2B = const Offset(220, 260); // Bottom Left
    Offset t2C = const Offset(340, 260); // Bottom Right

    if (step >= 0) {
      final fillPaint = Paint()
        ..color = accentBlue.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      final strokePaint = Paint()
        ..color = accentBlue
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      Path pathT1 = Path()
        ..moveTo(t1A.dx, t1A.dy)
        ..lineTo(t1B.dx, t1B.dy)
        ..lineTo(t1C.dx, t1C.dy)
        ..close();

      if (step >= 2) canvas.drawPath(pathT1, fillPaint);
      canvas.drawPath(pathT1, strokePaint);

      _drawRightAngle(canvas, t1B, 1, -1, accentBlue);
    }

    if (step >= 3) {
      final fillPaint = Paint()
        ..color = accentPink.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      final strokePaint = Paint()
        ..color = accentPink
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      Path pathT2 = Path()
        ..moveTo(t2A.dx, t2A.dy)
        ..lineTo(t2B.dx, t2B.dy)
        ..lineTo(t2C.dx, t2C.dy)
        ..close();

      if (step >= 5) canvas.drawPath(pathT2, fillPaint);
      canvas.drawPath(pathT2, strokePaint);

      _drawRightAngle(canvas, t2B, 1, -1, accentPink);

      if (step >= 9) {
        final dashedPaint = Paint()
          ..color = accentPink.withOpacity(0.6)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;
        // Midpoints
        Offset midAB = Offset((t2A.dx + t2B.dx) / 2, (t2A.dy + t2B.dy) / 2);
        Offset midBC = Offset((t2B.dx + t2C.dx) / 2, (t2B.dy + t2C.dy) / 2);
        Offset midCA = Offset((t2C.dx + t2A.dx) / 2, (t2C.dy + t2A.dy) / 2);

        _drawDashedLine(canvas, midAB, midBC, dashedPaint);
        _drawDashedLine(canvas, midBC, midCA, dashedPaint);
        _drawDashedLine(canvas, midCA, midAB, dashedPaint);
      }
    }
  }

  void _drawRightAngle(
    Canvas canvas,
    Offset corner,
    double dirX,
    double dirY,
    Color color,
  ) {
    const double size = 12;
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
          startX + dashWidth * Math.cos(angle),
          startY + dashWidth * Math.sin(angle),
        ),
        paint,
      );
      startX += (dashWidth + dashSpace) * Math.cos(angle);
      startY += (dashWidth + dashSpace) * Math.sin(angle);
      drawnLength += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant AreaRatioPainter oldDelegate) {
    return oldDelegate.step != step;
  }
}

class Math {
  static double cos(double x) => dartMath.cos(x);
  static double sin(double x) => dartMath.sin(x);
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.0;

    const double step = 30;
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
