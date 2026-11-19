// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class VisualSimilarityRatiosLab extends StatefulWidget {
  const VisualSimilarityRatiosLab({Key? key}) : super(key: key);

  @override
  State<VisualSimilarityRatiosLab> createState() =>
      _VisualSimilarityRatiosLabState();
}

class _VisualSimilarityRatiosLabState extends State<VisualSimilarityRatiosLab>
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
  double _scaleFactor = 1.0; // For Step 2 slider
  int _step3SelectedAnswer = -1;
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
      'titleMain': 'Visual Similarity & Ratios',
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
      'labels': {
        'side': 'Side = x',
        'side3': 'Side = 3x',
        'area': 'Area = x²',
        'area9': 'Area = 9x²',
      },
      'steps': [
        {
          'title': 'Step 1: Basic Similarity',
          'theory':
              "Welcome to Concept 4: Visual Similarity.\n\nWhen we scale a shape, its side lengths change by a specific 'Scale Factor'.\n\nObserve the small square. Its side length is 'x' and its area is x².",
          'hudTitle': 'Observe Base Shape',
          'hudInstruction':
              "Observe the initial square with side length 'x' on the canvas.",
          'type': 'observe',
        },
        {
          'title': 'Step 2: Scaling the Shape',
          'theory':
              "Let's increase the scale factor of the shape.\n\nIf we multiply the side length by 3, the new side length becomes 3x.\n\nAdjust the slider to scale the square by a factor of 3.",
          'hudTitle': 'Scale Factor = 3',
          'hudInstruction':
              "Drag the slider to scale the square by a factor of 3.0.",
          'targetValue': 3.0,
          'type': 'slider',
        },
        {
          'title': 'Step 3: The Area Ratio',
          'theory':
              "Look at the new large square! It doesn't just contain 3 small squares. It contains 9!\n\nWhen you scale a 2D shape's sides by a factor of 'k', the Area scales by a factor of k².\n\nSince 3² = 9, the new area is 9x².",
          'hudTitle': 'Identify Area Scaling',
          'hudInstruction':
              "If the scale factor was 4, what would the new area be?",
          'options': ['4x²', '8x²', '16x²', '12x²'],
          'correctIdx': 2,
          'type': 'mcq',
        },
        {
          'title': 'Step 4: Perimeter vs Area',
          'theory':
              "Does the perimeter scale the same way as the area?\n\nPerimeter is a 1D measurement (just length). Area is a 2D measurement.\n\nIf the side scales by 3, the perimeter also scales by exactly 3. Only the area squares.",
          'hudTitle': 'Perimeter Scaling',
          'hudInstruction':
              "If a shape's sides are doubled (x2), what happens to its perimeter?",
          'options': ['Doubles (x2)', 'Quadruples (x4)', 'Stays same'],
          'correctIdx': 0,
          'type': 'mcq',
        },
        {
          'title': 'Step 5: Application',
          'theory':
              "Let's apply the k² area rule.\n\nA photograph has an area of 20 cm².\n\nIf we enlarge the photograph so that its sides are 5 times longer (scale factor k = 5), what will the new area be?",
          'hudTitle': 'Calculate New Area',
          'hudInstruction': "Calculate the new area: 20 × 5² = ?",
          'correctValue': 500,
          'type': 'input',
        },
      ],
    },
    'hi': {
      'langCode': 'HI',
      'titleMain': 'दृश्य समानता और अनुपात',
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
      'labels': {
        'side': 'भुजा = x',
        'side3': 'भुजा = 3x',
        'area': 'क्षेत्रफल = x²',
        'area9': 'क्षेत्रफल = 9x²',
      },
      'steps': [
        {
          'title': 'चरण 1: बुनियादी समानता',
          'theory':
              "कांसेप्ट 4 में आपका स्वागत है: दृश्य समानता।\n\nजब हम किसी आकार को स्केल करते हैं, तो उसकी भुजा की लंबाई एक विशिष्ट 'स्केल फैक्टर' से बदल जाती है।\n\nछोटे वर्ग का निरीक्षण करें। इसकी भुजा की लंबाई 'x' है और इसका क्षेत्रफल x² है।",
          'hudTitle': 'आधार आकार का निरीक्षण करें',
          'hudInstruction':
              "कैनवास पर भुजा की लंबाई 'x' वाले प्रारंभिक वर्ग का निरीक्षण करें।",
          'type': 'observe',
        },
        {
          'title': 'चरण 2: आकार को स्केल करना',
          'theory':
              "आइए आकार के स्केल फैक्टर को बढ़ाएं।\n\nयदि हम भुजा की लंबाई को 3 से गुणा करते हैं, तो नई भुजा की लंबाई 3x हो जाती है।\n\nवर्ग को 3 के कारक से स्केल करने के लिए स्लाइडर को समायोजित करें।",
          'hudTitle': 'स्केल फैक्टर = 3',
          'hudInstruction':
              "वर्ग को 3.0 के कारक से स्केल करने के लिए स्लाइडर खींचें।",
          'targetValue': 3.0,
          'type': 'slider',
        },
        {
          'title': 'चरण 3: क्षेत्र अनुपात',
          'theory':
              "नए बड़े वर्ग को देखें! इसमें केवल 3 छोटे वर्ग नहीं हैं। इसमें 9 हैं!\n\nजब आप 'k' के कारक से 2D आकार की भुजाओं को स्केल करते हैं, तो क्षेत्रफल k² के कारक से स्केल होता है।\n\nचूंकि 3² = 9, नया क्षेत्रफल 9x² है।",
          'hudTitle': 'क्षेत्र स्केलिंग की पहचान करें',
          'hudInstruction':
              "यदि स्केल फैक्टर 4 था, तो नया क्षेत्रफल क्या होगा?",
          'options': ['4x²', '8x²', '16x²', '12x²'],
          'correctIdx': 2,
          'type': 'mcq',
        },
        {
          'title': 'चरण 4: परिधि बनाम क्षेत्रफल',
          'theory':
              "क्या परिधि क्षेत्रफल की तरह ही स्केल होती है?\n\nपरिधि एक 1D माप है (केवल लंबाई)। क्षेत्रफल एक 2D माप है।\n\nयदि भुजा 3 से स्केल होती है, तो परिधि भी ठीक 3 से स्केल होती है। केवल क्षेत्रफल वर्ग होता है।",
          'hudTitle': 'परिधि स्केलिंग',
          'hudInstruction':
              "यदि किसी आकार की भुजाओं को दोगुना (x2) कर दिया जाए, तो उसकी परिधि का क्या होता है?",
          'options': ['दोगुना (x2)', 'चौगुना (x4)', 'समान रहता है'],
          'correctIdx': 0,
          'type': 'mcq',
        },
        {
          'title': 'चरण 5: अनुप्रयोग',
          'theory':
              "आइए k² क्षेत्र नियम लागू करें।\n\nएक तस्वीर का क्षेत्रफल 20 सेमी² है।\n\nयदि हम तस्वीर को बड़ा करते हैं ताकि उसकी भुजाएं 5 गुना लंबी हों (स्केल फैक्टर k = 5), तो नया क्षेत्रफल क्या होगा?",
          'hudTitle': 'नए क्षेत्रफल की गणना करें',
          'hudInstruction': "नए क्षेत्रफल की गणना करें: 20 × 5² = ?",
          'correctValue': 500,
          'type': 'input',
        },
      ],
    },
  };

  // --- Safe Map Accessors (Prevents Null TypeErrors) ---
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

      // Reset Step States
      _scaleFactor = 1.0;
      _step3SelectedAnswer = -1;
      _step4SelectedAnswer = -1;
      _inputController.clear();

      // Auto-complete non-interactive observational steps
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
    } else if (type == 'slider') {
      double target = currentScenario['targetValue'] ?? 3.0;
      if ((_scaleFactor - target).abs() < 0.1) {
        _showFeedback(_getString('toastSuccess'), true);
      } else {
        _showFeedback(_getString('toastError'), false);
      }
    } else if (type == 'mcq') {
      int answerIndex = -1;
      if (_currentStep == 2) answerIndex = _step3SelectedAnswer;
      if (_currentStep == 3) answerIndex = _step4SelectedAnswer;

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
    } else if (type == 'input') {
      int? parsed = int.tryParse(_inputController.text.trim());
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
  }

  void _handleMCQChoice(int answerIndex) {
    if (_interactionCompleted) return;
    _playSound('tap');

    setState(() {
      if (_currentStep == 2) _step3SelectedAnswer = answerIndex;
      if (_currentStep == 3) _step4SelectedAnswer = answerIndex;
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
    } else if (type == 'slider') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "Scale: ${_scaleFactor.toStringAsFixed(1)}",
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 200,
            child: Slider(
              value: _scaleFactor,
              min: 1.0,
              max: 3.0,
              divisions: 20,
              activeColor: Colors.amber,
              inactiveColor: borderPanel,
              onChanged: _interactionCompleted
                  ? null
                  : (val) {
                      setState(() => _scaleFactor = val);
                      double target = currentScenario['targetValue'] ?? 3.0;
                      if ((val - target).abs() < 0.1 &&
                          !_interactionCompleted) {
                        _playSound('success');
                        _showFeedback(_getString('toastSuccess'), true);
                      }
                    },
            ),
          ),
        ],
      );
    } else if (type == 'mcq') {
      List<String> options = List<String>.from(
        currentScenario['options'] ?? [],
      );
      int currentAnswer = -1;
      if (_currentStep == 2) currentAnswer = _step3SelectedAnswer;
      if (_currentStep == 3) currentAnswer = _step4SelectedAnswer;
      int correctIdx = currentScenario['correctIdx'] ?? -1;

      return Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: List.generate(options.length, (idx) {
          bool isSelected = currentAnswer == idx;
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
                painter: VisualSimilarityPainter(
                  isDark: _isDarkTheme,
                  step: _currentStep,
                  scaleFactor: _scaleFactor,
                  isInteractionComplete: _interactionCompleted,
                  labels: tLabels,
                ),
              ),

              // Floating math summary overlays
              if (_currentStep == 2 || _currentStep == 3)
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
                      _currentStep == 2
                          ? "Side × k ⟹ Area × k²"
                          : "Area is 2D (k²), Perimeter is 1D (k)",
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              if (_currentStep == 4)
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
                    child: const Text(
                      "New Area = Old Area × k²\nNew Area = 20 × 5² = 20 × 25",
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
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
              right: 20,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: screenHeight * 0.45,
                  maxWidth: 400,
                ),
                child: _buildGlassPanel(
                  padding: EdgeInsets.zero,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
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
                              Icons.aspect_ratio,
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
                        Icons.aspect_ratio,
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
class VisualSimilarityPainter extends CustomPainter {
  final bool isDark;
  final int step;
  final double scaleFactor;
  final bool isInteractionComplete;
  final Map<String, dynamic> labels;

  VisualSimilarityPainter({
    required this.isDark,
    required this.step,
    required this.scaleFactor,
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

    double baseSize = 80;
    final pBaseFill = Paint()
      ..color = Colors.blueAccent.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    final pBaseStroke = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final pScaleFill = Paint()
      ..color = Colors.amber.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    final pScaleStroke = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Base shape (left)
    Rect rBase = Rect.fromCenter(
      center: center + const Offset(-150, 0),
      width: baseSize,
      height: baseSize,
    );
    canvas.drawRect(rBase, pBaseFill);
    canvas.drawRect(rBase, pBaseStroke);

    drawText(
      labels['side']?.toString() ?? "Side = x",
      center + const Offset(-150, 60),
      Colors.white,
      fontSize: 18,
    );
    drawText(
      labels['area']?.toString() ?? "Area = x²",
      center + const Offset(-150, -60),
      Colors.white,
      fontSize: 18,
    );

    // Scaled shape (right)
    if (step >= 1) {
      double currentScale = (step == 1 && !isInteractionComplete)
          ? scaleFactor
          : 3.0;
      if (step > 1) currentScale = 3.0;

      double lSize = baseSize * currentScale;
      Rect rLarge = Rect.fromCenter(
        center: center + const Offset(150, 0),
        width: lSize,
        height: lSize,
      );

      canvas.drawRect(rLarge, pScaleFill);
      canvas.drawRect(rLarge, pScaleStroke);

      if (currentScale >= 3.0) {
        // Draw grid inside the 3x3 square to prove 9 sub-squares
        final thinLine = Paint()
          ..color = Colors.orangeAccent.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
        double stepSize = lSize / 3;
        double startX = center.dx + 150 - lSize / 2;
        double startY = center.dy - lSize / 2;

        for (int i = 1; i < 3; i++) {
          canvas.drawLine(
            Offset(startX + (i * stepSize), startY),
            Offset(startX + (i * stepSize), startY + lSize),
            thinLine,
          );
          canvas.drawLine(
            Offset(startX, startY + (i * stepSize)),
            Offset(startX + lSize, startY + (i * stepSize)),
            thinLine,
          );
        }

        drawText(
          labels['side3']?.toString() ?? "Side = 3x",
          center + const Offset(150, 150),
          Colors.amber,
          fontSize: 18,
        );
        drawText(
          labels['area9']?.toString() ?? "Area = 9x²",
          center + const Offset(150, -150),
          Colors.amber,
          fontSize: 18,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant VisualSimilarityPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.step != step ||
        oldDelegate.scaleFactor != scaleFactor ||
        oldDelegate.isInteractionComplete != isInteractionComplete ||
        oldDelegate.labels != labels;
  }
}
