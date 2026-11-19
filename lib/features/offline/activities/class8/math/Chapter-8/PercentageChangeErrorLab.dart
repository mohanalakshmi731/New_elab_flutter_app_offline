// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class PercentageChangeErrorLab extends StatefulWidget {
  const PercentageChangeErrorLab({Key? key}) : super(key: key);

  @override
  State<PercentageChangeErrorLab> createState() =>
      _PercentageChangeErrorLabState();
}

class _PercentageChangeErrorLabState extends State<PercentageChangeErrorLab>
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
      'titleMain': 'Percentage Change & Error',
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
        'exact': 'Exact Value',
        'estimated': 'Estimated Value',
        'error': 'Error',
      },
      'steps': [
        {
          'title': 'Step 1: Percentage Increase',
          'theory':
              "Percentage Change tells us how much a quantity has grown or shrunk relative to its original amount.\n\nFormula: (Change / Original) × 100\n\nIf a town's population grows from 10,000 to 12,000, the change is 2,000.",
          'hudTitle': 'Calculate Increase',
          'hudInstruction':
              "What is the percentage increase? (2000 / 10000) × 100",
          'correctValue': 20,
          'type': 'input',
        },
        {
          'title': 'Step 2: Percentage Decrease',
          'theory':
              "The same formula works for decreases! Always divide by the ORIGINAL amount, not the new one.\n\nIf a \$50 shirt is on sale for \$40, the decrease is \$10.\nThe original price is \$50.",
          'hudTitle': 'Calculate Decrease',
          'hudInstruction': "What is the percentage decrease? (10 / 50) × 100",
          'correctValue': 20,
          'type': 'input',
        },
        {
          'title': 'Step 3: Introducing Percentage Error',
          'theory':
              "Sometimes we estimate or measure things incorrectly. Percentage Error tells us how far off our estimate was from the EXACT value.\n\nError = |Estimated Value - Exact Value|",
          'hudTitle': 'Observe the Error',
          'hudInstruction':
              "Observe the bars. The blue bar is the Exact value (300). The estimated value is 360. The red segment shows the Error (+60).",
          'type': 'observe',
        },
        {
          'title': 'Step 4: The Error Formula',
          'theory':
              "To find the Percentage Error, we compare the Error to the EXACT value, not the estimated value.\n\nFormula: (|Error| / Exact Value) × 100\n\nWe estimated 360, but the exact was 300. The error is 60.",
          'hudTitle': 'Identify the Base',
          'hudInstruction':
              "Which value must go in the denominator (bottom) to calculate the % error?",
          'options': ['Estimated (360)', 'Exact (300)', 'Error (60)'],
          'correctIdx': 1,
          'type': 'mcq',
        },
        {
          'title': 'Step 5: Calculate Percentage Error',
          'theory':
              "Now apply the formula to our example.\n\nError = 60\nExact Value = 300\n\nPercentage Error = (60 / 300) × 100",
          'hudTitle': 'Solve for % Error',
          'hudInstruction': "Calculate the Percentage Error.",
          'correctValue': 20,
          'type': 'input',
        },
      ],
    },
    'hi': {
      'langCode': 'HI',
      'titleMain': 'प्रतिशत परिवर्तन और त्रुटि',
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
        'exact': 'सटीक मान',
        'estimated': 'अनुमानित मान',
        'error': 'त्रुटि',
      },
      'steps': [
        {
          'title': 'चरण 1: प्रतिशत वृद्धि',
          'theory':
              "प्रतिशत परिवर्तन हमें बताता है कि कोई मात्रा अपनी मूल मात्रा के सापेक्ष कितनी बढ़ी या घटी है।\n\nसूत्र: (परिवर्तन / मूल) × 100\n\nयदि किसी कस्बे की जनसंख्या 10,000 से बढ़कर 12,000 हो जाती है, तो परिवर्तन 2,000 है।",
          'hudTitle': 'वृद्धि की गणना करें',
          'hudInstruction': "प्रतिशत वृद्धि क्या है? (2000 / 10000) × 100",
          'correctValue': 20,
          'type': 'input',
        },
        {
          'title': 'चरण 2: प्रतिशत कमी',
          'theory':
              "यही सूत्र कमी के लिए काम करता है! हमेशा मूल (ORIGINAL) राशि से विभाजित करें, नई राशि से नहीं।\n\nयदि \$50 की शर्ट \$40 में बिक्री पर है, तो कमी \$10 है।\nमूल मूल्य \$50 है।",
          'hudTitle': 'कमी की गणना करें',
          'hudInstruction': "प्रतिशत कमी क्या है? (10 / 50) × 100",
          'correctValue': 20,
          'type': 'input',
        },
        {
          'title': 'चरण 3: प्रतिशत त्रुटि का परिचय',
          'theory':
              "कभी-कभी हम चीजों का गलत अनुमान लगाते हैं या मापते हैं। प्रतिशत त्रुटि हमें बताती है कि हमारा अनुमान EXACT मान से कितना दूर था।\n\nत्रुटि = |अनुमानित मान - सटीक मान|",
          'hudTitle': 'त्रुटि का निरीक्षण करें',
          'hudInstruction':
              "बारों का निरीक्षण करें। नीली पट्टी सटीक मान (300) है। अनुमानित मान 360 है। लाल खंड त्रुटि (+60) दिखाता है।",
          'type': 'observe',
        },
        {
          'title': 'चरण 4: त्रुटि सूत्र',
          'theory':
              "प्रतिशत त्रुटि ज्ञात करने के लिए, हम त्रुटि की तुलना EXACT मान से करते हैं, अनुमानित मान से नहीं।\n\nसूत्र: (|त्रुटि| / सटीक मान) × 100\n\nहमने 360 का अनुमान लगाया, लेकिन सटीक 300 था। त्रुटि 60 है।",
          'hudTitle': 'आधार की पहचान करें',
          'hudInstruction':
              "% त्रुटि की गणना करने के लिए हर (नीचे) में कौन सा मान जाना चाहिए?",
          'options': ['अनुमानित (360)', 'सटीक (300)', 'त्रुटि (60)'],
          'correctIdx': 1,
          'type': 'mcq',
        },
        {
          'title': 'चरण 5: प्रतिशत त्रुटि की गणना करें',
          'theory':
              "अब हमारे उदाहरण में सूत्र लागू करें।\n\nत्रुटि = 60\nसटीक मान = 300\n\nप्रतिशत त्रुटि = (60 / 300) × 100",
          'hudTitle': '% त्रुटि के लिए हल करें',
          'hudInstruction': "प्रतिशत त्रुटि की गणना करें।",
          'correctValue': 20,
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
                painter: PercentageChangePainter(
                  isDark: _isDarkTheme,
                  step: _currentStep,
                  isInteractionComplete: _interactionCompleted,
                  labels: tLabels,
                ),
              ),

              // Only in Step 1/2 - Floating math summary
              if (_currentStep == 0 || _currentStep == 1)
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
                      _currentStep == 0
                          ? "10,000 → 12,000 (+2,000)"
                          : "\$50 → \$40 (-\$10)",
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
                              Icons.analytics,
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
                        Icons.analytics,
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
class PercentageChangePainter extends CustomPainter {
  final bool isDark;
  final int step;
  final bool isInteractionComplete;
  final Map<String, dynamic> labels;

  PercentageChangePainter({
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

    void drawBar(Rect rect, Paint paint, {bool border = true}) {
      canvas.drawRect(rect, paint);
      if (border) {
        canvas.drawRect(
          rect,
          Paint()
            ..color = Colors.white54
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }

    double h = 40;

    if (step == 0) {
      // Increase Bar
      final pBase = Paint()
        ..color = Colors.blueAccent.withOpacity(0.8)
        ..style = PaintingStyle.fill;
      final pInc = Paint()
        ..color = Colors.greenAccent.withOpacity(0.8)
        ..style = PaintingStyle.fill;

      drawText(
        "10,000",
        center + const Offset(-40, -100),
        isDark ? Colors.white : Colors.black87,
        fontSize: 24,
        shadow: true,
      );
      Rect baseRect = Rect.fromLTWH(center.dx - 140, center.dy - 60, 200, h);
      drawBar(baseRect, pBase);

      if (isInteractionComplete) {
        drawText(
          "+2,000",
          center + const Offset(120, -100),
          Colors.green,
          fontSize: 24,
          shadow: true,
        );
        Rect incRect = Rect.fromLTWH(center.dx + 60, center.dy - 60, 40, h);
        drawBar(incRect, pInc);
        drawText(
          "12,000 Total",
          center + const Offset(0, 20),
          Colors.amber,
          fontSize: 24,
          shadow: true,
        );
      }
    } else if (step == 1) {
      // Decrease Bar
      final pBase = Paint()
        ..color = Colors.blueAccent.withOpacity(0.8)
        ..style = PaintingStyle.fill;
      final pDec = Paint()
        ..color = Colors.redAccent.withOpacity(0.8)
        ..style = PaintingStyle.fill;

      drawText(
        "\$50",
        center + const Offset(0, -100),
        isDark ? Colors.white : Colors.black87,
        fontSize: 24,
        shadow: true,
      );
      Rect baseRect = Rect.fromLTWH(center.dx - 150, center.dy - 60, 300, h);
      drawBar(baseRect, pBase);

      if (isInteractionComplete) {
        // Overlay the decreased portion in red
        Rect decRect = Rect.fromLTWH(
          center.dx - 150 + 240,
          center.dy - 60,
          60,
          h,
        );
        drawBar(decRect, pDec);
        drawText(
          "-\$10",
          center + const Offset(120, -100),
          Colors.red,
          fontSize: 24,
          shadow: true,
        );
        drawText(
          "\$40 New Price",
          center + const Offset(-30, 20),
          Colors.amber,
          fontSize: 24,
          shadow: true,
        );
      }
    } else if (step >= 2) {
      // Percentage Error Visual
      final pBase = Paint()
        ..color = Colors.blueAccent.withOpacity(0.8)
        ..style = PaintingStyle.fill;
      final pDec = Paint()
        ..color = Colors.redAccent.withOpacity(0.8)
        ..style = PaintingStyle.fill;

      drawText(
        labels['exact'] ?? "Exact Value (300)",
        center + const Offset(-180, -100),
        Colors.blueAccent,
      );
      drawText(
        labels['estimated'] ?? "Estimated Value (360)",
        center + const Offset(180, -100),
        Colors.amber,
      );

      Rect exactRect = Rect.fromLTWH(center.dx - 240, center.dy - 60, 240, h);
      drawBar(exactRect, pBase);
      drawText("300", center + const Offset(-120, -40), Colors.white);

      Rect actRect = Rect.fromLTWH(center.dx + 60, center.dy - 60, 240 + 48, h);
      drawBar(actRect, pBase);
      drawText("360", center + const Offset(204, -40), Colors.white);

      // Error portion highlighted inside the estimated bar
      Rect errRect = Rect.fromLTWH(center.dx + 60 + 240, center.dy - 60, 48, h);
      drawBar(errRect, pDec);
      drawText(
        labels['error'] ?? "Error",
        center + const Offset(60 + 240 + 24, -80),
        Colors.redAccent,
        fontSize: 14,
      );
      drawText(
        "+60",
        center + const Offset(60 + 240 + 24, -40),
        Colors.white,
        fontSize: 16,
      );

      if (step >= 4 && isInteractionComplete) {
        drawText(
          "Error = |360 - 300| = 60",
          center + const Offset(0, 40),
          Colors.redAccent,
          fontSize: 24,
        );
        drawText(
          "% Error = (60 / 300) × 100 = 20%",
          center + const Offset(0, 80),
          Colors.greenAccent,
          fontSize: 24,
        );
      } else if (step == 3 && isInteractionComplete) {
        drawText(
          "Always divide by EXACT (300)!",
          center + const Offset(0, 40),
          Colors.amber,
          fontSize: 24,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant PercentageChangePainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.step != step ||
        oldDelegate.isInteractionComplete != isInteractionComplete ||
        oldDelegate.labels != labels;
  }
}
