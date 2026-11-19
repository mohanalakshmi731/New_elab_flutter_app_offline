// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class FinancialLiteracyLab extends StatefulWidget {
  const FinancialLiteracyLab({Key? key}) : super(key: key);

  @override
  State<FinancialLiteracyLab> createState() => _FinancialLiteracyLabState();
}

class _FinancialLiteracyLabState extends State<FinancialLiteracyLab>
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
  int _step3SelectedAnswer = -1;
  String? _droppedStamp;
  final TextEditingController _inputController = TextEditingController();

  // --- Animations & Audio ---
  late AnimationController _curtainController;
  late Animation<Offset> _curtainAnimation;
  late AudioPlayer _audioPlayer;

  // --- Localization Data ---
  final Map<String, Map<String, dynamic>> _translations = {
    'en': {
      'langCode': 'EN',
      'titleMain': 'Financial Literacy',
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
        'principal': 'Principal: \$1000',
        'rate': 'Rate: 10% p.a.',
        'time': 'Time',
        'value': 'Value',
        'dropTarget': 'Drop Sign',
        'si': 'Simple Interest',
        'ci': 'Compound Interest',
      },
      'steps': [
        {
          'title': 'Step 1: Simple Interest',
          'theory':
              "Welcome to Concept 5: Financial Literacy.\n\nWhen you deposit money (Principal) in a bank, it earns 'Interest'.\n\nSimple Interest (SI) is calculated only on the Principal amount every year.\nSI = (Principal × Rate × Time) / 100",
          'hudTitle': 'Calculate SI',
          'hudInstruction':
              "Calculate the Simple Interest for 1 year on \$1000 at 10% per year.",
          'correctValue': 100,
          'type': 'input',
        },
        {
          'title': 'Step 2: Total Amount (Year 1)',
          'theory':
              "At the end of Year 1, the total Amount in the bank is the Principal plus the Interest earned.\n\nAmount = Principal + Interest\n\nNote: For the very first year, Simple Interest and Compound Interest are exactly the same!",
          'hudTitle': 'Calculate Amount',
          'hudInstruction':
              "What is the Total Amount in the bank after Year 1? (\$1000 + \$100)",
          'correctValue': 1100,
          'type': 'input',
        },
        {
          'title': 'Step 3: The Power of Compounding',
          'theory':
              "In Year 2, things change! \n\nSimple Interest is still calculated on the original \$1000 (earning \$100 again).\nBut Compound Interest (CI) is calculated on the NEW Amount (\$1100). It earns 'interest on the interest'!\n\n10% of \$1100 = \$110.",
          'hudTitle': 'Compare Returns',
          'hudInstruction': "In Year 2, which method yields more interest?",
          'options': ['Simple Interest', 'Compound Interest', 'They are equal'],
          'correctIdx': 1,
          'type': 'mcq',
        },
        {
          'title': 'Step 4: Mathematical Inequality',
          'theory':
              "Because Compound Interest recalculates the base amount every year, it grows much faster over time than Simple Interest.\n\nFor any time period greater than 1 year, Compound Interest will always be greater than Simple Interest.",
          'hudTitle': 'Place the Sign',
          'hudInstruction':
              "Drag the correct mathematical sign (>, <, =) into the box to compare CI and SI over 10 years.",
          'targetStamp': '>',
          'type': 'drag',
        },
        {
          'title': 'Step 5: The Exponential Curve',
          'theory':
              "Let's visualize this growth on a graph over 10 years.\n\nThe Simple Interest line (Blue) grows steadily and forms a straight line.\nThe Compound Interest curve (Green) accelerates upward, forming an exponential curve!",
          'hudTitle': 'Observe the Graph',
          'hudInstruction':
              "Observe the graph on the canvas. Notice how the Green CI curve breaks away and rises exponentially.",
          'type': 'observe',
        },
      ],
    },
    'hi': {
      'langCode': 'HI',
      'titleMain': 'वित्तीय साक्षरता',
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
        'principal': 'मूलधन: \$1000',
        'rate': 'दर: 10% प्रति वर्ष',
        'time': 'समय',
        'value': 'मूल्य',
        'dropTarget': 'चिह्न छोड़ें',
        'si': 'साधारण ब्याज',
        'ci': 'चक्रवृद्धि ब्याज',
      },
      'steps': [
        {
          'title': 'चरण 1: साधारण ब्याज',
          'theory':
              "कांसेप्ट 5 में आपका स्वागत है: वित्तीय साक्षरता।\n\nजब आप बैंक में पैसा (मूलधन) जमा करते हैं, तो उस पर 'ब्याज' मिलता है।\n\nसाधारण ब्याज (SI) की गणना हर साल केवल मूलधन पर की जाती है।\nSI = (मूलधन × दर × समय) / 100",
          'hudTitle': 'SI की गणना करें',
          'hudInstruction':
              "10% प्रति वर्ष की दर से \$1000 पर 1 वर्ष के लिए साधारण ब्याज की गणना करें।",
          'correctValue': 100,
          'type': 'input',
        },
        {
          'title': 'चरण 2: कुल राशि (वर्ष 1)',
          'theory':
              "वर्ष 1 के अंत में, बैंक में कुल राशि मूलधन और अर्जित ब्याज है।\n\nराशि = मूलधन + ब्याज\n\nनोट: पहले वर्ष के लिए, साधारण ब्याज और चक्रवृद्धि ब्याज बिल्कुल समान हैं!",
          'hudTitle': 'राशि की गणना करें',
          'hudInstruction':
              "वर्ष 1 के बाद बैंक में कुल राशि क्या है? (\$1000 + \$100)",
          'correctValue': 1100,
          'type': 'input',
        },
        {
          'title': 'चरण 3: चक्रवृद्धि की शक्ति',
          'theory':
              "वर्ष 2 में, चीजें बदल जाती हैं!\n\nसाधारण ब्याज की गणना अभी भी मूल \$1000 पर की जाती है (फिर से \$100 कमाना)।\nलेकिन चक्रवृद्धि ब्याज (CI) की गणना नई राशि (\$1100) पर की जाती है। यह 'ब्याज पर ब्याज' कमाता है!\n\n\$1100 का 10% = \$110।",
          'hudTitle': 'रिटर्न की तुलना करें',
          'hudInstruction': "वर्ष 2 में, कौन सी विधि अधिक ब्याज देती है?",
          'options': ['साधारण ब्याज', 'चक्रवृद्धि ब्याज', 'वे समान हैं'],
          'correctIdx': 1,
          'type': 'mcq',
        },
        {
          'title': 'चरण 4: गणितीय असमानता',
          'theory':
              "चूंकि चक्रवृद्धि ब्याज हर साल आधार राशि की पुनर्गणना करता है, यह साधारण ब्याज की तुलना में समय के साथ बहुत तेजी से बढ़ता है।\n\n1 वर्ष से अधिक की किसी भी समयावधि के लिए, चक्रवृद्धि ब्याज हमेशा साधारण ब्याज से अधिक होगा।",
          'hudTitle': 'चिह्न लगाएं',
          'hudInstruction':
              "10 वर्षों में CI और SI की तुलना करने के लिए सही गणितीय चिह्न (>, <, =) को बॉक्स में खींचें।",
          'targetStamp': '>',
          'type': 'drag',
        },
        {
          'title': 'चरण 5: घातीय वक्र',
          'theory':
              "आइए इस वृद्धि को 10 वर्षों के ग्राफ़ पर देखें।\n\nसाधारण ब्याज रेखा (नीला) लगातार बढ़ती है और एक सीधी रेखा बनाती है।\nचक्रवृद्धि ब्याज वक्र (हरा) ऊपर की ओर बढ़ता है, एक घातीय वक्र (exponential curve) बनाता है!",
          'hudTitle': 'ग्राफ का निरीक्षण करें',
          'hudInstruction':
              "कैनवास पर ग्राफ का निरीक्षण करें। ध्यान दें कि ग्रीन सीआई वक्र कैसे टूटता है और तेजी से बढ़ता है।",
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
  String _getLabel(String key) => tLabels[key]?.toString() ?? '';
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
      _step3SelectedAnswer = -1;
      _droppedStamp = null;
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
      int answerIndex = -1;
      if (_currentStep == 2) answerIndex = _step3SelectedAnswer;

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
    } else if (type == 'drag') {
      String target = currentScenario['targetStamp'] ?? '';
      if (_droppedStamp == target) {
        _showFeedback(_getString('toastSuccess'), true);
      } else {
        _showFeedback(_getString('toastError'), false);
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted && !_interactionCompleted) {
            setState(() {
              _droppedStamp = null;
              _feedbackMessage = null;
            });
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
    });

    _validateInvestigation();
  }

  void _handleInputSubmit(String value) {
    if (_interactionCompleted) return;
    _playSound('tap');
    _validateInvestigation();
  }

  void _handleStampDrop(String stamp) {
    if (_interactionCompleted) return;
    _playSound('tap');
    setState(() {
      _droppedStamp = stamp;
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
      if (_currentStep == 2) currentAnswer = _step3SelectedAnswer;
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
    } else if (type == 'drag') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: ['>', '<', '='].map((stamp) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Draggable<String>(
              data: stamp,
              feedback: _buildStampWidget(stamp, isDragging: true),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: _buildStampWidget(stamp),
              ),
              child: _buildStampWidget(stamp),
            ),
          );
        }).toList(),
      );
    }
    return const SizedBox();
  }

  Widget _buildStampWidget(String label, {bool isDragging = false}) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: isDragging
              ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.8),
                    blurRadius: 20,
                  ),
                ]
              : [
                  const BoxShadow(
                    color: Colors.black54,
                    blurRadius: 4,
                    offset: Offset(0, 4),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
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
          final centerX = canvasSize.width / 2;
          final centerY = canvasSize.height / 2;

          return Stack(
            alignment: Alignment.center,
            children: [
              // 2D Geometric Render Background
              CustomPaint(
                size: Size.infinite,
                painter: FinancialLiteracyPainter(
                  isDark: _isDarkTheme,
                  step: _currentStep,
                  isInteractionComplete: _interactionCompleted,
                  labels: tLabels,
                ),
              ),

              // Step 4 Drag & Drop Target
              if (_currentStep == 3)
                Positioned(
                  top: centerY - 40,
                  left: centerX - 40,
                  child: DragTarget<String>(
                    builder: (context, candidateData, rejectedData) {
                      bool isHovered = candidateData.isNotEmpty;
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: isHovered
                              ? Colors.amber.withOpacity(0.3)
                              : Colors.white10,
                          border: Border.all(
                            color: isHovered
                                ? Colors.amber
                                : (_droppedStamp != null
                                      ? Colors.greenAccent
                                      : Colors.white54),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: _droppedStamp != null
                            ? Text(
                                _droppedStamp!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Text(
                                _getLabel('dropTarget'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 12,
                                ),
                              ),
                      );
                    },
                    onAccept: (data) => _handleStampDrop(data),
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
                              Icons.account_balance,
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
                        Icons.account_balance,
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
class FinancialLiteracyPainter extends CustomPainter {
  final bool isDark;
  final int step;
  final bool isInteractionComplete;
  final Map<String, dynamic> labels;

  FinancialLiteracyPainter({
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
      double fontSize = 20,
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
                ? [const Shadow(color: Colors.black87, blurRadius: 4)]
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
      drawText(
        labels['principal'] ?? 'Principal: \$1000',
        center + const Offset(0, -120),
        Colors.amber,
        fontSize: 28,
      );
      drawText(
        labels['rate'] ?? 'Rate: 10% p.a.',
        center + const Offset(0, -80),
        Colors.white70,
        fontSize: 20,
      );

      if (step == 0) {
        drawText(
          "Year 1 Interest:",
          center + const Offset(0, -20),
          Colors.white,
          fontSize: 24,
        );
        if (isInteractionComplete) {
          drawText(
            "\$100",
            center + const Offset(0, 30),
            Colors.greenAccent,
            fontSize: 40,
          );
        } else {
          drawText(
            "?",
            center + const Offset(0, 30),
            Colors.white54,
            fontSize: 40,
          );
        }
      } else if (step == 1) {
        drawText(
          "Total Amount (Year 1):",
          center + const Offset(0, -20),
          Colors.white,
          fontSize: 24,
        );
        if (isInteractionComplete) {
          drawText(
            "\$1100",
            center + const Offset(0, 30),
            Colors.greenAccent,
            fontSize: 40,
          );
        } else {
          drawText(
            "?",
            center + const Offset(0, 30),
            Colors.white54,
            fontSize: 40,
          );
        }
      } else if (step == 2) {
        drawText(
          "Year 2 Interest",
          center + const Offset(0, -20),
          Colors.white,
          fontSize: 24,
        );
        drawText(
          "SI: \$100",
          center + const Offset(-100, 30),
          Colors.blueAccent,
          fontSize: 32,
        );
        drawText(
          "CI: \$110",
          center + const Offset(100, 30),
          Colors.greenAccent,
          fontSize: 32,
        );

        if (isInteractionComplete) {
          drawText(
            "Compound Interest Yields More!",
            center + const Offset(0, 100),
            Colors.amber,
            fontSize: 24,
          );
        }
      }
    } else if (step == 3) {
      // Document Board for Stamp
      Rect doc = Rect.fromCenter(center: center, width: 280, height: 180);
      canvas.drawRRect(
        RRect.fromRectAndRadius(doc, const Radius.circular(12)),
        Paint()..color = Colors.black54,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(doc, const Radius.circular(12)),
        Paint()
          ..color = Colors.amber
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      drawText(
        "CI",
        center + const Offset(-80, -60),
        Colors.greenAccent,
        fontSize: 36,
      );
      drawText(
        "SI",
        center + const Offset(60, -60),
        Colors.blueAccent,
        fontSize: 36,
      );
      drawText(
        "Over 10 Years",
        center + const Offset(0, 40),
        Colors.white54,
        fontSize: 18,
      );
    } else if (step == 4) {
      // Draw Exponential Graph
      Offset graphOrigin = center + const Offset(-140, 100);

      final axisPaint = Paint()
        ..color = Colors.white70
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawLine(
        graphOrigin,
        graphOrigin + const Offset(280, 0),
        axisPaint,
      ); // X-axis (Time)
      drawText(
        labels['time'] ?? 'Time',
        graphOrigin + const Offset(140, 25),
        Colors.white70,
        fontSize: 14,
      );

      canvas.drawLine(
        graphOrigin,
        graphOrigin + const Offset(0, -200),
        axisPaint,
      ); // Y-axis (Value)
      drawText(
        labels['value'] ?? 'Value',
        graphOrigin + const Offset(-35, -100),
        Colors.white70,
        fontSize: 14,
      );

      // SI Curve (Straight Line)
      Path siLine = Path()..moveTo(graphOrigin.dx, graphOrigin.dy);
      siLine.lineTo(graphOrigin.dx + 280, graphOrigin.dy - 100);
      canvas.drawPath(
        siLine,
        Paint()
          ..color = Colors.blueAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );

      // CI Curve (Exponential)
      Path ciCurve = Path()..moveTo(graphOrigin.dx, graphOrigin.dy);
      for (int x = 0; x <= 280; x += 10) {
        // Simple exponential simulation y = x^2 scaled
        double y = math.pow((x / 280), 2) * 180;
        ciCurve.lineTo(graphOrigin.dx + x, graphOrigin.dy - y);
      }

      if (isInteractionComplete) {
        canvas.drawPath(
          ciCurve,
          Paint()
            ..color = Colors.greenAccent
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4,
        );
      } else {
        // Draw it dashed or lighter before interaction
        canvas.drawPath(
          ciCurve,
          Paint()
            ..color = Colors.white24
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }

      // Legend
      drawText(
        labels['si'] ?? 'Simple Interest',
        graphOrigin + const Offset(60, -180),
        Colors.blueAccent,
        fontSize: 14,
      );
      drawText(
        labels['ci'] ?? 'Compound Interest',
        graphOrigin + const Offset(60, -150),
        Colors.greenAccent,
        fontSize: 14,
      );
    }
  }

  @override
  bool shouldRepaint(covariant FinancialLiteracyPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.step != step ||
        oldDelegate.isInteractionComplete != isInteractionComplete ||
        oldDelegate.labels != labels;
  }
}
