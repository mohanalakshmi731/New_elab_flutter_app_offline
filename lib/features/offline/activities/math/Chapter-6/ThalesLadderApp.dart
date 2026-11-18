// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:elab_app/features/offline/activities/math_activity_audio.dart';

// --- CONSTANTS & STRINGS ---

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
      'app_title': 'THALES LADDER',
      'tagline': 'Basic Proportionality Theorem (BPT)',
      'init_btn': 'INITIALIZE SIMULATION',
      'header_title': "Thales' Ladder",
      'header_subtitle': 'Class 10 • Triangles & BPT',
      'phase_label': 'VERIFICATION PHASE',
      'step_label': 'Stage',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'BPT Verified',
      'success_desc': 'The theorem holds true for all parallel lines.',
      'btn_restart': 'NEW SIMULATION',
      's0': 'Identify Triangle ABC.',
      's1': 'Construct line DE parallel to BC.',
      's2': 'Measure left segments (AD, DB).',
      's3': 'Measure right segments (AE, EC).',
      's4': 'Calculate left ratio (AD/DB).',
      's5': 'Calculate right ratio (AE/EC).',
      's6': 'Verify ratio equality.',
      's7': 'Move line DE to test dynamically.',
      's8': 'Observe the live calculations.',
      's9': 'Confirm Basic Proportionality Theorem.',
      'btn_triangle': 'ESTABLISH TRIANGLE',
      'btn_draw_de': 'DRAW LINE DE',
      'btn_measure_left': 'MEASURE LEFT',
      'btn_measure_right': 'MEASURE RIGHT',
      'btn_calc_left': 'CALCULATE LEFT RATIO',
      'btn_calc_right': 'CALCULATE RIGHT RATIO',
      'btn_compare': 'VERIFY EQUALITY',
      'btn_lock_pos': 'LOCK POSITION',
      'btn_verify_new': 'VERIFY NEW RATIOS',
      'btn_conclude': 'CONFIRM BPT',
      'lbl_move_de': 'Slide to move DE up/down:',
      'msg_ok': 'Action Confirmed.',
      'msg_move_req': 'Please move the slider to a new position.',
    },
    'hi': {
      'app_title': 'थेल्स की सीढ़ी',
      'tagline': 'आधारभूत आनुपातिकता प्रमेय (BPT)',
      'init_btn': 'सिमुलेशन प्रारंभ करें',
      'header_title': "थेल्स की सीढ़ी",
      'header_subtitle': 'कक्षा 10 • त्रिभुज और BPT',
      'phase_label': 'सत्यापन चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'BPT सत्यापित',
      'success_desc': 'प्रमेय सभी समांतर रेखाओं के लिए सत्य है।',
      'btn_restart': 'नया सिमुलेशन',
      's0': 'त्रिभुज ABC की पहचान करें।',
      's1': 'BC के समांतर रेखा DE बनाएं।',
      's2': 'बाएं खंड (AD, DB) को मापें।',
      's3': 'दाएं खंड (AE, EC) को मापें।',
      's4': 'बाएं अनुपात की गणना करें (AD/DB)।',
      's5': 'दाएं अनुपात की गणना करें (AE/EC)।',
      's6': 'अनुपात समानता की जाँच करें।',
      's7': 'सत्यापित करने के लिए DE रेखा को घुमाएँ।',
      's8': 'लाइव गणनाओं का निरीक्षण करें।',
      's9': 'आधारभूत आनुपातिकता प्रमेय की पुष्टि करें।',
      'btn_triangle': 'त्रिभुज स्थापित करें',
      'btn_draw_de': 'रेखा DE बनाएं',
      'btn_measure_left': 'बाएं मापें',
      'btn_measure_right': 'दाएं मापें',
      'btn_calc_left': 'बाएं अनुपात की गणना करें',
      'btn_calc_right': 'दाएं अनुपात की गणना करें',
      'btn_compare': 'समानता सत्यापित करें',
      'btn_lock_pos': 'स्थिति लॉक करें',
      'btn_verify_new': 'नए अनुपात सत्यापित करें',
      'btn_conclude': 'BPT की पुष्टि करें',
      'lbl_move_de': 'DE को ऊपर/नीचे ले जाने के लिए स्लाइड करें:',
      'msg_ok': 'कार्रवाई की पुष्टि हुई।',
      'msg_move_req': 'कृपया स्लाइडर को नई स्थिति में ले जाएँ।',
    },
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['en']![key] ?? key;
  }
}

class ThalesLadderApp extends StatefulWidget {
  const ThalesLadderApp({super.key});

  @override
  State<ThalesLadderApp> createState() => _ThalesLadderAppState();
}

class _ThalesLadderAppState extends State<ThalesLadderApp> {
  bool hasStarted = false;
  String lang = 'en';
  bool panelOpen = true;

  // Activity State
  int currentStep = 0;
  bool showSuccessModal = false;

  // Geometry State
  double ratioAlpha = 0.5;
  bool hasMovedSlider = false;

  // Canvas Control
  final TransformationController _transformController =
      TransformationController();
  bool _isInitialPanSet = false;

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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
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
            width: 2,
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void advanceStep() {
    if (currentStep < 9) {
      playVibration('click');
      setState(() {
        currentStep++;
        showToast(AppStrings.get(lang, 'msg_ok'));

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
      ratioAlpha = 0.5;
      hasMovedSlider = false;
      showSuccessModal = false;
      hasStarted = false;
      panelOpen = true;
      _isInitialPanSet = false;
      _transformController.value = Matrix4.identity();
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
                    Icons.architecture,
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
                        child: _buildSidePanel(t: AppStrings.data[lang]!),
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
                                  Center(child: _buildSceneGraphics()),
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
                child: _buildFloatingHUD(t: AppStrings.data[lang]!),
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
            if (showSuccessModal) _buildSuccessModal(t: AppStrings.data[lang]!),
          ],
        ),
      ),
    );
  }

  // --- UI BUILDERS ---

  Widget _buildSidePanel({required Map<String, String> t}) {
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
                          Icons.change_history,
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
              child: _buildExploreContent(t: t),
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

  Widget _buildExploreContent({required Map<String, String> t}) {
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

  Widget _buildFloatingHUD({required Map<String, String> t}) {
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
          text: t['btn_triangle']!,
          color: accentBlue,
          onPressed: advanceStep,
        );
      case 1:
        return _ControlButton(
          text: t['btn_draw_de']!,
          color: accentPink,
          onPressed: advanceStep,
        );
      case 2:
        return _ControlButton(
          text: t['btn_measure_left']!,
          color: accentGreen,
          onPressed: advanceStep,
        );
      case 3:
        return _ControlButton(
          text: t['btn_measure_right']!,
          color: accentYellow,
          onPressed: advanceStep,
        );
      case 4:
        return _ControlButton(
          text: t['btn_calc_left']!,
          color: accentBlue,
          onPressed: advanceStep,
        );
      case 5:
        return _ControlButton(
          text: t['btn_calc_right']!,
          color: accentPink,
          onPressed: advanceStep,
        );
      case 6:
        return _ControlButton(
          text: t['btn_compare']!,
          color: accentGreen,
          onPressed: advanceStep,
        );
      case 7:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t['lbl_move_de']!,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Slider(
              value: ratioAlpha,
              min: 0.2,
              max: 0.8,
              activeColor: accentPink,
              inactiveColor: Colors.white24,
              onChanged: (v) {
                setState(() {
                  ratioAlpha = v;
                  hasMovedSlider = true;
                });
              },
            ),
            _ControlButton(
              text: t['btn_lock_pos']!,
              color: hasMovedSlider ? accentBlue : Colors.white24,
              onPressed: () {
                if (hasMovedSlider) {
                  advanceStep();
                } else {
                  showToast(t['msg_move_req']!, isError: true);
                }
              },
            ),
          ],
        );
      case 8:
        return _ControlButton(
          text: t['btn_verify_new']!,
          color: accentGreen,
          onPressed: advanceStep,
        );
      case 9:
        return _ControlButton(
          text: t['btn_conclude']!,
          color: accentYellow,
          onPressed: advanceStep,
        );
      default:
        return const SizedBox();
    }
  }

  // --- Graphical Scenes ---

  Widget _buildSceneGraphics() {
    // Stable coordinate system box for precise rendering.
    return SizedBox(
      width: 500,
      height: 320,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: const Size(500, 320),
            painter: TrianglePainter(ratioAlpha: ratioAlpha, step: currentStep),
          ),

          // --- LABELS & MEASUREMENTS ---
          // Vertices
          if (currentStep >= 0) ...[
            const Positioned(
              left: 240,
              top: 10,
              child: Text(
                "A",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
            const Positioned(
              left: 70,
              top: 265,
              child: Text(
                "B",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
            const Positioned(
              left: 410,
              top: 265,
              child: Text(
                "C",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
          if (currentStep >= 1) ...[
            Positioned(
              left: 250 + (100 - 250) * ratioAlpha - 30,
              top: 40 + (260 - 40) * ratioAlpha - 10,
              child: const Text(
                "D",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: accentPink,
                ),
              ),
            ),
            Positioned(
              left: 250 + (400 - 250) * ratioAlpha + 15,
              top: 40 + (260 - 40) * ratioAlpha - 10,
              child: const Text(
                "E",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: accentPink,
                ),
              ),
            ),
          ],

          // Edge Measurements
          if (currentStep >= 2) ...[
            Positioned(
              left: 250 + (100 - 250) * (ratioAlpha / 2) - 60,
              top: 40 + (260 - 40) * (ratioAlpha / 2) - 10,
              child: _MeasurementBadge(
                label: "AD",
                value: ratioAlpha * 10,
                color: accentBlue,
              ),
            ),
            Positioned(
              left: (250 + (100 - 250) * ratioAlpha + 100) / 2 - 60,
              top: (40 + (260 - 40) * ratioAlpha + 260) / 2 - 10,
              child: _MeasurementBadge(
                label: "DB",
                value: (1 - ratioAlpha) * 10,
                color: accentBlue,
              ),
            ),
          ],
          if (currentStep >= 3) ...[
            Positioned(
              left: 250 + (400 - 250) * (ratioAlpha / 2) + 20,
              top: 40 + (260 - 40) * (ratioAlpha / 2) - 10,
              child: _MeasurementBadge(
                label: "AE",
                value: ratioAlpha * 15,
                color: accentGreen,
              ),
            ),
            Positioned(
              left: (250 + (400 - 250) * ratioAlpha + 400) / 2 + 20,
              top: (40 + (260 - 40) * ratioAlpha + 260) / 2 - 10,
              child: _MeasurementBadge(
                label: "EC",
                value: (1 - ratioAlpha) * 15,
                color: accentGreen,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuccessModal({required Map<String, String> t}) {
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

class _MeasurementBadge extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MeasurementBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgDark,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        "$label = ${value.toStringAsFixed(1)}",
        style: TextStyle(
          color: color,
          fontSize: 12,
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

class TrianglePainter extends CustomPainter {
  final double ratioAlpha;
  final int step;

  TrianglePainter({required this.ratioAlpha, required this.step});

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white;

    final paintPoint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    Offset ptA = const Offset(250, 40);
    Offset ptB = const Offset(100, 260);
    Offset ptC = const Offset(400, 260);

    Offset ptD = Offset(
      ptA.dx + (ptB.dx - ptA.dx) * ratioAlpha,
      ptA.dy + (ptB.dy - ptA.dy) * ratioAlpha,
    );
    Offset ptE = Offset(
      ptA.dx + (ptC.dx - ptA.dx) * ratioAlpha,
      ptA.dy + (ptC.dy - ptA.dy) * ratioAlpha,
    );

    if (step >= 0) {
      // Draw Triangle ABC
      canvas.drawLine(ptA, ptB, paintLine);
      canvas.drawLine(ptB, ptC, paintLine);
      canvas.drawLine(ptC, ptA, paintLine);

      // Draw Points A, B, C
      canvas.drawCircle(ptA, 5, paintPoint);
      canvas.drawCircle(ptB, 5, paintPoint);
      canvas.drawCircle(ptC, 5, paintPoint);
    }

    if (step >= 1) {
      // Draw Line DE
      paintLine.color = accentPink;
      paintLine.strokeWidth = 3;
      canvas.drawLine(ptD, ptE, paintLine);

      // Draw Points D, E
      paintPoint.color = accentPink;
      canvas.drawCircle(ptD, 6, paintPoint);
      canvas.drawCircle(ptE, 6, paintPoint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.0;

    const double step = 40;
    // Draw extensive grid for smooth panning
    for (double i = -5000; i < 5000; i += step) {
      canvas.drawLine(Offset(i, -5000), Offset(i, 5000), paint);
      canvas.drawLine(Offset(-5000, i), Offset(5000, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
