// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class DivisibilityLogicLab extends StatefulWidget {
  const DivisibilityLogicLab({Key? key}) : super(key: key);

  @override
  State<DivisibilityLogicLab> createState() => _DivisibilityLogicLabState();
}

class _DivisibilityLogicLabState extends State<DivisibilityLogicLab>
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

  // Step 1: Expand blocks
  bool _step1Expanded = false;

  // Step 2-5: MCQs
  int _step2SelectedAnswer = -1;
  int _step3SelectedAnswer = -1;
  int _step4SelectedAnswer = -1;
  int _step5SelectedAnswer = -1;

  // --- Animations & Audio ---
  late AnimationController _curtainController;
  late Animation<Offset> _curtainAnimation;
  late AudioPlayer _audioPlayer;

  // --- Localization Data ---
  final Map<String, Map<String, dynamic>> _translations = {
    'en': {
      'langCode': 'EN',
      'titleMain': 'Divisibility Logic',
      'chapterMain': 'Class 8 • Playing with Numbers',
      'enterBtn': 'Enter Virtual Lab',
      'teacherTitle': 'Mission Objective',
      'targetOutput': 'Target Output',
      'proceedBtn': 'Proceed to Next Step',
      'validateBtn': 'Validate Logic',
      'restartBtn': 'Restart Activity',
      'activeStep': 'Current Investigation',
      'toastSuccess': 'Excellent! Logic Validated.',
      'toastError': 'Incorrect. Review the theory and try again.',
      'selectWarn': 'Please make a selection in the HUD.',
      'labels': {'tens': 'Tens (10a)', 'units': 'Units (b)'},
      'steps': [
        {
          'title': 'Step 1: Generalised Form',
          'theory':
              "Any 2-digit number can be broken down into its 'Generalised Form'.\n\nTake the number 52. It is made of 5 Tens and 2 Units. Mathematically, 52 = 10 × 5 + 2.\n\nGenerally, any 2-digit number 'ab' is written as 10a + b.",
          'hudTitle': 'Number Structure',
          'hudInstruction':
              "Tap 'Expand' to visualize 52 broken into its Generalised Form.",
        },
        {
          'title': 'Step 2: Divisibility by 2 & 5',
          'theory':
              "Let's look at the generalised form: 10a + b.\n\nThe first part (10a) is a multiple of 10. Since 10 is divisible by both 2 and 5, the '10a' part will ALWAYS be divisible by 2 and 5, no matter what 'a' is!\n\nTherefore, the divisibility of the whole number depends entirely on the unit digit.",
          'hudTitle': 'Logical Deduction',
          'hudInstruction':
              "Which part of '10a + b' dictates if the number is divisible by 5?",
        },
        {
          'title': 'Step 3: Divisibility by 3 & 9',
          'theory':
              "Can we use a similar trick for 3 and 9?\n\nLet's rewrite 10a + b as (9a + a) + b. We can rearrange this to: 9a + (a + b).\n\nThe first part '9a' is ALWAYS divisible by 3 and 9! So, we only need to check the second part.",
          'hudTitle': 'Identify the Rule',
          'hudInstruction':
              "What does the remaining part '(a + b)' represent in the number 'ab'?",
        },
        {
          'title': 'Step 4: Divisibility by 11',
          'theory':
              "For a 3-digit number 'abc', its form is 100a + 10b + c.\n\nWe rewrite this cleverly as: (99a + a) + (11b - b) + c.\nRearranging gives us: 11(9a + b) + (a - b + c).\n\nThe 11(9a + b) part is obviously divisible by 11. We only check (a - b + c).",
          'hudTitle': 'Alternating Sum',
          'hudInstruction':
              "For the number 352, calculate its alternating sum (a - b + c): (3 - 5 + 2).",
        },
        {
          'title': 'Step 5: Put it to the Test',
          'theory':
              "Let's apply our newly discovered rule for 11 to a new number: 418.\n\nRule: A number is divisible by 11 if its alternating sum (a - b + c) is either 0 or a multiple of 11.\n\nCalculate the alternating sum for 418.",
          'hudTitle': 'Final Challenge',
          'hudInstruction': "Is the number 418 divisible by 11?",
        },
      ],
    },
    'hi': {
      'langCode': 'HI',
      'titleMain': 'विभाज्यता तर्क',
      'chapterMain': 'कक्षा 8 • संख्याओं के साथ खेलना',
      'enterBtn': 'वर्चुअल लैब में प्रवेश करें',
      'teacherTitle': 'मिशन का उद्देश्य',
      'targetOutput': 'लक्षित आउटपुट',
      'proceedBtn': 'अगले चरण पर जाएँ',
      'validateBtn': 'तर्क मान्य करें',
      'restartBtn': 'गतिविधि पुनः आरंभ करें',
      'activeStep': 'वर्तमान अन्वेषण',
      'toastSuccess': 'उत्कृष्ट! तर्क मान्य।',
      'toastError': 'गलत। सिद्धांत की समीक्षा करें और पुनः प्रयास करें।',
      'selectWarn': 'कृपया HUD में एक विकल्प चुनें।',
      'labels': {'tens': 'दहाई (10a)', 'units': 'इकाई (b)'},
      'steps': [
        {
          'title': 'चरण 1: सामान्यीकृत रूप',
          'theory':
              "किसी भी 2-अंकीय संख्या को उसके 'सामान्यीकृत रूप' (Generalised Form) में तोड़ा जा सकता है।\n\nसंख्या 52 लें। यह 5 दहाई और 2 इकाई से बना है। गणितीय रूप से, 52 = 10 × 5 + 2।\n\nआमतौर पर, किसी भी 2-अंकीय संख्या 'ab' को 10a + b के रूप में लिखा जाता है।",
          'hudTitle': 'संख्या संरचना',
          'hudInstruction':
              "52 को उसके सामान्यीकृत रूप में देखने के लिए 'विस्तार करें' (Expand) पर टैप करें।",
        },
        {
          'title': 'चरण 2: 2 और 5 से विभाज्यता',
          'theory':
              "आइए सामान्यीकृत रूप को देखें: 10a + b।\n\nपहला भाग (10a) 10 का गुणज है। चूँकि 10 दोनों 2 और 5 से विभाज्य है, '10a' भाग हमेशा 2 और 5 से विभाज्य होगा, चाहे 'a' कुछ भी हो!\n\nइसलिए, पूरी संख्या की विभाज्यता पूरी तरह से इकाई अंक पर निर्भर करती है।",
          'hudTitle': 'तार्किक कटौती',
          'hudInstruction':
              "'10a + b' का कौन सा भाग यह निर्धारित करता है कि संख्या 5 से विभाज्य है या नहीं?",
        },
        {
          'title': 'चरण 3: 3 और 9 से विभाज्यता',
          'theory':
              "क्या हम 3 और 9 के लिए एक समान तरकीब का उपयोग कर सकते हैं?\n\nआइए 10a + b को (9a + a) + b के रूप में फिर से लिखें। हम इसे फिर से व्यवस्थित कर सकते हैं: 9a + (a + b)।\n\nपहला भाग '9a' हमेशा 3 और 9 से विभाज्य होता है! इसलिए, हमें केवल दूसरे भाग की जांच करने की आवश्यकता है।",
          'hudTitle': 'नियम पहचानें',
          'hudInstruction':
              "शेष भाग '(a + b)' संख्या 'ab' में क्या दर्शाता है?",
        },
        {
          'title': 'चरण 4: 11 से विभाज्यता',
          'theory':
              "3-अंकीय संख्या 'abc' के लिए, इसका रूप 100a + 10b + c है।\n\nहम इसे चतुराई से फिर से लिखते हैं: (99a + a) + (11b - b) + c।\nपुनर्व्यवस्थित करने पर हमें प्राप्त होता है: 11(9a + b) + (a - b + c)।\n\n11(9a + b) भाग स्पष्ट रूप से 11 से विभाज्य है। हम केवल (a - b + c) की जांच करते हैं।",
          'hudTitle': 'वैकल्पिक योग',
          'hudInstruction':
              "संख्या 352 के लिए, इसके वैकल्पिक योग (a - b + c) की गणना करें: (3 - 5 + 2)।",
        },
        {
          'title': 'चरण 5: इसका परीक्षण करें',
          'theory':
              "आइए 11 के लिए हमारे नए खोजे गए नियम को एक नई संख्या: 418 पर लागू करें।\n\nनियम: एक संख्या 11 से विभाज्य है यदि उसका वैकल्पिक योग (a - b + c) 0 है या 11 का गुणज है।\n\n418 के लिए वैकल्पिक योग की गणना करें।",
          'hudTitle': 'अंतिम चुनौती',
          'hudInstruction': "क्या संख्या 418, 11 से विभाज्य है?",
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

      // Reset step specific states
      _step1Expanded = false;
      _step2SelectedAnswer = -1;
      _step3SelectedAnswer = -1;
      _step4SelectedAnswer = -1;
      _step5SelectedAnswer = -1;
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
      if (!_step1Expanded) {
        _showFeedback(_getString('selectWarn'), false);
      }
    } else if (_currentStep == 1) {
      if (_step2SelectedAnswer == 1) {
        _showFeedback(_getString('toastSuccess'), true);
      } else {
        _showFeedback(
          _step2SelectedAnswer == -1
              ? _getString('selectWarn')
              : _getString('toastError'),
          false,
        );
      }
    } else if (_currentStep == 2) {
      if (_step3SelectedAnswer == 2) {
        _showFeedback(_getString('toastSuccess'), true);
      } else {
        _showFeedback(
          _step3SelectedAnswer == -1
              ? _getString('selectWarn')
              : _getString('toastError'),
          false,
        );
      }
    } else if (_currentStep == 3) {
      if (_step4SelectedAnswer == 0) {
        _showFeedback(_getString('toastSuccess'), true);
      } else {
        _showFeedback(
          _step4SelectedAnswer == -1
              ? _getString('selectWarn')
              : _getString('toastError'),
          false,
        );
      }
    } else if (_currentStep == 4) {
      if (_step5SelectedAnswer == 1) {
        _showFeedback(_getString('toastSuccess'), true);
      } else {
        _showFeedback(
          _step5SelectedAnswer == -1
              ? _getString('selectWarn')
              : _getString('toastError'),
          false,
        );
      }
    }
  }

  void _handleStep1Expand() {
    if (_interactionCompleted) return;
    _playSound('tap');
    setState(() => _step1Expanded = true);
    _showFeedback(_getString('toastSuccess'), true);
  }

  void _handleStep2Choice(int answer) {
    if (_interactionCompleted) return;
    _playSound('tap');
    setState(() => _step2SelectedAnswer = answer);
    _validateInvestigation();
  }

  void _handleStep3Choice(int answer) {
    if (_interactionCompleted) return;
    _playSound('tap');
    setState(() => _step3SelectedAnswer = answer);
    _validateInvestigation();
  }

  void _handleStep4Choice(int answer) {
    if (_interactionCompleted) return;
    _playSound('tap');
    setState(() => _step4SelectedAnswer = answer);
    _validateInvestigation();
  }

  void _handleStep5Choice(int answer) {
    if (_interactionCompleted) return;
    _playSound('tap');
    setState(() => _step5SelectedAnswer = answer);
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
    if (_currentStep == 0 && !_interactionCompleted) {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: _handleStep1Expand,
        icon: const Icon(Icons.open_in_full),
        label: Text(
          _currentLang == 'en' ? 'Expand 52' : 'विस्तार करें 52',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );
    } else if (_currentStep == 1) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          _buildMCQBtn(0, "10a", _step2SelectedAnswer, 1, _handleStep2Choice),
          _buildMCQBtn(1, "b", _step2SelectedAnswer, 1, _handleStep2Choice),
          _buildMCQBtn(
            2,
            "10a + b",
            _step2SelectedAnswer,
            1,
            _handleStep2Choice,
          ),
        ],
      );
    } else if (_currentStep == 2) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          _buildMCQBtn(
            0,
            _currentLang == 'en' ? "Product of Digits" : "अंकों का गुणनफल",
            _step3SelectedAnswer,
            2,
            _handleStep3Choice,
          ),
          _buildMCQBtn(
            1,
            _currentLang == 'en' ? "Difference" : "अंतर",
            _step3SelectedAnswer,
            2,
            _handleStep3Choice,
          ),
          _buildMCQBtn(
            2,
            _currentLang == 'en' ? "Sum of Digits" : "अंकों का योग",
            _step3SelectedAnswer,
            2,
            _handleStep3Choice,
          ),
        ],
      );
    } else if (_currentStep == 3) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          _buildMCQBtn(0, "0", _step4SelectedAnswer, 0, _handleStep4Choice),
          _buildMCQBtn(1, "10", _step4SelectedAnswer, 0, _handleStep4Choice),
          _buildMCQBtn(2, "11", _step4SelectedAnswer, 0, _handleStep4Choice),
        ],
      );
    } else if (_currentStep == 4) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          _buildMCQBtn(
            1,
            _currentLang == 'en' ? "Yes" : "हाँ",
            _step5SelectedAnswer,
            1,
            _handleStep5Choice,
          ),
          _buildMCQBtn(
            0,
            _currentLang == 'en' ? "No" : "नहीं",
            _step5SelectedAnswer,
            1,
            _handleStep5Choice,
          ),
        ],
      );
    }
    return const SizedBox();
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

  Widget _buildInteractiveCanvas() {
    return Container(
      color: _isDarkTheme ? const Color(0xFF0B1120) : const Color(0xFFE2E8F0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          Size canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
          return Stack(
            alignment: Alignment.center,
            children: [
              // 2D Geometry Background
              CustomPaint(
                size: Size.infinite,
                painter: DivisibilityPainter(
                  step: _currentStep,
                  isDark: _isDarkTheme,
                  expanded: _step1Expanded,
                ),
              ),

              // Absolute HTML-like Overlays for Equations & Text
              ..._buildCanvasOverlays(canvasSize),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildCanvasOverlays(Size canvasSize) {
    List<Widget> overlays = [];
    final centerX = canvasSize.width / 2;
    final centerY = canvasSize.height / 2;

    Widget equationBox(
      String text,
      double dx,
      double dy, {
      Color color = Colors.amber,
      double size = 24,
      Color bgColor = Colors.black87,
      Color borderColor = Colors.amber,
    }) {
      return Positioned(
        left: centerX + dx,
        top: centerY + dy,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: size,
              letterSpacing: 1.5,
            ),
          ),
        ),
      );
    }

    Widget plainText(
      String text,
      double dx,
      double dy, {
      Color color = Colors.white,
      double size = 18,
    }) {
      return Positioned(
        left: centerX + dx,
        top: centerY + dy,
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: size,
          ),
        ),
      );
    }

    if (_currentStep == 0) {
      if (!_step1Expanded) {
        overlays.add(equationBox("52", -40, -40, size: 40));
      } else {
        overlays.add(
          equationBox(
            "10 × 5",
            -120,
            -120,
            color: Colors.blueAccent,
            borderColor: Colors.blueAccent,
          ),
        );
        overlays.add(
          equationBox(
            "+ 2",
            40,
            -120,
            color: Colors.greenAccent,
            borderColor: Colors.greenAccent,
          ),
        );
        overlays.add(
          plainText(_getLabel('tens'), -100, -50, color: Colors.blueAccent),
        );
        overlays.add(
          plainText(_getLabel('units'), 60, -50, color: Colors.greenAccent),
        );
      }
    } else if (_currentStep == 1) {
      overlays.add(equationBox("10a + b", -70, -100, size: 32));
      if (_interactionCompleted) {
        overlays.add(
          equationBox(
            "10a",
            -100,
            20,
            color: Colors.greenAccent,
            borderColor: Colors.greenAccent,
          ),
        );
        overlays.add(
          plainText(
            "Always divisible by 2 & 5",
            -120,
            80,
            color: Colors.greenAccent,
            size: 14,
          ),
        );
        overlays.add(
          equationBox(
            "b",
            60,
            20,
            color: Colors.amber,
            borderColor: Colors.amber,
          ),
        );
        overlays.add(
          plainText(
            "Check this unit digit!",
            20,
            80,
            color: Colors.amber,
            size: 14,
          ),
        );
      }
    } else if (_currentStep == 2) {
      overlays.add(
        equationBox(
          "10a + b",
          -70,
          -140,
          size: 28,
          color: Colors.white70,
          borderColor: Colors.white24,
        ),
      );
      overlays.add(plainText("↓", -10, -80, size: 24));
      overlays.add(
        equationBox(
          "(9a + a) + b",
          -95,
          -40,
          size: 28,
          color: Colors.white70,
          borderColor: Colors.white24,
        ),
      );
      overlays.add(plainText("↓", -10, 20, size: 24));

      if (_interactionCompleted) {
        overlays.add(
          equationBox(
            "9a",
            -110,
            60,
            color: Colors.greenAccent,
            borderColor: Colors.greenAccent,
          ),
        );
        overlays.add(plainText("+", -20, 70, size: 28));
        overlays.add(
          equationBox(
            "(a + b)",
            10,
            60,
            color: Colors.amber,
            borderColor: Colors.amber,
          ),
        );
        overlays.add(
          plainText(
            "Divisible by 3 & 9",
            -140,
            130,
            color: Colors.greenAccent,
            size: 14,
          ),
        );
        overlays.add(
          plainText("Sum of Digits!", 20, 130, color: Colors.amber, size: 14),
        );
      } else {
        overlays.add(equationBox("9a + (a + b)", -100, 60, size: 32));
      }
    } else if (_currentStep == 3) {
      overlays.add(
        equationBox(
          "100a + 10b + c",
          -115,
          -140,
          size: 24,
          color: Colors.white70,
          borderColor: Colors.white24,
        ),
      );
      overlays.add(plainText("↓", -10, -85, size: 20));
      overlays.add(
        equationBox("11(9a + b) + (a - b + c)", -150, -50, size: 24),
      );

      if (_interactionCompleted) {
        overlays.add(
          plainText(
            "For 352: a=3, b=5, c=2",
            -100,
            40,
            color: Colors.lightBlueAccent,
          ),
        );
        overlays.add(
          equationBox(
            "3 - 5 + 2 = 0",
            -90,
            80,
            color: Colors.greenAccent,
            borderColor: Colors.greenAccent,
          ),
        );
        overlays.add(
          plainText(
            "0 is a multiple of 11! Divisible.",
            -120,
            150,
            color: Colors.greenAccent,
            size: 16,
          ),
        );
      }
    } else if (_currentStep == 4) {
      overlays.add(
        equationBox(
          "418",
          -40,
          -120,
          size: 40,
          color: Colors.white,
          borderColor: Colors.blueAccent,
        ),
      );
      if (_interactionCompleted) {
        overlays.add(
          equationBox(
            "4 - 1 + 8 = 11",
            -110,
            -20,
            size: 32,
            color: Colors.amber,
            borderColor: Colors.amber,
          ),
        );
        overlays.add(
          equationBox(
            "11 is divisible by 11. Success!",
            -170,
            80,
            size: 20,
            color: Colors.greenAccent,
            borderColor: Colors.greenAccent,
          ),
        );
      } else {
        overlays.add(
          plainText("a = 4    b = 1    c = 8", -90, 0, color: Colors.white70),
        );
        overlays.add(
          equationBox(
            "a - b + c = ?",
            -90,
            50,
            size: 28,
            color: Colors.white54,
            borderColor: Colors.white24,
          ),
        );
      }
    }

    return overlays;
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
                top: 70,
                left: 14,
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
              child: Center(
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
                            _feedbackMessage ??
                                _getStepString('hudInstruction'),
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
                    top: 70,
                    left: 20,
                    right: 20,
                    bottom: 20,
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
                      Divider(color: borderPanel),
                      const SizedBox(height: 24),

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
                icon: Icon(
                  _isSidebarOpen ? Icons.menu_open : Icons.menu,
                  size: 28,
                ),
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
                        Icons.calculate,
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
                          elevation: 10,
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

// --- Native Background Painter ---
class DivisibilityPainter extends CustomPainter {
  final int step;
  final bool isDark;
  final bool expanded;

  DivisibilityPainter({
    required this.step,
    required this.isDark,
    required this.expanded,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background Grid
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

    final center = Offset(size.width / 2, size.height / 2);

    // Decorative graphical elements (blocks) for Step 1
    if (step == 0 && expanded) {
      final Paint blockPaint10s = Paint()
        ..color = Colors.blueAccent.withOpacity(0.6)
        ..style = PaintingStyle.fill;
      final Paint blockPaintUnits = Paint()
        ..color = Colors.greenAccent.withOpacity(0.6)
        ..style = PaintingStyle.fill;
      final Paint strokePaint = Paint()
        ..color = Colors.white54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      // Draw 5 "Tens" blocks
      for (int i = 0; i < 5; i++) {
        Rect rect = Rect.fromLTWH(
          center.dx - 180 + (i * 30),
          center.dy,
          20,
          100,
        );
        canvas.drawRect(rect, blockPaint10s);
        canvas.drawRect(rect, strokePaint);
      }

      // Draw 2 "Units" blocks
      for (int i = 0; i < 2; i++) {
        Rect rect = Rect.fromLTWH(
          center.dx + 50 + (i * 30),
          center.dy + 80,
          20,
          20,
        );
        canvas.drawRect(rect, blockPaintUnits);
        canvas.drawRect(rect, strokePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DivisibilityPainter oldDelegate) {
    return oldDelegate.step != step ||
        oldDelegate.isDark != isDark ||
        oldDelegate.expanded != expanded;
  }
}
