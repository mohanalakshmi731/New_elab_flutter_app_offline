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
      'app_title': 'THE SIMILARITY SCANNER',
      'tagline': 'Similarity Criteria (AA, SSS, SAS)',
      'init_btn': 'INITIALIZE SCANNER',
      'header_title': 'The Similarity Scanner',
      'header_subtitle': 'Class 10 • Triangles & Similarity',
      'phase_label': 'SCANNING PHASE',
      'step_label': 'Stage',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Scan Complete',
      'success_desc':
          'All similarity criteria (AA, SSS, SAS) successfully verified.',
      'btn_restart': 'NEW SCAN',
      's0': 'Initialize Scanner: System Ready.',
      's1': 'Target Acquired: Subject Alpha.',
      's2': 'Scan Angles (AA Criterion).',
      's3': 'Conclusion: AA Verified.',
      's4': 'Target Acquired: Subject Beta.',
      's5': 'Scan Sides (SSS Criterion).',
      's6': 'Conclusion: SSS Verified.',
      's7': 'Target Acquired: Subject Gamma.',
      's8': 'Scan Sides & Angle (SAS Criterion).',
      's9': 'Conclusion: SAS Verified.',
      'btn_start_scan': 'SCAN ENVIRONMENT',
      'btn_measure_ang': 'MEASURE ANGLES',
      'btn_verify_aa': 'VERIFY AA SIMILARITY',
      'btn_scan_next': 'SCAN NEXT TARGET',
      'btn_measure_sides': 'MEASURE SIDES',
      'btn_verify_sss': 'VERIFY SSS SIMILARITY',
      'btn_measure_sas': 'MEASURE SIDES & ANGLE',
      'btn_verify_sas': 'VERIFY SAS SIMILARITY',
      'btn_complete': 'FINALIZE REPORT',
      'msg_scan_ok': 'Target Identified.',
      'msg_measure_ok': 'Dimensions Recorded.',
      'msg_verify_ok': 'Similarity Verified!',
      'lbl_aa': 'AA SIMILAR',
      'lbl_sss': 'SSS SIMILAR',
      'lbl_sas': 'SAS SIMILAR',
      'ratio_1': 'Ratio = 1:2',
    },
    'hi': {
      'app_title': 'समरूपता स्कैनर',
      'tagline': 'समरूपता मानदंड (AA, SSS, SAS)',
      'init_btn': 'स्कैनर प्रारंभ करें',
      'header_title': 'समरूपता स्कैनर',
      'header_subtitle': 'कक्षा 10 • त्रिभुज और समरूपता',
      'phase_label': 'स्कैनिंग चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'स्कैन पूर्ण',
      'success_desc':
          'सभी समरूपता मानदंड (AA, SSS, SAS) सफलतापूर्वक सत्यापित किए गए।',
      'btn_restart': 'नया स्कैन',
      's0': 'स्कैनर प्रारंभ करें: सिस्टम तैयार।',
      's1': 'लक्ष्य प्राप्त: विषय अल्फा।',
      's2': 'कोणों को स्कैन करें (AA मानदंड)।',
      's3': 'निष्कर्ष: AA सत्यापित।',
      's4': 'लक्ष्य प्राप्त: विषय बीटा।',
      's5': 'भुजाओं को स्कैन करें (SSS मानदंड)।',
      's6': 'निष्कर्ष: SSS सत्यापित।',
      's7': 'लक्ष्य प्राप्त: विषय गामा।',
      's8': 'भुजाओं और कोण को स्कैन करें (SAS)।',
      's9': 'निष्कर्ष: SAS सत्यापित।',
      'btn_start_scan': 'पर्यावरण स्कैन करें',
      'btn_measure_ang': 'कोण मापें',
      'btn_verify_aa': 'AA समरूपता जांचें',
      'btn_scan_next': 'अगला लक्ष्य स्कैन करें',
      'btn_measure_sides': 'भुजाएं मापें',
      'btn_verify_sss': 'SSS समरूपता जांचें',
      'btn_measure_sas': 'भुजाएं और कोण मापें',
      'btn_verify_sas': 'SAS समरूपता जांचें',
      'btn_complete': 'रिपोर्ट पूरी करें',
      'msg_scan_ok': 'लक्ष्य पहचाना गया।',
      'msg_measure_ok': 'आयाम दर्ज किए गए।',
      'msg_verify_ok': 'समरूपता सत्यापित!',
      'lbl_aa': 'AA समरूप',
      'lbl_sss': 'SSS समरूप',
      'lbl_sas': 'SAS समरूप',
      'ratio_1': 'अनुपात = 1:2',
    },
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['en']![key] ?? key;
  }
}

class SimilarityScannerApp extends StatefulWidget {
  const SimilarityScannerApp({super.key});

  @override
  State<SimilarityScannerApp> createState() => _SimilarityScannerAppState();
}

class _SimilarityScannerAppState extends State<SimilarityScannerApp>
    with TickerProviderStateMixin {
  bool hasStarted = false;
  String lang = 'en';
  bool panelOpen = true;

  // Activity State
  int currentStep = 0;
  bool showSuccessModal = false;

  // Visual States
  bool showAlpha = false;
  bool showAlphaAng = false;
  bool isAAVerified = false;

  bool showBeta = false;
  bool showBetaSides = false;
  bool isSSSVerified = false;

  bool showGamma = false;
  bool showGammaSAS = false;
  bool isSASVerified = false;

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
            showAlphaAng = true;
            showToast(AppStrings.get(lang, 'msg_measure_ok'));
            break;
          case 3:
            isAAVerified = true;
            showToast(AppStrings.get(lang, 'msg_verify_ok'));
            playVibration('success');
            break;
          case 4:
            showAlpha = false;
            showAlphaAng = false;
            isAAVerified = false;
            showBeta = true;
            showToast(AppStrings.get(lang, 'msg_scan_ok'));
            break;
          case 5:
            showBetaSides = true;
            showToast(AppStrings.get(lang, 'msg_measure_ok'));
            break;
          case 6:
            isSSSVerified = true;
            showToast(AppStrings.get(lang, 'msg_verify_ok'));
            playVibration('success');
            break;
          case 7:
            showBeta = false;
            showBetaSides = false;
            isSSSVerified = false;
            showGamma = true;
            showToast(AppStrings.get(lang, 'msg_scan_ok'));
            break;
          case 8:
            showGammaSAS = true;
            showToast(AppStrings.get(lang, 'msg_measure_ok'));
            break;
          case 9:
            isSASVerified = true;
            showToast(AppStrings.get(lang, 'msg_verify_ok'));
            playVibration('success');
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
      showAlphaAng = false;
      isAAVerified = false;

      showBeta = false;
      showBetaSides = false;
      isSSSVerified = false;

      showGamma = false;
      showGammaSAS = false;
      isSASVerified = false;
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
                    Icons.document_scanner,
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
                top: 80,
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
                        child: const Icon(Icons.radar, color: bgDark, size: 20),
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
        maxHeight: MediaQuery.of(context).size.height - 70,
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
          text: t['btn_start_scan']!,
          color: accentBlue,
          onPressed: advanceStep,
        );
      case 1:
        return _ControlButton(
          text: t['btn_measure_ang']!,
          color: accentPink,
          onPressed: advanceStep,
        );
      case 2:
        return _ControlButton(
          text: t['btn_verify_aa']!,
          color: accentGreen,
          onPressed: advanceStep,
        );
      case 3:
        return _ControlButton(
          text: t['btn_scan_next']!,
          color: accentBlue,
          onPressed: advanceStep,
        );
      case 4:
        return _ControlButton(
          text: t['btn_measure_sides']!,
          color: accentPink,
          onPressed: advanceStep,
        );
      case 5:
        return _ControlButton(
          text: t['btn_verify_sss']!,
          color: accentGreen,
          onPressed: advanceStep,
        );
      case 6:
        return _ControlButton(
          text: t['btn_scan_next']!,
          color: accentBlue,
          onPressed: advanceStep,
        );
      case 7:
        return _ControlButton(
          text: t['btn_measure_sas']!,
          color: accentPink,
          onPressed: advanceStep,
        );
      case 8:
        return _ControlButton(
          text: t['btn_verify_sas']!,
          color: accentGreen,
          onPressed: advanceStep,
        );
      case 9:
        return _ControlButton(
          text: t['btn_complete']!,
          color: accentYellow,
          onPressed: advanceStep,
        );
      default:
        return const SizedBox();
    }
  }

  // --- Graphical Scenes ---

  Widget _buildSceneGraphics(Map<String, String> t) {
    // Determine which pair to show based on step
    int activePair = 0; // 0=none, 1=Alpha(AA), 2=Beta(SSS), 3=Gamma(SAS)
    bool showAngles = false;
    bool showSides = false;
    bool showConclusion = false;

    if (currentStep >= 1 && currentStep <= 3) {
      activePair = 1;
      if (currentStep >= 2) showAngles = true;
      if (currentStep >= 3) showConclusion = true;
    } else if (currentStep >= 4 && currentStep <= 6) {
      activePair = 2;
      if (currentStep >= 5) showSides = true;
      if (currentStep >= 6) showConclusion = true;
    } else if (currentStep >= 7 && currentStep <= 9) {
      activePair = 3;
      if (currentStep >= 8) {
        showAngles = true;
        showSides = true;
      }
      if (currentStep >= 9) showConclusion = true;
    }

    if (activePair == 0) {
      return const Center(
        child: Icon(Icons.radar, size: 100, color: Colors.white10),
      );
    }

    return SizedBox(
      width: 500,
      height: 320,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // The base geometric shapes drawn via CustomPaint
          CustomPaint(
            size: const Size(500, 320),
            painter: SimilarityTrianglePainter(pairType: activePair),
          ),

          // Labels & Overlays positioned precisely over the CustomPaint shapes
          if (activePair == 1) ..._buildAlphaLabels(showAngles),
          if (activePair == 2) ..._buildBetaLabels(showSides),
          if (activePair == 3) ..._buildGammaLabels(showSides, showAngles),

          // Conclusion Label
          if (showConclusion)
            Positioned.fill(
              child: Center(
                child: Transform.translate(
                  offset: const Offset(0, 80),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: accentGreen,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      activePair == 1
                          ? t['lbl_aa']!
                          : activePair == 2
                          ? t['lbl_sss']!
                          : t['lbl_sas']!,
                      style: const TextStyle(
                        color: bgDark,
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
    );
  }

  List<Widget> _buildAlphaLabels(bool showAngles) {
    List<Widget> labels = [];
    if (showAngles) {
      // Left Triangle (larger) Top & Left Angles
      labels.add(
        const Positioned(
          left: 140,
          top: 70,
          child: Text(
            "60°",
            style: TextStyle(color: accentYellow, fontWeight: FontWeight.bold),
          ),
        ),
      );
      labels.add(
        const Positioned(
          left: 85,
          top: 200,
          child: Text(
            "40°",
            style: TextStyle(color: accentYellow, fontWeight: FontWeight.bold),
          ),
        ),
      );
      // Right Triangle (smaller) Top & Left Angles
      labels.add(
        const Positioned(
          left: 340,
          top: 110,
          child: Text(
            "60°",
            style: TextStyle(color: accentYellow, fontWeight: FontWeight.bold),
          ),
        ),
      );
      labels.add(
        const Positioned(
          left: 305,
          top: 200,
          child: Text(
            "40°",
            style: TextStyle(color: accentYellow, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    return labels;
  }

  List<Widget> _buildBetaLabels(bool showSides) {
    List<Widget> labels = [];
    if (showSides) {
      // Left Triangle (smaller) Sides
      labels.add(
        const Positioned(
          left: 140,
          top: 230,
          child: Text(
            "4",
            style: TextStyle(color: accentPink, fontWeight: FontWeight.bold),
          ),
        ),
      );
      labels.add(
        const Positioned(
          left: 80,
          top: 150,
          child: Text(
            "3",
            style: TextStyle(color: accentPink, fontWeight: FontWeight.bold),
          ),
        ),
      );
      labels.add(
        const Positioned(
          left: 160,
          top: 150,
          child: Text(
            "5",
            style: TextStyle(color: accentPink, fontWeight: FontWeight.bold),
          ),
        ),
      );

      // Right Triangle (larger) Sides
      labels.add(
        const Positioned(
          left: 340,
          top: 230,
          child: Text(
            "8",
            style: TextStyle(color: accentPink, fontWeight: FontWeight.bold),
          ),
        ),
      );
      labels.add(
        const Positioned(
          left: 260,
          top: 120,
          child: Text(
            "6",
            style: TextStyle(color: accentPink, fontWeight: FontWeight.bold),
          ),
        ),
      );
      labels.add(
        const Positioned(
          left: 370,
          top: 120,
          child: Text(
            "10",
            style: TextStyle(color: accentPink, fontWeight: FontWeight.bold),
          ),
        ),
      );

      // Info
      labels.add(
        Positioned(
          left: 200,
          top: 20,
          child: Text(
            AppStrings.get(lang, 'ratio_1'),
            style: const TextStyle(
              color: accentGreen,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              fontSize: 18,
            ),
          ),
        ),
      );
    }
    return labels;
  }

  List<Widget> _buildGammaLabels(bool showSides, bool showAngles) {
    List<Widget> labels = [];
    if (showAngles) {
      // Angles
      labels.add(
        const Positioned(
          left: 95,
          top: 200,
          child: Text(
            "50°",
            style: TextStyle(color: accentYellow, fontWeight: FontWeight.bold),
          ),
        ),
      );
      labels.add(
        const Positioned(
          left: 265,
          top: 200,
          child: Text(
            "50°",
            style: TextStyle(color: accentYellow, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    if (showSides) {
      // Left Triangle Sides
      labels.add(
        const Positioned(
          left: 130,
          top: 230,
          child: Text(
            "6",
            style: TextStyle(color: accentPink, fontWeight: FontWeight.bold),
          ),
        ),
      );
      labels.add(
        const Positioned(
          left: 100,
          top: 130,
          child: Text(
            "4",
            style: TextStyle(color: accentPink, fontWeight: FontWeight.bold),
          ),
        ),
      );

      // Right Triangle Sides
      labels.add(
        const Positioned(
          left: 330,
          top: 230,
          child: Text(
            "12",
            style: TextStyle(color: accentPink, fontWeight: FontWeight.bold),
          ),
        ),
      );
      labels.add(
        const Positioned(
          left: 280,
          top: 110,
          child: Text(
            "8",
            style: TextStyle(color: accentPink, fontWeight: FontWeight.bold),
          ),
        ),
      );

      // Info
      labels.add(
        Positioned(
          left: 200,
          top: 20,
          child: Text(
            AppStrings.get(lang, 'ratio_1'),
            style: const TextStyle(
              color: accentGreen,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              fontSize: 18,
            ),
          ),
        ),
      );
    }
    return labels;
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
                  style: const TextStyle(color: Colors.white),
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

class SimilarityTrianglePainter extends CustomPainter {
  final int pairType; // 1=AA, 2=SSS, 3=SAS

  SimilarityTrianglePainter({required this.pairType});

  @override
  void paint(Canvas canvas, Size size) {
    if (pairType == 0) return;

    final paintLine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = accentBlue;

    final paintFill = Paint()
      ..style = PaintingStyle.fill
      ..color = accentBlue.withOpacity(0.2);

    Path t1 = Path();
    Path t2 = Path();

    if (pairType == 1) {
      // AA: Generic similar triangles
      // Left Triangle
      t1.moveTo(150, 50);
      t1.lineTo(70, 220);
      t1.lineTo(230, 220);
      t1.close();

      // Right Triangle (scaled by ~0.6, translated)
      t2.moveTo(350, 118);
      t2.lineTo(302, 220);
      t2.lineTo(398, 220);
      t2.close();
    } else if (pairType == 2) {
      // SSS: Right Triangles (3-4-5 and 6-8-10 scaled)
      paintLine.color = accentPink;
      paintFill.color = accentPink.withOpacity(0.2);

      // Left
      t1.moveTo(100, 100);
      t1.lineTo(100, 220);
      t1.lineTo(200, 220);
      t1.close();

      // Right (Double size)
      t2.moveTo(280, -20);
      t2.lineTo(280, 220);
      t2.lineTo(480, 220);
      t2.close();
    } else if (pairType == 3) {
      // SAS: Obtuse/Acute combinations
      paintLine.color = Colors.cyan;
      paintFill.color = Colors.cyan.withOpacity(0.2);

      // Left
      t1.moveTo(150, 80);
      t1.lineTo(80, 220);
      t1.lineTo(200, 220);
      t1.close();

      // Right (Scaled by 2)
      t2.moveTo(390, -60);
      t2.lineTo(250, 220);
      t2.lineTo(490, 220);
      t2.close();
    }

    // Draw Shadows
    canvas.drawPath(
      t1,
      Paint()
        ..color = paintLine.color.withOpacity(0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawPath(
      t2,
      Paint()
        ..color = paintLine.color.withOpacity(0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Draw Fills
    canvas.drawPath(t1, paintFill);
    canvas.drawPath(t2, paintFill);

    // Draw Outlines
    canvas.drawPath(t1, paintLine);
    canvas.drawPath(t2, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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
          foregroundColor: color == accentYellow ? bgDark : Colors.white,
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

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.0;

    const double step = 40;
    // Draw extensive grid for smooth panning
    for (double i = -5000; i < size.width + 5000; i += step) {
      canvas.drawLine(Offset(i, -5000), Offset(i, size.height + 5000), paint);
    }
    for (double i = -5000; i < size.height + 5000; i += step) {
      canvas.drawLine(Offset(-5000, i), Offset(size.width + 5000, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
