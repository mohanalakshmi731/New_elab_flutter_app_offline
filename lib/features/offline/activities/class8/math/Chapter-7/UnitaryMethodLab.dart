// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class UnitaryMethodLab extends StatefulWidget {
  const UnitaryMethodLab({Key? key}) : super(key: key);

  @override
  State<UnitaryMethodLab> createState() => _UnitaryMethodLabState();
}

class _UnitaryMethodLabState extends State<UnitaryMethodLab>
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
      'titleMain': 'The Unitary Method',
      'chapterMain': 'Class 8 • Direct & Inverse Proportions',
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
        'cost': 'Cost:',
        'apples': 'Apples',
        'builders': 'Builders',
        'days': 'Days',
      },
      'steps': [
        {
          'title': 'Step 1: Direct Proportion',
          'theory':
              "Welcome to Concept 1: Direct Proportion.\n\nWhen two quantities increase or decrease together at the same rate, they are in direct proportion.\n\nImagine 3 apples cost \6. If you buy more apples, the total cost will naturally increase.",
          'hudTitle': 'Observe the Baseline',
          'hudInstruction':
              "Observe the canvas. 3 apples have a total cost of \6.",
          'type': 'observe',
        },
        {
          'title': 'Step 2: Finding the Unit Value',
          'theory':
              "To find the cost of ANY number of apples, we must first find the 'Unit Value' (the value of exactly ONE item).\n\nIf 3 apples cost \6, we divide the total cost by the number of apples to find the cost of 1 apple.",
          'hudTitle': 'Calculate Unit Cost',
          'hudInstruction': "Calculate the cost of 1 apple (\6 ÷ 3).",
          'correctValue': 2,
          'type': 'input',
        },
        {
          'title': 'Step 3: Scaling Up',
          'theory':
              "Now that we know 1 apple costs \2, we can find the cost of any quantity by simply multiplying!\n\nThis two-step process (find one unit, then multiply for many units) is called the 'Unitary Method'.",
          'hudTitle': 'Solve for N Units',
          'hudInstruction': "What is the cost of 5 apples? (5 × \2)",
          'correctValue': 10,
          'type': 'input',
        },
        {
          'title': 'Step 4: Inverse Proportion',
          'theory':
              "Now let's look at Inverse Proportion. This happens when an increase in one quantity causes a proportional decrease in another.\n\nImagine building a house. If 4 builders take 6 days to finish the job, what happens if we hire more builders? The days required will DECREASE.",
          'hudTitle': 'Observe the Work Rate',
          'hudInstruction':
              "Observe the canvas. 4 builders complete the project in 6 days.",
          'type': 'observe',
        },
        {
          'title': 'Step 5: The Rule of Three',
          'theory':
              "First, find the total 'worker-days' needed for the whole job. 4 builders × 6 days = 24 worker-days.\n\nIf we hire 8 builders, the total work (24) remains the same. We divide the total work by the new number of builders.",
          'hudTitle': 'Solve Inverse Proportion',
          'hudInstruction':
              "If 8 builders are working, how many days will it take? (24 ÷ 8)",
          'correctValue': 3,
          'type': 'input',
        },
      ],
    },
    'hi': {
      'langCode': 'HI',
      'titleMain': 'एकात्मक विधि (Unitary Method)',
      'chapterMain': 'कक्षा 8 • सीधा और प्रतिलोम समानुपात',
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
        'cost': 'लागत (Cost):',
        'apples': 'सेब (Apples)',
        'builders': 'मजदूर',
        'days': 'दिन (Days)',
      },
      'steps': [
        {
          'title': 'चरण 1: सीधा समानुपात',
          'theory':
              "कांसेप्ट 1 में आपका स्वागत है: सीधा समानुपात।\n\nजब दो मात्राएँ एक ही दर पर एक साथ बढ़ती या घटती हैं, तो वे सीधे समानुपात में होती हैं।\n\nकल्पना करें कि 3 सेब की कीमत \6 है। यदि आप अधिक सेब खरीदते हैं, तो कुल लागत स्वाभाविक रूप से बढ़ जाएगी।",
          'hudTitle': 'बेसलाइन का निरीक्षण करें',
          'hudInstruction':
              "कैनवास का निरीक्षण करें। 3 सेब की कुल कीमत \6 है।",
          'type': 'observe',
        },
        {
          'title': 'चरण 2: इकाई मूल्य ज्ञात करना',
          'theory':
              "किसी भी संख्या में सेब की कीमत जानने के लिए, हमें पहले 'इकाई मूल्य' (ठीक एक वस्तु का मूल्य) खोजना होगा।\n\nयदि 3 सेब की कीमत \6 है, तो 1 सेब की कीमत जानने के लिए हम कुल कीमत को सेब की संख्या से विभाजित करते हैं।",
          'hudTitle': 'इकाई लागत की गणना करें',
          'hudInstruction': "1 सेब की कीमत की गणना करें (\6 ÷ 3)।",
          'correctValue': 2,
          'type': 'input',
        },
        {
          'title': 'चरण 3: स्केलिंग अप',
          'theory':
              "अब जब हम जानते हैं कि 1 सेब की कीमत \2 है, तो हम केवल गुणा करके किसी भी मात्रा की कीमत का पता लगा सकते हैं!\n\nइस दो-चरणीय प्रक्रिया (एक इकाई खोजें, फिर कई इकाइयों के लिए गुणा करें) को 'एकात्मक विधि' (Unitary Method) कहा जाता है।",
          'hudTitle': 'N इकाइयों के लिए हल करें',
          'hudInstruction': "5 सेब की कीमत क्या है? (5 × \2)",
          'correctValue': 10,
          'type': 'input',
        },
        {
          'title': 'चरण 4: प्रतिलोम समानुपात',
          'theory':
              "अब प्रतिलोम समानुपात (Inverse Proportion) देखते हैं। यह तब होता है जब एक मात्रा में वृद्धि से दूसरे में आनुपातिक कमी आती है।\n\nकल्पना करें कि एक घर बनाया जा रहा है। यदि 4 बिल्डरों को काम खत्म करने में 6 दिन लगते हैं, तो क्या होगा यदि हम अधिक बिल्डरों को नियुक्त करें? आवश्यक दिन घट जाएंगे।",
          'hudTitle': 'कार्य दर का निरीक्षण करें',
          'hudInstruction':
              "कैनवास का निरीक्षण करें। 4 बिल्डर 6 दिनों में परियोजना को पूरा करते हैं।",
          'type': 'observe',
        },
        {
          'title': 'चरण 5: तीन का नियम',
          'theory':
              "सबसे पहले, पूरे काम के लिए आवश्यक कुल 'मजदूर-दिन' (worker-days) का पता लगाएं। 4 बिल्डर × 6 दिन = 24 मजदूर-दिन।\n\nयदि हम 8 बिल्डरों को नियुक्त करते हैं, तो कुल कार्य (24) वही रहता है। हम कुल कार्य को बिल्डरों की नई संख्या से विभाजित करते हैं।",
          'hudTitle': 'प्रतिलोम हल करें',
          'hudInstruction':
              "यदि 8 बिल्डर काम कर रहे हैं, तो कितने दिन लगेंगे? (24 ÷ 8)",
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
      _loadScenario(0); // init first step
    });
  }

  void _loadScenario(int step) {
    setState(() {
      _currentStep = step;
      _feedbackMessage = null;
      _interactionCompleted = false;

      // Reset Step States
      _mcqSelectedAnswer = -1;
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
    setState(() => _mcqSelectedAnswer = answerIndex);
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
                painter: UnitaryMethodPainter(
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

    // Format Theory to handle MathJax strings natively if any
    String formattedTheory = currentScenario['theory']
        .toString()
        .replaceAll(r"$", "")
        .replaceAll(r"\times", "×");

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
                      const Icon(Icons.balance, color: Colors.amber, size: 80),
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
class UnitaryMethodPainter extends CustomPainter {
  final bool isDark;
  final int step;
  final bool isInteractionComplete;
  final Map<String, dynamic> labels;

  UnitaryMethodPainter({
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

    void drawApples(int count, double xStart, double yPos) {
      final pRed = Paint()..color = Colors.redAccent;
      final pGreen = Paint()..color = Colors.green;
      for (int i = 0; i < count; i++) {
        Offset p = Offset(xStart + (i * 60), yPos);
        canvas.drawCircle(p, 20, pRed);
        canvas.drawCircle(p + const Offset(0, -20), 6, pGreen);
      }
    }

    void drawCost(String cost, double xPos, double yPos) {
      Rect tag = Rect.fromCenter(
        center: Offset(xPos, yPos),
        width: 80,
        height: 40,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(tag, const Radius.circular(8)),
        Paint()..color = Colors.amber,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(tag, const Radius.circular(8)),
        Paint()
          ..color = Colors.orange
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      drawText(cost, Offset(xPos, yPos), Colors.black, fontSize: 20);
    }

    void drawBuilders(int count, double xStart, double yPos) {
      final pHead = Paint()..color = Colors.amber;
      final pBody = Paint()
        ..color = Colors.blueAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      for (int i = 0; i < count; i++) {
        Offset p = Offset(xStart + (i * 45), yPos);
        canvas.drawCircle(p + const Offset(0, -15), 10, pHead);
        canvas.drawLine(
          p + const Offset(0, -5),
          p + const Offset(0, 15),
          pBody,
        );
        canvas.drawLine(
          p + const Offset(0, 0),
          p + const Offset(-10, 10),
          pBody,
        );
        canvas.drawLine(
          p + const Offset(0, 0),
          p + const Offset(10, 10),
          pBody,
        );
      }
    }

    void drawDays(double xPos, double yPos) {
      IconData calendar = Icons.calendar_month;
      TextPainter textPainter = TextPainter(textDirection: TextDirection.rtl);
      textPainter.text = TextSpan(
        text: String.fromCharCode(calendar.codePoint),
        style: TextStyle(
          fontSize: 60.0,
          fontFamily: calendar.fontFamily,
          color: Colors.blueAccent,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(xPos - 30, yPos - 30));
    }

    // Direct Proportion (Apples & Cost)
    if (step <= 2) {
      // Base: 3 Apples = $6
      drawApples(3, center.dx - 120, center.dy - 100);
      drawCost("\6", center.dx + 120, center.dy - 100);

      final arrowPaint = Paint()
        ..color = Colors.white54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawLine(
        center + const Offset(-20, -100),
        center + const Offset(60, -100),
        arrowPaint,
      );

      if (step >= 1) {
        // Find 1 Unit
        drawApples(1, center.dx - 120, center.dy + 20);
        if (step == 1 && isInteractionComplete) {
          drawCost("\2", center.dx + 120, center.dy + 20);
        } else if (step > 1) {
          drawCost("\2", center.dx + 120, center.dy + 20);
        } else {
          drawCost("?", center.dx + 120, center.dy + 20);
        }
        canvas.drawLine(
          center + const Offset(-80, 20),
          center + const Offset(60, 20),
          arrowPaint,
        );
      }

      if (step == 2) {
        // Find 5 Units
        drawApples(5, center.dx - 220, center.dy + 140);
        if (isInteractionComplete) {
          drawCost("\10", center.dx + 120, center.dy + 140);
        } else {
          drawCost("?", center.dx + 120, center.dy + 140);
        }
        canvas.drawLine(
          center + const Offset(80, 140),
          center + const Offset(60, 140), // Reversed arrow conceptually
          arrowPaint,
        );
        canvas.drawLine(
          center + const Offset(20, 140),
          center + const Offset(60, 140),
          arrowPaint,
        );
      }
    }
    // Inverse Proportion (Builders & Days)
    else if (step == 3 || step == 4) {
      // Base: 4 Builders = 6 Days
      drawBuilders(4, center.dx - 150, center.dy - 100);
      drawDays(center.dx + 120, center.dy - 100);
      drawText(
        "6 ${labels['days'] ?? 'Days'}",
        Offset(center.dx + 120, center.dy - 20),
        Colors.amber,
        fontSize: 18,
      );

      final arrowPaint = Paint()
        ..color = Colors.white54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawLine(
        center + const Offset(0, -100),
        center + const Offset(60, -100),
        arrowPaint,
      );

      // Total Work visualization
      Rect workBlock = Rect.fromCenter(
        center: center + const Offset(0, 0),
        width: 300,
        height: 40,
      );
      canvas.drawRect(
        workBlock,
        Paint()..color = Colors.green.withOpacity(0.3),
      );
      canvas.drawRect(
        workBlock,
        Paint()
          ..color = Colors.greenAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      drawText("Total Work = 24", center, Colors.greenAccent, fontSize: 18);

      if (step == 4) {
        // Find 8 Builders
        drawBuilders(8, center.dx - 240, center.dy + 100);
        if (isInteractionComplete) {
          drawDays(center.dx + 120, center.dy + 100);
          drawText(
            "3 ${labels['days'] ?? 'Days'}",
            Offset(center.dx + 120, center.dy + 160),
            Colors.amber,
            fontSize: 18,
          );
        } else {
          drawText(
            "? ${labels['days'] ?? 'Days'}",
            Offset(center.dx + 120, center.dy + 100),
            Colors.amber,
            fontSize: 24,
          );
        }
        canvas.drawLine(
          center + const Offset(100, 100),
          center + const Offset(60, 100),
          arrowPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant UnitaryMethodPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.step != step ||
        oldDelegate.isInteractionComplete != isInteractionComplete ||
        oldDelegate.labels != labels;
  }
}
