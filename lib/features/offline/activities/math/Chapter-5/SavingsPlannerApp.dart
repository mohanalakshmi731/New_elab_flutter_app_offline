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
      'app_title': 'THE SAVINGS PLANNER',
      'tagline': 'Sum of First N Terms (AP)',
      'init_btn': 'START PLANNING',
      'header_title': 'The Savings Planner',
      'header_subtitle': 'Class 10 • Arithmetic Progression',
      'phase_label': 'PLANNING PHASE',
      'step_label': 'Step',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Savings Guru',
      'success_desc': 'Smart planning successful!',
      'btn_restart': 'PLAN NEW GOAL',
      's0': 'Client Interview: Data Collection.',
      's1': 'Parameters: Click 100(a), then 150 & 100 for (d).',
      's2': 'Horizon: Can I buy it in a year? (12 mo)',
      's3': 'Tool: Need savings in 12th mo or Total?',
      's4': 'Assemble: Fill formula variables.',
      's5': 'Compute Brackets.',
      's6': 'Final Summation.',
      's7': 'Reality Check: 4500 < 5000',
      's8': 'Calculate Shortfall.',
      's9': 'Advisory: Wait 1 Month.',
      'btn_review': 'REVIEW SAVINGS PLAN',
      'btn_set_n': 'SET DURATION',
      'btn_opt_an': 'Find nth Term (a_n)',
      'btn_opt_sn': 'Find Sum (S_n)',
      'btn_process:': 'PROCESS INNER TERMS',
      'btn_total': 'TOTALIZE',
      'btn_diff': 'DIFFERENCE TOOL',
      'btn_buy': 'BUY BIKE NOW',
      'btn_wait': 'WAIT 1 MONTH',
      'lbl_target': 'Target: 5000',
      'lbl_insuf': 'Insufficient Funds',
      'msg_seq_id': 'Sequence: 100, 150, 200... (AP)',
      'msg_param_ok': 'a=100, d=50',
      'msg_n_ok': 'Horizon: 12 Months. Target Set.',
      'msg_form_ok': 'Formula Selected: S_n (Total Sum)',
      'msg_eq_ok': 'Equation Assembled',
      'msg_inter_ok': 'Values Simplified',
      'msg_comp_fail': '4500 < 5000',
      'msg_short_ok': 'Shortfall: 500',
      'msg_err': 'Incorrect. Try again.',
      'msg_click_param': "Click '100' for 'a'. Click '150' then '100' for 'd'.",
      'msg_drag_stack': "Drag savings to compare: 4500 vs 5000",
      'msg_month_13': 'Month 13 Savings: 700. New Total: 5200.',
      'msg_tool_q':
          'Do we need savings in the 12th month or the total savings?',
      'msg_click_prev': "Now click the previous term (100).",
      'ledger_title': 'SAVINGS LEDGER',
      'month_1': 'Month 1',
      'month_2': 'Month 2',
      'month_3': 'Month 3',
      'err_a_click': 'Click 100 for First Term (a)',
      'err_n_plan': 'The scenario requires a 1-year (12 month) plan.',
      'lbl_missing': 'MISSING',
      'step_8_eq': '5000 - 4500 = ?',
    },
    'hi': {
      'app_title': 'बचत योजनाकार',
      'tagline': 'प्रथम n पदों का योग',
      'init_btn': 'योजना शुरू करें',
      'header_title': 'बचत योजनाकार',
      'header_subtitle': 'कक्षा 10 • समान्तर श्रेढ़ी',
      'phase_label': 'योजना चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'बचत गुरु',
      'success_desc': 'स्मार्ट योजना सफल!',
      'btn_restart': 'नया लक्ष्य',
      's0': 'डेटा संग्रह।',
      's1': 'पैरामीटर: 100(a), फिर 150 और 100 (d) क्लिक करें।',
      's2': 'अवधि: क्या मैं एक साल में खरीद सकता हूँ? (12 महीने)',
      's3': 'उपकरण: 12वें महीने की बचत या कुल?',
      's4': 'संयोजन: सूत्र में चर भरें।',
      's5': 'कोष्ठक की गणना करें।',
      's6': 'अंतिम योग।',
      's7': 'वास्तविकता जाँच: 4500 < 5000',
      's8': 'कमी की गणना करें।',
      's9': 'सलाह: 1 महीने रुकें।',
      'btn_review': 'योजना की समीक्षा',
      'btn_set_n': 'अवधि सेट करें',
      'btn_opt_an:': 'nवां पद खोजें (a_n)',
      'btn_opt_sn': 'योग खोजें (S_n)',
      'btn_process': 'आंतरिक गणना',
      'btn_total': 'कुल करें',
      'btn_diff': 'अंतर उपकरण',
      'btn_buy': 'अभी खरीदें',
      'btn_wait': '1 महीने रुकें',
      'lbl_target': 'लक्ष्य: 5000',
      'lbl_insuf': 'अपर्याप्त धनराशि',
      'msg_seq_id': 'अनुक्रम: 100, 150, 200... (AP)',
      'msg_param_ok': 'a=100, d=50',
      'msg_n_ok': 'क्षितिज: 12 महीने। लक्ष्य निर्धारित।',
      'msg_form_ok': 'सूत्र चयनित: S_n',
      'msg_eq_ok': 'समीकरण तैयार',
      'msg_inter_ok': 'मान सरल किए गए',
      'msg_comp_fail': '4500 < 5000',
      'msg_short_ok': 'कमी: 500',
      'msg_err': 'गलत। पुनः प्रयास करें।',
      'msg_click_param':
          "'a' के लिए '100' क्लिक करें। 'd' के लिए '150' फिर '100' क्लिक करें।",
      'msg_drag_stack': "तुलना करने के लिए बचत को खींचें: 4500 बनाम 5000",
      'msg_month_13': 'महीना 13 बचत: 700। नया कुल: 5200।',
      'msg_tool_q': 'क्या हमें 12वें महीने में बचत की जरूरत है या कुल बचत की?',
      'msg_click_prev': "अब पिछले पद (100) पर क्लिक करें।",
      'ledger_title': 'बचत खाता',
      'month_1': 'महीना 1',
      'month_2': 'महीना 2',
      'month_3': 'महीना 3',
      'err_a_click': 'प्रथम पद (a) के लिए 100 पर क्लिक करें',
      'err_n_plan': '1-वर्ष (12 महीने) की योजना आवश्यक है।',
      'lbl_missing': 'कमी',
      'step_8_eq': '5000 - 4500 = ?',
    },
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['en']![key] ?? key;
  }
}

class SavingsPlannerApp extends StatefulWidget {
  const SavingsPlannerApp({super.key});

  @override
  State<SavingsPlannerApp> createState() => _SavingsPlannerAppState();
}

class _SavingsPlannerAppState extends State<SavingsPlannerApp>
    with TickerProviderStateMixin {
  bool hasStarted = false;
  String lang = 'en';
  bool panelOpen = true;

  // Activity State
  int currentStep = 0;
  bool showSuccessModal = false;

  // Interaction State Data
  int ledgerState = 0; // 0: init, 1: 'a' found, 2: 150 clicked, 3: 'd' found
  double sliderVal = 1;
  Map<String, bool> formulaSlots = {'n': false, 'a': false, 'd': false};

  // Animation States
  double stackHeightPerc = 0;
  String currentStackLabel = "0";
  double comparisonDragDx = 0;
  late AnimationController _bikeAnimController;
  late Animation<double> _bikeAnimation;

  // Input Controllers
  final TextEditingController _inpDiff = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bikeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _bikeAnimation =
        Tween<double>(begin: -0.2, end: 1.2).animate(
          CurvedAnimation(parent: _bikeAnimController, curve: Curves.easeInOut),
        )..addListener(() {
          setState(() {});
        });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _inpDiff.dispose();
    _bikeAnimController.dispose();
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

      // Step Specific Resets & Animations
      if (currentStep == 6) {
        _animateStackGrowth();
      }
    }
  }

  void resetLab() {
    playMathStart();
    playVibration('click');
    setState(() {
      currentStep = 0;
      ledgerState = 0;
      sliderVal = 1;
      formulaSlots = {'n': false, 'a': false, 'd': false};
      stackHeightPerc = 0;
      currentStackLabel = "0";
      comparisonDragDx = 0;
      _inpDiff.clear();
      showSuccessModal = false;
      hasStarted = false;
      panelOpen = true;
      _bikeAnimController.reset();
    });
  }

  // --- Step Specific Logic ---

  void onLedgerTap(int value) {
    if (currentStep != 1) return;

    if (ledgerState == 0) {
      if (value == 100) {
        playVibration('success');
        setState(() => ledgerState = 1);
        showToast("a = 100", isSuccess: true);
      } else {
        playVibration('error');
        showToast(AppStrings.get(lang, 'err_a_click'), isError: true);
      }
    } else if (ledgerState == 1) {
      if (value == 150) {
        playVibration('click');
        setState(() => ledgerState = 2);
        showToast(AppStrings.get(lang, 'msg_click_prev'), isSuccess: false);
      } else {
        playVibration('error');
        showToast(AppStrings.get(lang, 'msg_err'), isError: true);
      }
    } else if (ledgerState == 2) {
      if (value == 100) {
        playVibration('success');
        setState(() => ledgerState = 3);
        showToast(AppStrings.get(lang, 'msg_param_ok'), isSuccess: true);
        Timer(const Duration(seconds: 1), advanceStep);
      } else {
        playVibration('error');
        setState(() => ledgerState = 1); // Reset d calculation
        showToast(AppStrings.get(lang, 'msg_err'), isError: true);
      }
    }
  }

  void onSetDuration() {
    if (sliderVal == 12) {
      playVibration('success');
      showToast(AppStrings.get(lang, 'msg_n_ok'), isSuccess: true);
      advanceStep();
    } else {
      playVibration('error');
      showToast(AppStrings.get(lang, 'err_n_plan'), isError: true);
    }
  }

  void fillSlot(String slot) {
    if (!formulaSlots[slot]!) {
      playVibration('click');
      setState(() => formulaSlots[slot] = true);
      if (formulaSlots['n']! && formulaSlots['a']! && formulaSlots['d']!) {
        playVibration('success');
        showToast(AppStrings.get(lang, 'msg_eq_ok'), isSuccess: true);
        Timer(const Duration(seconds: 1), advanceStep);
      }
    }
  }

  void _animateStackGrowth() {
    int current = 0;
    int target = 4500;
    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (current >= target) {
        timer.cancel();
        setState(() {
          currentStackLabel = target.toString();
          stackHeightPerc = (target / 6000);
        });
      } else {
        setState(() {
          current += 150;
          currentStackLabel = current.toString();
          stackHeightPerc = (current / 6000);
        });
      }
    });
  }

  void onComparisonDrag(DragUpdateDetails details) {
    setState(() {
      comparisonDragDx += details.delta.dx;
      // Collision detection: if dragged right by roughly 80 pixels
      if (comparisonDragDx > 80) {
        comparisonDragDx = 0;
        playVibration('error');
        showToast(AppStrings.get(lang, 'msg_comp_fail'), isError: true);
        Timer(const Duration(seconds: 1), advanceStep);
      }
    });
  }

  void onComparisonDragEnd(DragEndDetails details) {
    setState(() {
      comparisonDragDx = 0; // snap back if not successful
    });
  }

  void checkShortfall() {
    if (_inpDiff.text == "500") {
      playVibration('success');
      showToast(AppStrings.get(lang, 'msg_short_ok'), isSuccess: true);
      advanceStep();
    } else {
      playVibration('error');
      showToast(AppStrings.get(lang, 'msg_err'), isError: true);
    }
  }

  void triggerFinalAnimation() {
    playVibration('success');
    showToast(AppStrings.get(lang, 'msg_month_13'), isSuccess: true);
    _bikeAnimController.forward().then((_) {
      setState(() {
        showSuccessModal = true;
      });
    });
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
                  child: const Icon(Icons.savings, size: 80, color: accentPink),
                ),
                const SizedBox(height: 20),
                Text(
                  AppStrings.get(lang, 'app_title'),
                  textAlign: TextAlign.center,
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
                  textAlign: TextAlign.center,
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
                    child: Stack(
                      children: [
                        // Zoom and Pan Canvas
                        InteractiveViewer(
                          boundaryMargin: const EdgeInsets.all(2000),
                          minScale: 0.5,
                          maxScale: 4.0,
                          panEnabled:
                              currentStep !=
                              7, // Disable pan when dragging stacks
                          child: Stack(
                            children: [
                              // Background Grid
                              Positioned.fill(
                                child: CustomPaint(painter: GridPainter()),
                              ),
                              // Dynamic Scene Graphics
                              Center(child: _buildSceneGraphics()),
                            ],
                          ),
                        ),
                      ],
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

            // Success Overlay
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
                          Icons.show_chart,
                          color: bgDark,
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t['header_title']!,
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
          child: _buildControlsArea(t: t),
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
                child: _buildControlsArea(t: t),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlsArea({required Map<String, String> t}) {
    switch (currentStep) {
      case 0:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              showToast(t['msg_seq_id']!);
              advanceStep();
            },
            style: ElevatedButton.styleFrom(backgroundColor: accentBlue),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                t['btn_review']!,
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
              t['msg_click_param']!,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: accentPink),
                borderRadius: BorderRadius.circular(8),
                color: Colors.black45,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "a = ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    ledgerState >= 1 ? "100" : "?",
                    style: TextStyle(
                      color: ledgerState >= 1 ? accentGreen : Colors.white54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    "d = ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    ledgerState >= 3 ? "50" : "?",
                    style: TextStyle(
                      color: ledgerState >= 3 ? accentGreen : Colors.white54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      case 2:
        return Column(
          children: [
            Text(
              "n = ${sliderVal.toInt()}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Slider(
              value: sliderVal,
              min: 1,
              max: 12,
              divisions: 11,
              activeColor: accentGreen,
              onChanged: (v) => setState(() => sliderVal = v),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentGreen,
                  foregroundColor: Colors.black,
                ),
                onPressed: onSetDuration,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    t['btn_set_n']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        );
      case 3:
        return Column(
          children: [
            Text(
              t['msg_tool_q']!,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: bgDark,
                  side: const BorderSide(color: Colors.white24),
                ),
                onPressed: () => showToast(t['msg_err']!, isError: true),
                child: Text(
                  t['btn_opt_an']!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: bgDark,
                  side: const BorderSide(color: Colors.white24),
                ),
                onPressed: () {
                  showToast(t['msg_form_ok']!);
                  advanceStep();
                },
                child: Text(
                  t['btn_opt_sn']!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      case 4:
        return Column(
          children: [
            const Text(
              "Drag to assemble",
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _VarChip(
                  label: "n",
                  isFilled: formulaSlots['n']!,
                  onTap: () => fillSlot('n'),
                ),
                _VarChip(
                  label: "a",
                  isFilled: formulaSlots['a']!,
                  onTap: () => fillSlot('a'),
                ),
                _VarChip(
                  label: "d",
                  isFilled: formulaSlots['d']!,
                  onTap: () => fillSlot('d'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                children: [
                  const Text(
                    "S = ",
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.white,
                    ),
                  ),
                  _SlotPlaceholder(
                    label: "n",
                    val: "12",
                    isFilled: formulaSlots['n']!,
                  ),
                  const Text(
                    "/2 [ 2(",
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.white,
                    ),
                  ),
                  _SlotPlaceholder(
                    label: "a",
                    val: "100",
                    isFilled: formulaSlots['a']!,
                  ),
                  const Text(
                    ") + (",
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.white,
                    ),
                  ),
                  _SlotPlaceholder(
                    label: "n",
                    val: "12",
                    isFilled: formulaSlots['n']!,
                  ),
                  const Text(
                    "-1)",
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.white,
                    ),
                  ),
                  _SlotPlaceholder(
                    label: "d",
                    val: "50",
                    isFilled: formulaSlots['d']!,
                  ),
                  const Text(
                    " ]",
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      case 5:
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "S = 6 [ 2(100) + (11)(50) ]",
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
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
                  showToast(t['msg_inter_ok']!);
                  advanceStep();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(t['btn_process:'] ?? 'PROCESS INNER TERMS'),
                ),
              ),
            ),
          ],
        );
      case 6:
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "S = 6 [ 200 + 550 ] = 6 [ 750 ]",
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentGreen,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  advanceStep();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(t['btn_total']!),
                ),
              ),
            ),
          ],
        );
      case 7:
        return Text(
          t['msg_drag_stack']!,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        );
      case 8:
        return Column(
          children: [
            Text(
              t['step_8_eq']!,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _inpDiff,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.black45,
                hintText: "?",
                hintStyle: TextStyle(color: Colors.white54),
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
                onPressed: checkShortfall,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(t['btn_diff']!),
                ),
              ),
            ),
          ],
        );
      case 9:
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: bgDark,
                  side: const BorderSide(color: Colors.white24),
                ),
                onPressed: () => showToast(t['lbl_insuf']!, isError: true),
                child: Text(
                  t['btn_buy']!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: bgDark,
                  side: const BorderSide(color: Colors.white24),
                ),
                onPressed: triggerFinalAnimation,
                child: Text(
                  t['btn_wait']!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  // --- Graphical Scenes ---

  Widget _buildSceneGraphics() {
    if (currentStep <= 1) return _buildLedger(AppStrings.data[lang]!);
    if (currentStep == 2) return _buildTimeline(AppStrings.data[lang]!);
    if (currentStep >= 3 && currentStep <= 5)
      return _buildLedger(AppStrings.data[lang]!);
    if (currentStep == 6) return _buildStackGrowth();
    if (currentStep >= 7 && currentStep <= 8)
      return _buildComparisonDrag(AppStrings.data[lang]!);
    if (currentStep >= 9) return _buildBikeScene();

    return const SizedBox();
  }

  Widget _buildLedger(Map<String, String> t) {
    return Container(
      width: 380,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgPanel.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t['ledger_title']!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white54,
            ),
          ),
          const Divider(),
          const SizedBox(height: 8),
          _LedgerRow(
            month: t['month_1']!,
            value: 100,
            color: ledgerState >= 1 ? accentGreen : accentBlue,
            onTap: () => onLedgerTap(100),
          ),
          _LedgerRow(
            month: t['month_2']!,
            value: 150,
            color: ledgerState == 1
                ? accentYellow
                : (ledgerState >= 2 ? accentBlue : accentBlue),
            onTap: () => onLedgerTap(150),
          ),
          _LedgerRow(
            month: t['month_3']!,
            value: 200,
            color: accentBlue,
            onTap: () => onLedgerTap(200),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(Map<String, String> t) {
    return Container(
      width: 500,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: bgDark,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white24),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 20,
                width: 500 * (sliderVal / 12),
                decoration: BoxDecoration(
                  color: accentBlue,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: accentBlue.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              if (sliderVal == 12)
                Positioned(
                  right: -10,
                  top: -50,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          t['lbl_target']!,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      Container(width: 2, height: 20, color: Colors.white),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: accentRed,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: accentRed, blurRadius: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              12,
              (i) => Text(
                "${i + 1}",
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStackGrowth() {
    return Container(
      height: 300,
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            currentStackLabel,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
              color: accentYellow,
            ),
          ),
          const SizedBox(height: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 150,
            height: 200 * stackHeightPerc,
            decoration: BoxDecoration(
              color: accentYellow,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              boxShadow: [
                BoxShadow(color: accentYellow.withOpacity(0.5), blurRadius: 20),
              ],
              border: Border.all(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonDrag(Map<String, String> t) {
    bool isShortfall = currentStep == 8;

    return Container(
      height: 350,
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(bottom: 20),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Base Line
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(height: 2, color: Colors.white24),
          ),

          // Target Stack (5000)
          Positioned(
            right: 150,
            bottom: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "5000",
                  style: TextStyle(
                    color: accentRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  width: 120,
                  height: 250,
                  decoration: BoxDecoration(
                    color: accentRed.withOpacity(0.2),
                    border: Border.all(
                      color: accentRed,
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.electric_moped,
                      size: 50,
                      color: accentRed,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Savings Stack (4500) - Draggable in step 7
          Positioned(
            left: 150,
            bottom: 2,
            child: Transform.translate(
              offset: Offset(comparisonDragDx, 0),
              child: GestureDetector(
                onPanUpdate: currentStep == 7 ? onComparisonDrag : null,
                onPanEnd: currentStep == 7 ? onComparisonDragEnd : null,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      isShortfall ? t['lbl_missing']! : "4500",
                      style: const TextStyle(
                        color: accentYellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: 120,
                      height:
                          250 *
                          (isShortfall
                              ? 1.0
                              : 0.9), // Scales to full height if shortfall is shown to align visually
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isShortfall)
                            Container(
                              height: 250 * 0.1,
                              width: double.infinity,
                              color: accentRed.withOpacity(0.8),
                              alignment: Alignment.center,
                              child: Text(
                                t['lbl_missing']!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          Container(
                            height: 250 * 0.9,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: accentYellow,
                              boxShadow: [
                                BoxShadow(
                                  color: accentYellow.withOpacity(0.4),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBikeScene() {
    return Stack(
      children: [
        // Final Stack (5200)
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedOpacity(
                  opacity: _bikeAnimation.value > 0.8 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: const Text(
                    "5200",
                    style: TextStyle(
                      color: accentGreen,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 150,
                  height: 260,
                  decoration: BoxDecoration(
                    color: accentGreen,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentGreen.withOpacity(0.5),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Animated Bike
        AnimatedBuilder(
          animation: _bikeAnimation,
          builder: (context, child) {
            return Positioned(
              bottom: 20,
              left:
                  MediaQuery.of(context).size.width * _bikeAnimation.value -
                  100,
              child: const Icon(
                Icons.electric_moped,
                size: 100,
                color: accentBlue,
              ),
            );
          },
        ),
      ],
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
                const Icon(Icons.electric_moped, color: accentGreen, size: 80),
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

class _LedgerRow extends StatelessWidget {
  final String month;
  final int value;
  final Color color;
  final VoidCallback onTap;

  const _LedgerRow({
    required this.month,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          border: Border.all(color: color.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              month,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.white,
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
}

class _VarChip extends StatelessWidget {
  final String label;
  final bool isFilled;
  final VoidCallback onTap;

  const _VarChip({
    required this.label,
    required this.isFilled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isFilled ? null : onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isFilled ? Colors.white10 : bgPanel,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isFilled ? Colors.white30 : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _SlotPlaceholder extends StatelessWidget {
  final String label;
  final String val;
  final bool isFilled;

  const _SlotPlaceholder({
    required this.label,
    required this.val,
    required this.isFilled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: isFilled ? Colors.white10 : Colors.black26,
        border: Border.all(
          color: isFilled ? Colors.white : Colors.white30,
          style: BorderStyle.solid,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isFilled ? val : label,
        style: TextStyle(
          color: isFilled ? Colors.white : Colors.white54,
          fontWeight: isFilled ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
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
    // Draw an extended grid so panning reveals more grid
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
