// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class ComparingProportionsLab extends StatefulWidget {
  const ComparingProportionsLab({Key? key}) : super(key: key);

  @override
  State<ComparingProportionsLab> createState() =>
      _ComparingProportionsLabState();
}

class _ComparingProportionsLabState extends State<ComparingProportionsLab>
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
      'titleMain': 'Comparing Proportions',
      'chapterMain': 'Class 8 • Comparing Quantities',
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
        'beakerA': 'Beaker A (2:3)',
        'beakerB': 'Beaker B (3:5)',
        'dropTarget': 'Drop Sign',
        'orange': 'Orange Juice',
        'water': 'Water',
      },
      'steps': [
        {
          'title': 'Step 1: Analyzing Mixtures',
          'theory':
              "Welcome to Concept 2: Comparing Proportions.\n\nImagine two beakers of orange squash. Beaker A mixes 2 parts orange syrup with 3 parts water (Ratio 2:3).\nBeaker B mixes 3 parts syrup with 5 parts water (Ratio 3:5).\n\nWhich beaker has a stronger orange taste?",
          'hudTitle': 'Observe the Beakers',
          'hudInstruction':
              "Observe the two liquid mixtures on the canvas. To compare them, we must look at their fractions.",
          'type': 'observe',
        },
        {
          'title': 'Step 2: Finding the Fraction',
          'theory':
              "First, convert the ratios into fractions representing the part of orange syrup out of the TOTAL mixture.\n\nBeaker A: Total parts = 2+3=5. Fraction = 2/5.\nBeaker B: Total parts = 3+5=8. Fraction = 3/8.\n\nTo compare 2/5 and 3/8, we need a common denominator.",
          'hudTitle': 'Find the LCM',
          'hudInstruction':
              "What is the Least Common Multiple (LCM) of the denominators 5 and 8?",
          'correctValue': 40,
          'type': 'input',
        },
        {
          'title': 'Step 3: Comparing Numerators',
          'theory':
              "Now we convert both fractions to have a denominator of 40.\n\nBeaker A: (2 × 8) / (5 × 8) = 16/40\nBeaker B: (3 × 5) / (8 × 5) = 15/40\n\nNow that the bases are equal, we just compare the numerators: 16 and 15.",
          'hudTitle': 'Identify the Stronger Mix',
          'hudInstruction':
              "Based on the numerators (16 vs 15), which beaker has the stronger orange flavor?",
          'options': ['Beaker A', 'Beaker B', 'They are equal'],
          'correctIdx': 0,
          'type': 'mcq',
        },
        {
          'title': 'Step 4: The Inequality Sign',
          'theory':
              "Since 16/40 is strictly greater than 15/40, we conclude that the ratio 2:3 represents a stronger proportion than 3:5.\n\nIn mathematics, we denote this relationship using an inequality sign.",
          'hudTitle': 'Place the Sign',
          'hudInstruction':
              "Drag the correct mathematical sign (>, <, =) into the box to compare 2/5 and 3/8.",
          'targetStamp': '>',
          'type': 'drag',
        },
        {
          'title': 'Step 5: Percentage Conversion',
          'theory':
              "Another great way to compare proportions is by converting them to percentages (parts per 100).\n\nLet's find the percentage of orange syrup in Beaker A.\nFraction = 2/5. To convert to a percentage, multiply by 100.",
          'hudTitle': 'Calculate Percentage',
          'hudInstruction':
              "What is the percentage of orange syrup in Beaker A? (Calculate: 2/5 × 100)",
          'correctValue': 40,
          'type': 'input',
        },
      ],
    },
    'hi': {
      'langCode': 'HI',
      'titleMain': 'समानुपातों की तुलना',
      'chapterMain': 'कक्षा 8 • राशियों की तुलना',
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
        'beakerA': 'बीकर A (2:3)',
        'beakerB': 'बीकर B (3:5)',
        'dropTarget': 'चिह्न छोड़ें',
        'orange': 'संतरे का रस',
        'water': 'पानी',
      },
      'steps': [
        {
          'title': 'चरण 1: मिश्रण का विश्लेषण',
          'theory':
              "कांसेप्ट 2 में आपका स्वागत है: समानुपातों की तुलना।\n\nसंतरे के रस के दो बीकरों की कल्पना करें। बीकर A में 2 भाग संतरे का सिरप 3 भाग पानी के साथ मिलाया जाता है (अनुपात 2:3)।\nबीकर B में 3 भाग सिरप 5 भाग पानी के साथ मिलाया जाता है (अनुपात 3:5)।\n\nकिस बीकर में संतरे का स्वाद अधिक मजबूत है?",
          'hudTitle': 'बीकरों का निरीक्षण करें',
          'hudInstruction':
              "कैनवास पर दो तरल मिश्रणों का निरीक्षण करें। उनकी तुलना करने के लिए, हमें उनके भिन्नों को देखना होगा।",
          'type': 'observe',
        },
        {
          'title': 'चरण 2: भिन्न खोजना',
          'theory':
              "सबसे पहले, अनुपातों को कुल मिश्रण में से संतरे के सिरप के भाग को दर्शाने वाले भिन्नों में बदलें।\n\nबीकर A: कुल भाग = 2+3=5। भिन्न = 2/5।\nबीकर B: कुल भाग = 3+5=8। भिन्न = 3/8।\n\n2/5 और 3/8 की तुलना करने के लिए, हमें एक समान हर (denominator) की आवश्यकता है।",
          'hudTitle': 'LCM ज्ञात करें',
          'hudInstruction': "हर 5 और 8 का लघुत्तम समापवर्त्य (LCM) क्या है?",
          'correctValue': 40,
          'type': 'input',
        },
        {
          'title': 'चरण 3: अंशों की तुलना',
          'theory':
              "अब हम दोनों भिन्नों को 40 के हर के रूप में बदलते हैं।\n\nबीकर A: (2 × 8) / (5 × 8) = 16/40\nबीकर B: (3 × 5) / (8 × 5) = 15/40\n\nचूंकि अब आधार समान हैं, हम केवल अंशों (numerators) की तुलना करते हैं: 16 और 15।",
          'hudTitle': 'मजबूत मिश्रण की पहचान करें',
          'hudInstruction':
              "अंशों (16 बनाम 15) के आधार पर, किस बीकर में संतरे का स्वाद अधिक मजबूत है?",
          'options': ['बीकर A', 'बीकर B', 'वे समान हैं'],
          'correctIdx': 0,
          'type': 'mcq',
        },
        {
          'title': 'चरण 4: असमानता चिह्न',
          'theory':
              "चूंकि 16/40, 15/40 से सख्ती से अधिक है, हम निष्कर्ष निकालते हैं कि 2:3 अनुपात 3:5 की तुलना में अधिक मजबूत अनुपात दर्शाता है।\n\nगणित में, हम इस संबंध को असमानता चिह्न का उपयोग करके दर्शाते हैं।",
          'hudTitle': 'चिह्न लगाएं',
          'hudInstruction':
              "2/5 और 3/8 की तुलना करने के लिए सही गणितीय चिह्न (>, <, =) को बॉक्स में खींचें।",
          'targetStamp': '>',
          'type': 'drag',
        },
        {
          'title': 'चरण 5: प्रतिशत रूपांतरण',
          'theory':
              "अनुपातों की तुलना करने का एक और शानदार तरीका उन्हें प्रतिशत (प्रति 100 भाग) में बदलना है।\n\nआइए बीकर A में संतरे के सिरप का प्रतिशत ज्ञात करें।\nभिन्न = 2/5। प्रतिशत में बदलने के लिए, 100 से गुणा करें।",
          'hudTitle': 'प्रतिशत की गणना करें',
          'hudInstruction':
              "बीकर A में संतरे के सिरप का प्रतिशत क्या है? (गणना करें: 2/5 × 100)",
          'correctValue': 40,
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
      _step3SelectedAnswer = -1;
      _droppedStamp = null;
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
                painter: ComparingProportionsPainter(
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

              // Step 5 Dynamic overlay
              if (_currentStep == 4 && _interactionCompleted)
                Positioned(
                  top: centerY + 60,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      border: Border.all(color: Colors.greenAccent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "2/5 × 100 = 40%\n\n3/8 × 100 = 37.5%\n\n40% > 37.5%",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                              Icons.compare_arrows,
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
                        Icons.compare_arrows,
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
class ComparingProportionsPainter extends CustomPainter {
  final bool isDark;
  final int step;
  final bool isInteractionComplete;
  final Map<String, dynamic> labels;

  ComparingProportionsPainter({
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

    void drawBeaker(Offset basePos, double fillOrange, double fillWater) {
      double width = 120;
      double height = 200;
      Rect beakerRect = Rect.fromCenter(
        center: basePos,
        width: width,
        height: height,
      );

      // Liquid Level
      double totalFill = fillOrange + fillWater; // should be 1.0 (100%)
      double liquidHeight = height * 0.8; // 80% filled
      double orangeHeight = liquidHeight * (fillOrange / totalFill);
      double waterHeight = liquidHeight * (fillWater / totalFill);

      Rect orangeRect = Rect.fromLTRB(
        beakerRect.left,
        beakerRect.bottom - orangeHeight,
        beakerRect.right,
        beakerRect.bottom,
      );
      Rect waterRect = Rect.fromLTRB(
        beakerRect.left,
        beakerRect.bottom - liquidHeight,
        beakerRect.right,
        beakerRect.bottom - orangeHeight,
      );

      canvas.drawRect(
        orangeRect,
        Paint()..color = Colors.orangeAccent.withOpacity(0.8),
      );
      canvas.drawRect(
        waterRect,
        Paint()..color = Colors.lightBlueAccent.withOpacity(0.5),
      );

      // Glass Outline
      final glassPaint = Paint()
        ..color = Colors.white70
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      Path glass = Path()
        ..moveTo(beakerRect.left, beakerRect.top)
        ..lineTo(beakerRect.left, beakerRect.bottom)
        ..lineTo(beakerRect.right, beakerRect.bottom)
        ..lineTo(beakerRect.right, beakerRect.top);
      canvas.drawPath(glass, glassPaint);

      // Labels
      drawText(
        labels['orange'] ?? 'Orange',
        basePos + Offset(0, height / 2 - (orangeHeight / 2)),
        Colors.white,
        fontSize: 16,
        shadow: true,
      );
      drawText(
        labels['water'] ?? 'Water',
        basePos + Offset(0, height / 2 - orangeHeight - (waterHeight / 2)),
        Colors.white,
        fontSize: 16,
        shadow: true,
      );
    }

    if (step <= 3) {
      // Titles
      drawText(
        labels['beakerA'] ?? 'Beaker A (2:3)',
        center + const Offset(-180, -100),
        Colors.amber,
      );
      drawText(
        labels['beakerB'] ?? 'Beaker B (3:5)',
        center + const Offset(120, -100),
        Colors.amber,
      );

      // Beaker A (2:3 -> 2/5 orange, 3/5 blue)
      drawBeaker(center + const Offset(-180, 40), 2 / 5, 3 / 5);

      // Beaker B (3:5 -> 3/8 orange, 5/8 blue)
      drawBeaker(center + const Offset(120, 40), 3 / 8, 5 / 8);
    } else if (step == 4) {
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

      if (isInteractionComplete) {
        // Draw crossing lines
        final crossPaint1 = Paint()
          ..color = Colors.greenAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
        canvas.drawLine(
          center + const Offset(-60, -75),
          center + const Offset(40, -45),
          crossPaint1,
        ); // 2 to 10
        canvas.drawLine(
          center + const Offset(-60, -45),
          center + const Offset(40, -75),
          Paint()
            ..color = Colors.redAccent
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        ); // 5 to 3
      }

      drawText(
        "2/5",
        center + const Offset(-80, -60),
        Colors.white,
        fontSize: 36,
      );
      drawText(
        "3/8",
        center + const Offset(60, -60),
        Colors.white,
        fontSize: 36,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ComparingProportionsPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.step != step ||
        oldDelegate.isInteractionComplete != isInteractionComplete ||
        oldDelegate.labels != labels;
  }
}
