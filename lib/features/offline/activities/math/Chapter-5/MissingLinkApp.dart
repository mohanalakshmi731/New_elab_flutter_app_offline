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

class AppStrings {
  static const Map<String, Map<String, String>> data = {
    'en': {
      'app_title': 'THE MISSING LINK',
      'tagline': 'Finding Missing Terms (AP)',
      'init_btn': 'START DECRYPTION',
      'header_title': 'The Missing Link',
      'header_subtitle': 'Class 10 • Arithmetic Progression',
      'phase_label': 'DECRYPTION PHASE',
      'step_label': 'Lock',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Code Breaker',
      'success_desc': 'Rule: Middle term is the Arithmetic Mean.',
      'btn_restart': 'NEW PUZZLE',
      's0': 'The First Lock: Simple sequence.',
      's1': 'Apply Mean Logic: (a+b)/2.',
      's2': 'Input Code: Unlock Stage 1.',
      's3': 'The Second Lock: Two missing.',
      's4': 'Formulate Equations.',
      's5': "Eliminate to Find 'd'.",
      's6': "Back-Substitute for 'a'.",
      's7': 'Fill the Sequence.',
      's8': 'Final Challenge: Fractions.',
      's9': 'Treasure Revealed.',
      'btn_mean': 'MEAN CALCULATOR',
      'btn_eq_decode': 'EQUATION DECODER',
      'btn_subtract': 'SUBTRACT EQS',
      'btn_substitute': 'SUBSTITUTE',
      'btn_submit': 'UNLOCK SAFE',
      'lbl_mean_res': 'Result = 14',
      'lbl_d_res': 'd = -5',
      'lbl_a_res': 'a = 18',
      'lbl_mean': 'Mean',
      'lbl_term': 'Term',
      'msg_lock1': 'Sequence: 2, [ ], 26',
      'msg_mean_ok': 'Mean Calculated: 14',
      'msg_unlock': 'Lock Opened!',
      'msg_lock2': 'Sequence: [ ], 13, [ ], 3',
      'msg_eq_ok': 'Equations Generated.',
      'msg_d_ok': 'Found d = -5.',
      'msg_a_ok': 'Found a = 18.',
      'msg_seq_fill': 'Sequence Complete.',
      'msg_final_ok': 'Safe Unlocked!',
      'msg_err': 'Incorrect. Try Again.',
      'eq_1': 'a + d = 13',
      'eq_2': 'a + 3d = 3',
    },
    'hi': {
      'app_title': 'मिसिंग लिंक',
      'tagline': 'लुप्त पद ज्ञात करना (AP)',
      'init_btn': 'डिक्रिप्शन शुरू करें',
      'header_title': 'मिसिंग लिंक',
      'header_subtitle': 'कक्षा 10 • समान्तर श्रेढ़ी',
      'phase_label': 'डिक्रिप्शन चरण',
      'step_label': 'लॉक',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'कोड ब्रेकर',
      'success_desc': 'नियम: मध्य पद समान्तर माध्य होता है।',
      'btn_restart': 'नई पहेली',
      's0': 'पहला लॉक: सरल अनुक्रम।',
      's1': 'माध्य तर्क: (a+b)/2।',
      's2': 'कोड दर्ज करें: स्टेज 1 अनलॉक।',
      's3': 'दूसरा लॉक: दो लुप्त।',
      's4': 'समीकरण बनाएँ।',
      's5': "'d' खोजने के लिए विलोपन।",
      's6': "'a' के लिए प्रतिस्थापन।",
      's7': 'अनुक्रम भरें।',
      's8': 'अंतिम चुनौती: भिन्न।',
      's9': 'खजाना खुला।',
      'btn_mean': 'माध्य कैलकुलेटर',
      'btn_eq_decode': 'समीकरण डिकोडर',
      'btn_subtract': 'समीकरण घटाएं',
      'btn_substitute': 'प्रतिस्थापित करें',
      'btn_submit': 'सेफ खोलें',
      'lbl_mean_res': 'परिणाम = 14',
      'lbl_d_res': 'd = -5',
      'lbl_a_res': 'a = 18',
      'lbl_mean': 'माध्य',
      'lbl_term': 'पद',
      'msg_lock1': 'अनुक्रम: 2, [ ], 26',
      'msg_mean_ok': 'माध्य: 14',
      'msg_unlock': 'लॉक खुला!',
      'msg_lock2': 'अनुक्रम: [ ], 13, [ ], 3',
      'msg_eq_ok': 'समीकरण निर्मित।',
      'msg_d_ok': 'd = -5 मिला।',
      'msg_a_ok': 'a = 18 मिला।',
      'msg_seq_fill': 'अनुक्रम पूर्ण।',
      'msg_final_ok': 'सेफ अनलॉक!',
      'msg_err': 'गलत। पुनः प्रयास करें।',
      'eq_1': 'a + d = 13',
      'eq_2': 'a + 3d = 3',
    },
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['en']![key] ?? key;
  }
}

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MissingLinkApp(),
    ),
  );
}

class MissingLinkApp extends StatefulWidget {
  const MissingLinkApp({super.key});

  @override
  State<MissingLinkApp> createState() => _MissingLinkAppState();
}

class _MissingLinkAppState extends State<MissingLinkApp> {
  bool hasStarted = false;
  String lang = 'en';
  bool panelOpen = true;

  // Activity State
  int currentStep = 0;
  bool showSuccessModal = false;

  // Interaction State Data
  Map<String, String> boxValues = {};
  Map<String, bool> boxUnlocked = {};

  // Input Controllers
  final TextEditingController _inpLock1 = TextEditingController();
  final TextEditingController _inpA1 = TextEditingController();
  final TextEditingController _inpA3 = TextEditingController();
  final TextEditingController _inpF1 = TextEditingController();
  final TextEditingController _inpF2 = TextEditingController();

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
    _inpLock1.dispose();
    _inpA1.dispose();
    _inpA3.dispose();
    _inpF1.dispose();
    _inpF2.dispose();
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void startGame() {
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
      });
      if (currentStep == 9) {
        showToast(AppStrings.get(lang, 'msg_final_ok'), isSuccess: true);
        Timer(const Duration(seconds: 1), () {
          playVibration('success');
          setState(() {
            showSuccessModal = true;
          });
        });
      }
    }
  }

  void resetLab() {
    playMathStart();
    playVibration('click');
    setState(() {
      currentStep = 0;
      boxValues.clear();
      boxUnlocked.clear();
      _inpLock1.clear();
      _inpA1.clear();
      _inpA3.clear();
      _inpF1.clear();
      _inpF2.clear();
      showSuccessModal = false;
      hasStarted = false;
      panelOpen = true;
    });
  }

  void checkLock1() {
    double? val = double.tryParse(_inpLock1.text);
    if (val == 14) {
      playVibration('success');
      showToast(AppStrings.get(lang, 'msg_unlock'));
      setState(() {
        boxValues['box1'] = "14";
        boxUnlocked['box1'] = true;
      });
      Timer(const Duration(seconds: 1), advanceStep);
    } else {
      playVibration('error');
      showToast(AppStrings.get(lang, 'msg_err'), isError: true);
    }
  }

  void checkSeq() {
    double? v1 = double.tryParse(_inpA1.text);
    double? v2 = double.tryParse(_inpA3.text);
    if (v1 == 18 && v2 == 8) {
      playVibration('success');
      showToast(AppStrings.get(lang, 'msg_seq_fill'));
      setState(() {
        boxValues['box2a'] = "18";
        boxUnlocked['box2a'] = true;
        boxValues['box2b'] = "8";
        boxUnlocked['box2b'] = true;
      });
      Timer(const Duration(seconds: 1), advanceStep);
    } else {
      playVibration('error');
      showToast(AppStrings.get(lang, 'msg_err'), isError: true);
    }
  }

  void checkFinal() {
    double? v1 = double.tryParse(_inpF1.text);
    double? v2 = double.tryParse(_inpF2.text);
    if (v1 != null &&
        v2 != null &&
        (v1 - 6.5).abs() < 0.1 &&
        (v2 - 8).abs() < 0.1) {
      playVibration('success');
      showToast(AppStrings.get(lang, 'msg_final_ok'));
      setState(() {
        boxValues['box3a'] = "6.5";
        boxUnlocked['box3a'] = true;
        boxValues['box3b'] = "8";
        boxUnlocked['box3b'] = true;
      });
      Timer(const Duration(seconds: 1), advanceStep);
    } else {
      playVibration('error');
      showToast(AppStrings.get(lang, 'msg_err'), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Responsive side panel width
    final double panelWidth = screenWidth < 600
        ? screenWidth * 0.85
        : (screenWidth * 0.4).clamp(320.0, 450.0);

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
                child: const Icon(Icons.lock_open, size: 80, color: accentPink),
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
                onPressed: () {
                  playVibration('intro');
                  startGame();
                },
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
                        child: _buildSidePanel(),
                      ),
                    ),
                  ),

                  // Interactive Canvas Area
                  Expanded(child: ClipRect(child: _buildInteractiveCanvas())),
                ],
              ),
            ),

            // Floating HUD (Visible when sidebar is collapsed)
            if (!panelOpen)
              Positioned(top: 90, left: 24, child: _buildFloatingHUD()),

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
            if (showSuccessModal) _buildSuccessModal(),
          ],
        ),
      ),
    );
  }

  // --- UI BUILDERS ---

  Widget _buildSidePanel() {
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
                          color: accentPink,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: accentPink.withOpacity(0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.link, color: bgDark, size: 20),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.get(lang, 'header_title'),
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
                              AppStrings.get(lang, 'header_subtitle'),
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
              child: _buildExploreContent(),
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

  Widget _buildExploreContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get(lang, 'phase_label'),
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
              "${AppStrings.get(lang, 'step_label')} ${currentStep + 1}/10",
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
          child: _buildControlsArea(),
        ),
      ],
    );
  }

  // Floating HUD for when the side panel is collapsed
  Widget _buildFloatingHUD() {
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
                    AppStrings.get(lang, 'active_mission').toUpperCase(),
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
                AppStrings.get(lang, 's$currentStep'),
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
                child: _buildControlsArea(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Interactive Canvas holding the actual visual puzzles
  Widget _buildInteractiveCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(4000), // Allow deep panning
          minScale: 0.2,
          maxScale: 4.0,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Infinite grid painter covering a massive area behind the scenes
              Positioned(
                left: -4000,
                top: -4000,
                right: -4000,
                bottom: -4000,
                child: CustomPaint(painter: GridPainter()),
              ),
              // Vault Graphics centered exactly to initial layout boundary
              SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: OverflowBox(
                  maxWidth: double.infinity,
                  maxHeight: double.infinity,
                  child: Center(child: _buildVaultGraphics()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlsArea() {
    switch (currentStep) {
      case 0:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: advanceStep,
            style: ElevatedButton.styleFrom(backgroundColor: accentBlue),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                AppStrings.get(lang, 'btn_mean'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      case 1:
        return Column(
          children: [
            Text(
              "${AppStrings.get(lang, 'lbl_mean')} = (a+b)/2",
              style: const TextStyle(color: accentBlue, fontSize: 12),
            ),
            const SizedBox(height: 5),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "(2 + 26) / 2 = ",
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "14",
                  style: TextStyle(
                    color: accentPink,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentBlue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  showToast(AppStrings.get(lang, 'lbl_mean_res'));
                  advanceStep();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    AppStrings.get(lang, 'btn_submit'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        );
      case 2:
        return Column(
          children: [
            _buildInputField(_inpLock1, "?"),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentGreen,
                  foregroundColor: Colors.black,
                ),
                onPressed: checkLock1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    AppStrings.get(lang, 'btn_submit'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        );
      case 3:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: advanceStep,
            style: ElevatedButton.styleFrom(backgroundColor: accentBlue),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                AppStrings.get(lang, 'btn_eq_decode'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      case 4:
        return Column(
          children: [
            _EqRow(
              color: Colors.blue,
              leftLabel: "${AppStrings.get(lang, 'lbl_term')} 2 (13)",
              rightLabel: AppStrings.get(lang, 'eq_1'),
            ),
            _EqRow(
              color: Colors.purple,
              leftLabel: "${AppStrings.get(lang, 'lbl_term')} 4 (3)",
              rightLabel: AppStrings.get(lang, 'eq_2'),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentBlue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  showToast(AppStrings.get(lang, 'msg_eq_ok'));
                  advanceStep();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    AppStrings.get(lang, 'btn_subtract'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        );
      case 5:
        return Column(
          children: [
            const Text(
              "(a+3d) - (a+d) = 3 - 13",
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "2d = -10",
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 18,
                color: accentPink,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "d = -5",
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: accentGreen,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentBlue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  showToast(AppStrings.get(lang, 'msg_d_ok'));
                  advanceStep();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    AppStrings.get(lang, 'btn_substitute'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        );
      case 6:
        return Column(
          children: [
            const Text(
              "a + (-5) = 13",
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "a = 18",
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: accentGreen,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentBlue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  showToast(AppStrings.get(lang, 'msg_a_ok'));
                  advanceStep();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    AppStrings.get(lang, 'btn_submit'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        );
      case 7:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    _inpA1,
                    "${AppStrings.get(lang, 'lbl_term')} 1",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    _inpA3,
                    "${AppStrings.get(lang, 'lbl_term')} 3",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentGreen,
                  foregroundColor: Colors.black,
                ),
                onPressed: checkSeq,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    AppStrings.get(lang, 'btn_submit'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        );
      case 8:
        return Column(
          children: [
            const Text(
              "a=5, a4=9.5 -> 3d=4.5 -> d=1.5",
              style: TextStyle(fontSize: 12, color: Colors.white54),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    _inpF1,
                    "${AppStrings.get(lang, 'lbl_term')} 2",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    _inpF2,
                    "${AppStrings.get(lang, 'lbl_term')} 3",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: checkFinal,
                style: ElevatedButton.styleFrom(backgroundColor: accentBlue),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    AppStrings.get(lang, 'btn_submit'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildInputField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'monospace',
        fontWeight: FontWeight.bold,
        color: Colors.white,
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
    );
  }

  Widget _buildVaultGraphics() {
    List<_BoxConfig> boxes = [];

    if (currentStep >= 0 && currentStep <= 2) {
      boxes = [
        _BoxConfig(text: "2", isFixed: true),
        _BoxConfig(
          text: boxValues['box1'] ?? "?",
          isFixed: false,
          isUnlocked: boxUnlocked['box1'] ?? false,
        ),
        _BoxConfig(text: "26", isFixed: true),
      ];
    } else if (currentStep >= 3 && currentStep <= 7) {
      boxes = [
        _BoxConfig(
          text: boxValues['box2a'] ?? "?",
          isFixed: false,
          isUnlocked: boxUnlocked['box2a'] ?? false,
        ),
        _BoxConfig(text: "13", isFixed: true),
        _BoxConfig(
          text: boxValues['box2b'] ?? "?",
          isFixed: false,
          isUnlocked: boxUnlocked['box2b'] ?? false,
        ),
        _BoxConfig(text: "3", isFixed: true),
      ];
    } else if (currentStep >= 8) {
      boxes = [
        _BoxConfig(text: "5", isFixed: true),
        _BoxConfig(
          text: boxValues['box3a'] ?? "?",
          isFixed: false,
          isUnlocked: boxUnlocked['box3a'] ?? false,
        ),
        _BoxConfig(
          text: boxValues['box3b'] ?? "?",
          isFixed: false,
          isUnlocked: boxUnlocked['box3b'] ?? false,
        ),
        _BoxConfig(text: "9.5", isFixed: true),
      ];
    }

    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: bgPanel.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: accentBlue.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: boxes.map((config) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: config.isFixed
                  ? bgDark
                  : (config.isUnlocked
                        ? accentGreen.withOpacity(0.1)
                        : const Color(0xFF334155)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: config.isFixed
                    ? Colors.white24
                    : (config.isUnlocked
                          ? accentGreen
                          : accentPink.withOpacity(0.5)),
                width: config.isUnlocked ? 3 : 2,
              ),
              boxShadow: config.isUnlocked
                  ? [
                      BoxShadow(
                        color: accentGreen.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ]
                  : (config.isFixed
                        ? null
                        : [
                            BoxShadow(
                              color: accentPink.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ]),
            ),
            alignment: Alignment.center,
            child: Text(
              config.text,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: config.isFixed
                    ? Colors.white
                    : (config.isUnlocked ? accentGreen : accentPink),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSuccessModal() {
    return Container(
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
              const Icon(Icons.lock_open, color: accentGreen, size: 80),
              const SizedBox(height: 20),
              Text(
                AppStrings.get(lang, 'badge_title').toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                AppStrings.get(lang, 'success_desc'),
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
                  AppStrings.get(lang, 'btn_restart'),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoxConfig {
  final String text;
  final bool isFixed;
  final bool isUnlocked;

  _BoxConfig({
    required this.text,
    required this.isFixed,
    this.isUnlocked = false,
  });
}

class _EqRow extends StatelessWidget {
  final Color color;
  final String leftLabel;
  final String rightLabel;

  const _EqRow({
    required this.color,
    required this.leftLabel,
    required this.rightLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border(left: BorderSide(color: color, width: 4)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            leftLabel,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          Text(
            rightLabel,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 16,
              color: accentPink,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
