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
      'app_title': 'THE SHAPE SHIFTER',
      'tagline': 'Similar vs Congruent Figures',
      'init_btn': 'INITIALIZE SCANNER',
      'header_title': 'The Shape Shifter',
      'header_subtitle': 'Class 10 • Triangles & Similarity',
      'phase_label': 'ANALYSIS PHASE',
      'step_label': 'Stage',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Geometry Master',
      'success_desc': 'Analysis of similar figures complete!',
      'btn_restart': 'NEW ANALYSIS',
      's0': 'Isolate Subject Alpha (Square).',
      's1': 'Measure Dimensions & Angles.',
      's2': 'Subject Beta Detected (Larger Square).',
      's3': 'Verify Angle Correspondence.',
      's4': 'Calculate Side Proportions.',
      's5': 'Conclusion: Similarity Confirmed.',
      's6': 'Subject Gamma Detected (Rectangle).',
      's7': 'Verify Angle Correspondence.',
      's8': 'Calculate Side Proportions.',
      's9': 'Conclusion: Non-Similar Confirmed.',
      'btn_scan_alpha': 'SCAN ALPHA',
      'btn_measure': 'MEASURE',
      'btn_scan_beta': 'SCAN BETA',
      'btn_verify_ang': 'VERIFY ANGLES',
      'btn_calc_ratio': 'CALCULATE RATIO',
      'btn_confirm_sim': 'CONFIRM SIMILAR',
      'btn_scan_gamma': 'SCAN GAMMA',
      'btn_confirm_not': 'CONFIRM MISMATCH',
      'lbl_alpha': 'Subject Alpha',
      'lbl_beta': 'Subject Beta',
      'lbl_gamma': 'Subject Gamma',
      'msg_scan_ok': 'Subject isolated successfully.',
      'msg_measure_ok': 'Dimensions recorded: 4x4, 90° angles.',
      'msg_ang_pass': 'Angles match: 90° = 90°',
      'msg_ratio_pass': 'Proportions match: 8/4 = 2',
      'msg_sim_ok': 'Subjects are mathematically SIMILAR.',
      'msg_ratio_fail': 'Proportion mismatch! Width=1, Height=1.5',
      'msg_not_sim': 'Subjects are NOT SIMILAR.',
      'ratio_math_1': 'Ratio = 8 / 4 = 2',
      'ratio_math_fail': 'W: 4/4 = 1 | H: 6/4 = 1.5',
    },
    'hi': {
      'app_title': 'शेप शिफ्टर',
      'tagline': 'समरूप बनाम सर्वांगसम आकृतियाँ',
      'init_btn': 'स्कैनर प्रारंभ करें',
      'header_title': 'शेप शिफ्टर',
      'header_subtitle': 'कक्षा 10 • त्रिभुज और समरूपता',
      'phase_label': 'विश्लेषण चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'ज्यामिति मास्टर',
      'success_desc': 'समरूप आकृतियों का विश्लेषण पूर्ण!',
      'btn_restart': 'नया विश्लेषण',
      's0': 'विषय अल्फा को अलग करें (वर्ग)।',
      's1': 'आयाम और कोण मापें।',
      's2': 'विषय बीटा मिला (बड़ा वर्ग)।',
      's3': 'कोण पत्राचार सत्यापित करें।',
      's4': 'भुजा अनुपात की गणना करें।',
      's5': 'निष्कर्ष: समरूपता की पुष्टि हुई।',
      's6': 'विषय गामा मिला (आयत)।',
      's7': 'कोण पत्राचार सत्यापित करें।',
      's8': 'भुजा अनुपात की गणना करें।',
      's9': 'निष्कर्ष: गैर-समरूप की पुष्टि हुई।',
      'btn_scan_alpha': 'स्कैन अल्फा',
      'btn_measure': 'मापें',
      'btn_scan_beta': 'स्कैन बीटा',
      'btn_verify_ang': 'कोण जांचें',
      'btn_calc_ratio': 'अनुपात गणना',
      'btn_confirm_sim': 'समरूप पुष्टि',
      'btn_scan_gamma': 'स्कैन गामा',
      'btn_confirm_not': 'बेमेल पुष्टि',
      'lbl_alpha': 'विषय अल्फा',
      'lbl_beta': 'विषय बीटा',
      'lbl_gamma': 'विषय गामा',
      'msg_scan_ok': 'विषय सफलतापूर्वक अलग किया गया।',
      'msg_measure_ok': 'आयाम दर्ज: 4x4, 90° कोण।',
      'msg_ang_pass': 'कोण मेल खाते हैं: 90° = 90°',
      'msg_ratio_pass': 'अनुपात मेल खाते हैं: 8/4 = 2',
      'msg_sim_ok': 'विषय गणितीय रूप से समरूप हैं।',
      'msg_ratio_fail': 'अनुपात बेमेल! चौड़ाई=1, ऊंचाई=1.5',
      'msg_not_sim': 'विषय समरूप नहीं हैं।',
      'ratio_math_1': 'अनुपात = 8 / 4 = 2',
      'ratio_math_fail': 'W: 4/4 = 1 | H: 6/4 = 1.5',
    },
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['en']![key] ?? key;
  }
}

class ShapeShifterApp extends StatefulWidget {
  const ShapeShifterApp({super.key});

  @override
  State<ShapeShifterApp> createState() => _ShapeShifterAppState();
}

class _ShapeShifterAppState extends State<ShapeShifterApp>
    with TickerProviderStateMixin {
  bool hasStarted = false;
  String lang = 'en';

  // Sidebar state
  bool panelOpen = true;

  // Activity State
  int currentStep = 0;
  bool showSuccessModal = false;

  // Visual States
  bool showAlpha = false;
  bool showAlphaDims = false;
  bool showBeta = false;
  bool showBetaAng = false;
  bool showBetaRatio = false;
  bool isSimilarLabel = false;

  bool showGamma = false;
  bool showGammaAng = false;
  bool showGammaRatio = false;
  bool isNotSimilarLabel = false;

  List<String> logs = ['System Standby...'];

  // Canvas Control
  final TransformationController _transformController =
      TransformationController();
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
    _transformController.dispose();
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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

  void startGame() {
    playVibration('intro');
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

  void addLog(String msg) {
    setState(() {
      logs.insert(0, msg);
      if (logs.length > 10) logs.removeLast();
    });
  }

  void showToast(
    String message, {
    bool isError = false,
    bool isSuccess = true,
  }) {
    if (isError) playMathError();
    addLog(message);
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
        backgroundColor: bgPanel,
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

  void advanceStep() {
    if (currentStep < 10) {
      playVibration('click');
      setState(() {
        currentStep++;

        // Step specific visual triggers
        switch (currentStep) {
          case 1:
            showAlpha = true;
            showToast(AppStrings.get(lang, 'msg_scan_ok'));
            break;
          case 2:
            showAlphaDims = true;
            showToast(AppStrings.get(lang, 'msg_measure_ok'));
            break;
          case 3:
            showBeta = true;
            showToast(AppStrings.get(lang, 'msg_scan_ok'));
            break;
          case 4:
            showBetaAng = true;
            showToast(AppStrings.get(lang, 'msg_ang_pass'));
            break;
          case 5:
            showBetaRatio = true;
            showToast(AppStrings.get(lang, 'msg_ratio_pass'));
            break;
          case 6:
            isSimilarLabel = true;
            showToast(AppStrings.get(lang, 'msg_sim_ok'));
            playVibration('success');
            // Reset for Gamma phase after delay
            Timer(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  showBeta = false;
                  showBetaAng = false;
                  showBetaRatio = false;
                  isSimilarLabel = false;
                  showGamma = true;
                  showToast(AppStrings.get(lang, 'msg_scan_ok'));
                  currentStep = 7;
                });
              }
            });
            break;
          case 8: // User clicked Verify Angles at step 7
            showGammaAng = true;
            showToast(AppStrings.get(lang, 'msg_ang_pass'));
            break;
          case 9: // User clicked Calc Ratio at step 8
            showGammaRatio = true;
            playVibration('error');
            showToast(AppStrings.get(lang, 'msg_ratio_fail'), isError: true);
            break;
          case 10: // User clicked Confirm Mismatch at step 9
            isNotSimilarLabel = true;
            playVibration('success');
            showToast(
              AppStrings.get(lang, 'msg_not_sim'),
              isSuccess: true,
              isError: false,
            );
            Timer(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  showSuccessModal = true;
                });
              }
            });
            break;
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

      logs = ['System Standby...'];
      _isInitialPanSet = false;
      _transformController.value = Matrix4.identity();

      showAlpha = false;
      showAlphaDims = false;
      showBeta = false;
      showBetaAng = false;
      showBetaRatio = false;
      isSimilarLabel = false;

      showGamma = false;
      showGammaAng = false;
      showGammaRatio = false;
      isNotSimilarLabel = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Responsive panel width
    final double panelWidth = screenWidth < 600
        ? screenWidth * 0.85
        : (screenWidth * 0.4).clamp(320.0, 450.0);

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
                  child: const Icon(
                    Icons.category,
                    size: 80,
                    color: accentPink,
                  ),
                ),
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
                      AppStrings.get(lang, 'init_btn'),
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
            // Core Layout: Responsive Side Panel + Canvas
            Positioned.fill(
              child: Row(
                children: [
                  // Animated Side Panel
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: panelOpen ? panelWidth : 0,
                    child: ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.centerLeft,
                        minWidth: panelWidth,
                        maxWidth: panelWidth,
                        child: _buildSidePanel(AppStrings.data[lang]!),
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
                              final dx = -(4000 - constraints.maxWidth) / 2;
                              final dy = -(4000 - constraints.maxHeight) / 2;
                              _transformController.value = Matrix4.identity()
                                ..translate(dx, dy);
                            });
                          }
                          return InteractiveViewer(
                            transformationController: _transformController,
                            boundaryMargin: const EdgeInsets.all(2000),
                            minScale: 0.1,
                            maxScale: 5.0,
                            constrained: false,
                            child: Container(
                              width: 4000,
                              height: 4000,
                              alignment: Alignment.center,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: CustomPaint(painter: GridPainter()),
                                  ),
                                  Center(
                                    child: _buildSceneGraphics(
                                      AppStrings.data[lang]!,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Floating HUD (Visible when sidebar is collapsed)
            if (!panelOpen)
              Positioned(
                top: 90,
                left: 24,
                child: _buildFloatingHUD(AppStrings.data[lang]!),
              ),

            // Top-Left Floating Button (Back / Reset)
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

            // Bottom-Left Floating Menu Toggle
            Positioned(
              top: 24,
              left: 24,
              child: FloatingActionButton(
                backgroundColor: accentBlue,
                elevation: 8,
                onPressed: () {
                  playVibration('click');
                  setState(() => panelOpen = !panelOpen);
                },
                child: Icon(
                  panelOpen ? Icons.menu_open : Icons.menu,
                  color: Colors.white,
                ),
              ),
            ),

            // Success Overlay Modal
            if (showSuccessModal) _buildSuccessModal(AppStrings.data[lang]!),
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
        border: const Border(right: BorderSide(color: Colors.white12)),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.only(
                top: 80, // Clear the top-left floating back button visually
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
                          color: accentPink,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: accentPink.withOpacity(0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.widgets,
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
                bottom: 90, // Clear the menu toggle button
              ),
              child: _buildExploreContent(t),
            ),
          ],
        ),
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
    int safeStep = currentStep > 9 ? 9 : currentStep;

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
              "${t['step_label']} ${safeStep + 1}/10",
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
          value: (safeStep + 1) / 10,
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
    int safeStep = currentStep > 9 ? 9 : currentStep;

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
                    "${safeStep + 1}/10",
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
                t['s$safeStep']!,
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
              const SizedBox(height: 12),
              Text(
                "> ${logs[0]}",
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  color: accentGreen,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
          text: t['btn_scan_alpha']!,
          color: accentBlue,
          onPressed: advanceStep,
        );
      case 1:
        return _ControlButton(
          text: t['btn_measure']!,
          color: accentGreen,
          onPressed: advanceStep,
        );
      case 2:
        return _ControlButton(
          text: t['btn_scan_beta']!,
          color: accentPink,
          onPressed: advanceStep,
        );
      case 3:
        return _ControlButton(
          text: t['btn_verify_ang']!,
          color: accentYellow,
          onPressed: advanceStep,
        );
      case 4:
        return Column(
          children: [
            Text(
              t['ratio_math_1']!,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: accentPink,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _ControlButton(
              text: t['btn_calc_ratio']!,
              color: accentBlue,
              onPressed: advanceStep,
            ),
          ],
        );
      case 5:
        return _ControlButton(
          text: t['btn_confirm_sim']!,
          color: accentGreen,
          onPressed: advanceStep,
        );
      case 6:
        return const Center(
          child: CircularProgressIndicator(color: accentBlue),
        );
      case 7:
        return _ControlButton(
          text: t['btn_verify_ang']!,
          color: accentYellow,
          onPressed: advanceStep,
        );
      case 8:
        return Column(
          children: [
            Text(
              t['ratio_math_fail']!,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: accentRed,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            _ControlButton(
              text: t['btn_calc_ratio']!,
              color: accentRed,
              onPressed: advanceStep,
            ),
          ],
        );
      case 9:
        return _ControlButton(
          text: t['btn_confirm_not']!,
          color: accentRed,
          onPressed: advanceStep,
        );
      default:
        return const SizedBox();
    }
  }

  // --- Graphical Scenes ---

  Widget _buildSceneGraphics(Map<String, String> t) {
    const double gridSize = 30.0;
    const double alphaW = 4 * gridSize;
    const double alphaH = 4 * gridSize;
    const double betaW = 8 * gridSize;
    const double betaH = 8 * gridSize;
    const double gammaW = 4 * gridSize;
    const double gammaH = 6 * gridSize;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Subject Alpha
        if (showAlpha)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t['lbl_alpha']!,
                style: const TextStyle(
                  color: accentBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: alphaW,
                    height: alphaH,
                    decoration: BoxDecoration(
                      color: accentBlue.withOpacity(0.2),
                      border: Border.all(color: accentBlue, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: accentBlue.withOpacity(0.3),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                  ),
                  if (showAlphaDims) ...[
                    const _AngleIndicator(top: 0, left: 0),
                    const _AngleIndicator(top: 0, right: 0),
                    const _AngleIndicator(bottom: 0, left: 0),
                    const _AngleIndicator(bottom: 0, right: 0),
                    const Positioned(
                      top: -25,
                      child: Text(
                        "4",
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          color: accentBlue,
                        ),
                      ),
                    ),
                    const Positioned(
                      right: -25,
                      child: Text(
                        "4",
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          color: accentBlue,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

        if (showAlpha && (showBeta || showGamma)) const SizedBox(width: 60),

        // Subject Beta
        if (showBeta)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t['lbl_beta']!,
                style: const TextStyle(
                  color: accentPink,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: betaW,
                    height: betaH,
                    decoration: BoxDecoration(
                      color: accentPink.withOpacity(0.2),
                      border: Border.all(color: accentPink, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: accentPink.withOpacity(0.3),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                  ),
                  if (showBetaAng) ...[
                    const _AngleIndicator(top: 0, left: 0, color: accentYellow),
                    const _AngleIndicator(
                      top: 0,
                      right: 0,
                      color: accentYellow,
                    ),
                    const _AngleIndicator(
                      bottom: 0,
                      left: 0,
                      color: accentYellow,
                    ),
                    const _AngleIndicator(
                      bottom: 0,
                      right: 0,
                      color: accentYellow,
                    ),
                  ],
                  if (showBetaRatio) ...[
                    const Positioned(
                      top: -25,
                      child: Text(
                        "8",
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          color: accentPink,
                        ),
                      ),
                    ),
                    const Positioned(
                      right: -25,
                      child: Text(
                        "8",
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          color: accentPink,
                        ),
                      ),
                    ),
                  ],
                  if (isSimilarLabel)
                    Positioned.fill(
                      child: Center(
                        child: Transform.rotate(
                          angle: -0.2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: accentGreen,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Text(
                              "SIMILAR",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

        // Subject Gamma
        if (showGamma)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t['lbl_gamma']!,
                style: const TextStyle(
                  color: Colors.cyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: gammaW,
                    height: gammaH,
                    decoration: BoxDecoration(
                      color: Colors.cyan.withOpacity(0.2),
                      border: Border.all(color: Colors.cyan, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withOpacity(0.3),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                  ),
                  if (showGammaAng) ...[
                    const _AngleIndicator(top: 0, left: 0, color: accentYellow),
                    const _AngleIndicator(
                      top: 0,
                      right: 0,
                      color: accentYellow,
                    ),
                    const _AngleIndicator(
                      bottom: 0,
                      left: 0,
                      color: accentYellow,
                    ),
                    const _AngleIndicator(
                      bottom: 0,
                      right: 0,
                      color: accentYellow,
                    ),
                  ],
                  if (showGammaRatio) ...[
                    const Positioned(
                      top: -25,
                      child: Text(
                        "4",
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan,
                        ),
                      ),
                    ),
                    const Positioned(
                      right: -25,
                      child: Text(
                        "6",
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan,
                        ),
                      ),
                    ),
                  ],
                  if (isNotSimilarLabel)
                    Positioned.fill(
                      child: Center(
                        child: Transform.rotate(
                          angle: -0.2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: accentRed,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Text(
                              "NOT SIMILAR",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
      ],
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
                const Icon(Icons.verified, color: accentGreen, size: 80),
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

class _AngleIndicator extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final Color color;

  const _AngleIndicator({
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 15,
        height: 15,
        decoration: BoxDecoration(
          border: Border(
            bottom: top != null
                ? BorderSide(color: color, width: 2)
                : BorderSide.none,
            top: bottom != null
                ? BorderSide(color: color, width: 2)
                : BorderSide.none,
            right: left != null
                ? BorderSide(color: color, width: 2)
                : BorderSide.none,
            left: right != null
                ? BorderSide(color: color, width: 2)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.0;

    const double step = 40;
    // Draw extensive grid for smooth panning
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
