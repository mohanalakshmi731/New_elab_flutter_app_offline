// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class GeneralisedDistributivityLab extends StatefulWidget {
  const GeneralisedDistributivityLab({Key? key}) : super(key: key);

  @override
  State<GeneralisedDistributivityLab> createState() =>
      _GeneralisedDistributivityLabState();
}

class _GeneralisedDistributivityLabState
    extends State<GeneralisedDistributivityLab>
    with TickerProviderStateMixin {
  // --- UI State ---
  bool _showCurtain = true;
  bool _isSidebarOpen = true;
  final bool _isDarkTheme = true;
  int _currentStep = 0;
  String _currentLang = 'en';
  final double _teacherFontSize = 16.0;

  // --- Interaction State ---
  String? _feedbackMessage;
  bool _feedbackIsSuccess = true;
  bool _interactionCompleted = false;

  // Step Interactions
  bool _isDrawn = false;
  bool _isSplitV = false;
  bool _isSplitH = false;
  int _step4SelectedAnswer = -1;
  final TextEditingController _inputController = TextEditingController();

  // --- Animations & Audio ---
  late AnimationController _curtainController;
  late Animation<Offset> _curtainAnimation;
  late AudioPlayer _audioPlayer;

  // --- Localization Data ---
  final Map<String, Map<String, dynamic>> _translations = {
    'en': {
      'langCode': 'EN',
      'titleMain': 'Generalised Distributivity',
      'chapterMain': 'Class 8 • Algebraic Expressions',
      'enterBtn': 'Enter Virtual Lab',
      'teacherTitle': 'Mission Objective',
      'targetOutput': 'Target Output',
      'proceedBtn': 'Proceed to Next Step',
      'validateBtn': 'Verify Logic',
      'restartBtn': 'Restart Activity',
      'activeStep': 'Current Investigation',
      'toastSuccess': 'Excellent! Logic Validated.',
      'toastError': 'Incorrect. Review the theory and try again.',
      'labels': {
        'ab_cd': '(a+b)(c+d)',
        'ac_d': 'a(c+d)',
        'bc_d': 'b(c+d)',
        'ac': 'ac',
        'ad': 'ad',
        'bc': 'bc',
        'bd': 'bd',
      },
      'steps': [
        {
          'title': 'Step 1: The Outer Rectangle',
          'theory':
              "Welcome to Concept 2. Let's multiply two binomials: (a + b) and (c + d).\n\nImagine a large rectangular field. Its total width is (a + b) and its total height is (c + d).\n\nMathematically, the total area of this field is the product: \$(a+b)(c+d)\$.",
          'hudTitle': 'Base Area',
          'hudInstruction': "Tap to draw the initial large rectangular field.",
          'btnText': 'Draw Rectangle',
        },
        {
          'title': 'Step 2: First Distribution',
          'theory':
              "We can break this large multiplication down.\n\nLet's slice the field vertically into two pieces: one piece with width 'a' and another piece with width 'b'.\n\nThe total area is now \$a(c+d) + b(c+d)\$. We distributed the width!",
          'hudTitle': 'Vertical Split',
          'hudInstruction':
              "Tap to slice the rectangle vertically into widths 'a' and 'b'.",
          'btnText': 'Slice Vertically',
        },
        {
          'title': 'Step 3: Second Distribution',
          'theory':
              "Now, let's slice both of those pieces horizontally, separating the height 'c' from the height 'd'.\n\nThis gives us four distinct, smaller rectangles. We just multiplied each term in the first bracket by each term in the second bracket!",
          'hudTitle': 'Horizontal Split',
          'hudInstruction':
              "Tap to slice the rectangles horizontally into heights 'c' and 'd'.",
          'btnText': 'Slice Horizontally',
        },
        {
          'title': 'Step 4: The Generalised Form',
          'theory':
              "Look at the four distinct areas we created: ac, ad, bc, and bd. By combining all four areas, we get the generalised distributivity rule.\n\nThis rule works for multiplying ANY two binomials together!",
          'hudTitle': 'Identify the Equation',
          'hudInstruction':
              "Select the correct algebraic identity for this area model.",
          'options': [
            '(a+b)(c+d) = a(c+d) + bd',
            '(a+b)(c+d) = ac + ad + bc + bd',
            '(a+b)(c+d) = ac + bd',
          ],
          'correctIdx': 1,
        },
        {
          'title': 'Step 5: Mathematical Application',
          'theory':
              "Let's apply this to mental math! Calculate \$104 \\times 105\$.\n\nWe can write this as \$(100+4)(100+5)\$.\nHere, \$a=100, b=4, c=100, d=5\$.\n\nArea = \$(100 \\times 100) + (100 \\times 5) + (4 \\times 100) + (4 \\times 5)\$",
          'hudTitle': 'Solve the Product',
          'hudInstruction':
              "Calculate the final numeric value of 104 × 105 using the generalized rule.",
          'correctValue': 10920,
        },
      ],
    },
    'hi': {
      'langCode': 'HI',
      'titleMain': 'सामान्यीकृत वितरण',
      'chapterMain': 'कक्षा 8 • बीजीय व्यंजक',
      'enterBtn': 'वर्चुअल लैब में प्रवेश करें',
      'teacherTitle': 'मिशन का उद्देश्य',
      'targetOutput': 'लक्षित आउटपुट',
      'proceedBtn': 'अगले चरण पर जाएँ',
      'validateBtn': 'तर्क सत्यापित करें',
      'restartBtn': 'गतिविधि पुनः आरंभ करें',
      'activeStep': 'वर्तमान अन्वेषण',
      'toastSuccess': 'उत्कृष्ट! तर्क मान्य।',
      'toastError': 'गलत। सिद्धांत की समीक्षा करें और पुनः प्रयास करें।',
      'labels': {
        'ab_cd': '(a+b)(c+d)',
        'ac_d': 'a(c+d)',
        'bc_d': 'b(c+d)',
        'ac': 'ac',
        'ad': 'ad',
        'bc': 'bc',
        'bd': 'bd',
      },
      'steps': [
        {
          'title': 'चरण 1: बाहरी आयत',
          'theory':
              "कांसेप्ट 2 में आपका स्वागत है। आइए दो द्विपदों को गुणा करें: (a + b) और (c + d)।\n\nएक बड़े आयताकार मैदान की कल्पना करें। इसकी कुल चौड़ाई (a + b) है और कुल ऊंचाई (c + d) है।\n\nगणितीय रूप से, इस मैदान का कुल क्षेत्रफल गुणनफल है: \$(a+b)(c+d)\$।",
          'hudTitle': 'मूल क्षेत्र',
          'hudInstruction':
              "प्रारंभिक बड़े आयताकार क्षेत्र को खींचने के लिए टैप करें।",
          'btnText': 'आयत बनाएं',
        },
        {
          'title': 'चरण 2: पहला वितरण',
          'theory':
              "हम इस बड़े गुणन को तोड़ सकते हैं।\n\nआइए मैदान को लंबवत रूप से दो टुकड़ों में काटें: एक टुकड़ा चौड़ाई 'a' के साथ और दूसरा टुकड़ा चौड़ाई 'b' के साथ।\n\nकुल क्षेत्रफल अब \$a(c+d) + b(c+d)\$ है। हमने चौड़ाई वितरित की!",
          'hudTitle': 'लंबवत विभाजन',
          'hudInstruction':
              "आयत को लंबवत रूप से 'a' और 'b' चौड़ाई में काटने के लिए टैप करें।",
          'btnText': 'लंबवत काटें',
        },
        {
          'title': 'चरण 3: दूसरा वितरण',
          'theory':
              "अब, ऊंचाई 'c' को ऊंचाई 'd' से अलग करते हुए, उन दोनों टुकड़ों को क्षैतिज रूप से काटें।\n\nयह हमें चार अलग-अलग, छोटे आयत देता है। हमने पहले कोष्ठक में प्रत्येक पद को दूसरे कोष्ठक में प्रत्येक पद से गुणा किया!",
          'hudTitle': 'क्षैतिज विभाजन',
          'hudInstruction':
              "आयतों को क्षैतिज रूप से 'c' और 'd' ऊंचाई में काटने के लिए टैप करें।",
          'btnText': 'क्षैतिज काटें',
        },
        {
          'title': 'चरण 4: सामान्यीकृत रूप',
          'theory':
              "हमारे द्वारा बनाए गए चार अलग-अलग क्षेत्रों को देखें: ac, ad, bc, और bd। सभी चार क्षेत्रों को मिलाकर, हमें सामान्यीकृत वितरण नियम मिलता है।\n\nयह नियम किन्हीं भी दो द्विपदों को एक साथ गुणा करने के लिए काम करता है!",
          'hudTitle': 'समीकरण की पहचान करें',
          'hudInstruction':
              "इस क्षेत्र मॉडल के लिए सही बीजीय सर्वसमिका का चयन करें।",
          'options': [
            '(a+b)(c+d) = a(c+d) + bd',
            '(a+b)(c+d) = ac + ad + bc + bd',
            '(a+b)(c+d) = ac + bd',
          ],
          'correctIdx': 1,
        },
        {
          'title': 'चरण 5: गणितीय अनुप्रयोग',
          'theory':
              "आइए इसे मानसिक गणित पर लागू करें! \$104 \\times 105\$ की गणना करें।\n\nहम इसे \$(100+4)(100+5)\$ के रूप में लिख सकते हैं।\nयहाँ, \$a=100, b=4, c=100, d=5\$।\n\nक्षेत्रफल = \$(100 \\times 100) + (100 \\times 5) + (4 \\times 100) + (4 \\times 5)\$",
          'hudTitle': 'गुणनफल हल करें',
          'hudInstruction':
              "सामान्यीकृत नियम का उपयोग करके 104 × 105 के अंतिम संख्यात्मक मान की गणना करें।",
          'correctValue': 10920,
        },
      ],
    },
  };

  // --- Safe Map Accessors ---
  Map<String, dynamic> get t =>
      _translations[_currentLang] ?? _translations['en']!;
  Map<String, dynamic> get tLabels =>
      (t['labels'] as Map?)?.cast<String, dynamic>() ?? {};
  Map<String, dynamic> get currentScenario {
    final steps = t['steps'] as List?;
    if (steps != null && _currentStep >= 0 && _currentStep < steps.length) {
      return steps[_currentStep] as Map<String, dynamic>;
    }
    return {};
  }

  String _getString(String key) => t[key]?.toString() ?? '';
  String _getStepString(String key) => currentScenario[key]?.toString() ?? '';

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
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _curtainController.dispose();
    _inputController.dispose();
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

      // Reset interaction states logically based on step
      if (step == 0) {
        _isDrawn = false;
        _isSplitV = false;
        _isSplitH = false;
      } else if (step == 1) {
        _isDrawn = true;
        _isSplitV = false;
        _isSplitH = false;
      } else if (step == 2) {
        _isDrawn = true;
        _isSplitV = true;
        _isSplitH = false;
      } else if (step == 3) {
        _isDrawn = true;
        _isSplitV = true;
        _isSplitH = true;
        _step4SelectedAnswer = -1;
      } else if (step == 4) {
        _isDrawn = true;
        _isSplitV = true;
        _isSplitH = true;
        _inputController.clear();
      }
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

  // --- Interaction Logic ---

  void _handleStepAction() {
    if (_interactionCompleted) return;
    _playSound('tap');
    setState(() {
      if (_currentStep == 0) _isDrawn = true;
      if (_currentStep == 1) _isSplitV = true;
      if (_currentStep == 2) _isSplitH = true;
    });
    _showFeedback(_getString('toastSuccess'), true);
  }

  void _handleMCQChoice(int answerIndex) {
    if (_interactionCompleted) return;
    _playSound('tap');
    int correctIdx = currentScenario['correctIdx'] ?? -1;
    setState(() => _step4SelectedAnswer = answerIndex);
    if (answerIndex == correctIdx) {
      _showFeedback(_getString('toastSuccess'), true);
    } else {
      _showFeedback(_getString('toastError'), false);
    }
  }

  void _handleInputSubmit(String value) {
    if (_interactionCompleted) return;
    int? parsed = int.tryParse(value.trim());
    int correctVal = currentScenario['correctValue'] ?? -999;

    if (parsed == correctVal) {
      _showFeedback(_getString('toastSuccess'), true);
    } else {
      _showFeedback(_getString('toastError'), false);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && !_interactionCompleted) {
          setState(() => _feedbackMessage = null);
        }
      });
    }
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
        if (_interactionCompleted) {
          if (_currentStep < 4) {
            _loadScenario(_currentStep + 1);
          } else {
            _loadScenario(0);
          }
        }
      },
      icon: Icon(
        _interactionCompleted
            ? (_currentStep == 4 ? Icons.refresh : Icons.arrow_forward)
            : Icons.lock,
      ),
      label: Text(
        _interactionCompleted
            ? (_currentStep == 4
                  ? _getString('restartBtn')
                  : _getString('proceedBtn'))
            : _getString('validateBtn'),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildHUDInteraction() {
    if ((_currentStep >= 0 && _currentStep <= 2) && !_interactionCompleted) {
      IconData icon = Icons.crop_square;
      if (_currentStep == 1) icon = Icons.vertical_split;
      if (_currentStep == 2) icon = Icons.horizontal_split;

      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        onPressed: _handleStepAction,
        icon: Icon(icon),
        label: Text(
          _getStepString('btnText'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    } else if (_currentStep == 3) {
      List<String> options = List<String>.from(
        currentScenario['options'] ?? [],
      );
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: List.generate(options.length, (idx) {
          bool isSelected = _step4SelectedAnswer == idx;
          bool isCorrect = idx == (currentScenario['correctIdx'] ?? -1);
          return InkWell(
            onTap: () {
              _playSound('tap');
              _handleMCQChoice(idx);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isCorrect ? Colors.green : Colors.redAccent)
                    : (_isDarkTheme ? Colors.white10 : Colors.black12),
                border: Border.all(
                  color: isSelected ? Colors.transparent : borderPanel,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                options[idx],
                style: TextStyle(
                  color: isSelected ? Colors.white : textBase,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }),
      );
    } else if (_currentStep == 4) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 140,
            child: TextField(
              controller: _inputController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                color: textBase,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
              enabled: !_interactionCompleted,
              decoration: InputDecoration(
                filled: true,
                fillColor: _isDarkTheme ? Colors.white10 : Colors.black12,
                hintText: "104 × 105",
                hintStyle: TextStyle(color: textMuted),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (val) {
                _playSound('tap');
                _handleInputSubmit(val);
              },
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _interactionCompleted
                  ? Colors.green
                  : Colors.amber,
              foregroundColor: _interactionCompleted
                  ? Colors.white
                  : Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _interactionCompleted
                ? null
                : () {
                    _playSound('tap');
                    _handleInputSubmit(_inputController.text);
                  },
            icon: Icon(_interactionCompleted ? Icons.check : Icons.send),
            label: Text(
              _getString('validateBtn'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    }
    return const SizedBox();
  }

  Widget _buildInteractiveCanvas() {
    return Container(
      color: _isDarkTheme ? const Color(0xFF0B1120) : const Color(0xFFE2E8F0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // 2D Geometric Render Area Model
              CustomPaint(
                size: Size.infinite,
                painter: DistributivityPainter(
                  isDark: _isDarkTheme,
                  isDrawn: _isDrawn,
                  isSplitV: _isSplitV,
                  isSplitH: _isSplitH,
                  labels: tLabels,
                ),
              ),

              // Only in Step 3/4/5 - Floating math summary
              if (_currentStep >= 3)
                Positioned(
                  top: 30,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      border: Border.all(color: Colors.amber),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _currentStep == 3
                          ? "(a + b)(c + d) = ac + ad + bc + bd"
                          : "10000 + 500 + 400 + 20",
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double sideWidth = (screenWidth * 0.3).clamp(300.0, 450.0);

    // Format Theory to handle MathJax strings natively
    String formattedTheory = currentScenario['theory']
        .toString()
        .replaceAll(r"$", "")
        .replaceAll(r"\times", "×")
        .replaceAll(r"^2", "²");

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
                top: 80,
                left: 24,
                bottom: 24,
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
              right: 24,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: screenHeight * 0.45,
                  maxWidth: 600,
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
                          _feedbackMessage ?? _getStepString('hudInstruction'),
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
                              Icons.science,
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
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 16),

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
                            items: List.generate(5, (index) {
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
                          formattedTheory,
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
                        Icons.grid_view,
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

// --- Native Area Model Painter ---
class DistributivityPainter extends CustomPainter {
  final bool isDark;
  final bool isDrawn;
  final bool isSplitV;
  final bool isSplitH;
  final Map<String, dynamic> labels;

  DistributivityPainter({
    required this.isDark,
    required this.isDrawn,
    required this.isSplitV,
    required this.isSplitH,
    required this.labels,
  });

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

    if (!isDrawn) return;

    final center = Offset(size.width / 2, size.height / 2);

    // Mathematical Proportions
    double wA = 140.0;
    double wB = 90.0;
    double hC = 120.0;
    double hD = 80.0;

    // Origins (centering the total combined box)
    double totalW = wA + wB;
    double totalH = hC + hD;
    double startX = center.dx - (totalW / 2);
    double startY = center.dy - (totalH / 2) - 10;

    // Paints
    final borderPaint = Paint()
      ..color = isDark ? Colors.white54 : Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final pBase = Paint()..color = Colors.amber.withOpacity(0.4);
    final pLeft = Paint()..color = Colors.blue.withOpacity(0.6);
    final pRight = Paint()..color = Colors.purple.withOpacity(0.6);

    final pAC = Paint()..color = Colors.blueAccent.withOpacity(0.8);
    final pAD = Paint()..color = Colors.orangeAccent.withOpacity(0.8);
    final pBC = Paint()..color = Colors.purpleAccent.withOpacity(0.8);
    final pBD = Paint()..color = Colors.greenAccent.withOpacity(0.8);

    // Helpers to draw text
    void drawLabel(String text, Rect rect, {double fontSize = 24}) {
      if (rect.width < 30 || rect.height < 20) return;
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
            shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          rect.center.dx - (textPainter.width / 2),
          rect.center.dy - (textPainter.height / 2),
        ),
      );
    }

    void drawAxisLabel(String text, Offset pos) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          pos.dx - (textPainter.width / 2),
          pos.dy - (textPainter.height / 2),
        ),
      );
    }

    // Step 1: Base Rectangle
    if (!isSplitV && !isSplitH) {
      Rect rectFull = Rect.fromLTWH(startX, startY, totalW, totalH);
      canvas.drawRect(rectFull, pBase);
      canvas.drawRect(rectFull, borderPaint);
      drawLabel(
        labels['ab_cd']?.toString() ?? '(a+b)(c+d)',
        rectFull,
        fontSize: 32,
      );

      drawAxisLabel("(a + b)", Offset(startX + (totalW / 2), startY - 20));
      drawAxisLabel("(c + d)", Offset(startX - 35, startY + (totalH / 2)));
    }
    // Step 2: Split Vertically (Left & Right)
    else if (isSplitV && !isSplitH) {
      Rect rectLeft = Rect.fromLTWH(startX, startY, wA, totalH);
      Rect rectRight = Rect.fromLTWH(startX + wA, startY, wB, totalH);

      canvas.drawRect(rectLeft, pLeft);
      canvas.drawRect(rectLeft, borderPaint);
      drawLabel(labels['ac_d']?.toString() ?? 'a(c+d)', rectLeft, fontSize: 24);

      canvas.drawRect(rectRight, pRight);
      canvas.drawRect(rectRight, borderPaint);
      drawLabel(
        labels['bc_d']?.toString() ?? 'b(c+d)',
        rectRight,
        fontSize: 24,
      );

      drawAxisLabel("a", Offset(startX + (wA / 2), startY - 20));
      drawAxisLabel("b", Offset(startX + wA + (wB / 2), startY - 20));
      drawAxisLabel("(c + d)", Offset(startX - 35, startY + (totalH / 2)));
    }
    // Step 3 & 4 & 5: Split Horizontally as well (Four regions)
    else if (isSplitV && isSplitH) {
      Rect rectAC = Rect.fromLTWH(startX, startY, wA, hC);
      Rect rectAD = Rect.fromLTWH(startX, startY + hC, wA, hD);
      Rect rectBC = Rect.fromLTWH(startX + wA, startY, wB, hC);
      Rect rectBD = Rect.fromLTWH(startX + wA, startY + hC, wB, hD);

      // AC
      canvas.drawRect(rectAC, pAC);
      canvas.drawRect(rectAC, borderPaint);
      drawLabel(labels['ac']?.toString() ?? 'ac', rectAC, fontSize: 28);

      // AD
      canvas.drawRect(rectAD, pAD);
      canvas.drawRect(rectAD, borderPaint);
      drawLabel(labels['ad']?.toString() ?? 'ad', rectAD, fontSize: 28);

      // BC
      canvas.drawRect(rectBC, pBC);
      canvas.drawRect(rectBC, borderPaint);
      drawLabel(labels['bc']?.toString() ?? 'bc', rectBC, fontSize: 28);

      // BD
      canvas.drawRect(rectBD, pBD);
      canvas.drawRect(rectBD, borderPaint);
      drawLabel(labels['bd']?.toString() ?? 'bd', rectBD, fontSize: 28);

      // Axes
      drawAxisLabel("a", Offset(startX + (wA / 2), startY - 20));
      drawAxisLabel("b", Offset(startX + wA + (wB / 2), startY - 20));
      drawAxisLabel("c", Offset(startX - 20, startY + (hC / 2)));
      drawAxisLabel("d", Offset(startX - 20, startY + hC + (hD / 2)));
    }
  }

  @override
  bool shouldRepaint(covariant DistributivityPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.isDrawn != isDrawn ||
        oldDelegate.isSplitV != isSplitV ||
        oldDelegate.isSplitH != isSplitH ||
        oldDelegate.labels != labels;
  }
}
