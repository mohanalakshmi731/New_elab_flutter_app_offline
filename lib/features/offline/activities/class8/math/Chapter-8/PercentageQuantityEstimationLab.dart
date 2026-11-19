// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class PercentageQuantityEstimationLab extends StatefulWidget {
  const PercentageQuantityEstimationLab({Key? key}) : super(key: key);

  @override
  State<PercentageQuantityEstimationLab> createState() =>
      _PercentageQuantityEstimationLabState();
}

class _PercentageQuantityEstimationLabState
    extends State<PercentageQuantityEstimationLab>
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
      'titleMain': 'Percentage Quantity & Estimation',
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
      'labels': {'total': 'Total'},
      'steps': [
        {
          'title': 'Step 1: Finding 10%',
          'theory':
              "Percentage means 'per 100'. Finding a percentage of a quantity means finding that fraction of the total amount.\n\nTo find 10% of any quantity, simply divide by 10 (or move the decimal point one place to the left).\n\nLet's say we have a quantity of 500.",
          'hudTitle': 'Calculate 10%',
          'hudInstruction': "What is 10% of 500?",
          'correctValue': 50,
          'type': 'input',
        },
        {
          'title': 'Step 2: Finding 5%',
          'theory':
              "Once you know 10%, finding 5% is very easy because 5% is exactly half of 10%.\n\nWe know 10% of 500 is 50.",
          'hudTitle': 'Calculate 5%',
          'hudInstruction': "What is 5% of 500? (Half of your previous answer)",
          'correctValue': 25,
          'type': 'input',
        },
        {
          'title': 'Step 3: Combining Percentages',
          'theory':
              "You can combine simple percentages to find more complex ones. \n\nFor example, 15% is simply 10% + 5%.\nSince we know 10% is 50, and 5% is 25...",
          'hudTitle': 'Combine Values',
          'hudInstruction':
              "What is 15% of 500? (Add your answers from Step 1 and 2)",
          'correctValue': 75,
          'type': 'input',
        },
        {
          'title': 'Step 4: Visual Estimation',
          'theory':
              "Often, we estimate percentages by looking at fractions of a whole shape, like a pie chart.\n\nLook at the pie chart on the canvas. The whole circle represents 100%.",
          'hudTitle': 'Estimate Percentage',
          'hudInstruction':
              "Look at the pie chart. What percentage of the circle is shaded amber?",
          'options': ['25%', '50%', '75%', '100%'],
          'correctIdx': 2,
          'type': 'mcq',
        },
        {
          'title': 'Step 5: Estimating Quantity',
          'theory':
              "We can use our visual fraction estimate to find a real quantity.\n\nIf the entire pie chart represents 400 people, we can estimate how many people are in the shaded region.",
          'hudTitle': 'Calculate People',
          'hudInstruction':
              "Since the shaded region is 75%, how many people does it represent? (75% of 400)",
          'correctValue': 300,
          'type': 'input',
        },
      ],
    },
    'hi': {
      'langCode': 'HI',
      'titleMain': 'प्रतिशत मात्रा और अनुमान',
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
      'labels': {'total': 'कुल'},
      'steps': [
        {
          'title': 'चरण 1: 10% ज्ञात करना',
          'theory':
              "प्रतिशत का अर्थ है 'प्रति 100'। किसी मात्रा का प्रतिशत ज्ञात करने का अर्थ है कुल राशि का वह अंश खोजना।\n\nकिसी भी मात्रा का 10% ज्ञात करने के लिए, बस 10 से विभाजित करें (या दशमलव बिंदु को एक स्थान बाईं ओर ले जाएं)।\n\nमान लें कि हमारे पास 500 की मात्रा है।",
          'hudTitle': '10% की गणना करें',
          'hudInstruction': "500 का 10% क्या है?",
          'correctValue': 50,
          'type': 'input',
        },
        {
          'title': 'चरण 2: 5% ज्ञात करना',
          'theory':
              "एक बार जब आप 10% जान लेते हैं, तो 5% ज्ञात करना बहुत आसान है क्योंकि 5%, 10% का ठीक आधा होता है।\n\nहम जानते हैं कि 500 का 10% 50 है।",
          'hudTitle': '5% की गणना करें',
          'hudInstruction': "500 का 5% क्या है? (अपने पिछले उत्तर का आधा)",
          'correctValue': 25,
          'type': 'input',
        },
        {
          'title': 'चरण 3: प्रतिशत का संयोजन',
          'theory':
              "आप अधिक जटिल प्रतिशत खोजने के लिए सरल प्रतिशत को जोड़ सकते हैं।\n\nउदाहरण के लिए, 15% केवल 10% + 5% है।\nचूंकि हम जानते हैं कि 10% 50 है, और 5% 25 है...",
          'hudTitle': 'मानों को मिलाएं',
          'hudInstruction':
              "500 का 15% क्या है? (चरण 1 और 2 से अपने उत्तर जोड़ें)",
          'correctValue': 75,
          'type': 'input',
        },
        {
          'title': 'चरण 4: दृश्य अनुमान',
          'theory':
              "अक्सर, हम एक पाई चार्ट की तरह, पूरे आकार के अंशों को देखकर प्रतिशत का अनुमान लगाते हैं।\n\nकैनवास पर पाई चार्ट देखें। पूरा चक्र 100% का प्रतिनिधित्व करता है।",
          'hudTitle': 'प्रतिशत का अनुमान लगाएं',
          'hudInstruction':
              "पाई चार्ट देखें। वृत्त का कितना प्रतिशत एम्बर छायांकित है?",
          'options': ['25%', '50%', '75%', '100%'],
          'correctIdx': 2,
          'type': 'mcq',
        },
        {
          'title': 'चरण 5: मात्रा का अनुमान लगाना',
          'theory':
              "हम एक वास्तविक मात्रा खोजने के लिए अपने दृश्य अंश अनुमान का उपयोग कर सकते हैं।\n\nयदि संपूर्ण पाई चार्ट 400 लोगों का प्रतिनिधित्व करता है, तो हम अनुमान लगा सकते हैं कि छायांकित क्षेत्र में कितने लोग हैं।",
          'hudTitle': 'लोगों की गणना करें',
          'hudInstruction':
              "चूंकि छायांकित क्षेत्र 75% है, यह कितने लोगों का प्रतिनिधित्व करता है? (400 का 75%)",
          'correctValue': 300,
          'type': 'input',
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
      _step4SelectedAnswer = -1;
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
      if (_step4SelectedAnswer == -1) {
        _showFeedback(_getString('selectWarn'), false);
        return;
      }
      int correctIdx = currentScenario['correctIdx'] as int? ?? -1;
      if (_step4SelectedAnswer == correctIdx) {
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
      _step4SelectedAnswer = answerIndex;
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
      int currentAnswer = -1;
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
                painter: PercentageQuantityEstimationPainter(
                  isDark: _isDarkTheme,
                  step: _currentStep,
                  isInteractionComplete: _interactionCompleted,
                  labels: tLabels,
                ),
              ),

              // Floating math summary overlays
              if (_currentStep == 0 && _interactionCompleted)
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
                      "10% of 500 = 50",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (_currentStep == 1 && _interactionCompleted)
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
                      "5% of 500 = 25",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (_currentStep == 2 && _interactionCompleted)
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
                      "10% + 5% = 15%\n50 + 25 = 75",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              if (_currentStep == 3 && _interactionCompleted)
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
                      "3/4 Shaded = 75%",
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (_currentStep == 4 && _interactionCompleted)
                Positioned(
                  top: 30,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      border: Border.all(color: Colors.greenAccent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "75% of 400 = 300 People",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
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
                              Icons.pie_chart,
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
                        Icons.pie_chart,
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
class PercentageQuantityEstimationPainter extends CustomPainter {
  final bool isDark;
  final int step;
  final bool isInteractionComplete;
  final Map<String, dynamic> labels;

  PercentageQuantityEstimationPainter({
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
      double fontSize = 18,
      bool shadow = false,
    }) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
            shadows: shadow
                ? [
                    Shadow(
                      color: isDark ? Colors.black : Colors.white,
                      blurRadius: 4,
                    ),
                  ]
                : null,
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

    if (step <= 2) {
      // Base Bar 500
      double bW = 400; // Base Width
      double bH = 60; // Base Height
      Rect rBase = Rect.fromCenter(center: center, width: bW, height: bH);

      canvas.drawRect(
        rBase,
        Paint()..color = Colors.blueAccent.withOpacity(0.4),
      );
      canvas.drawRect(
        rBase,
        Paint()
          ..color = Colors.blueAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      drawText(
        "500 (${labels['total'] ?? 'Total'})",
        center + const Offset(0, -60),
        Colors.amber,
        fontSize: 24,
        shadow: true,
      );

      // Step 1: 10%
      if (step == 0) {
        if (isInteractionComplete) {
          double bW10 = 40; // 10%
          Rect r10 = Rect.fromCenter(
            center: center + const Offset(-180, 0),
            width: bW10,
            height: bH,
          );
          canvas.drawRect(
            r10,
            Paint()..color = Colors.greenAccent.withOpacity(0.8),
          );
          canvas.drawRect(
            r10,
            Paint()
              ..color = Colors.greenAccent
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
          drawText(
            "10%",
            center + const Offset(-180, 50),
            Colors.greenAccent,
            shadow: true,
          );
        }
      }
      // Step 2: 5%
      else if (step == 1) {
        double bW10 = 40; // 10% (Static background highlight)
        Rect r10 = Rect.fromCenter(
          center: center + const Offset(-180, 0),
          width: bW10,
          height: bH,
        );
        canvas.drawRect(
          r10,
          Paint()..color = Colors.greenAccent.withOpacity(0.5),
        );

        if (isInteractionComplete) {
          double bW5 = 20; // 5%
          Rect r5 = Rect.fromCenter(
            center: center + const Offset(-150, 0),
            width: bW5,
            height: bH,
          );
          canvas.drawRect(r5, Paint()..color = Colors.amber.withOpacity(0.8));
          canvas.drawRect(
            r5,
            Paint()
              ..color = Colors.amber
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
          drawText(
            "5%",
            center + const Offset(-150, 50),
            Colors.amber,
            shadow: true,
          );
        }
      }
      // Step 3: 15% (10 + 5)
      else if (step == 2) {
        if (isInteractionComplete) {
          double bW15 = 60; // 15%
          Rect r15 = Rect.fromCenter(
            center: center + const Offset(-170, 0),
            width: bW15,
            height: bH,
          );
          canvas.drawRect(
            r15,
            Paint()..color = Colors.purpleAccent.withOpacity(0.8),
          );
          canvas.drawRect(
            r15,
            Paint()
              ..color = Colors.purpleAccent
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
          drawText(
            "15%",
            center + const Offset(-170, 50),
            Colors.purpleAccent,
            shadow: true,
          );
        }
      }
    } else if (step == 3 || step == 4) {
      // Pie Chart
      Offset pieCenter = center + const Offset(0, 0);
      double radius = 120;

      // Empty circle background
      canvas.drawCircle(
        pieCenter,
        radius,
        Paint()
          ..color = Colors.blueGrey.withOpacity(0.3)
          ..style = PaintingStyle.fill,
      );

      // Shaded quadrants (3 out of 4)
      final pFill = Paint()
        ..color = Colors.amber
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: pieCenter, radius: radius),
        -math.pi / 2,
        (3 * math.pi) / 2,
        true,
        pFill,
      );

      // Lines
      final pLine = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(pieCenter, radius, pLine);
      canvas.drawLine(
        pieCenter + Offset(0, -radius),
        pieCenter + Offset(0, radius),
        pLine,
      );
      canvas.drawLine(
        pieCenter + Offset(-radius, 0),
        pieCenter + Offset(radius, 0),
        pLine,
      );

      if (step == 4) {
        drawText(
          "400 People Total",
          pieCenter + const Offset(0, 150),
          Colors.blueAccent,
          fontSize: 24,
          shadow: true,
        );
      }
    }
  }

  @override
  bool shouldRepaint(
    covariant PercentageQuantityEstimationPainter oldDelegate,
  ) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.step != step ||
        oldDelegate.isInteractionComplete != isInteractionComplete ||
        oldDelegate.labels != labels;
  }
}
