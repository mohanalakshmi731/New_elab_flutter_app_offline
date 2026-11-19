// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class GrowthCompoundingLab extends StatefulWidget {
  const GrowthCompoundingLab({Key? key}) : super(key: key);

  @override
  State<GrowthCompoundingLab> createState() => _GrowthCompoundingLabState();
}

class _GrowthCompoundingLabState extends State<GrowthCompoundingLab>
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

  // Step Specific State
  int _mcqSelectedAnswer = -1;
  final TextEditingController _inputController = TextEditingController();

  // --- Animations & Audio ---
  late AnimationController _curtainController;
  late Animation<Offset> _curtainAnimation;
  late AudioPlayer _audioPlayer;

  // --- Localization Data ---
  final Map<String, Map<String, dynamic>> _translations = {
    'en': {
      'langCode': 'EN',
      'titleMain': 'Growth & Compounding',
      'chapterMain': 'Class 8 • Comparing Quantities',
      'enterBtn': 'Enter Virtual Lab',
      'teacherTitle': 'Mission Objective',
      'targetOutput': 'Target Output',
      'proceedBtn': 'Proceed to Next Step',
      'validateBtn': 'Verify Math',
      'restartBtn': 'Restart Activity',
      'activeStep': 'Current Investigation',
      'toastSuccess': 'Excellent! Logic Validated.',
      'toastError': 'Incorrect. Review the theory and try again.',
      'selectWarn': 'Please make a selection in the HUD.',
      'labels': {'pop': 'Population', 'dep': 'Value'},
      'steps': [
        {
          'title': 'Step 1: Population Growth',
          'theory':
              "Welcome to Concept 6: Growth and Depreciation.\n\nPopulations grow similarly to Compound Interest. If a town of 10,000 grows by 10% annually, we use the formula: A = P(1 + R/100)ⁿ.",
          'hudTitle': 'Calculate Growth',
          'hudInstruction':
              "What is the population after 1 year? (10000 × 1.10)",
          'correctValue': 11000,
          'type': 'input',
        },
        {
          'title': 'Step 2: Depreciation (Decay)',
          'theory':
              "Some values decrease over time, like the price of a car or a shrinking bacteria colony. This is called 'Depreciation'.\n\nInstead of adding the rate, we subtract it: A = P(1 - R/100)ⁿ.",
          'hudTitle': 'Identify the Multiplier',
          'hudInstruction':
              "If a car depreciates by 20% each year, what do we multiply its value by?",
          'options': ['1.20', '0.80', '0.20'],
          'correctIdx': 1,
          'type': 'mcq',
        },
        {
          'title': 'Step 3: Compounding Half-Yearly (Time)',
          'theory':
              "Banks often calculate compound interest more than once a year. 'Half-Yearly' means every 6 months.\n\nIn 1 year, there are 2 half-years. So the number of time periods (n) doubles!",
          'hudTitle': 'Calculate Periods',
          'hudInstruction':
              "If money is invested for 1.5 years compounded half-yearly, how many compounding periods (n) are there?",
          'correctValue': 3,
          'type': 'input',
        },
        {
          'title': 'Step 4: Compounding Half-Yearly (Rate)',
          'theory':
              "Since we are calculating interest twice a year, the Annual Rate (R) must be split in half for each period.\n\nIf the bank offers 10% per annum, the half-yearly rate is 10% ÷ 2 = 5%.",
          'hudTitle': 'Calculate New Rate',
          'hudInstruction':
              "If the annual rate is 12%, what is the rate used for half-yearly calculations?",
          'correctValue': 6,
          'type': 'input',
        },
        {
          'title': 'Step 5: The Timeline',
          'theory':
              "Let's visualize Half-Yearly compounding over 1 Year.\n\nInterest is calculated and added to the principal at the 6-month mark (first arc), and then calculated AGAIN on the new amount at the 12-month mark (second arc).",
          'hudTitle': 'Observe Timeline',
          'hudInstruction':
              "Observe the timeline on the canvas showing the two distinct compounding periods in one year.",
          'type': 'observe',
        },
      ],
    },
    'hi': {
      'langCode': 'HI',
      'titleMain': 'विकास और चक्रवृद्धि',
      'chapterMain': 'कक्षा 8 • राशियों की तुलना',
      'enterBtn': 'वर्चुअल लैब में प्रवेश करें',
      'teacherTitle': 'मिशन का उद्देश्य',
      'targetOutput': 'लक्षित आउटपुट',
      'proceedBtn': 'अगले चरण पर जाएँ',
      'validateBtn': 'गणित सत्यापित करें',
      'restartBtn': 'गतिविधि पुनः आरंभ करें',
      'activeStep': 'वर्तमान अन्वेषण',
      'toastSuccess': 'उत्कृष्ट! तर्क मान्य।',
      'toastError': 'गलत। सिद्धांत की समीक्षा करें और पुनः प्रयास करें।',
      'selectWarn': 'कृपया HUD में एक विकल्प चुनें।',
      'labels': {'pop': 'जनसंख्या', 'dep': 'मूल्य'},
      'steps': [
        {
          'title': 'चरण 1: जनसंख्या वृद्धि',
          'theory':
              "कांसेप्ट 6 में आपका स्वागत है: विकास और मूल्यह्रास।\n\nजनसंख्या चक्रवृद्धि ब्याज के समान बढ़ती है। यदि 10,000 का शहर सालाना 10% बढ़ता है, तो हम सूत्र का उपयोग करते हैं: A = P(1 + R/100)ⁿ।",
          'hudTitle': 'वृद्धि की गणना करें',
          'hudInstruction': "1 वर्ष के बाद जनसंख्या क्या है? (10000 × 1.10)",
          'correctValue': 11000,
          'type': 'input',
        },
        {
          'title': 'चरण 2: मूल्यह्रास (क्षय)',
          'theory':
              "समय के साथ कुछ मूल्य घटते हैं, जैसे कार की कीमत या सिकुड़ती बैक्टीरिया कॉलोनी। इसे 'मूल्यह्रास' कहा जाता है।\n\nदर जोड़ने के बजाय, हम इसे घटाते हैं: A = P(1 - R/100)ⁿ।",
          'hudTitle': 'गुणक को पहचानें',
          'hudInstruction':
              "यदि एक कार का मूल्य हर साल 20% कम हो जाता है, तो हम उसके मूल्य को किससे गुणा करते हैं?",
          'options': ['1.20', '0.80', '0.20'],
          'correctIdx': 1,
          'type': 'mcq',
        },
        {
          'title': 'चरण 3: छमाही चक्रवृद्धि (समय)',
          'theory':
              "बैंक अक्सर साल में एक से अधिक बार चक्रवृद्धि ब्याज की गणना करते हैं। 'अर्धवार्षिक' का अर्थ है हर 6 महीने।\n\n1 वर्ष में 2 छमाही होती हैं। तो समय अवधि (n) की संख्या दोगुनी हो जाती है!",
          'hudTitle': 'अवधियों की गणना करें',
          'hudInstruction':
              "यदि पैसा 1.5 साल के लिए अर्धवार्षिक रूप से संयोजित किया जाता है, तो कितनी चक्रवृद्धि अवधि (n) हैं?",
          'correctValue': 3,
          'type': 'input',
        },
        {
          'title': 'चरण 4: छमाही चक्रवृद्धि (दर)',
          'theory':
              "चूंकि हम वर्ष में दो बार ब्याज की गणना कर रहे हैं, इसलिए वार्षिक दर (R) को प्रत्येक अवधि के लिए आधा किया जाना चाहिए।\n\nयदि बैंक प्रति वर्ष 10% की पेशकश करता है, तो अर्धवार्षिक दर 10% ÷ 2 = 5% है।",
          'hudTitle': 'नई दर की गणना करें',
          'hudInstruction':
              "यदि वार्षिक दर 12% है, तो अर्धवार्षिक गणना के लिए किस दर का उपयोग किया जाता है?",
          'correctValue': 6,
          'type': 'input',
        },
        {
          'title': 'चरण 5: समयरेखा',
          'theory':
              "आइए 1 वर्ष में अर्धवार्षिक चक्रवृद्धि की कल्पना करें।\n\nब्याज की गणना की जाती है और 6 महीने के निशान (पहला चाप) पर मूलधन में जोड़ा जाता है, और फिर 12 महीने के निशान (दूसरा चाप) पर नई राशि पर फिर से गणना की जाती है।",
          'hudTitle': 'समयरेखा का निरीक्षण करें',
          'hudInstruction':
              "कैनवास पर समयरेखा का निरीक्षण करें जो एक वर्ष में दो अलग-अलग चक्रवृद्धि अवधियों को दिखाती है।",
          'type': 'observe',
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
      _loadScenario(0);
    });
  }

  void _loadScenario(int step) {
    setState(() {
      _currentStep = step;
      _feedbackMessage = null;
      _interactionCompleted = false;

      // Reset Step State
      _mcqSelectedAnswer = -1;
      _inputController.clear();

      String type = _getStepString('type');
      if (type == 'observe') {
        _interactionCompleted = true;
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

  // --- Interaction Validation ---

  void _validateInvestigation() {
    String type = _getStepString('type');

    if (type == 'observe') {
      _showFeedback(_getString('toastSuccess'), true);
    } else if (type == 'mcq') {
      if (_mcqSelectedAnswer == -1) {
        _showFeedback(_getString('selectWarn'), false);
        return;
      }
      int correctIdx = currentScenario['correctIdx'] as int? ?? -1;
      if (_mcqSelectedAnswer == correctIdx) {
        _showFeedback(_getString('toastSuccess'), true);
      } else {
        _showFeedback(_getString('toastError'), false);
      }
    } else if (type == 'input') {
      num? parsed = num.tryParse(_inputController.text.trim());
      num correctVal = currentScenario['correctValue'] ?? -999;

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
  }

  void _handleMCQChoice(int answerIndex) {
    if (_interactionCompleted) return;
    _playSound('tap');

    setState(() {
      _mcqSelectedAnswer = answerIndex;
    });

    _validateInvestigation();
  }

  void _handleInputSubmit(String value) {
    if (_interactionCompleted) return;
    _playSound('tap');
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
            : Icons.verified,
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
    String type = _getStepString('type');

    if (type == 'observe') {
      return const Text(
        "Observation Complete. Please Proceed.",
        style: TextStyle(
          color: Colors.greenAccent,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      );
    } else if (type == 'mcq') {
      List<String> options = List<String>.from(
        currentScenario['options'] ?? [],
      );
      int correctIdx = currentScenario['correctIdx'] ?? -1;

      return Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: List.generate(options.length, (idx) {
          bool isSelected = _mcqSelectedAnswer == idx;
          bool isCorrect = idx == correctIdx;
          return InkWell(
            onTap: _interactionCompleted
                ? null
                : () {
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
    } else if (type == 'input') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 140,
            child: TextField(
              controller: _inputController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
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
                hintText: "?",
                hintStyle: TextStyle(color: textMuted),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (val) {
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
              // 2D Geometric Render Background
              CustomPaint(
                size: Size.infinite,
                painter: GrowthCompoundingPainter(
                  isDark: _isDarkTheme,
                  step: _currentStep,
                  isInteractionComplete: _interactionCompleted,
                  labels: tLabels,
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
                  maxWidth: 500,
                ),
                child: _buildGlassPanel(
                  padding: EdgeInsets.zero,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
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
                        if (_currentStep >= 0) ...[
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
                    top: 80,
                    left: 24,
                    right: 24,
                    bottom: 24,
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
                              Icons.show_chart,
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
                icon: Icon(_isSidebarOpen ? Icons.close : Icons.menu, size: 28),
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
                        Icons.show_chart,
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

// --- Native Canvas Background Painter ---
class GrowthCompoundingPainter extends CustomPainter {
  final bool isDark;
  final int step;
  final bool isInteractionComplete;
  final Map<String, dynamic> labels;

  GrowthCompoundingPainter({
    required this.isDark,
    required this.step,
    required this.isInteractionComplete,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Background Grid Pattern
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

    void drawText(
      String text,
      Offset pos,
      Color color, {
      double fontSize = 24,
    }) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
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

    void _drawArrow(Offset start, Offset end, Color color) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawLine(start, end, paint);

      // Arrowhead
      double angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
      double arrowLen = 10;
      Offset p1 =
          end -
          Offset(
            arrowLen * math.cos(angle - math.pi / 6),
            arrowLen * math.sin(angle - math.pi / 6),
          );
      Offset p2 =
          end -
          Offset(
            arrowLen * math.cos(angle + math.pi / 6),
            arrowLen * math.sin(angle + math.pi / 6),
          );

      Path head = Path()
        ..moveTo(end.dx, end.dy)
        ..lineTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..close();
      canvas.drawPath(
        head,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
    }

    if (step == 0) {
      drawText(
        labels['pop'] ?? 'Population',
        center + const Offset(-150, -60),
        Colors.white54,
        fontSize: 16,
      );
      drawText(
        "10,000",
        center + const Offset(-150, -20),
        Colors.amber,
        fontSize: 32,
      );

      if (isInteractionComplete) {
        drawText(
          labels['pop'] ?? 'Population',
          center + const Offset(150, -60),
          Colors.white54,
          fontSize: 16,
        );
        drawText(
          "11,000",
          center + const Offset(150, -20),
          Colors.greenAccent,
          fontSize: 32,
        );
      } else {
        drawText(
          "?",
          center + const Offset(150, -20),
          Colors.white54,
          fontSize: 32,
        );
      }

      _drawArrow(
        center + const Offset(-80, -20),
        center + const Offset(80, -20),
        Colors.white54,
      );
      drawText(
        "+ 10%",
        center + const Offset(0, -40),
        Colors.amber,
        fontSize: 16,
      );
    } else if (step == 1) {
      drawText(
        labels['dep'] ?? 'Value',
        center + const Offset(-150, -60),
        Colors.white54,
        fontSize: 16,
      );
      drawText(
        "\$10,000",
        center + const Offset(-150, -20),
        Colors.amber,
        fontSize: 32,
      );

      if (isInteractionComplete) {
        drawText(
          labels['dep'] ?? 'Value',
          center + const Offset(150, -60),
          Colors.white54,
          fontSize: 16,
        );
        drawText(
          "\$8,000",
          center + const Offset(150, -20),
          Colors.redAccent,
          fontSize: 32,
        );
      } else {
        drawText(
          "?",
          center + const Offset(150, -20),
          Colors.white54,
          fontSize: 32,
        );
      }

      _drawArrow(
        center + const Offset(-80, -20),
        center + const Offset(80, -20),
        Colors.white54,
      );
      drawText(
        "- 20%",
        center + const Offset(0, -40),
        Colors.redAccent,
        fontSize: 16,
      );
    } else if (step == 2 || step == 3) {
      // Show 1 year divided into 2 periods
      drawText(
        "1 Year",
        center + const Offset(0, -80),
        Colors.amber,
        fontSize: 24,
      );

      Rect yearRect = Rect.fromCenter(
        center: center + const Offset(0, -20),
        width: 300,
        height: 60,
      );
      canvas.drawRect(yearRect, Paint()..color = Colors.amber.withOpacity(0.2));
      canvas.drawRect(
        yearRect,
        Paint()
          ..color = Colors.amber
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      if (isInteractionComplete || step == 3) {
        // Split rect
        canvas.drawLine(
          center + const Offset(0, -50),
          center + const Offset(0, 10),
          Paint()
            ..color = Colors.amber
            ..strokeWidth = 2,
        );
        drawText(
          "Period 1",
          center + const Offset(-75, -20),
          Colors.greenAccent,
          fontSize: 16,
        );
        drawText(
          "Period 2",
          center + const Offset(75, -20),
          Colors.greenAccent,
          fontSize: 16,
        );
      }

      if (step == 3) {
        if (isInteractionComplete) {
          drawText(
            "Rate 1: 5%",
            center + const Offset(-75, 40),
            Colors.blueAccent,
            fontSize: 16,
          );
          drawText(
            "Rate 2: 5%",
            center + const Offset(75, 40),
            Colors.blueAccent,
            fontSize: 16,
          );
        } else {
          drawText(
            "Annual Rate = 10%",
            center + const Offset(0, 40),
            Colors.blueAccent,
            fontSize: 16,
          );
        }
      }
    } else if (step == 4) {
      // Timeline for Half-Yearly
      Offset tStart = center + const Offset(-200, 0);
      Offset tEnd = center + const Offset(200, 0);
      Offset tMid = center;

      final pLine = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawLine(tStart, tEnd, pLine);

      // Ticks
      canvas.drawLine(
        tStart + const Offset(0, -10),
        tStart + const Offset(0, 10),
        pLine,
      );
      canvas.drawLine(
        tMid + const Offset(0, -10),
        tMid + const Offset(0, 10),
        pLine,
      );
      canvas.drawLine(
        tEnd + const Offset(0, -10),
        tEnd + const Offset(0, 10),
        pLine,
      );

      // Period arcs
      final pArc = Paint()
        ..color = Colors.amber
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      Path arc1 = Path()
        ..moveTo(tStart.dx, tStart.dy)
        ..quadraticBezierTo(tStart.dx + 100, tStart.dy - 40, tMid.dx, tMid.dy);
      Path arc2 = Path()
        ..moveTo(tMid.dx, tMid.dy)
        ..quadraticBezierTo(tMid.dx + 100, tMid.dy - 40, tEnd.dx, tEnd.dy);

      canvas.drawPath(arc1, pArc);
      canvas.drawPath(arc2, pArc);

      drawText(
        "Start",
        tStart + const Offset(0, 30),
        Colors.white,
        fontSize: 16,
      );
      drawText(
        "6 Months",
        tMid + const Offset(0, 30),
        Colors.white,
        fontSize: 16,
      );
      drawText(
        "12 Months",
        tEnd + const Offset(0, 30),
        Colors.white,
        fontSize: 16,
      );

      drawText(
        "Compounded!",
        tMid + const Offset(0, -30),
        Colors.greenAccent,
        fontSize: 14,
      );
      drawText(
        "Compounded!",
        tEnd + const Offset(0, -30),
        Colors.greenAccent,
        fontSize: 14,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GrowthCompoundingPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.step != step ||
        oldDelegate.isInteractionComplete != isInteractionComplete ||
        oldDelegate.labels != labels;
  }
}
