// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class PolynomialsLikeTermsLab extends StatefulWidget {
  const PolynomialsLikeTermsLab({Key? key}) : super(key: key);

  @override
  State<PolynomialsLikeTermsLab> createState() =>
      _PolynomialsLikeTermsLabState();
}

class _PolynomialsLikeTermsLabState extends State<PolynomialsLikeTermsLab>
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
  int _step1SelectedAnswer = -1;
  int _step2SelectedAnswer = -1;
  int _step3SelectedAnswer = -1;
  int _step5SelectedAnswer = -1;

  // Step 4 Drag & Drop Grid State
  String? _dropTL;
  String? _dropTR;
  String? _dropBL;
  String? _dropBR;
  List<String> _availableDraggables = ['x²', 'xy_1', 'xy_2', 'y²'];

  // --- Animations & Audio ---
  late AnimationController _curtainController;
  late Animation<Offset> _curtainAnimation;
  late AudioPlayer _audioPlayer;

  // --- Localization Data ---
  final Map<String, Map<String, dynamic>> _translations = {
    'en': {
      'langCode': 'EN',
      'titleMain': 'Polynomials & Like Terms',
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
      'selectWarn': 'Please make a selection in the HUD.',
      'labels': {
        'gridTL': 'x² Term',
        'gridTR': 'xy Term',
        'gridBL': 'xy Term',
        'gridBR': 'y² Term',
        'dropHere': 'Drop',
      },
      'steps': [
        {
          'title': 'Step 1: Anatomy of a Term',
          'theory':
              "An algebraic expression is made of 'terms' separated by + or - signs.\n\nTake the term '3x²'. The '3' is the coefficient, 'x' is the variable, and '2' is the exponent.",
          'hudTitle': 'Identify Coefficient',
          'hudInstruction': "In the expression '5xy', what is the coefficient?",
          'options': ['x', 'y', '5', 'xy'],
          'correctIdx': 2,
        },
        {
          'title': 'Step 2: Like vs Unlike Terms',
          'theory':
              "'Like terms' are terms that have the exact same variables with the exact same exponents. The coefficients can be different.\n\nFor example, '3x²' and '-5x²' are like terms. But '3x²' and '3x' are NOT.",
          'hudTitle': 'Find the Match',
          'hudInstruction': "Which of the following is a 'Like Term' to '4xy'?",
          'options': ['4x', '7xy', '4y', 'x²y'],
          'correctIdx': 1,
        },
        {
          'title': 'Step 3: Combining Like Terms',
          'theory':
              "We can add or subtract 'like terms' by simply adding or subtracting their coefficients.\n\nThink of it like adding physical objects: 3 apples + 2 apples = 5 apples. \n\nSimilarly, 3xy + 2xy = 5xy.",
          'hudTitle': 'Simplify Expression',
          'hudInstruction': "Simplify the expression: 7x² - 2x²",
          'options': ['9x²', '5x²', '5x⁴', '14x²'],
          'correctIdx': 1,
        },
        {
          'title': 'Step 4: Sorting terms of (x+y)²',
          'theory':
              "Let's expand the polynomial (x + y)².\n\n(x + y)(x + y) = x(x+y) + y(x+y) = x² + xy + yx + y².\nSince xy and yx are exactly the same, we have two 'xy' like terms.",
          'hudTitle': 'Polynomial Grid',
          'hudInstruction':
              "Drag the 4 terms into the correct grid spaces to reconstruct the expanded polynomial.",
        },
        {
          'title': 'Step 5: Final Synthesis',
          'theory':
              "By combining the like terms from our grid, we get the final simplified polynomial identity.\n\nx² + xy + xy + y² simplifies by combining the two 'xy' terms into '2xy'.",
          'hudTitle': 'Select Final Identity',
          'hudInstruction':
              "Select the correctly simplified identity for (x+y)².",
          'options': ['x² + y²', 'x² + 2xy + y²', '2x + 2y', 'x² + xy²'],
          'correctIdx': 1,
        },
      ],
    },
    'hi': {
      'langCode': 'HI',
      'titleMain': 'बहुपद और समान पद',
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
      'selectWarn': 'कृपया HUD में एक विकल्प चुनें।',
      'labels': {
        'gridTL': 'x² पद',
        'gridTR': 'xy पद',
        'gridBL': 'xy पद',
        'gridBR': 'y² पद',
        'dropHere': 'यहाँ छोड़ें',
      },
      'steps': [
        {
          'title': 'चरण 1: एक पद की शारीरिक रचना',
          'theory':
              "एक बीजीय व्यंजक + या - चिह्नों द्वारा अलग किए गए 'पदों' से बना होता है।\n\nपद '3x²' लें। '3' गुणांक (coefficient) है, 'x' चर (variable) है, और '2' घातांक (exponent) है।",
          'hudTitle': 'गुणांक पहचानें',
          'hudInstruction': "व्यंजक '5xy' में गुणांक क्या है?",
          'options': ['x', 'y', '5', 'xy'],
          'correctIdx': 2,
        },
        {
          'title': 'चरण 2: समान बनाम असमान पद',
          'theory':
              "'समान पद' (Like terms) वे पद होते हैं जिनमें बिल्कुल समान घातांक वाले बिल्कुल समान चर होते हैं। गुणांक भिन्न हो सकते हैं।\n\nउदाहरण के लिए, '3x²' और '-5x²' समान पद हैं। लेकिन '3x²' और '3x' नहीं हैं।",
          'hudTitle': 'समान खोजें',
          'hudInstruction': "निम्नलिखित में से कौन सा '4xy' का 'समान पद' है?",
          'options': ['4x', '7xy', '4y', 'x²y'],
          'correctIdx': 1,
        },
        {
          'title': 'चरण 3: समान पदों को मिलाना',
          'theory':
              "हम 'समान पदों' को केवल उनके गुणांकों को जोड़कर या घटाकर जोड़ या घटा सकते हैं।\n\nइसे भौतिक वस्तुओं को जोड़ने जैसा समझें: 3 सेब + 2 सेब = 5 सेब। \n\nइसी तरह, 3xy + 2xy = 5xy।",
          'hudTitle': 'व्यंजक सरल करें',
          'hudInstruction': "व्यंजक को सरल करें: 7x² - 2x²",
          'options': ['9x²', '5x²', '5x⁴', '14x²'],
          'correctIdx': 1,
        },
        {
          'title': 'चरण 4: (x+y)² के पदों को छाँटना',
          'theory':
              "आइए बहुपद (x + y)² का विस्तार करें।\n\n(x + y)(x + y) = x(x+y) + y(x+y) = x² + xy + yx + y²।\nचूंकि xy और yx समान हैं, इसलिए हमारे पास दो 'xy' समान पद हैं।",
          'hudTitle': 'बहुपद ग्रिड',
          'hudInstruction':
              "विस्तारित बहुपद के पुनर्निर्माण के लिए 4 पदों को सही ग्रिड स्थानों में खींचें।",
        },
        {
          'title': 'चरण 5: अंतिम संश्लेषण',
          'theory':
              "हमारे ग्रिड से समान पदों को मिलाकर, हमें अंतिम सरलीकृत बहुपद सर्वसमिका प्राप्त होती है।\n\nx² + xy + xy + y² दो 'xy' पदों को '2xy' में मिलाकर सरल हो जाता है।",
          'hudTitle': 'अंतिम सर्वसमिका चुनें',
          'hudInstruction':
              "(x+y)² के लिए सही ढंग से सरलीकृत सर्वसमिका का चयन करें।",
          'options': ['x² + y²', 'x² + 2xy + y²', '2x + 2y', 'x² + xy²'],
          'correctIdx': 1,
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
      _step1SelectedAnswer = -1;
      _step2SelectedAnswer = -1;
      _step3SelectedAnswer = -1;
      _step5SelectedAnswer = -1;

      _dropTL = null;
      _dropTR = null;
      _dropBL = null;
      _dropBR = null;
      _availableDraggables = ['x²', 'xy_1', 'xy_2', 'y²'];
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
    if (_currentStep == 0) {
      _evaluateMCQ(_step1SelectedAnswer);
    } else if (_currentStep == 1) {
      _evaluateMCQ(_step2SelectedAnswer);
    } else if (_currentStep == 2) {
      _evaluateMCQ(_step3SelectedAnswer);
    } else if (_currentStep == 3) {
      // Step 4 is drag and drop automatic evaluation via _checkStep4Completion
      _showFeedback(_getString('toastSuccess'), true);
    } else if (_currentStep == 4) {
      _evaluateMCQ(_step5SelectedAnswer);
    }
  }

  void _evaluateMCQ(int answerIndex) {
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
  }

  void _handleMCQChoice(int answerIndex) {
    if (_interactionCompleted) return;
    _playSound('tap');

    setState(() {
      if (_currentStep == 0) _step1SelectedAnswer = answerIndex;
      if (_currentStep == 1) _step2SelectedAnswer = answerIndex;
      if (_currentStep == 2) _step3SelectedAnswer = answerIndex;
      if (_currentStep == 4) _step5SelectedAnswer = answerIndex;
    });

    _validateInvestigation();
  }

  void _handleDrop(String gridPos, String data) {
    if (_interactionCompleted) return;
    _playSound('tap');

    setState(() {
      _availableDraggables.remove(data);

      if (gridPos == 'TL') {
        if (_dropTL != null) _availableDraggables.add(_dropTL!);
        _dropTL = data;
      } else if (gridPos == 'TR') {
        if (_dropTR != null) _availableDraggables.add(_dropTR!);
        _dropTR = data;
      } else if (gridPos == 'BL') {
        if (_dropBL != null) _availableDraggables.add(_dropBL!);
        _dropBL = data;
      } else if (gridPos == 'BR') {
        if (_dropBR != null) _availableDraggables.add(_dropBR!);
        _dropBR = data;
      }
    });

    _checkStep4Completion();
  }

  void _checkStep4Completion() {
    if (_dropTL != null &&
        _dropTR != null &&
        _dropBL != null &&
        _dropBR != null) {
      if (_dropTL == 'x²' &&
          _dropBR == 'y²' &&
          (_dropTR == 'xy_1' || _dropTR == 'xy_2') &&
          (_dropBL == 'xy_1' || _dropBL == 'xy_2')) {
        _showFeedback(_getString('toastSuccess'), true);
      } else {
        _playSound('error');
        setState(() {
          _feedbackMessage = _getString('toastError');
          _feedbackIsSuccess = false;
        });
      }
    }
  }

  String _getDisplayStringForDraggable(String id) {
    if (id.startsWith('xy')) return 'xy';
    return id;
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
    if (_currentStep == 3) {
      return Text(
        _interactionCompleted
            ? "Grid Completed!"
            : "Drag terms into the grid on canvas.",
        style: TextStyle(
          color: _interactionCompleted ? Colors.greenAccent : Colors.amber,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      );
    }

    List<String> options = List<String>.from(currentScenario['options'] ?? []);
    int currentAnswer = -1;
    if (_currentStep == 0) currentAnswer = _step1SelectedAnswer;
    if (_currentStep == 1) currentAnswer = _step2SelectedAnswer;
    if (_currentStep == 2) currentAnswer = _step3SelectedAnswer;
    if (_currentStep == 4) currentAnswer = _step5SelectedAnswer;
    int correctIdx = currentScenario['correctIdx'] ?? -1;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: List.generate(options.length, (idx) {
        return _buildMCQBtn(
          idx,
          options[idx],
          currentAnswer,
          correctIdx,
          _handleMCQChoice,
        );
      }),
    );
  }

  Widget _buildMCQBtn(
    int value,
    String text,
    int currentValue,
    int correctValue,
    Function(int) onTap,
  ) {
    bool isSelected = currentValue == value;
    return InkWell(
      onTap: _interactionCompleted ? null : () => onTap(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (value == correctValue ? Colors.green : Colors.redAccent)
              : (_isDarkTheme ? Colors.white10 : Colors.black12),
          border: Border.all(
            color: isSelected ? Colors.transparent : borderPanel,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : textBase,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDropTarget(String gridPos, String? data, String label) {
    return DragTarget<String>(
      builder: (context, candidateData, rejectedData) {
        bool isHovered = candidateData.isNotEmpty;
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: isHovered
                ? Colors.amber.withOpacity(0.3)
                : (_isDarkTheme ? Colors.black26 : Colors.white54),
            border: Border.all(
              color: isHovered
                  ? Colors.amber
                  : (data != null ? Colors.greenAccent : borderPanel),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (data == null)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.arrow_downward,
                      color: Colors.amber,
                      size: 24,
                    ),
                    Text(
                      _getLabel('dropHere'),
                      style: TextStyle(color: textMuted, fontSize: 12),
                    ),
                  ],
                ),
              if (data != null)
                Text(
                  _getDisplayStringForDraggable(data),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              Positioned(
                bottom: 4,
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ),
            ],
          ),
        );
      },
      onAccept: (data) => _handleDrop(gridPos, data),
    );
  }

  Widget _buildDraggableItem(String id, {bool isDragging = false}) {
    String display = _getDisplayStringForDraggable(id);
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: isDragging
              ? [BoxShadow(color: Colors.blue.withOpacity(0.8), blurRadius: 20)]
              : [
                  const BoxShadow(
                    color: Colors.black54,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.lightBlueAccent, Colors.blue],
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          display,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
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
              // 2D Canvas Background Painter
              CustomPaint(
                size: Size.infinite,
                painter: PolynomialsPainter(isDark: _isDarkTheme),
              ),

              // Step 4: Interactive Drag & Drop Grid
              if (_currentStep == 3) ...[
                // The Grid
                Positioned(
                  left: centerX - 110,
                  top: centerY - 110,
                  child: _buildDropTarget('TL', _dropTL, _getLabel('gridTL')),
                ),
                Positioned(
                  left: centerX + 10,
                  top: centerY - 110,
                  child: _buildDropTarget('TR', _dropTR, _getLabel('gridTR')),
                ),
                Positioned(
                  left: centerX - 110,
                  top: centerY + 10,
                  child: _buildDropTarget('BL', _dropBL, _getLabel('gridBL')),
                ),
                Positioned(
                  left: centerX + 10,
                  top: centerY + 10,
                  child: _buildDropTarget('BR', _dropBR, _getLabel('gridBR')),
                ),

                // Available Draggables
                if (!_interactionCompleted)
                  Positioned(
                    top: centerY - 240,
                    child: Row(
                      children: _availableDraggables
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Draggable<String>(
                                data: item,
                                feedback: _buildDraggableItem(
                                  item,
                                  isDragging: true,
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.3,
                                  child: _buildDraggableItem(item),
                                ),
                                child: _buildDraggableItem(item),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),

                // Success Formula Overlay
                if (_interactionCompleted)
                  Positioned(
                    top: centerY - 220,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        border: Border.all(color: Colors.greenAccent, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "(x + y)² = x² + xy + xy + y²",
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
              ] else ...[
                // For Steps 0, 1, 2, 4 - Show static decorative representations
                Positioned(
                  top: centerY - 60,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      border: Border.all(color: Colors.amber),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.2),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Text(
                      _currentStep == 0
                          ? "3x²"
                          : _currentStep == 1
                          ? "4xy"
                          : _currentStep == 2
                          ? "7x² - 2x² = ?"
                          : "x² + 2xy + y²",
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
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
                              Icons.calculate,
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
                      const Icon(Icons.category, color: Colors.amber, size: 80),
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
class PolynomialsPainter extends CustomPainter {
  final bool isDark;

  PolynomialsPainter({required this.isDark});

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
  }

  @override
  bool shouldRepaint(covariant PolynomialsPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
