// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class DivisibilityProofsLab extends StatefulWidget {
  const DivisibilityProofsLab({Key? key}) : super(key: key);

  @override
  State<DivisibilityProofsLab> createState() => _DivisibilityProofsLabState();
}

class _DivisibilityProofsLabState extends State<DivisibilityProofsLab>
    with TickerProviderStateMixin {
  // --- UI State ---
  bool _showCurtain = true;
  bool _isSidebarOpen = true;
  bool _isDarkTheme = true;
  int _currentStep = 0;
  String _currentLang = 'en';
  final double _teacherFontSize = 16.0;

  // --- Interaction State ---
  String? _feedbackMessage;
  bool _feedbackIsSuccess = true;
  bool _interactionCompleted = false;

  // Step Interactions
  bool _step1Expanded = false;
  int _step2SelectedAnswer = -1;
  int _step3SelectedAnswer = -1;
  int _step4SelectedAnswer = -1;

  // --- Animations & Audio ---
  late AnimationController _curtainController;
  late Animation<Offset> _curtainAnimation;
  late AnimationController _expansionController;
  late AudioPlayer _audioPlayer;

  // --- Localization Data ---
  final Map<String, Map<String, dynamic>> _translations = {
    'en': {
      'langCode': 'EN',
      'titleMain': 'Proofs of Divisibility',
      'chapterMain': 'Class 8 • Playing with Numbers',
      'enterBtn': 'Enter Virtual Lab',
      'teacherTitle': 'Mission Objective',
      'targetOutput': 'Target Output',
      'proceedBtn': 'Proceed to Next Step',
      'validateBtn': 'Verify Logic',
      'restartBtn': 'Restart Activity',
      'activeStep': 'Current Investigation',
      'toastSuccess': 'Excellent! Logic Validated.',
      'toastError': 'Incorrect. Review the theory and try again.',
      'selectWarn': 'Please make a selection in the HUD.',
      'steps': [
        {
          'title': 'Step 1: Algebraic Foundation',
          'theory':
              "Welcome to Concept 3. To prove divisibility rules, we must first translate numbers into algebra.\n\nTake any 2-digit number 'ab'. The 'a' is in the tens place, and the 'b' is in the units place.\n\nMathematically, the value of this number is 10a + b.",
          'hudTitle': 'Equation Expansion',
          'hudInstruction':
              "Tap 'Expand Equation' to visualize 'ab' as an algebraic expression.",
          'btnText': 'Expand Equation',
        },
        {
          'title': 'Step 2: The Rule of 2',
          'theory':
              "Let's prove the divisibility rule for 2 using our algebraic form: 10a + b.\n\nLook at the first term, 10a. Since 10 is an even number (divisible by 2), 10a will ALWAYS be divisible by 2, regardless of what 'a' is.\n\nTherefore, we only need to look at the second term.",
          'hudTitle': 'Logical Deduction',
          'hudInstruction':
              "Which part of the equation entirely determines if the whole number is divisible by 2?",
          'options': ['a', '10a', 'b'],
          'correctIdx': 2,
        },
        {
          'title': 'Step 3: The Rule of 9',
          'theory':
              "Let's prove the rule for 9. We rewrite 10a + b cleverly as:\n\n(9a + a) + b\n\nRearranging the terms gives us: 9a + (a + b).\nThe term '9a' is explicitly a multiple of 9, so it is always divisible by 9. We only need to check the remainder: (a + b).",
          'hudTitle': 'Identify the Rule',
          'hudInstruction':
              "What does the expression (a + b) represent in the original number 'ab'?",
          'options': ['Product of Digits', 'Difference', 'Sum of Digits'],
          'correctIdx': 2,
        },
        {
          'title': 'Step 4: Challenge - Rule of 4',
          'theory':
              "Let's apply this thinking to a 3-digit number 'abc'. Its form is 100a + 10b + c.\n\nWe want to test for divisibility by 4. Look at the first term, 100a. Since 100 ÷ 4 = 25 exactly, 100a is ALWAYS divisible by 4.\n\nWhat terms are left over to check?",
          'hudTitle': 'Rule of 4 Challenge',
          'hudInstruction':
              "Based on the algebraic proof, which part determines divisibility by 4?",
          'options': ['a + b + c', '10b + c', 'c'],
          'correctIdx': 1,
        },
      ],
    },
    'hi': {
      'langCode': 'HI',
      'titleMain': 'विभाज्यता के नियम (प्रमाण)',
      'chapterMain': 'कक्षा 8 • संख्याओं के साथ खेलना',
      'enterBtn': 'वर्चुअल लैब में प्रवेश करें',
      'teacherTitle': 'मिशन का उद्देश्य',
      'targetOutput': 'लक्षित आउटपुट',
      'proceedBtn': 'अगले चरण पर जाएँ',
      'validateBtn': 'तर्क सत्यापित करें',
      'restartBtn': 'गतिविधि पुनः आरंभ करें',
      'activeStep': 'वर्तमान अन्वेषण',
      'toastSuccess': 'उत्कृष्ट! तर्क मान्य।',
      'toastError': 'गलत। सिद्धांत की समीक्षा करें और पुनः प्रयास करें।',
      'selectWarn': 'कृपया HUD में एक विकल्प चुनें।',
      'steps': [
        {
          'title': 'चरण 1: बीजीय आधार',
          'theory':
              "कांसेप्ट 3 में आपका स्वागत है। विभाज्यता नियमों को सिद्ध करने के लिए, हमें पहले संख्याओं को बीजगणित में बदलना होगा।\n\nकोई भी 2-अंकीय संख्या 'ab' लें। 'a' दहाई के स्थान पर है, और 'b' इकाई के स्थान पर है।\n\nगणितीय रूप से, इस संख्या का मान 10a + b है।",
          'hudTitle': 'समीकरण का विस्तार',
          'hudInstruction':
              "'ab' को बीजीय व्यंजक के रूप में देखने के लिए 'समीकरण का विस्तार करें' पर टैप करें।",
          'btnText': 'समीकरण का विस्तार करें',
        },
        {
          'title': 'चरण 2: 2 का नियम',
          'theory':
              "आइए अपने बीजीय रूप का उपयोग करके 2 के लिए विभाज्यता नियम सिद्ध करें: 10a + b।\n\nपहले पद, 10a को देखें। चूंकि 10 एक सम संख्या है (2 से विभाज्य है), 10a हमेशा 2 से विभाज्य होगा, चाहे 'a' कुछ भी हो।\n\nइसलिए, हमें केवल दूसरे पद को देखने की आवश्यकता है।",
          'hudTitle': 'तार्किक कटौती',
          'hudInstruction':
              "समीकरण का कौन सा भाग पूरी तरह से यह निर्धारित करता है कि पूरी संख्या 2 से विभाज्य है या नहीं?",
          'options': ['a', '10a', 'b'],
          'correctIdx': 2,
        },
        {
          'title': 'चरण 3: 9 का नियम',
          'theory':
              "आइए 9 के नियम को सिद्ध करें। हम चतुराई से 10a + b को फिर से लिखते हैं:\n\n(9a + a) + b\n\nपदों को पुनर्व्यवस्थित करने पर हमें प्राप्त होता है: 9a + (a + b)।\nपद '9a' स्पष्ट रूप से 9 का गुणज है, इसलिए यह हमेशा 9 से विभाज्य होता है। हमें केवल शेष की जांच करनी है: (a + b)।",
          'hudTitle': 'नियम की पहचान करें',
          'hudInstruction':
              "मूल संख्या 'ab' में व्यंजक (a + b) क्या दर्शाता है?",
          'options': ['अंकों का गुणनफल', 'अंतर', 'अंकों का योग'],
          'correctIdx': 2,
        },
        {
          'title': 'चरण 4: चुनौती - 4 का नियम',
          'theory':
              "आइए इस सोच को 3-अंकीय संख्या 'abc' पर लागू करें। इसका रूप 100a + 10b + c है।\n\nहम 4 से विभाज्यता का परीक्षण करना चाहते हैं। पहले पद, 100a को देखें। चूँकि 100 ÷ 4 = 25 सटीक रूप से होता है, 100a हमेशा 4 से विभाज्य होता है।\n\nजाँचने के लिए कौन से पद बचे हैं?",
          'hudTitle': '4 की चुनौती का नियम',
          'hudInstruction':
              "बीजीय प्रमाण के आधार पर, कौन सा भाग 4 से विभाज्यता निर्धारित करता है?",
          'options': ['a + b + c', '10b + c', 'c'],
          'correctIdx': 1,
        },
      ],
    },
  };

  // --- Safe Map Accessors ---
  Map<String, dynamic> get t =>
      _translations[_currentLang] ?? _translations['en']!;
  Map<String, dynamic> get currentScenario {
    final steps = t['steps'] as List?;
    if (steps != null && _currentStep >= 0 && _currentStep < steps.length) {
      return steps[_currentStep] as Map<String, dynamic>;
    }
    return {};
  }

  String _getString(String key) => t[key]?.toString() ?? '';
  String _getStepString(String key) => currentScenario[key]?.toString() ?? '';

  List<String> get _currentOptions {
    final opts = currentScenario['options'] as List?;
    return opts?.map((e) => e.toString()).toList() ?? [];
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _audioPlayer = AudioPlayer();

    _curtainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _curtainAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1.0)).animate(
          CurvedAnimation(
            parent: _curtainController,
            curve: Curves.easeInOutCubic,
          ),
        );

    _expansionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _curtainController.dispose();
    _expansionController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playSound(String type) async {
    try {
      String url = '';
      if (type == 'success') {
        url =
            'audio/class8/mixkit_2013.mp3';
      } else if (type == 'error') {
        url =
            'audio/class8/mixkit_2954.mp3';
      } else if (type == 'tap') {
        url =
            'audio/class8/mixkit_2568.mp3';
      }

      if (url.isNotEmpty) {
        await _audioPlayer.play(AssetSource(url));
      }
    } catch (e) {
      debugPrint("Audio play failed: $e");
    }
  }

  void _enterLab() {
    _playSound('success');
    _curtainController.forward().then((_) {
      setState(() => _showCurtain = false);
    });
  }

  void _loadScenario(int step) {
    setState(() {
      _currentStep = step;
      _feedbackMessage = null;
      _interactionCompleted = false;

      // Reset step states
      _step1Expanded = false;
      _expansionController.reset();
      _step2SelectedAnswer = -1;
      _step3SelectedAnswer = -1;
      _step4SelectedAnswer = -1;
    });
  }

  void _showFeedback(String msg, bool success) {
    _playSound(success ? 'success' : 'error');
    setState(() {
      _feedbackMessage = msg;
      _feedbackIsSuccess = success;
      if (success) _interactionCompleted = true;
    });
  }

  // --- Interaction Validation ---

  void _validateInvestigation() {
    if (_currentStep == 0) {
      if (!_step1Expanded) {
        _showFeedback(_getString('selectWarn'), false);
      }
    } else if (_currentStep == 1) {
      _evaluateMCQ(_step2SelectedAnswer);
    } else if (_currentStep == 2) {
      _evaluateMCQ(_step3SelectedAnswer);
    } else if (_currentStep == 3) {
      _evaluateMCQ(_step4SelectedAnswer);
    }
  }

  void _evaluateMCQ(int answerIndex) {
    if (answerIndex == -1) {
      _showFeedback(_getString('selectWarn'), false);
      return;
    }
    int correctIdx = currentScenario['correctIdx'] as int? ?? -1;
    if (answerIndex == correctIdx) {
      _showFeedback(_getString('toastSuccess'), true);
    } else {
      _showFeedback(_getString('toastError'), false);
    }
  }

  void _handleStep1Expand() {
    if (_interactionCompleted) return;
    _playSound('tap');
    setState(() => _step1Expanded = true);
    _expansionController.forward();
    _showFeedback(_getString('toastSuccess'), true);
  }

  void _handleMCQChoice(int answerIndex) {
    if (_interactionCompleted) return;
    _playSound('tap');

    setState(() {
      if (_currentStep == 1) _step2SelectedAnswer = answerIndex;
      if (_currentStep == 2) _step3SelectedAnswer = answerIndex;
      if (_currentStep == 3) _step4SelectedAnswer = answerIndex;
    });

    _validateInvestigation();
  }

  // --- UI Builders ---

  Color get bgBase =>
      _isDarkTheme ? const Color(0xFF020617) : const Color(0xFFF1F5F9);
  Color get bgPanel =>
      _isDarkTheme ? const Color(0xD90F172A) : const Color(0xD9FFFFFF);
  Color get textBase =>
      _isDarkTheme ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  Color get textMuted =>
      _isDarkTheme ? const Color(0xFF94A3B8) : const Color(0xFF475569);
  Color get borderPanel => _isDarkTheme ? Colors.white24 : Colors.black12;

  Widget _buildGlassPanel({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgPanel.withOpacity(0.85),
        border: Border.all(color: borderPanel),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: child,
    );
  }

  Widget _buildMainActionButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: _interactionCompleted ? Colors.green : Colors.amber,
        foregroundColor: _interactionCompleted ? Colors.white : Colors.black,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        _playSound('tap');
        if (!_interactionCompleted) {
          _validateInvestigation();
        } else {
          if (_currentStep < 3) {
            _loadScenario(_currentStep + 1);
          } else {
            _loadScenario(0);
          }
        }
      },
      icon: Icon(
        _interactionCompleted
            ? (_currentStep == 3 ? Icons.refresh : Icons.arrow_forward)
            : Icons.verified,
      ),
      label: Text(
        _interactionCompleted
            ? (_currentStep == 3
                  ? _getString('restartBtn')
                  : _getString('proceedBtn'))
            : _getString('validateBtn'),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildHUDInteraction() {
    if (_currentStep == 0 && !_interactionCompleted) {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: _handleStep1Expand,
        icon: const Icon(Icons.compare_arrows),
        label: Text(
          _getStepString('btnText'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );
    } else if (_currentStep > 0) {
      List<String> options = _currentOptions;
      int currentAnswer = -1;
      if (_currentStep == 1) currentAnswer = _step2SelectedAnswer;
      if (_currentStep == 2) currentAnswer = _step3SelectedAnswer;
      if (_currentStep == 3) currentAnswer = _step4SelectedAnswer;
      int correctIdx = currentScenario['correctIdx'] as int? ?? -1;

      return Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: List.generate(options.length, (idx) {
          return _buildMCQBtn(
            idx,
            options[idx],
            currentAnswer,
            correctIdx,
            _handleMCQChoice,
          );
        }),
      );
    }
    return const SizedBox();
  }

  Widget _buildMCQBtn(
    int value,
    String text,
    int currentValue,
    int correctValue,
    Function(int) onTap,
  ) {
    bool isSelected = currentValue == value;
    return InkWell(
      onTap: _interactionCompleted ? null : () => onTap(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (value == correctValue ? Colors.green : Colors.redAccent)
              : (_isDarkTheme ? Colors.white10 : Colors.black12),
          border: Border.all(
            color: isSelected ? Colors.transparent : borderPanel,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : textBase,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveCanvas() {
    return Container(
      color: _isDarkTheme ? const Color(0xFF0B1120) : const Color(0xFFE2E8F0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          Size canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
          return Stack(
            alignment: Alignment.center,
            children: [
              // 2D Geometric Render Background
              CustomPaint(
                size: Size.infinite,
                painter: DivisibilityProofsPainter(isDark: _isDarkTheme),
              ),

              // Absolute HTML-like Overlays for Algebraic Equations
              ..._buildCanvasOverlays(canvasSize),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildCanvasOverlays(Size canvasSize) {
    List<Widget> overlays = [];
    final centerX = canvasSize.width / 2;
    final centerY = canvasSize.height / 2;

    Widget mathBlock(
      String text,
      double dx,
      double dy, {
      Color color = Colors.amber,
      double size = 32,
      Color borderColor = Colors.amber,
      Color bg = Colors.black87,
    }) {
      return Positioned(
        left: centerX + dx,
        top: centerY + dy,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(color: borderColor.withOpacity(0.3), blurRadius: 10),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: size,
              fontFamily: 'monospace',
            ),
          ),
        ),
      );
    }

    Widget plainText(
      String text,
      double dx,
      double dy, {
      Color color = Colors.white,
      double size = 20,
    }) {
      return Positioned(
        left: centerX + dx,
        top: centerY + dy,
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: size,
          ),
        ),
      );
    }

    if (_currentStep == 0) {
      if (!_step1Expanded) {
        overlays.add(
          mathBlock(
            "ab",
            -40,
            -40,
            size: 48,
            color: Colors.white,
            borderColor: Colors.white54,
          ),
        );
      } else {
        overlays.add(
          AnimatedBuilder(
            animation: _expansionController,
            builder: (context, child) {
              double expandAmt = _expansionController.value * 120;
              return Stack(
                children: [
                  mathBlock(
                    "10a",
                    -40 - expandAmt,
                    -40,
                    color: Colors.blueAccent,
                    borderColor: Colors.blueAccent,
                  ),
                  plainText("+", -10, -25, size: 36),
                  mathBlock(
                    "b",
                    10 + expandAmt,
                    -40,
                    color: Colors.greenAccent,
                    borderColor: Colors.greenAccent,
                  ),
                ],
              );
            },
          ),
        );
      }
    } else if (_currentStep == 1) {
      overlays.add(
        mathBlock(
          "10a",
          -100,
          -80,
          color: Colors.white,
          borderColor: Colors.white54,
          bg: Colors.transparent,
        ),
      );
      overlays.add(plainText("+", -10, -65, size: 32));
      overlays.add(
        mathBlock(
          "b",
          20,
          -80,
          color: Colors.white,
          borderColor: Colors.white54,
          bg: Colors.transparent,
        ),
      );

      if (_interactionCompleted) {
        overlays.add(
          mathBlock(
            "10a",
            -100,
            20,
            color: Colors.greenAccent,
            borderColor: Colors.greenAccent,
          ),
        );
        overlays.add(
          plainText(
            "Always ÷ 2",
            -120,
            90,
            color: Colors.greenAccent,
            size: 16,
          ),
        );
        overlays.add(
          mathBlock(
            "b",
            20,
            20,
            color: Colors.amber,
            borderColor: Colors.amber,
          ),
        );
        overlays.add(
          plainText("Determines Result!", 0, 90, color: Colors.amber, size: 16),
        );
      }
    } else if (_currentStep == 2) {
      overlays.add(
        mathBlock(
          "10a + b",
          -110,
          -140,
          size: 28,
          color: Colors.white54,
          borderColor: Colors.transparent,
          bg: Colors.transparent,
        ),
      );
      overlays.add(plainText("↓", -10, -90, size: 24, color: Colors.white54));
      overlays.add(
        mathBlock(
          "(9a + a) + b",
          -130,
          -50,
          size: 28,
          color: Colors.white,
          borderColor: Colors.white30,
          bg: Colors.transparent,
        ),
      );

      if (_interactionCompleted) {
        overlays.add(plainText("↓", -10, 20, size: 24, color: Colors.white54));
        overlays.add(
          mathBlock(
            "9a",
            -120,
            60,
            color: Colors.greenAccent,
            borderColor: Colors.greenAccent,
          ),
        );
        overlays.add(plainText("+", -35, 75, size: 28));
        overlays.add(
          mathBlock(
            "(a + b)",
            -10,
            60,
            color: Colors.amber,
            borderColor: Colors.amber,
          ),
        );
      }
    } else if (_currentStep == 3) {
      overlays.add(
        mathBlock(
          "100a + 10b + c",
          -150,
          -120,
          size: 28,
          color: Colors.white70,
          borderColor: Colors.white24,
          bg: Colors.transparent,
        ),
      );
      overlays.add(plainText("↓", -10, -60, size: 24, color: Colors.white54));

      if (_interactionCompleted) {
        overlays.add(
          mathBlock(
            "100a",
            -160,
            -10,
            color: Colors.greenAccent,
            borderColor: Colors.greenAccent,
          ),
        );
        overlays.add(plainText("+", -40, 5, size: 28));
        overlays.add(
          mathBlock(
            "(10b + c)",
            -15,
            -10,
            color: Colors.amber,
            borderColor: Colors.amber,
          ),
        );

        overlays.add(
          plainText(
            "Always ÷ 4",
            -150,
            70,
            color: Colors.greenAccent,
            size: 16,
          ),
        );
        overlays.add(
          plainText(
            "Check Last 2 Digits",
            -10,
            70,
            color: Colors.amber,
            size: 16,
          ),
        );
      } else {
        overlays.add(
          mathBlock(
            "100a + (10b + c)",
            -165,
            -10,
            size: 28,
            color: Colors.white,
            borderColor: Colors.white54,
          ),
        );
      }
    }

    return overlays;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double sideWidth = (screenWidth * 0.3).clamp(300.0, 450.0);

    return Scaffold(
      backgroundColor: bgBase,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () =>
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
        child: Stack(
          children: [
            // --- 1. Zoomable & Responsive Main Canvas ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: _isSidebarOpen ? sideWidth : 0,
              right: 0,
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                boundaryMargin: const EdgeInsets.all(double.infinity),
                child: _buildInteractiveCanvas(),
              ),
            ),

            // --- 2. Floating Mission Card (Visible when sidebar collapsed) ---
            if (!_isSidebarOpen)
              Positioned(
                top: 70,
                left: 20,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 250,
                    maxHeight: screenHeight * 1.0,
                  ),
                  child: _buildGlassPanel(
                    padding: EdgeInsets.zero,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.track_changes,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _getString('targetOutput'),
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _getStepString('hudInstruction'),
                            style: TextStyle(
                              color: textBase,
                              fontSize: _teacherFontSize,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildMainActionButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // --- 3. Scrollable HUD Success/Interaction Popup ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: 20,
              right: 20,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: screenHeight * 0.45,
                    maxWidth: 500,
                  ),
                  child: _buildGlassPanel(
                    padding: EdgeInsets.zero,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getStepString('hudTitle').toUpperCase(),
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _feedbackMessage ??
                                _getStepString('hudInstruction'),
                            style: TextStyle(
                              color: _feedbackMessage == null
                                  ? textBase
                                  : (_feedbackIsSuccess
                                        ? Colors.greenAccent
                                        : Colors.redAccent),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (!_interactionCompleted || _currentStep == 0) ...[
                            const SizedBox(height: 16),
                            _buildHUDInteraction(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // --- 4. Foreground Sidebar Overlay (z-index front) ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: _isSidebarOpen ? 0 : -sideWidth,
              width: sideWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: bgPanel.withOpacity(0.95),
                  border: Border(right: BorderSide(color: borderPanel)),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 10),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    top: 70,
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.calculate,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getString('titleMain'),
                                  style: TextStyle(
                                    color: textBase,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  _getString('chapterMain'),
                                  style: TextStyle(
                                    color: textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Toolbelt Row (Lang, Theme, Refresh)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              _playSound('tap');
                              setState(() {
                                _currentLang = _currentLang == 'en'
                                    ? 'hi'
                                    : 'en';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: borderPanel),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.language,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _getString('langCode'),
                                    style: TextStyle(
                                      color: textBase,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            color: textBase,
                            tooltip: 'Reset',
                            onPressed: () {
                              _playSound('tap');
                              _loadScenario(0);
                            },
                          ),
                          // IconButton(
                          //   icon: Icon(
                          //     _isDarkTheme ? Icons.light_mode : Icons.dark_mode,
                          //   ),
                          //   color: textBase,
                          //   tooltip: 'Theme',
                          //   onPressed: () {
                          //     _playSound('tap');
                          //     setState(() => _isDarkTheme = !_isDarkTheme);
                          //   },
                          // ),
                        ],
                      ),
                      Divider(color: borderPanel),
                      const SizedBox(height: 14),

                      // Dropdown Steps
                      Text(
                        _getString('activeStep').toUpperCase(),
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: borderPanel),
                          borderRadius: BorderRadius.circular(8),
                          color: _isDarkTheme
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: _currentStep,
                            dropdownColor: bgBase,
                            style: TextStyle(
                              color: textBase,
                              fontWeight: FontWeight.bold,
                            ),
                            items: List.generate(4, (index) {
                              final stepsList = t['steps'] as List?;
                              final titleStr =
                                  (stepsList != null &&
                                      index < stepsList.length)
                                  ? stepsList[index]['title']?.toString() ?? ''
                                  : '';
                              return DropdownMenuItem(
                                value: index,
                                child: Text(
                                  titleStr,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }),
                            onChanged: (val) {
                              if (val != null) {
                                _playSound('tap');
                                _loadScenario(val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Mission Objective / Theory
                      Text(
                        _getString('teacherTitle').toUpperCase(),
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _isDarkTheme ? Colors.black26 : Colors.white54,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderPanel),
                        ),
                        child: Text(
                          _getStepString('theory'),
                          style: TextStyle(
                            color: textBase,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Target Output Visual Box
                      Text(
                        _getString('targetOutput').toUpperCase(),
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _isDarkTheme ? Colors.black26 : Colors.white54,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderPanel),
                        ),
                        child: Text(
                          _getStepString('hudInstruction'),
                          style: TextStyle(
                            color: textBase,
                            fontSize: 14,
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Action Button
                      _buildMainActionButton(),
                      const SizedBox(height: 40),

                      // Footer with specifically requested text
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          "© ZeroScienceLab - Fall in love with math and Science",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            letterSpacing: 1.1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- 5. Floating Menu Button (Top Left) ---
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(
                  _isSidebarOpen ? Icons.menu_open : Icons.menu,
                  size: 28,
                ),
                color: Colors.amber,
                onPressed: () {
                  _playSound('tap');
                  setState(() => _isSidebarOpen = !_isSidebarOpen);
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ),

            // --- 6. Initial Curtain Raiser ---
            if (_showCurtain)
              SlideTransition(
                position: _curtainAnimation,
                child: Container(
                  color: const Color(0xFF0F172A),
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calculate,
                        color: Colors.amber,
                        size: 80,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _getString('titleMain'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getString('chapterMain'),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 10,
                        ),
                        onPressed: _enterLab,
                        icon: const Icon(Icons.play_arrow, size: 28),
                        label: Text(
                          _getString('enterBtn'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- Native Background Painter ---
class DivisibilityProofsPainter extends CustomPainter {
  final bool isDark;

  DivisibilityProofsPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // Elegant Background Grid Pattern
    final gridPaint = Paint()
      ..color = isDark
          ? Colors.white.withOpacity(0.03)
          : Colors.black.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    double gridStep = 40;
    for (double i = 0; i < size.width; i += gridStep) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += gridStep) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant DivisibilityProofsPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
