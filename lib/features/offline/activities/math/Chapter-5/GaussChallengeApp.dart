// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:elab_app/features/offline/activities/math_activity_audio.dart';

// --- स्थिरांक और स्ट्रिंग्स (Constants & Strings) ---

const Color bgDark = Color(0xFF020617);
const Color bgPanel = Color(0xFF0F172A);
const Color accentPink = Color(0xFFF472B6);
const Color accentBlue = Color(0xFF3B82F6);
const Color accentGreen = Color(0xFF22C55E);
const Color accentRed = Color(0xFFEF4444);

class AppStrings {
  static const Map<String, Map<String, String>> data = {
    'en': {
      'app_title': 'THE GAUSS CHALLENGE',
      'tagline': 'Sum of First n Terms',
      'init_btn': 'START CHALLENGE',
      'header_title': 'The Gauss Challenge',
      'header_subtitle': 'Class 10 • Arithmetic Progression',
      'phase_label': 'GAUSS PHASE',
      'step_label': 'Step',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Math Prodigy',
      'success_desc': 'This works for any AP!',
      'btn_restart': 'RESTART',
      's0': 'The Problem Statement',
      's1': 'The Pairing Insight',
      's2': 'The Pattern Confirmation',
      's3': 'The Generalization',
      's4': 'Counting the Pairs',
      's5': 'The Final Calculation',
      's6': 'Deriving the General Formula',
      's7': "Expanding for 'd'",
      's8': 'Practice Run',
      's9': 'Award Ceremony',
      'lbl_total': 'Total',
      'lbl_pair_sum': 'Pair Sum',
      'lbl_pairs': 'Pairs',
      'lbl_pairing_box': 'Pairing Box',
      'lbl_sum_var': 'Sum',
      'btn_autopair': 'AUTO-PAIR',
      'btn_create_form': 'CREATE FORMULA',
      'btn_check': 'CHECK',
      'btn_sub': 'SUBMIT',
      'btn_substitute_l': 'SUBSTITUTE l',
      'btn_next': 'NEXT',
      'btn_start_prac': 'START PRACTICE',
      'msg_start': 'Sequence Loaded: 1...100',
      'msg_pair1': 'Pair Sum = 101',
      'msg_pair2': 'Pair Sum = 101',
      'msg_fold': 'Sequence Folded!',
      'msg_count_ok': 'Pairs = 50',
      'msg_calc_ok': 'Teacher is shocked! Total = 5050',
      'msg_form_ok': 'Formula Derived!',
      'msg_gen_ok': 'General Formula Ready.',
      'msg_prac_ok': 'Correct! 275.',
      'msg_err': 'Incorrect value.',
      'msg_drag': 'Tap 1 and 100 to pair.',
      'msg_sel_2_99': 'Select 2 and 99',
      'msg_card_sel': "Card Selected. Tap 'l' to place.",
      'q_pairs': 'How many pairs? (100 / 2)',
      'q_calc': '50 * 101 = ?',
      'q_prac': 'Sum of 10 multiples of 5? (n=10, a=5, l=50)',
      'lbl_ap': 'AP',
    },
    'hi': {
      'app_title': 'गॉस चुनौती',
      'tagline': 'प्रथम n पदों का योग',
      'init_btn': 'चुनौती शुरू करें',
      'header_title': 'गॉस चुनौती',
      'header_subtitle': 'कक्षा 10 • समान्तर श्रेढ़ी',
      'phase_label': 'गॉस चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'गणित कौतुक',
      'success_desc': 'यह किसी भी AP के लिए काम करता है!',
      'btn_restart': 'पुनः आरंभ करें',
      's0': 'समस्या कथन',
      's1': 'युग्मन अंतर्दृष्टि',
      's2': 'पैटर्न की पुष्टि',
      's3': 'सामान्यीकरण',
      's4': 'जोड़े गिनना',
      's5': 'अंतिम गणना',
      's6': 'सामान्य सूत्र व्युत्पन्न करना',
      's7': "'d' के लिए विस्तार",
      's8': 'अभ्यास',
      's9': 'पुरस्कार समारोह',
      'lbl_total': 'योग',
      'lbl_pair_sum': 'युग्म योग',
      'lbl_pairs': 'जोड़े',
      'lbl_pairing_box': 'युग्मन बॉक्स',
      'lbl_sum_var': 'योग',
      'btn_autopair': 'ऑटो-पेयर',
      'btn_create_form': 'सूत्र बनाएँ',
      'btn_check': 'जाँच करें',
      'btn_sub': 'सबमिट',
      'btn_substitute_l': 'l को प्रतिस्थापित करें',
      'btn_next': 'अगला',
      'btn_start_prac': 'अभ्यास शुरू करें',
      'msg_start': 'अनुक्रम लोड: 1...100',
      'msg_pair1': 'युग्म योग = 101',
      'msg_pair2': 'युग्म योग = 101',
      'msg_fold': 'अनुक्रम मुड़ा हुआ!',
      'msg_count_ok': 'जोड़े = 50',
      'msg_calc_ok': 'शिक्षक हैरान हैं! कुल = 5050',
      'msg_form_ok': 'सूत्र व्युत्पन्न!',
      'msg_gen_ok': 'सामान्य सूत्र तैयार।',
      'msg_prac_ok': 'सही! 275।',
      'msg_err': 'गलत मान।',
      'msg_drag': 'जोड़ने के लिए 1 और 100 पर क्लिक करें।',
      'msg_sel_2_99': '2 और 99 चुनें',
      'msg_card_sel': "कार्ड चुना गया। रखने के लिए 'l' पर टैप करें।",
      'q_pairs': 'कितने जोड़े? (100 / 2)',
      'q_calc': '50 * 101 = ?',
      'q_prac': '5 के 10 गुणजों का योग? (n=10, a=5, l=50)',
      'lbl_ap': 'AP',
    },
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['en']![key] ?? key;
  }
}

// --- अवस्था मॉडल (STATE MODELS) ---

class NodeItem {
  final int id;
  double x;
  double y;
  Color color;
  String text;
  bool isVisible;

  NodeItem({
    required this.id,
    required this.x,
    required this.y,
    required this.color,
    required this.text,
    this.isVisible = true,
  });
}

class GaussChallengeApp extends StatefulWidget {
  const GaussChallengeApp({super.key});

  @override
  State<GaussChallengeApp> createState() => _GaussChallengeAppState();
}

class _GaussChallengeAppState extends State<GaussChallengeApp> {
  bool hasStarted = false;
  String lang = 'hi'; // डिफ़ॉल्ट रूप से हिंदी सेट किया गया
  bool panelOpen = true;

  // गतिविधि स्थिति (Activity State)
  int currentStep = 0;
  bool showSuccessModal = false;

  // ग्रिड / एनीमेशन स्थिति (Grid / Animation State)
  List<NodeItem> nodes = [];
  List<int> clickedNums = [];
  bool pairingZoneActive = false;
  String pairingZoneText = "";

  // सूत्र / अभ्यास स्थिति (Formula / Practice State)
  bool showGrid = true;
  bool formulaAnimState = false;
  bool lSubstituted = false;
  List<int> practiceBlocks = [];

  // कैनवास कंट्रोल (Canvas Control)
  final TransformationController _transformController =
      TransformationController();
  bool _isInitialPanSet = false;

  // इनपुट कंट्रोलर (Input Controllers)
  final TextEditingController _inpPairs = TextEditingController();
  final TextEditingController _inpTotal = TextEditingController();
  final TextEditingController _inpPrac = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initNodes();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _inpPairs.dispose();
    _inpTotal.dispose();
    _inpPrac.dispose();
    _transformController.dispose();
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _initNodes() {
    nodes.clear();
    double startX = 30.0;
    double startY = 160.0;
    double spacing = 42.0;

    for (int i = 1; i <= 100; i++) {
      int col = (i - 1) % 20;
      int row = (i - 1) ~/ 20;
      nodes.add(
        NodeItem(
          id: i,
          x: startX + col * spacing,
          y: startY + row * spacing,
          color: const Color(0xFF1E293B),
          text: i.toString(),
        ),
      );
    }
  }

  void startGame() {
    playMathStart();
    playVibration('click');
    setState(() {
      hasStarted = true;
    });
    showToast(AppStrings.get(lang, 'msg_start'));
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
      setState(() {
        currentStep++;
      });

      // चरण-विशिष्ट आरंभीकरण (Step-specific initializations)
      if (currentStep == 1 || currentStep == 2) {
        clickedNums.clear();
        pairingZoneActive = true;
        pairingZoneText = "";
      } else if (currentStep == 6) {
        // ग्रिड छिपाएं, सूत्र दिखाएं (Hide Grid, Show formula)
        showGrid = false;
        Timer(const Duration(milliseconds: 500), () {
          setState(() => formulaAnimState = true);
        });
        Timer(const Duration(seconds: 2), () {
          advanceStep();
        });
      } else if (currentStep == 9) {
        playMathSuccess();
        showToast(AppStrings.get(lang, 'success_desc'), isSuccess: true);
        Timer(const Duration(seconds: 1), () {
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
      _initNodes();
      clickedNums.clear();
      pairingZoneActive = false;
      showGrid = true;
      formulaAnimState = false;
      lSubstituted = false;
      practiceBlocks.clear();
      _inpPairs.clear();
      _inpTotal.clear();
      _inpPrac.clear();
      showSuccessModal = false;
      hasStarted = false;
      panelOpen = true;
      _isInitialPanSet = false;
      _transformController.value = Matrix4.identity();
    });
  }

  // --- इंटरैक्शन लॉजिक (INTERACTION LOGIC) ---

  void onNodeTap(NodeItem node) {
    if (currentStep == 1) {
      if ((node.id == 1 || node.id == 100) && !clickedNums.contains(node.id)) {
        playVibration('click');
        setState(() {
          clickedNums.add(node.id);
          node.color = accentGreen;
          node.x = node.id == 1 ? 380.0 : 460.0;
          node.y = 80.0; // पेयरिंग बॉक्स क्षेत्र
        });

        if (clickedNums.length == 2) {
          Timer(const Duration(milliseconds: 800), () {
            setState(() {
              pairingZoneText = AppStrings.get(lang, 'msg_pair1');
            });
            showToast(AppStrings.get(lang, 'msg_pair1'));
            Timer(const Duration(seconds: 2), advanceStep);
          });
        }
      }
    } else if (currentStep == 2) {
      if ((node.id == 2 || node.id == 99) && !clickedNums.contains(node.id)) {
        playVibration('click');
        setState(() {
          clickedNums.add(node.id);
          node.color = accentBlue;
          node.x = node.id == 2 ? 380.0 : 460.0;
          node.y = 120.0;
        });

        if (clickedNums.length == 2) {
          Timer(const Duration(milliseconds: 800), () {
            setState(() {
              pairingZoneText =
                  "${AppStrings.get(lang, 'msg_pair1')}\n${AppStrings.get(lang, 'msg_pair2')}";
            });
            showToast(AppStrings.get(lang, 'msg_pair2'));
            Timer(const Duration(seconds: 2), advanceStep);
          });
        }
      }
    }
  }

  void autoPair() {
    playVibration('click');
    setState(() {
      pairingZoneActive = false;
      // 51-100 को 1-50 पर ओवरलैप करने के लिए एनिमेट करें
      for (int i = 50; i < 100; i++) {
        NodeItem target = nodes[100 - i - 1]; // 100 -> 1, 99 -> 2, आदि।
        nodes[i].x = target.x;
        nodes[i].y = target.y;
        nodes[i].color = accentPink;
        nodes[i].text = "101";

        // लक्ष्य के रंग और टेक्स्ट को भी अपडेट करें ताकि वे मर्ज किए गए दिखें
        target.color = accentPink;
        target.text = "101";
      }
    });

    showToast(AppStrings.get(lang, 'msg_fold'));
    Timer(const Duration(seconds: 2), advanceStep);
  }

  void checkInput(String type) {
    playVibration('click');
    if (type == 'pairs') {
      if (_inpPairs.text.trim() == '50') {
        showToast(AppStrings.get(lang, 'msg_count_ok'));
        advanceStep();
      } else {
        playVibration('error');
        showToast(AppStrings.get(lang, 'msg_err'), isError: true);
      }
    } else if (type == 'total') {
      if (_inpTotal.text.trim() == '5050') {
        showToast(AppStrings.get(lang, 'msg_calc_ok'));
        advanceStep();
      } else {
        playVibration('error');
        showToast(AppStrings.get(lang, 'msg_err'), isError: true);
      }
    } else if (type == 'prac') {
      if (_inpPrac.text.trim() == '275') {
        showToast(AppStrings.get(lang, 'msg_prac_ok'));
        // अभ्यास ब्लॉक एनीमेशन बनाएँ
        int count = 0;
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
          if (count >= 11) {
            // 11 * 25 = 275
            timer.cancel();
            Timer(const Duration(seconds: 2), advanceStep);
          } else {
            setState(() {
              practiceBlocks.add(25);
            });
            count++;
          }
        });
      } else {
        playVibration('error');
        showToast(AppStrings.get(lang, 'msg_err'), isError: true);
      }
    }
  }

  void substituteFormula() {
    playVibration('click');
    setState(() {
      lSubstituted = true;
    });
    showToast(AppStrings.get(lang, 'msg_gen_ok'));
    Timer(const Duration(seconds: 2), advanceStep);
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
                child: const Icon(
                  Icons.all_inclusive,
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
            // Core Layout
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
                  Expanded(
                    child: ClipRect(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (!_isInitialPanSet) {
                            _isInitialPanSet = true;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              final dx = -(2000 - constraints.maxWidth) / 2;
                              final dy = -(1500 - constraints.maxHeight) / 2;
                              _transformController.value = Matrix4.identity()
                                ..translate(dx, dy);
                            });
                          }
                          return InteractiveViewer(
                            transformationController: _transformController,
                            boundaryMargin: const EdgeInsets.all(1500),
                            minScale: 0.1,
                            maxScale: 5.0,
                            constrained: false,
                            child: Container(
                              width: 2000,
                              height: 1500,
                              alignment: Alignment.center,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: CustomPaint(painter: GridPainter()),
                                  ),
                                  Center(
                                    child: showGrid
                                        ? _buildNumberGridScene()
                                        : _buildFormulaScene(),
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

            // Floating HUD (when sidebar is closed)
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

            // Success Overlay
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
                            Icons.psychology,
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
                            style: const TextStyle(
                              color: Colors.white,
                            ), // Made white for visibility
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
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidePanel() {
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
                          Icons.calculate,
                          color: bgDark,
                          size: 20,
                        ),
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

  Widget _buildFloatingHUD() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 180,
        maxWidth: 320,
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

  Widget _buildControlsArea() {
    switch (currentStep) {
      case 0:
        return ElevatedButton(
          onPressed: () {
            playMathClick();
            advanceStep();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              AppStrings.get(lang, 'init_btn'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      case 1:
        return Text(
          AppStrings.get(lang, 'msg_drag'),
          style: const TextStyle(
            color: accentPink,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        );
      case 2:
        return Text(
          AppStrings.get(lang, 'msg_sel_2_99'),
          style: const TextStyle(
            color: accentBlue,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        );
      case 3:
        return ElevatedButton(
          onPressed: autoPair,
          style: ElevatedButton.styleFrom(
            backgroundColor: accentBlue,
            foregroundColor: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              AppStrings.get(lang, 'btn_autopair'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      case 4:
        return Column(
          children: [
            Text(
              AppStrings.get(lang, 'q_pairs'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            _buildInputField(_inpPairs, "?"),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentGreen,
                  foregroundColor: Colors.black,
                ),
                onPressed: () => checkInput('pairs'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    AppStrings.get(lang, 'btn_sub'),
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
            Text(
              AppStrings.get(lang, 'q_calc'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            _buildInputField(_inpTotal, "?"),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentGreen,
                  foregroundColor: Colors.black,
                ),
                onPressed: () => checkInput('total'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    AppStrings.get(lang, 'btn_sub'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        );
      case 6:
        return const Center(
          child: CircularProgressIndicator(color: accentPink),
        );
      case 7:
        return Column(
          children: [
            Text(
              AppStrings.get(lang, 'btn_substitute_l'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: substituteFormula,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: accentBlue,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white30),
                ),
                child: const Text(
                  "l = a + (n-1)d",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      case 8:
        return Column(
          children: [
            Text(
              AppStrings.get(lang, 'q_prac'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            _buildInputField(_inpPrac, "?"),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentGreen,
                  foregroundColor: Colors.black,
                ),
                onPressed: () => checkInput('prac'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    AppStrings.get(lang, 'btn_check'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
    );
  }

  // --- दृश्य निर्माता (SCENE BUILDERS) ---

  Widget _buildNumberGridScene() {
    return SizedBox(
      width: 880,
      height: 400,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // नोड्स (Nodes)
          ...nodes.map((node) {
            return AnimatedPositioned(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              left: node.x,
              top: node.y,
              child: GestureDetector(
                onTap: () => onNodeTap(node),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: node.color,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: node.color == const Color(0xFF1E293B)
                          ? accentBlue.withOpacity(0.5)
                          : Colors.white,
                    ),
                    boxShadow: node.color != const Color(0xFF1E293B)
                        ? [
                            BoxShadow(
                              color: node.color.withOpacity(0.5),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    node.text,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: node.text == "101" ? 12 : 14,
                      color: node.color == const Color(0xFF1E293B)
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ),
            );
          }),

          // पेयरिंग ज़ोन बॉक्स (Pairing Zone Box)
          if (pairingZoneActive)
            Positioned(
              left: 320,
              top: 20,
              child: Container(
                width: 260,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accentPink, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: accentPink.withOpacity(0.3),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.get(lang, 'lbl_pairing_box').toUpperCase(),
                      style: const TextStyle(
                        color: accentPink,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const Divider(color: accentPink),
                    const SizedBox(height: 80), // नोड्स के लिए स्थान
                    Text(
                      pairingZoneText,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

          // '50 Pairs' फ्लोटिंग लेबल
          if (currentStep >= 5 && currentStep < 6)
            Positioned(
              left: 300,
              top: 150,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: bgDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accentGreen, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: accentGreen.withOpacity(0.5),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: Text(
                  "50 ${AppStrings.get(lang, 'lbl_pairs')}",
                  style: const TextStyle(
                    color: accentGreen,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFormulaScene() {
    if (currentStep == 8) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (practiceBlocks.length >= 11)
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                "275",
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                  color: Colors.white,
                  shadows: [Shadow(color: accentGreen, blurRadius: 20)],
                ),
              ),
            ),
          ...practiceBlocks.map(
            (_) => Container(
              width: 150,
              height: 25,
              margin: const EdgeInsets.only(bottom: 2),
              decoration: BoxDecoration(
                color: Colors
                    .primaries[practiceBlocks.length % Colors.primaries.length]
                    .shade400,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.black26),
              ),
              alignment: Alignment.center,
              child: const Text(
                "+25",
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // सूत्र एनीमेशन लॉजिक (Formula Animation Logic)
    return AnimatedScale(
      scale: formulaAnimState ? 1.0 : 0.0,
      duration: const Duration(seconds: 1),
      curve: Curves.elasticOut,
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: bgPanel.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: lSubstituted ? accentGreen : accentPink,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: (lSubstituted ? accentGreen : accentPink).withOpacity(0.3),
              blurRadius: 50,
            ),
          ],
        ),
        child: Text.rich(
          TextSpan(
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            children: lSubstituted
                ? [
                    const TextSpan(text: "S = "),
                    const TextSpan(
                      text: "n/2",
                      style: TextStyle(color: accentPink),
                    ),
                    const TextSpan(text: " [ "),
                    const TextSpan(
                      text: "2a + (n-1)d",
                      style: TextStyle(color: accentGreen),
                    ),
                    const TextSpan(text: " ]"),
                  ]
                : [
                    const TextSpan(text: "S = "),
                    const TextSpan(
                      text: "n/2",
                      style: TextStyle(color: accentPink),
                    ),
                    const TextSpan(text: " [ "),
                    const TextSpan(
                      text: "a",
                      style: TextStyle(color: accentBlue),
                    ),
                    const TextSpan(text: " + "),
                    TextSpan(
                      text: "l",
                      style: TextStyle(
                        color: currentStep == 7 ? accentGreen : accentBlue,
                        decoration: currentStep == 7
                            ? TextDecoration.underline
                            : TextDecoration.none,
                        decorationStyle: TextDecorationStyle.dashed,
                      ),
                    ),
                    const TextSpan(text: " ]"),
                  ],
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
