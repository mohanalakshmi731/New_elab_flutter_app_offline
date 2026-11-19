// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class InverseVariationLab extends StatefulWidget {
  const InverseVariationLab({Key? key}) : super(key: key);

  @override
  State<InverseVariationLab> createState() => _InverseVariationLabState();
}

class _InverseVariationLabState extends State<InverseVariationLab>
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

  // Step Specific State
  int _step2SelectedAnswer = -1;
  // -1 means no answer in MCQ
  final TextEditingController _inputController = TextEditingController();

  // --- Animations & Audio ---
  late AnimationController _curtainController;
  late Animation<Offset> _curtainAnimation;
  late AudioPlayer _audioPlayer;

  // --- Localization Data ---
  final Map<String, Map<String, dynamic>> _translations = {
    'en': {
      'langCode': 'EN',
      'titleMain': 'Inverse Variation',
      'chapterMain': 'Class 8 • Direct & Inverse Proportions',
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
      'labels': {
        'xLabel': 'X-Axis',
        'yLabel': 'Y-Axis',
        'gearA': 'Gear A',
        'gearB': 'Gear B',
      },
      'steps': [
        {
          'title': 'Step 1: Introduction to Inverse',
          'theory':
              "When two quantities are related such that an increase in one causes a proportional decrease in the other, they are in 'Inverse Variation'.\n\nMathematically: x × y = k (where k is a constant).\n\nIf you double 'x', 'y' must be halved to keep 'k' the same.",
          'hudTitle': 'Observe Area',
          'hudInstruction':
              "Observe the rectangles. As Width (x) increases, Height (y) decreases, but the Area (k) remains constant.",
          'type': 'observe',
        },
        {
          'title': 'Step 2: Workers and Time',
          'theory':
              "A classic example is building a wall.\n\nIf 5 workers can build a wall in 20 days, the total 'work constant' is 5 × 20 = 100 worker-days.\n\nIf we increase the workers to 10, how many days will it take? The product must remain 100.",
          'hudTitle': 'Solve for Time',
          'hudInstruction':
              "If 10 workers are hired instead of 5, how many days will it take?",
          'options': ['40 Days', '10 Days', '5 Days', '25 Days'],
          'correctIdx': 1,
          'type': 'mcq',
        },
        {
          'title': 'Step 3: Mechanical Gears',
          'theory':
              "Gears in an engine also follow inverse variation! The number of teeth on a gear and its rotational speed are inversely proportional.\n\nA large gear with 24 teeth is connected to a small gear with 8 teeth.\nThe ratio of their teeth is 3:1.",
          'hudTitle': 'Observe Rotation',
          'hudInstruction':
              "Because the small gear has 1/3 the teeth, it must spin 3 times as fast to keep up!",
          'type': 'observe',
        },
        {
          'title': 'Step 4: The Hyperbola Graph',
          'theory':
              "Unlike Direct Variation, which forms a straight line passing through the origin, Inverse Variation forms a curve.\n\nSince y = k/x, as 'x' gets larger, 'y' gets closer and closer to zero. This distinct curve is called a 'Hyperbola'.",
          'hudTitle': 'Analyze the Curve',
          'hudInstruction':
              "Notice how the curve never actually touches the X or Y axes (because division by zero is impossible).",
          'type': 'observe',
        },
        {
          'title': 'Step 5: Mathematical Application',
          'theory':
              "Let's apply the inverse variation formula: x₁y₁ = x₂y₂.\n\nA car traveling at 60 km/h takes 4 hours to reach its destination.\n\nIf the driver increases the speed to 80 km/h, how many hours will the journey take?",
          'hudTitle': 'Solve the Equation',
          'hudInstruction':
              "Calculate the new time taken (in hours). Use the equation: 60 × 4 = 80 × y₂",
          'correctValue': 3,
          'type': 'input',
        },
      ],
    },
    'hi': {
      'langCode': 'HI',
      'titleMain': 'प्रतिलोम समानुपात',
      'chapterMain': 'कक्षा 8 • सीधा और प्रतिलोम समानुपात',
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
      'labels': {
        'xLabel': 'X-अक्ष',
        'yLabel': 'Y-अक्ष',
        'gearA': 'गियर A',
        'gearB': 'गियर B',
      },
      'steps': [
        {
          'title': 'चरण 1: प्रतिलोम का परिचय',
          'theory':
              "जब दो मात्राएं इस प्रकार संबंधित होती हैं कि एक में वृद्धि के कारण दूसरे में आनुपातिक कमी होती है, तो वे 'प्रतिलोम समानुपात' (Inverse Variation) में होते हैं।\n\nगणितीय रूप से: x × y = k (जहाँ k एक स्थिरांक है)।\n\nयदि आप 'x' को दोगुना करते हैं, तो 'k' को समान रखने के लिए 'y' को आधा करना होगा।",
          'hudTitle': 'क्षेत्रफल का निरीक्षण करें',
          'hudInstruction':
              "आयतों का निरीक्षण करें। जैसे-जैसे चौड़ाई (x) बढ़ती है, ऊंचाई (y) कम होती जाती है, लेकिन क्षेत्रफल (k) स्थिर रहता है।",
          'type': 'observe',
        },
        {
          'title': 'चरण 2: मजदूर और समय',
          'theory':
              "एक उत्कृष्ट उदाहरण दीवार बनाना है।\n\nयदि 5 मजदूर 20 दिनों में एक दीवार बना सकते हैं, तो कुल 'कार्य स्थिरांक' 5 × 20 = 100 मजदूर-दिन है।\n\nयदि हम मजदूरों को 10 तक बढ़ाते हैं, तो कितने दिन लगेंगे? गुणनफल 100 रहना चाहिए।",
          'hudTitle': 'समय ज्ञात करें',
          'hudInstruction':
              "यदि 5 के बजाय 10 मजदूरों को काम पर रखा जाता है, तो कितने दिन लगेंगे?",
          'options': ['40 दिन', '10 दिन', '5 दिन', '25 दिन'],
          'correctIdx': 1,
          'type': 'mcq',
        },
        {
          'title': 'चरण 3: यांत्रिक गियर',
          'theory':
              "इंजन में गियर भी प्रतिलोम समानुपात का पालन करते हैं! गियर पर दांतों की संख्या और उसकी घूर्णन गति व्युत्क्रमानुपाती (inversely proportional) होती है।\n\n24 दांतों वाला एक बड़ा गियर 8 दांतों वाले एक छोटे गियर से जुड़ा होता है।\nउनके दांतों का अनुपात 3:1 है।",
          'hudTitle': 'रोटेशन का निरीक्षण करें',
          'hudInstruction':
              "चूंकि छोटे गियर में 1/3 दांत होते हैं, इसलिए इसे गति बनाए रखने के लिए 3 गुना तेज घूमना चाहिए!",
          'type': 'observe',
        },
        {
          'title': 'चरण 4: अतिपरवलय ग्राफ',
          'theory':
              "सीधे समानुपात के विपरीत, जो मूल बिंदु से गुजरने वाली एक सीधी रेखा बनाता है, प्रतिलोम समानुपात एक वक्र बनाता है।\n\nचूंकि y = k/x, जैसे-जैसे 'x' बड़ा होता जाता है, 'y' शून्य के करीब और करीब आता जाता है। इस विशिष्ट वक्र को 'अतिपरवलय' (Hyperbola) कहा जाता है।",
          'hudTitle': 'वक्र का विश्लेषण करें',
          'hudInstruction':
              "ध्यान दें कि कैसे वक्र कभी भी वास्तव में X या Y अक्षों को नहीं छूता है (क्योंकि शून्य से विभाजन असंभव है)।",
          'type': 'observe',
        },
        {
          'title': 'चरण 5: गणितीय अनुप्रयोग',
          'theory':
              "आइए प्रतिलोम समानुपात सूत्र लागू करें: x₁y₁ = x₂y₂।\n\n60 किमी/घंटा की गति से यात्रा करने वाली एक कार को अपने गंतव्य तक पहुंचने में 4 घंटे लगते हैं।\n\nयदि चालक गति को 80 किमी/घंटा तक बढ़ाता है, तो यात्रा में कितने घंटे लगेंगे?",
          'hudTitle': 'समीकरण हल करें',
          'hudInstruction':
              "लिए गए नए समय (घंटों में) की गणना करें। समीकरण का उपयोग करें: 60 × 4 = 80 × y₂",
          'correctValue': 3,
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
    });
  }

  void _loadScenario(int step) {
    setState(() {
      _currentStep = step;
      _feedbackMessage = null;
      _interactionCompleted = false;

      // Reset Step State
      _step2SelectedAnswer = -1;
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
    } else if (type == 'mcq') {
      int answerIndex = -1;
      if (_currentStep == 1) answerIndex = _step2SelectedAnswer;

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
      if (_currentStep == 1) _step2SelectedAnswer = answerIndex;
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
      return Text(
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
      if (_currentStep == 1) currentAnswer = _step2SelectedAnswer;
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
                hintText: "y₂ = ?",
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
                painter: InverseVariationPainter(
                  isDark: _isDarkTheme,
                  step: _currentStep,
                ),
              ),

              // Step specific dynamic overlays
              if (_currentStep == 0) ...[
                Positioned(
                  top: constraints.maxHeight / 2 - 160,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.black54,
                    child: const Text(
                      "x = 10, y = 20\nArea = 200",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Positioned(
                  top: constraints.maxHeight / 2 + 120,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.black54,
                    child: const Text(
                      "x = 20, y = 10\nArea = 200",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ] else if (_currentStep == 4) ...[
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
                      "60 × 4 = 240\n80 × y₂ = 240",
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

    // Theory is now formatted with native Unicode inside the translations map directly
    String formattedTheory = currentScenario['theory'].toString();

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
                      horizontal: 20,
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
                        Icons.settings_suggest,
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
class InverseVariationPainter extends CustomPainter {
  final bool isDark;
  final int step;

  InverseVariationPainter({required this.isDark, required this.step});

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

    if (step == 0) {
      // Draw Area rectangles
      final rectPaint1 = Paint()
        ..color = Colors.blueAccent.withOpacity(0.5)
        ..style = PaintingStyle.fill;
      final rectPaint2 = Paint()
        ..color = Colors.greenAccent.withOpacity(0.5)
        ..style = PaintingStyle.fill;
      final strokePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      // Rectangle 1 (10 x 20 -> scaled to 100 x 200)
      Rect r1 = Rect.fromCenter(
        center: center + const Offset(0, -100),
        width: 100,
        height: 200,
      );
      canvas.drawRect(r1, rectPaint1);
      canvas.drawRect(r1, strokePaint);

      // Rectangle 2 (20 x 10 -> scaled to 200 x 100)
      Rect r2 = Rect.fromCenter(
        center: center + const Offset(0, 100),
        width: 200,
        height: 100,
      );
      canvas.drawRect(r2, rectPaint2);
      canvas.drawRect(r2, strokePaint);
    } else if (step == 1) {
      // Draw Workers (Circles)
      final p1 = Paint()..color = Colors.orangeAccent;
      final p2 = Paint()..color = Colors.purpleAccent;

      for (int i = 0; i < 5; i++) {
        canvas.drawCircle(center + Offset(-100 + (i * 50), -80), 15, p1);
      }
      for (int i = 0; i < 10; i++) {
        canvas.drawCircle(center + Offset(-225 + (i * 50), 80), 15, p2);
      }
    } else if (step == 2 || step == 3) {
      // Function to draw gears
      void drawGear(Offset c, double r, Color color, int teeth) {
        final p = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(c, r * 0.8, p); // inner

        final pTeeth = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8;
        for (int i = 0; i < teeth; i++) {
          double angle = i * 2 * math.pi / teeth;
          canvas.drawLine(
            c,
            c + Offset(math.cos(angle) * r, math.sin(angle) * r),
            pTeeth,
          );
        }
        canvas.drawCircle(c, r * 0.3, Paint()..color = Colors.black87); // hole
      }

      // Large Gear (24 Teeth, R=60)
      drawGear(center + const Offset(-100, 0), 60, Colors.blueAccent, 24);
      // Small Gear (8 Teeth, R=20)
      drawGear(center + const Offset(10, 0), 20, Colors.amber, 8);
    } else if (step == 4) {
      // Hyperbola Graph
      final axisPaint = Paint()
        ..color = Colors.white70
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      // Axes
      canvas.drawLine(
        center + const Offset(-150, 100),
        center + const Offset(150, 100),
        axisPaint,
      ); // X
      canvas.drawLine(
        center + const Offset(-150, 100),
        center + const Offset(-150, -100),
        axisPaint,
      ); // Y

      // Hyperbola Curve y = 1/x (scaled)
      final curvePaint = Paint()
        ..color = Colors.amber
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      Path curve = Path();
      bool first = true;
      for (double x = 10; x <= 250; x += 5) {
        double y = 2000 / x; // k = 2000 for visual scale
        if (y > 180) continue; // cap height
        Offset point = center + Offset(-150 + x, 100 - y);
        if (first) {
          curve.moveTo(point.dx, point.dy);
          first = false;
        } else {
          curve.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(curve, curvePaint);
    }
  }

  @override
  bool shouldRepaint(covariant InverseVariationPainter oldDelegate) {
    return oldDelegate.isDark != isDark || oldDelegate.step != step;
  }
}