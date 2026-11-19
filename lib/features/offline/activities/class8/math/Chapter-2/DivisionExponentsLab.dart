// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart'; // Ensure audioplayers: ^5.2.1 is in pubspec.yaml

class DivisionExponentsLab extends StatefulWidget {
  const DivisionExponentsLab({Key? key}) : super(key: key);

  @override
  State<DivisionExponentsLab> createState() => _DivisionExponentsLabState();
}

class _DivisionExponentsLabState extends State<DivisionExponentsLab>
    with TickerProviderStateMixin {
  // App State
  String currentLang = 'en';
  int currentStep = 0;
  bool showCurtain = true;
  bool leftSidebarOpen = true; // Replaced rightPanelOpen with leftSidebarOpen

  // Validation State
  bool isTaskComplete = false;
  bool showSuccessToast = false;

  // --- Step 1 State: Multiplication ---
  bool s1Grouped = false;

  // --- Step 2, 3, 4 State: Division / Cancellation ---
  bool s2Cancelled = false;
  bool s3Cancelled = false;
  bool s4Cancelled = false;

  // --- Step 5 State: Chalkboard Quiz ---
  int quizProgress = 0;
  String quizFeedback = "";

  // Animation Controllers
  late AnimationController _actionAnimController;
  late AnimationController _cancelAnimController;

  // Audio Player & Tones (Mixkit Free Assets)
  final AudioPlayer _audioPlayer = AudioPlayer();
  final String tapSound =
      'audio/class8/mixkit_2568.mp3';
  final String successSound =
      'audio/class8/mixkit_2000.mp3';
  final String errorSound =
      'audio/class8/mixkit_2003.mp3';

  // Localization Dictionary
  final Map<String, Map<String, dynamic>> i18n = {
    'en': {
      'title': "Division, Zero, & Negative Exponents",
      'subtitle': "Class 8 Math • POWER PLAY",
      'enterLab': "Enter Virtual Lab",
      'btnValidate': "Derive & Proceed",
      'btnTaskFirst': "Complete Canvas Task First",
      'quizDone': "Lab Completed! You've mastered the Laws of Exponents.",
      'steps': [
        {
          'dropdown': "Step 1: Multiplication Refresher",
          'theory':
              "<b>The Addition Law Refresher</b>\n\nBefore we dive into division, let's quickly remember how multiplication works.\n\nWhen we multiply 2<sup>2</sup> (which is 2 × 2) by 2<sup>3</sup> (which is 2 × 2 × 2), we are simply pooling them all together into one big group.\n\n2<sup>2</sup> × 2<sup>3</sup> = 2<sup>2+3</sup> = 2<sup>5</sup>\n\n<i>Group the terms on the canvas to see them combine.</i>",
          'hud':
              "Click 'Group Terms' to combine 2<sup>2</sup> and 2<sup>3</sup>.",
          'btn': "Group Terms",
          'success':
              "They merged into 2<sup>5</sup>! Now let's see what happens when we divide.",
        },
        {
          'dropdown': "Step 2: The Cancellation (Division)",
          'theory':
              "<b>The Subtraction Law</b>\n\nNow, let's divide: 2<sup>5</sup> ÷ 2<sup>3</sup>.\n\nImagine a fraction. We have five 2s on top (numerator) and three 2s on the bottom (denominator).\n\nFor every 2 on the bottom, we can cancel out a 2 on the top!\n\nWhat's left? Exactly two 2s on the top. 2<sup>2</sup>.\n\n<b>The Shortcut:</b> Instead of drawing them out, just subtract the bottom exponent from the top one!\n\na<sup>m</sup> ÷ a<sup>n</sup> = a<sup>m - n</sup>",
          'hud': "Click 'Cancel Matching Blocks' to cross out identical pairs.",
          'btn': "Cancel Matching Blocks",
          'success': "Cancelled! 5 - 3 = 2. We are left with 2<sup>2</sup>.",
        },
        {
          'dropdown': "Step 3: The Zero Exponent",
          'theory':
              "<b>Creating Nothing out of Something?</b>\n\nWhat if the top and bottom are exactly the same? Let's try 2<sup>3</sup> ÷ 2<sup>3</sup>.\n\nUsing our subtraction rule: 2<sup>3 - 3</sup> = 2<sup>0</sup>.\n\nBut look at the canvas. If we cancel everything on the top with everything on the bottom, what is a number divided by itself? It's 1!\n\n<b>The Golden Rule:</b>\n\nAny non-zero number raised to the power of 0 is exactly 1.\n\na<sup>0</sup> = 1",
          'hud':
              "Cancel the blocks to discover the secret of the zero exponent.",
          'btn': "Cancel Matching Blocks",
          'success': "Everything cancelled! Leaving us with exactly 1.",
        },
        {
          'dropdown': "Step 4: Negative Exponents",
          'theory':
              "<b>Falling Below Zero</b>\n\nWhat if the denominator is bigger? Let's divide 2<sup>2</sup> ÷ 2<sup>5</sup>.\n\nSubtracting gives us: 2<sup>2 - 5</sup> = 2<sup>-3</sup>.\n\nBut what does a negative exponent actually mean? Look at the fraction on the canvas. After cancelling, we run out of 2s on top, but we still have three 2s left on the <i>bottom</i>.\n\nSo, 2<sup>-3</sup> is exactly the same as 1 / 2<sup>3</sup>.\n\n<b>The Inverse Rule:</b>\n\na<sup>-n</sup> = 1 / a<sup>n</sup>",
          'hud': "Cancel the blocks to see where the remaining blocks end up.",
          'btn': "Cancel Matching Blocks",
          'success':
              "They stayed on the bottom! Negative exponents mean fractions.",
        },
        {
          'dropdown': "Step 5: Equation Builder",
          'theory':
              "<b>Test Your Knowledge</b>\n\nYou have discovered three major laws today:\n\n1. Division Law: a<sup>m</sup> ÷ a<sup>n</sup> = a<sup>m-n</sup>\n2. Zero Law: a<sup>0</sup> = 1\n3. Negative Law: a<sup>-n</sup> = 1 / a<sup>n</sup>\n\nNow, face the Chalkboard. Solve the rapid-fire questions to complete the lab.",
          'hud': "Select the correct answer on the chalkboard.",
          'success': "All correct! You've mastered the laws of exponents.",
        },
      ],
      'quiz': [
        {
          'q': "7<sup>6</sup> ÷ 7<sup>6</sup> = ?",
          'options': ["0", "1", "7", "7<sup>1</sup>"],
          'ans': "1",
          'full': "7^{6-6} = 7^0 = 1",
        },
        {
          'q': "4<sup>3</sup> ÷ 4<sup>5</sup> = ?",
          'options': ["4<sup>2</sup>", "4<sup>-2</sup>", "1", "-4<sup>2</sup>"],
          'ans': "4<sup>-2</sup>",
          'full': "4^{3-5} = 4^{-2} = \\frac{1}{4^2}",
        },
        {
          'q': "x<sup>2</sup> × x<sup>-5</sup> = ?",
          'options': [
            "x<sup>-3</sup>",
            "x<sup>3</sup>",
            "x<sup>-10</sup>",
            "1",
          ],
          'ans': "x<sup>-3</sup>",
          'full': "x^{2+(-5)} = x^{-3}",
        },
      ],
    },
    'hi': {
      'title': "विभाजन, शून्य और ऋणात्मक घातांक",
      'subtitle': "कक्षा 8 गणित • पावर प्ले",
      'enterLab': "वर्चुअल लैब में प्रवेश करें",
      'btnValidate': "व्युत्पन्न करें और आगे बढ़ें",
      'btnTaskFirst': "पहले कैनवास कार्य पूरा करें",
      'quizDone':
          "लैब पूरी हुई! आपने घातांक के नियमों में महारत हासिल कर ली है।",
      'steps': [
        {
          'dropdown': "चरण 1: गुणन (Multiplication)",
          'theory':
              "<b>जोड़ नियम का पुनरीक्षण</b>\n\nविभाजन में गोता लगाने से पहले, आइए जल्दी से याद करें कि गुणा कैसे काम करता है।\n\nजब हम 2<sup>2</sup> को 2<sup>3</sup> से गुणा करते हैं, तो हम बस उन सभी को एक बड़े समूह में मिला रहे होते हैं।\n\n2<sup>2</sup> × 2<sup>3</sup> = 2<sup>2+3</sup> = 2<sup>5</sup>\n\n<i>कैनवास पर पदों को मिलाने के लिए 'समूह' पर क्लिक करें।</i>",
          'hud':
              "2<sup>2</sup> और 2<sup>3</sup> को मिलाने के लिए 'समूह' पर क्लिक करें।",
          'btn': "समूह (Group Terms)",
          'success':
              "वे 2<sup>5</sup> में विलीन हो गए! अब देखते हैं कि जब हम भाग करते हैं तो क्या होता है।",
        },
        {
          'dropdown': "चरण 2: रद्दीकरण (Division)",
          'theory':
              "<b>घटाव का नियम</b>\n\nअब, आइए भाग दें: 2<sup>5</sup> ÷ 2<sup>3</sup>।\n\nएक भिन्न की कल्पना करें। हमारे पास ऊपर पाँच 2 हैं और नीचे तीन 2 हैं।\n\nनीचे के प्रत्येक 2 के लिए, हम ऊपर के एक 2 को काट सकते हैं!\n\nक्या बचा? ऊपर ठीक दो 2। 2<sup>2</sup>।\n\n<b>शॉर्टकट:</b> उन्हें खींचने के बजाय, बस ऊपर वाले घातांक से नीचे वाले को घटा दें!\n\na<sup>m</sup> ÷ a<sup>n</sup> = a<sup>m - n</sup>",
          'hud': "समान जोड़े को काटने के लिए 'रद्द करें' पर क्लिक करें।",
          'btn': "समान ब्लॉक रद्द करें",
          'success': "रद्द कर दिया! 5 - 3 = 2. हमारे पास 2<sup>2</sup> बचा है।",
        },
        {
          'dropdown': "चरण 3: शून्य घातांक",
          'theory':
              "<b>क्या कुछ नहीं से कुछ बनता है?</b>\n\nक्या होगा यदि ऊपर और नीचे बिल्कुल समान हैं? आइए 2<sup>3</sup> ÷ 2<sup>3</sup> आज़माएं।\n\nहमारे घटाव नियम का उपयोग करते हुए: 2<sup>3 - 3</sup> = 2<sup>0</sup>।\n\nलेकिन कैनवास पर देखें। अगर हम ऊपर की हर चीज़ को नीचे की हर चीज़ से काट दें, तो एक संख्या को उसी से भाग देने पर क्या आता है? यह 1 है!\n\n<b>सुनहरा नियम:</b>\n\n0 की घात वाली कोई भी गैर-शून्य संख्या ठीक 1 होती है।\n\na<sup>0</sup> = 1",
          'hud': "शून्य घातांक का रहस्य खोजने के लिए ब्लॉकों को रद्द करें।",
          'btn': "समान ब्लॉक रद्द करें",
          'success': "सब कुछ रद्द हो गया! हमारे पास ठीक 1 बचा है।",
        },
        {
          'dropdown': "चरण 4: ऋणात्मक घातांक",
          'theory':
              "<b>शून्य से नीचे गिरना</b>\n\nक्या होगा यदि हर (नीचे) बड़ा है? आइए 2<sup>2</sup> ÷ 2<sup>5</sup> को भाग दें।\n\nघटाने पर हमें मिलता है: 2<sup>2 - 5</sup> = 2<sup>-3</sup>।\n\nलेकिन ऋणात्मक घातांक का वास्तव में क्या अर्थ है? कैनवास पर भिन्न को देखें। काटने के बाद, हमारे पास ऊपर 2 खत्म हो जाते हैं, लेकिन नीचे अभी भी तीन 2 बचे हैं।\n\nइसलिए, 2<sup>-3</sup> बिल्कुल 1 / 2<sup>3</sup> के समान है।\n\n<b>व्युत्क्रम नियम:</b>\n\na<sup>-n</sup> = 1 / a<sup>n</sup>",
          'hud':
              "यह देखने के लिए कि बचे हुए ब्लॉक कहाँ जाते हैं, ब्लॉकों को रद्द करें।",
          'btn': "समान ब्लॉक रद्द करें",
          'success': "वे नीचे ही रहे! ऋणात्मक घातांक का अर्थ है भिन्न।",
        },
        {
          'dropdown': "चरण 5: समीकरण निर्माता (Quiz)",
          'theory':
              "<b>अपने ज्ञान का परीक्षण करें</b>\n\nआपने आज तीन प्रमुख नियमों की खोज कीান্তর खोज की है:\n\n1. विभाजन नियम: a<sup>m</sup> ÷ a<sup>n</sup> = a<sup>m-n</sup>\n2. शून्य नियम: a<sup>0</sup> = 1\n3. ऋणात्मक नियम: a<sup>-n</sup> = 1 / a<sup>n</sup>\n\nअब, चॉकबोर्ड का सामना करें। लैब को पूरा करने के लिए रैपिड-फायर प्रश्नों को हल करें।",
          'hud': "चॉकबोर्ड पर सही उत्तर चुनें।",
          'success': "सभी सही! आपने घातांक के नियमों में महारत हासिल कर ली है।",
        },
      ],
      'quiz': [
        {
          'q': "7<sup>6</sup> ÷ 7<sup>6</sup> = ?",
          'options': ["0", "1", "7", "7<sup>1</sup>"],
          'ans': "1",
          'full': "7^{6-6} = 7^0 = 1",
        },
        {
          'q': "4<sup>3</sup> ÷ 4<sup>5</sup> = ?",
          'options': ["4<sup>2</sup>", "4<sup>-2</sup>", "1", "-4<sup>2</sup>"],
          'ans': "4<sup>-2</sup>",
          'full': "4^{3-5} = 4^{-2} = \\frac{1}{4^2}",
        },
        {
          'q': "x<sup>2</sup> × x<sup>-5</sup> = ?",
          'options': [
            "x<sup>-3</sup>",
            "x<sup>3</sup>",
            "x<sup>-10</sup>",
            "1",
          ],
          'ans': "x<sup>-3</sup>",
          'full': "x^{2+(-5)} = x^{-3}",
        },
      ],
    },
  };

  String t(String key) => i18n[currentLang]![key] as String;
  Map<String, dynamic> tStep(int index) =>
      (i18n[currentLang]!['steps'] as List)[index];
  List<dynamic> tQuiz() => i18n[currentLang]!['quiz'] as List;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _actionAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cancelAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _actionAnimController.dispose();
    _cancelAnimController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // Helper for Sound Playback
  Future<void> _playSound(String url) async {
    try {
      await _audioPlayer.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio play error: $e");
    }
  }

  void _loadScenario(int index) {
    setState(() {
      currentStep = index;
      isTaskComplete = false;
      showSuccessToast = false;

      // Automatically collapse sidebar when the Quiz step starts
      if (index == 4) {
        leftSidebarOpen = false;
      }

      // Reset State Variables
      s1Grouped = false;
      s2Cancelled = false;
      s3Cancelled = false;
      s4Cancelled = false;

      if (index == 4) {
        quizProgress = 0;
        quizFeedback = "";
      }

      _actionAnimController.reset();
      _cancelAnimController.reset();
    });
  }

  void _checkValidation() {
    bool passed = false;
    switch (currentStep) {
      case 0:
        passed = s1Grouped;
        break;
      case 1:
        passed = s2Cancelled;
        break;
      case 2:
        passed = s3Cancelled;
        break;
      case 3:
        passed = s4Cancelled;
        break;
      case 4:
        passed = quizProgress >= tQuiz().length;
        break;
    }

    if (passed && !isTaskComplete) {
      setState(() {
        isTaskComplete = true;
        showSuccessToast = true;
      });
      _playSound(successSound); // Play achievement sound on step complete

      // Auto-hide the success toast after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            showSuccessToast = false;
          });
        }
      });
    }
  }

  // --- Task Actions ---
  void _triggerS1Group() {
    _playSound(tapSound);
    setState(() {
      s1Grouped = true;
    });
    _actionAnimController.forward();
    _checkValidation();
  }

  void _triggerCancel() {
    _playSound(tapSound);
    setState(() {
      if (currentStep == 1) s2Cancelled = true;
      if (currentStep == 2) s3Cancelled = true;
      if (currentStep == 3) s4Cancelled = true;
    });
    _cancelAnimController.forward();
    _checkValidation();
  }

  void _handleQuizAnswer(String selectedOption, String correctOption) {
    if (selectedOption == correctOption) {
      _playSound(successSound);
      setState(() {
        quizFeedback = "Correct!";
      });
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        setState(() {
          quizProgress++;
          quizFeedback = "";
          _checkValidation();
        });
      });
    } else {
      _playSound(errorSound);
      setState(() {
        quizFeedback = "Incorrect, try again!";
      });
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        setState(() => quizFeedback = "");
      });
    }
  }

  void _nextStep() {
    _playSound(tapSound);
    if (currentStep < 4) {
      _loadScenario(currentStep + 1);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t('quizDone'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.greenAccent,
            ),
          ),
          backgroundColor: Colors.blueGrey.shade900,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadScenario(0);
    }
  }

  // --- Shared Reusable Buttons ---
  Widget _buildActionButton(Map<String, dynamic> stepData) {
    if (currentStep == 0) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.group_work),
        label: Text(stepData['btn'] ?? ''),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: s1Grouped ? null : _triggerS1Group,
      );
    } else if (currentStep >= 1 && currentStep <= 3) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.cancel),
        label: Text(stepData['btn'] ?? ''),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Colors.red.shade500,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed:
            (currentStep == 1 && s2Cancelled) ||
                (currentStep == 2 && s3Cancelled) ||
                (currentStep == 3 && s4Cancelled)
            ? null
            : _triggerCancel,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildNextButton() {
    return ElevatedButton.icon(
      icon: Icon(isTaskComplete ? Icons.arrow_forward : Icons.lock_outline),
      label: Text(
        isTaskComplete ? t('btnValidate') : t('btnTaskFirst'),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isTaskComplete
            ? Colors.amber.shade500
            : Colors.blueGrey.shade800,
        foregroundColor: isTaskComplete ? Colors.black : Colors.white54,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: isTaskComplete ? _nextStep : null,
    );
  }

  // --- UI Building ---
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Determine a safe sidebar width that fits the header properly (min 320 for safety)
    final sidebarWidth = math.max(screenWidth * 0.3, 320.0);

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () =>
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
        child: Stack(
          children: [
            // Background Layer
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [Color(0xFF0f172a), Color(0xFF020617)],
                    stops: [0.0, 1.0],
                  ),
                ),
              ),
            ),

            // Grid lines Layer
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(painter: GridPainter()),
              ),
            ),

            // Main Canvas Area (Full Screen, but adjusted visual center for sidebar later)
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildCanvasArea(isSidebarOpen: leftSidebarOpen),
            ),

            // Floating Mission Card (Revealed underneath the sidebar when it collapses)
            Positioned(top: 80, left: 16, child: _buildFloatingMissionCard()),

            // Left Sidebar Overlay
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: leftSidebarOpen ? 0 : -sidebarWidth,
              width: sidebarWidth,
              child: Material(
                elevation: 16,
                color: Colors.transparent,
                child: _buildLeftSidebar(),
              ),
            ),

            // Floating Controls (Fixed position, highest z-index rendering after sidebar)
            Positioned(
              top: 16,
              left: 16,
              child: Material(
                elevation: 8,
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1e293b).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueGrey.shade700),
                    boxShadow: const [
                      BoxShadow(color: Colors.black45, blurRadius: 8),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          leftSidebarOpen ? Icons.menu_open : Icons.menu,
                        ),
                        color: Colors.amberAccent,
                        onPressed: () {
                          _playSound(tapSound);
                          setState(() => leftSidebarOpen = !leftSidebarOpen);
                        },
                        tooltip: leftSidebarOpen
                            ? 'Collapse Menu'
                            : 'Open Menu',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Task Status Toast (Scrollable and Floating Front)
            if (showSuccessToast && currentStep < 4)
              Positioned(
                top: 24,
                left: leftSidebarOpen
                    ? sidebarWidth + 20
                    : 350, // Pushed right to clear floating mission card
                right: 20,
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      border: Border.all(color: Colors.greenAccent),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 10),
                      ],
                    ),
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        // FIX: Replaced standard Text widget with _parseRichMathText so <sup> tags are rendered
                        child: _parseRichMathText(
                          "<b>${tStep(currentStep)['success']}</b>",
                          color: Colors.greenAccent,
                          center: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Curtain Raiser (Highest z-index)
            if (showCurtain) Positioned.fill(child: _buildCurtainRaiser()),
          ],
        ),
      ),
    );
  }

  // Floating Mission Card shown when Sidebar is collapsed
  Widget _buildFloatingMissionCard() {
    Map<String, dynamic> stepData = tStep(currentStep);

    // Determine whether the card should be shown.
    // It should ONLY be shown if the sidebar is closed, curtain is up, AND we are NOT on the quiz step.
    bool isQuizStep = currentStep == 4;
    bool shouldShowCard = !leftSidebarOpen && !showCurtain && !isQuizStep;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 280),
      opacity: shouldShowCard ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: !shouldShowCard, // Ignore touches when invisible
        child: Container(
          width: 280,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height - 80,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1e293b).withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blueGrey.shade700),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(
                      Icons.track_changes,
                      color: Colors.amberAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        stepData['dropdown'].toString().toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Instructions
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blueGrey.shade800),
                  ),
                  child: _parseRichMathText(
                    stepData['hud'],
                    color: Colors.amberAccent,
                    fontSize: 13,
                    center: true,
                  ),
                ),
                const SizedBox(height: 16),

                // Dynamic Action Buttons
                _buildActionButton(stepData),
                if (currentStep < 4) const SizedBox(height: 12),

                // Next/Validate Button
                _buildNextButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // The Header content integrated into the Sidebar with appropriate top padding to clear the Floating Controls
  Widget _buildSidebarHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        70,
        20,
        20,
      ), // Top padding leaves space for floating controls
      decoration: BoxDecoration(
        color: const Color(0xFF0f172a).withOpacity(0.95),
        border: Border(bottom: BorderSide(color: Colors.blueGrey.shade800)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & Subtitle Row with Language & Reset
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.superscript,
                  color: Colors.amberAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('title'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t('subtitle'),
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Language and Reset right under title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1e293b),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blueGrey.shade700),
                          ),
                          padding: const EdgeInsets.all(2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: ['en', 'hi'].map((lang) {
                              bool isActive = currentLang == lang;
                              return GestureDetector(
                                onTap: () {
                                  _playSound(tapSound);
                                  setState(() => currentLang = lang);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Colors.amber.shade700
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    lang.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isActive
                                          ? Colors.black
                                          : Colors.white54,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        IconButton(
                          iconSize: 28,
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            _playSound(tapSound);
                            setState(() {
                              showCurtain = true;
                              leftSidebarOpen = true;
                            });
                            _loadScenario(0);
                          },
                          tooltip: 'Reset Activity',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeftSidebar() {
    Map<String, dynamic> stepData = tStep(currentStep);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b).withOpacity(0.95),
        border: Border(right: BorderSide(color: Colors.blueGrey.shade800)),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 15, spreadRadius: 2),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Render the integrated header at the very top of the scrollable area
                    _buildSidebarHeader(),

                    // Dropdown Step Selector
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0f172a),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blueGrey.shade700),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            dropdownColor: const Color(0xFF0f172a),
                            isExpanded: true,
                            value: currentStep,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            items: List.generate(5, (index) {
                              return DropdownMenuItem(
                                value: index,
                                child: Text(tStep(index)['dropdown']),
                              );
                            }),
                            onChanged: (v) {
                              if (v != null) {
                                _playSound(tapSound);
                                _loadScenario(v);
                              }
                            },
                          ),
                        ),
                      ),
                    ),

                    // Expandable Area for Theory, HUD Output, Buttons (pushes footer to bottom)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Theory Section
                            _parseRichMathText(stepData['theory']),

                            const SizedBox(height: 24),
                            const Divider(color: Colors.white24, thickness: 1),
                            const SizedBox(height: 20),

                            // Target HUD Output Instructions
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blueGrey.shade800,
                                ),
                              ),
                              child: _parseRichMathText(
                                stepData['hud'],
                                color: Colors.amberAccent,
                                fontSize: 13,
                                center: true,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Dynamic Controls / Action Buttons (Extracted to reusable method)
                            _buildActionButton(stepData),
                            if (currentStep < 4) const SizedBox(height: 32),

                            // Validate / Next Button (Extracted to reusable method)
                            _buildNextButton(),
                          ],
                        ),
                      ),
                    ),

                    // Required Copyright Footer included at end of scrollable content
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        border: Border(
                          top: BorderSide(color: Colors.blueGrey.shade900),
                        ),
                      ),
                      child: const Text(
                        "© ZeroScienceLab - Fall in love with math and Science",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCanvasArea({required bool isSidebarOpen}) {
    return Stack(
      children: [
        // 2D Visual Engine Painter wrapped in InteractiveViewer for Canvas Zoom
        if (currentStep < 4)
          Positioned.fill(
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(double.infinity),
              minScale: 0.2,
              maxScale: 4.0,
              panEnabled: true,
              scaleEnabled: true,
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _actionAnimController,
                  _cancelAnimController,
                ]),
                builder: (context, child) {
                  return CustomPaint(
                    size: Size.infinite,
                    painter: FractionBlockPainter(
                      step: currentStep,
                      s1Grouped: s1Grouped,
                      s2Cancelled: s2Cancelled,
                      s3Cancelled: s3Cancelled,
                      s4Cancelled: s4Cancelled,
                      groupAnimValue: _actionAnimController.value,
                      cancelAnimValue: _cancelAnimController.value,
                      isSidebarOpen: isSidebarOpen,
                    ),
                  );
                },
              ),
            ),
          ),

        // Step 4 (Index 4): Chalkboard Quiz
        if (currentStep == 4) _buildChalkboardQuiz(),
      ],
    );
  }

  Widget _buildChalkboardQuiz() {
    if (quizProgress >= tQuiz().length) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 80),
            const SizedBox(height: 20),
            Text(
              t('quizDone'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    final qData = tQuiz()[quizProgress];

    return Center(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade900,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.blueGrey.shade600, width: 4),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _parseRichMathText(
              "Question ${quizProgress + 1} of ${tQuiz().length}",
              color: Colors.white54,
              fontSize: 14,
            ),
            const SizedBox(height: 20),
            _parseRichMathText(
              qData['q'],
              color: Colors.amberAccent,
              fontSize: 32,
              center: true,
            ),
            const SizedBox(height: 40),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: (qData['options'] as List).map((opt) {
                return InkWell(
                  onTap: () => _handleQuizAnswer(opt, qData['ans']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade800,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.withOpacity(0.5)),
                    ),
                    child: _parseRichMathText(
                      opt,
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            Text(
              quizFeedback,
              style: TextStyle(
                color: quizFeedback == "Correct!"
                    ? Colors.greenAccent
                    : Colors.redAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurtainRaiser() {
    return AnimatedOpacity(
      opacity: showCurtain ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 800),
      onEnd: () {
        if (!showCurtain) setState(() {});
      },
      child: Container(
        color: const Color(0xFF020617),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.superscript, color: Colors.amber, size: 80),
            const SizedBox(height: 20),
            Text(
              t('subtitle').toUpperCase(),
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
                letterSpacing: 3,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              t('title'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_circle_fill),
              label: Text(
                t('enterLab'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                _playSound(tapSound);
                setState(() => showCurtain = false);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                backgroundColor: Colors.amber.shade600,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to parse pseudo-HTML and pseudo-Math into RichText
  Widget _parseRichMathText(
    String text, {
    Color color = Colors.white70,
    double fontSize = 14,
    bool center = false,
  }) {
    List<InlineSpan> spans = [];

    final RegExp tagExp = RegExp(r'(<b>|</b>|<i>|</i>|<sup>|</sup>)');
    Iterable<Match> matches = tagExp.allMatches(text);

    int lastMatchEnd = 0;
    bool isBold = false;
    bool isItalic = false;
    bool isSup = false;

    void addSpan(String content) {
      if (content.isEmpty) return;

      TextStyle style = TextStyle(
        color: color,
        fontSize: fontSize,
        height: 1.6,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
      );

      if (isSup) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.top,
            child: Transform.translate(
              offset: Offset(0, -fontSize * 0.4), // shift up
              child: Text(
                content,
                style: style.copyWith(fontSize: fontSize * 0.7),
              ),
            ),
          ),
        );
      } else {
        spans.add(TextSpan(text: content, style: style));
      }
    }

    for (Match match in matches) {
      addSpan(text.substring(lastMatchEnd, match.start));
      String tag = match.group(0)!;
      if (tag == '<b>') {
        isBold = true;
      } else if (tag == '</b>') {
        isBold = false;
      } else if (tag == '<i>') {
        isItalic = true;
      } else if (tag == '</i>') {
        isItalic = false;
      } else if (tag == '<sup>') {
        isSup = true;
      } else if (tag == '</sup>') {
        isSup = false;
      }
      lastMatchEnd = match.end;
    }
    addSpan(text.substring(lastMatchEnd));

    return RichText(
      textAlign: center ? TextAlign.center : TextAlign.left,
      text: TextSpan(children: spans),
    );
  }
}

// --- Visual Engine Custom Painter ---
class FractionBlockPainter extends CustomPainter {
  final int step;
  final bool s1Grouped;
  final bool s2Cancelled;
  final bool s3Cancelled;
  final bool s4Cancelled;
  final double groupAnimValue;
  final double cancelAnimValue;
  final bool isSidebarOpen;

  FractionBlockPainter({
    required this.step,
    required this.s1Grouped,
    required this.s2Cancelled,
    required this.s3Cancelled,
    required this.s4Cancelled,
    required this.groupAnimValue,
    required this.cancelAnimValue,
    required this.isSidebarOpen,
  });

  void _drawBlock(
    Canvas canvas,
    Offset pos,
    String text, {
    double scale = 1.0,
    double opacity = 1.0,
  }) {
    if (opacity <= 0) return;

    Paint bg = Paint()..color = Colors.blueAccent.withOpacity(0.8 * opacity);
    Paint border = Paint()
      ..color = Colors.cyanAccent.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    Rect rect = Rect.fromCenter(
      center: pos,
      width: 50 * scale,
      height: 50 * scale,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(8 * scale)),
      bg,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(8 * scale)),
      border,
    );

    // Text
    TextSpan span = TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.white.withOpacity(opacity),
        fontSize: 24 * scale,
        fontWeight: FontWeight.bold,
      ),
    );
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawFractionLine(Canvas canvas, Offset center, double length) {
    Paint line = Paint()
      ..color = Colors.amber
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center - Offset(length / 2, 0),
      center + Offset(length / 2, 0),
      line,
    );
  }

  void _drawStrike(Canvas canvas, Offset pos, double progress) {
    if (progress <= 0) return;
    Paint strike = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    double l = 30 * progress;
    canvas.drawLine(pos - Offset(l, l), pos + Offset(l, l), strike);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Dynamically adjust center if left sidebar is overlaying
    double centerXMod = isSidebarOpen ? 0.65 : 0.5;
    Offset center = Offset(size.width * centerXMod, size.height * 0.5);

    if (step == 0) {
      // Multiplication: 2^2 x 2^3
      double spacing = 60;
      if (!s1Grouped) {
        // Show 2 groups
        _drawBlock(canvas, center + Offset(-spacing * 2, 0), "2");
        _drawBlock(canvas, center + Offset(-spacing, 0), "2");

        TextSpan span = const TextSpan(
          text: "×",
          style: TextStyle(
            color: Colors.white54,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        );
        TextPainter tp = TextPainter(
          text: span,
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));

        _drawBlock(canvas, center + Offset(spacing, 0), "2");
        _drawBlock(canvas, center + Offset(spacing * 2, 0), "2");
        _drawBlock(canvas, center + Offset(spacing * 3, 0), "2");
      } else {
        // Explode into 5 group
        double spread = 1.0 - (groupAnimValue * 0.2); // slight contraction
        for (int i = 0; i < 5; i++) {
          _drawBlock(
            canvas,
            center + Offset((i - 2) * spacing * spread, 0),
            "2",
          );
        }

        if (groupAnimValue == 1.0) {
          TextSpan span = const TextSpan(
            text: "= 2⁵",
            style: TextStyle(
              color: Colors.amber,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          );
          TextPainter tp = TextPainter(
            text: span,
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(canvas, center + Offset(0, 80) - Offset(tp.width / 2, 0));
        }
      }
    } else if (step >= 1 && step <= 3) {
      // Division Modes
      int nTop = 5;
      int nBot = 3;
      if (step == 2) {
        nTop = 3;
        nBot = 3;
      }
      if (step == 3) {
        nTop = 2;
        nBot = 5;
      }

      double spacing = 60;
      double yOffset = 50;

      // Draw Fraction Line
      double lineLength = math.max(nTop, nBot) * spacing + 40;
      _drawFractionLine(canvas, center, lineLength);

      int cancelCount = math.min(nTop, nBot);

      // Calculate opacity and scale based on cancel animation
      double remainingOpacity = 1.0 - cancelAnimValue;
      if (remainingOpacity < 0) remainingOpacity = 0;

      // Draw Top Blocks
      for (int i = 0; i < nTop; i++) {
        double x = (i - (nTop - 1) / 2) * spacing;
        Offset pos = center + Offset(x, -yOffset);
        bool isCancelled = i < cancelCount;

        double op = isCancelled ? remainingOpacity : 1.0;
        _drawBlock(canvas, pos, "2", opacity: op);
        if (isCancelled && cancelAnimValue > 0 && cancelAnimValue < 1) {
          _drawStrike(
            canvas,
            pos,
            cancelAnimValue * 2 > 1 ? 1 : cancelAnimValue * 2,
          );
        }
      }

      // Draw Bottom Blocks
      for (int i = 0; i < nBot; i++) {
        double x = (i - (nBot - 1) / 2) * spacing;
        Offset pos = center + Offset(x, yOffset);
        bool isCancelled = i < cancelCount;

        double op = isCancelled ? remainingOpacity : 1.0;
        _drawBlock(canvas, pos, "2", opacity: op);
        if (isCancelled && cancelAnimValue > 0 && cancelAnimValue < 1) {
          _drawStrike(
            canvas,
            pos,
            cancelAnimValue * 2 > 1 ? 1 : cancelAnimValue * 2,
          );
        }
      }

      // Special cases when fully cancelled
      if (cancelAnimValue == 1.0) {
        if (step == 2) {
          // Zero Exponent -> Everything is 1
          TextSpan span = const TextSpan(
            text: "1",
            style: TextStyle(
              color: Colors.amber,
              fontSize: 80,
              fontWeight: FontWeight.bold,
            ),
          );
          TextPainter tp = TextPainter(
            text: span,
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
        } else if (step == 1) {
          // Left with 2^2 on top
          TextSpan span = const TextSpan(
            text: "= 2²",
            style: TextStyle(
              color: Colors.amber,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          );
          TextPainter tp = TextPainter(
            text: span,
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(canvas, center + Offset(lineLength / 2 + 20, -20));
        } else if (step == 3) {
          // Left with 2^3 on bottom
          TextSpan span1 = const TextSpan(
            text: "1",
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          );
          TextPainter tp1 = TextPainter(
            text: span1,
            textDirection: TextDirection.ltr,
          )..layout();
          tp1.paint(canvas, center + Offset(0, -yOffset - tp1.height / 2));

          TextSpan span = const TextSpan(
            text: "= 2⁻³",
            style: TextStyle(
              color: Colors.amber,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          );
          TextPainter tp = TextPainter(
            text: span,
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(canvas, center + Offset(lineLength / 2 + 20, -20));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant FractionBlockPainter oldDelegate) {
    return oldDelegate.s1Grouped != s1Grouped ||
        oldDelegate.s2Cancelled != s2Cancelled ||
        oldDelegate.groupAnimValue != groupAnimValue ||
        oldDelegate.cancelAnimValue != cancelAnimValue ||
        oldDelegate.isSidebarOpen != isSidebarOpen ||
        oldDelegate.step != step;
  }
}

// Background Grid Painter
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blueGrey.shade800
      ..strokeWidth = 1.0;

    double step = 40;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
