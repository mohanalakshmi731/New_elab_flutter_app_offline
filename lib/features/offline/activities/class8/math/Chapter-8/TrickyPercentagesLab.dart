// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class TrickyPercentagesLab extends StatefulWidget {
  const TrickyPercentagesLab({Key? key}) : super(key: key);

  @override
  State<TrickyPercentagesLab> createState() => _TrickyPercentagesLabState();
}

class _TrickyPercentagesLabState extends State<TrickyPercentagesLab>
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
  int _step1SelectedAnswer = -1;
  final TextEditingController _inputController = TextEditingController();
  String? _dropA;
  String? _dropB;

  // --- Animations & Audio ---
  late AnimationController _curtainController;
  late Animation<Offset> _curtainAnimation;
  late AudioPlayer _audioPlayer;

  // --- Localization Data ---
  final Map<String, Map<String, dynamic>> _translations = {
    'en': {
      'langCode': 'EN',
      'titleMain': 'Tricky Percentages',
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
      'labels': {'dropTarget': 'Drop %'},
      'steps': [
        {
          'title': 'Step 1: The +/- Illusion',
          'theory':
              "Welcome to Concept 7: Tricky Percentages!\n\nImagine a shoe costs \$100. The store increases the price by 10%. Later, they decrease the new price by 10%.\n\nDoes the final price return exactly back to \$100?",
          'hudTitle': 'Make a Prediction',
          'hudInstruction':
              "If a price goes +10% and then -10%, does it return to the original price?",
          'options': [
            'Yes, it returns to \$100',
            'No, it will be higher',
            'No, it will be lower',
          ],
          'correctIdx': 2,
          'type': 'mcq',
        },
        {
          'title': 'Step 2: The Math Behind the Trap',
          'theory':
              "Let's do the math!\n\nOriginal: \$100\n+10% Increase: \$100 + \$10 = \$110.\n\nNow, the -10% decrease is calculated on the NEW price (\$110), not the old one!\n10% of \$110 is \$11.",
          'hudTitle': 'Calculate Final Price',
          'hudInstruction':
              "Subtract \$11 from \$110. What is the final price of the shoe?",
          'correctValue': 99,
          'type': 'input',
        },
        {
          'title': 'Step 3: The "Of" Trap (Reversal)',
          'theory':
              "Here is a magical percentage trick: x% of y is exactly equal to y% of x.\n\nTrying to calculate 16% of 50 in your head is tricky. But if you reverse it... 50% of 16 is incredibly easy!\n\n50% just means 'half'. Half of 16 is 8. So, 16% of 50 is also 8!",
          'hudTitle': 'Observe the Bar Models',
          'hudInstruction':
              "Observe the canvas. Notice how 20% of 50 yields the exact same area/result as 50% of 20.",
          'type': 'observe',
        },
        {
          'title': 'Step 4: Reversing Percentages',
          'theory':
              "By swapping the numbers around the 'of', you can often turn a hard math problem into mental math.\n\nProblem: What is 4% of 25?\nInstead of solving that, let's reverse it to 25% of 4.",
          'hudTitle': 'Create the Reversal',
          'hudInstruction':
              "Drag the numbers to correctly construct the reversed problem: 25% of 4.",
          'targetA': '25',
          'targetB': '4',
          'type': 'drag',
        },
        {
          'title': 'Step 5: Quick Calculation',
          'theory':
              "Now that you have reversed it to '25% of 4', you know that 25% is just a quarter (1/4).\n\nWhat is one quarter of 4? It's much easier to solve!",
          'hudTitle': 'Solve the Reversed Math',
          'hudInstruction': "Calculate the final answer for 25% of 4.",
          'correctValue': 1,
          'type': 'input',
        },
      ],
    },
    'hi': {
      'langCode': 'HI',
      'titleMain': 'कठिन प्रतिशत',
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
      'labels': {'dropTarget': 'यहाँ छोड़ें'},
      'steps': [
        {
          'title': 'चरण 1: +/- भ्रम',
          'theory':
              "कांसेप्ट 7 में आपका स्वागत है: कठिन प्रतिशत!\n\nकल्पना करें कि एक जूते की कीमत \$100 है। स्टोर कीमत में 10% की वृद्धि करता है। बाद में, वे नई कीमत में 10% की कमी करते हैं।\n\nक्या अंतिम कीमत ठीक \$100 पर वापस आ जाती है?",
          'hudTitle': 'भविष्यवाणी करें',
          'hudInstruction':
              "यदि कोई कीमत +10% और फिर -10% हो जाती है, तो क्या वह मूल कीमत पर वापस आ जाती है?",
          'options': [
            'हाँ, यह \$100 पर वापस आता है',
            'नहीं, यह अधिक होगा',
            'नहीं, यह कम होगा',
          ],
          'correctIdx': 2,
          'type': 'mcq',
        },
        {
          'title': 'चरण 2: जाल के पीछे का गणित',
          'theory':
              "आइए गणित करते हैं!\n\nमूल: \$100\n+10% वृद्धि: \$100 + \$10 = \$110।\n\nअब, -10% कमी की गणना नई कीमत (\$110) पर की जाती है, पुरानी पर नहीं!\n\$110 का 10% \$11 है।",
          'hudTitle': 'अंतिम मूल्य की गणना करें',
          'hudInstruction':
              "\$110 में से \$11 घटाएं। जूते की अंतिम कीमत क्या है?",
          'correctValue': 99,
          'type': 'input',
        },
        {
          'title': 'चरण 3: "का" जाल (उलटा)',
          'theory':
              "यहाँ एक जादुई प्रतिशत चाल है: y का x% ठीक x के y% के बराबर है।\n\nअपने दिमाग में 50 का 16% गिनने की कोशिश करना मुश्किल है। लेकिन अगर आप इसे उल्टा कर दें... 16 का 50% अविश्वसनीय रूप से आसान है!\n\n50% का मतलब है 'आधा'। 16 का आधा 8 है। तो, 50 का 16% भी 8 है!",
          'hudTitle': 'बार मॉडल का निरीक्षण करें',
          'hudInstruction':
              "कैनवास का निरीक्षण करें। ध्यान दें कि कैसे 50 का 20% ठीक वही परिणाम देता है जो 20 का 50% देता है।",
          'type': 'observe',
        },
        {
          'title': 'चरण 4: प्रतिशत को उलटना',
          'theory':
              "'का' ('of') के चारों ओर संख्याओं की अदला-बदली करके, आप अक्सर एक कठिन गणित की समस्या को मानसिक गणित में बदल सकते हैं।\n\nसमस्या: 25 का 4% क्या है?\nइसे हल करने के बजाय, आइए इसे 4 के 25% में उलट दें।",
          'hudTitle': 'उलट बनाएं',
          'hudInstruction':
              "उलटी समस्या का सही ढंग से निर्माण करने के लिए संख्याओं को खींचें: 4 का 25%।",
          'targetA': '25',
          'targetB': '4',
          'type': 'drag',
        },
        {
          'title': 'चरण 5: त्वरित गणना',
          'theory':
              "अब जब आपने इसे '4 का 25%' में उलट दिया है, तो आप जानते हैं कि 25% केवल एक चौथाई (1/4) है।\n\n4 का एक चौथाई क्या है? इसे हल करना बहुत आसान है!",
          'hudTitle': 'उल्टे गणित को हल करें',
          'hudInstruction': "4 के 25% के लिए अंतिम उत्तर की गणना करें।",
          'correctValue': 1,
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
      _step1SelectedAnswer = -1;
      _dropA = null;
      _dropB = null;
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
      if (_step1SelectedAnswer == -1) {
        _showFeedback(_getString('selectWarn'), false);
        return;
      }
      int correctIdx = currentScenario['correctIdx'] as int? ?? -1;
      if (_step1SelectedAnswer == correctIdx) {
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
    } else if (type == 'drag') {
      String targetA = currentScenario['targetA'] ?? '';
      String targetB = currentScenario['targetB'] ?? '';

      if (_dropA == targetA && _dropB == targetB) {
        _showFeedback(_getString('toastSuccess'), true);
      } else if (_dropA != null && _dropB != null) {
        _showFeedback(_getString('toastError'), false);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && !_interactionCompleted) {
            setState(() {
              _dropA = null;
              _dropB = null;
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
      _step1SelectedAnswer = answerIndex;
    });
    _validateInvestigation();
  }

  void _handleInputSubmit(String value) {
    if (_interactionCompleted) return;
    _playSound('tap');
    _validateInvestigation();
  }

  void _handleDrop(String pos, String data) {
    if (_interactionCompleted) return;
    _playSound('tap');
    setState(() {
      if (pos == 'A') _dropA = data;
      if (pos == 'B') _dropB = data;
    });

    if (_dropA != null && _dropB != null) {
      _validateInvestigation();
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
      if (_currentStep == 0) currentAnswer = _step1SelectedAnswer;
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
    } else if (type == 'drag') {
      return const SizedBox(); // Drag interface is built onto the canvas directly
    }
    return const SizedBox();
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
                painter: TrickyPercentagesPainter(
                  isDark: _isDarkTheme,
                  step: _currentStep,
                  isInteractionComplete: _interactionCompleted,
                  labels: tLabels,
                ),
              ),

              // Step 4 Drag & Drop UI
              if (_currentStep == 3) ...[
                // Drop Zone A
                Positioned(
                  left: centerX - 180,
                  top: centerY - 40,
                  child: DragTarget<String>(
                    builder: (context, candidateData, rejectedData) {
                      bool isHovered = candidateData.isNotEmpty;
                      return Container(
                        width: 100,
                        height: 80,
                        decoration: BoxDecoration(
                          color: isHovered
                              ? Colors.amber.withOpacity(0.3)
                              : Colors.white10,
                          border: Border.all(
                            color: isHovered
                                ? Colors.amber
                                : (_dropA != null
                                      ? Colors.greenAccent
                                      : Colors.white54),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: _dropA != null
                            ? Text(
                                _dropA!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Text(
                                _getLabel('dropTarget'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 14,
                                ),
                              ),
                      );
                    },
                    onAccept: (data) => _handleDrop('A', data),
                  ),
                ),
                // Drop Zone B
                Positioned(
                  left: centerX + 110,
                  top: centerY - 40,
                  child: DragTarget<String>(
                    builder: (context, candidateData, rejectedData) {
                      bool isHovered = candidateData.isNotEmpty;
                      return Container(
                        width: 100,
                        height: 80,
                        decoration: BoxDecoration(
                          color: isHovered
                              ? Colors.amber.withOpacity(0.3)
                              : Colors.white10,
                          border: Border.all(
                            color: isHovered
                                ? Colors.amber
                                : (_dropB != null
                                      ? Colors.greenAccent
                                      : Colors.white54),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: _dropB != null
                            ? Text(
                                _dropB!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Text(
                                _getLabel('dropTarget'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 14,
                                ),
                              ),
                      );
                    },
                    onAccept: (data) => _handleDrop('B', data),
                  ),
                ),

                // Draggable Options
                if (!_interactionCompleted)
                  Positioned(
                    top: centerY + 120,
                    child: Row(
                      children: ['4', '25']
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Draggable<String>(
                                data: item,
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.8),
                                          blurRadius: 20,
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.3,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
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
                              Icons.psychology,
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
                        Icons.psychology,
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
class TrickyPercentagesPainter extends CustomPainter {
  final bool isDark;
  final int step;
  final bool isInteractionComplete;
  final Map<String, dynamic> labels;

  TrickyPercentagesPainter({
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

    void drawBlock(Offset pos, double w, Color color, {String label = ""}) {
      Rect rect = Rect.fromCenter(center: pos, width: w, height: 60);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        Paint()
          ..color = color.withOpacity(0.4)
          ..style = PaintingStyle.fill,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      if (label.isNotEmpty) drawText(label, pos, Colors.white);
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

    if (step == 0 || step == 1) {
      // 100 -> 110 -> 99 Sequence
      drawBlock(
        center + const Offset(-200, 0),
        100,
        Colors.blueAccent,
        label: "\$100",
      );
      _drawArrow(
        center + const Offset(-140, 0),
        center + const Offset(-60, 0),
        Colors.greenAccent,
      );
      drawText(
        "+10%",
        center + const Offset(-100, -30),
        Colors.greenAccent,
        fontSize: 16,
      );

      if (step == 1) {
        drawBlock(center, 110, Colors.amber, label: "\$110");
        _drawArrow(
          center + const Offset(60, 0),
          center + const Offset(140, 0),
          Colors.redAccent,
        );
        drawText(
          "-10%",
          center + const Offset(100, -30),
          Colors.redAccent,
          fontSize: 16,
        );

        if (isInteractionComplete) {
          drawBlock(
            center + const Offset(200, 0),
            90,
            Colors.redAccent,
            label: "\$99",
          );
          drawText(
            "It does NOT return to \$100!",
            center + const Offset(0, 100),
            Colors.amber,
            fontSize: 24,
          );
        } else {
          drawText(
            "?",
            center + const Offset(200, 0),
            Colors.white54,
            fontSize: 32,
          );
        }
      } else {
        drawText("?", center, Colors.white54, fontSize: 32);
        drawText(
          "?",
          center + const Offset(200, 0),
          Colors.white54,
          fontSize: 32,
        );
        drawText(
          "...",
          center + const Offset(100, -30),
          Colors.white24,
          fontSize: 16,
        );
      }
    } else if (step == 2) {
      // Bar Models for 'Of' trap
      double bW50 = 250;
      double bW20 = 100;

      // 20% of 50
      Rect r50 = Rect.fromCenter(
        center: center + const Offset(-60, -70),
        width: bW50,
        height: 40,
      );
      canvas.drawRect(r50, Paint()..color = Colors.amber.withOpacity(0.3));
      canvas.drawRect(
        r50,
        Paint()
          ..color = Colors.amber
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      // Highlight 1/5th
      canvas.drawRect(
        Rect.fromLTWH(r50.left, r50.top, bW50 * 0.2, 40),
        Paint()..color = Colors.amber,
      );
      drawText(
        "20% of 50",
        center + const Offset(-60, -110),
        Colors.amber,
        fontSize: 20,
      );
      drawText(
        "10",
        center + Offset(r50.left + (bW50 * 0.1), r50.top + 20),
        Colors.black,
        fontSize: 16,
      );

      // 50% of 20
      Rect r20 = Rect.fromCenter(
        center: center + const Offset(-135, 50),
        width: bW20,
        height: 40,
      );
      canvas.drawRect(r20, Paint()..color = Colors.blueAccent.withOpacity(0.3));
      canvas.drawRect(
        r20,
        Paint()
          ..color = Colors.blueAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      // Highlight 1/2
      canvas.drawRect(
        Rect.fromLTWH(r20.left, r20.top, bW20 * 0.5, 40),
        Paint()..color = Colors.blueAccent,
      );
      drawText(
        "50% of 20",
        center + const Offset(-135, 10),
        Colors.blueAccent,
        fontSize: 20,
      );
      drawText(
        "10",
        center + Offset(r20.left + (bW20 * 0.25), r20.top + 20),
        Colors.white,
        fontSize: 16,
      );

      drawText(
        "Notice how the resulting area (10) is identical!",
        center + const Offset(0, 120),
        Colors.greenAccent,
        fontSize: 20,
      );
    } else if (step >= 3) {
      drawText(
        "What is 4% of 25?",
        center + const Offset(0, -120),
        Colors.white54,
        fontSize: 24,
      );

      if (step == 3) {
        drawText(
          "%  of",
          center + const Offset(-20, -40),
          Colors.amber,
          fontSize: 40,
        );
        drawText(
          "=",
          center + const Offset(200, -40),
          Colors.white54,
          fontSize: 40,
        );
      }

      if (step == 4) {
        drawText(
          "25 %  of  4",
          center + const Offset(0, -40),
          Colors.amber,
          fontSize: 40,
        );
        drawText(
          "=   1/4  of  4",
          center + const Offset(0, 30),
          Colors.blueAccent,
          fontSize: 32,
        );

        if (isInteractionComplete) {
          drawText(
            "=   1",
            center + const Offset(0, 90),
            Colors.greenAccent,
            fontSize: 48,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant TrickyPercentagesPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.step != step ||
        oldDelegate.isInteractionComplete != isInteractionComplete ||
        oldDelegate.labels != labels;
  }
}
