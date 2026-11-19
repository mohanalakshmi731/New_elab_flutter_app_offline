// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class IncrementsInProductsLab extends StatefulWidget {
  const IncrementsInProductsLab({Key? key}) : super(key: key);

  @override
  State<IncrementsInProductsLab> createState() =>
      _IncrementsInProductsLabState();
}

class _IncrementsInProductsLabState extends State<IncrementsInProductsLab>
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

  // Step Interactions
  bool _step1SquareDrawn = false;
  double _valA = 2.0; // Increment a
  double _valB = 3.0; // Increment b
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
      'titleMain': 'Increments in Products',
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
        'x2': 'x²',
        'ax': 'ax',
        'bx': 'bx',
        'ab': 'ab',
        'width': 'Width',
        'height': 'Height',
      },
      'steps': [
        {
          'title': 'Step 1: The Base Square',
          'theory':
              "Welcome to Concept 1. Let's investigate how products increase when we add increments to their factors.\n\nImagine a piece of land that is a perfect square with a side length of 'x'.\n\nMathematically, the area of this land is \$x \\times x = x^2\$.",
          'hudTitle': 'Base Area',
          'hudInstruction':
              "Tap to draw the initial square piece of land (Area = x²).",
          'btnText': 'Draw Square',
        },
        {
          'title': 'Step 2: Adding Increment \'a\'',
          'theory':
              "What happens if we increase the width of the land by a small amount 'a'?\n\nThe total width becomes (x + a). The area isn't just \$x^2\$ anymore.\n\nWe have added a new rectangular piece of land attached to the side. The area of this new piece is \$a \\times x = ax\$.",
          'hudTitle': 'Increase Width',
          'hudInstruction':
              "Drag the slider to increase the width by increment 'a'.",
        },
        {
          'title': 'Step 3: Adding Increment \'b\'',
          'theory':
              "Now, what if we also increase the height of the land by an amount 'b'?\n\nWe add another rectangle at the bottom with area \$b \\times x = bx\$.\n\nBut look closely! To complete the new large rectangle, we also have to fill in a small corner piece. The area of this corner piece is \$a \\times b = ab\$.",
          'hudTitle': 'Increase Height',
          'hudInstruction':
              "Drag the slider to increase the height by increment 'b'.",
        },
        {
          'title': 'Step 4: The Geometric Proof',
          'theory':
              "Look at the complete figure! We started with sides (x) and (x). We ended with sides (x + a) and (x + b).\n\nThe total area of the new large rectangle is the sum of all four individual puzzle pieces we created.",
          'hudTitle': 'Identify the Equation',
          'hudInstruction':
              "Select the correct algebraic equation representing this entire area model.",
          'options': [
            '(x+a)(x+b) = x² + a + b',
            '(x+a)(x+b) = x² + ax + bx + ab',
            '(x+a)(x+b) = x² + ab',
          ],
          'correctIdx': 1,
        },
        {
          'title': 'Step 5: Mathematical Application',
          'theory':
              "This geometric proof gives us a powerful algebraic identity:\n\$(x+a)(x+b) = x^2 + (a+b)x + ab\$.\n\nLet's calculate \$102 \\times 103\$. We can write this as \$(100+2)(100+3)\$.\nHere, \$x=100\$, \$a=2\$, and \$b=3\$.\n\nArea = \$100^2 + (2+3)100 + (2 \\times 3)\$",
          'hudTitle': 'Solve the Product',
          'hudInstruction':
              "Calculate the final numeric value of 102 × 103 using the formula.",
          'correctValue': 10506,
        },
      ],
    },
    'hi': {
      'langCode': 'HI',
      'titleMain': 'गुणनफल में वृद्धि',
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
        'x2': 'x²',
        'ax': 'ax',
        'bx': 'bx',
        'ab': 'ab',
        'width': 'चौड़ाई',
        'height': 'ऊंचाई',
      },
      'steps': [
        {
          'title': 'चरण 1: मूल वर्ग',
          'theory':
              "कांसेप्ट 1 में आपका स्वागत है। आइए जांच करें कि जब हम उनके कारकों में वृद्धि जोड़ते हैं तो गुणनफल कैसे बढ़ता है।\n\nभूमि के एक टुकड़े की कल्पना करें जो 'x' की भुजा की लंबाई वाला एक पूर्ण वर्ग है।\n\nगणितीय रूप से, इस भूमि का क्षेत्रफल \$x \\times x = x^2\$ है।",
          'hudTitle': 'मूल क्षेत्र',
          'hudInstruction':
              "भूमि का प्रारंभिक वर्गाकार टुकड़ा (क्षेत्रफल = x²) खींचने के लिए टैप करें।",
          'btnText': 'वर्ग बनाएं',
        },
        {
          'title': 'चरण 2: वृद्धि \'a\' जोड़ना',
          'theory':
              "क्या होता है यदि हम भूमि की चौड़ाई को थोड़ी मात्रा 'a' से बढ़ाते हैं?\n\nकुल चौड़ाई (x + a) हो जाती है। क्षेत्रफल अब केवल \$x^2\$ नहीं है।\n\nहमने किनारे से जुड़ा भूमि का एक नया आयताकार टुकड़ा जोड़ा है। इस नए टुकड़े का क्षेत्रफल \$a \\times x = ax\$ है।",
          'hudTitle': 'चौड़ाई बढ़ाएँ',
          'hudInstruction':
              "वृद्धि 'a' से चौड़ाई बढ़ाने के लिए स्लाइडर को खींचें।",
        },
        {
          'title': 'चरण 3: वृद्धि \'b\' जोड़ना',
          'theory':
              "अब, क्या होगा यदि हम भूमि की ऊंचाई भी 'b' मात्रा से बढ़ाते हैं?\n\nहम नीचे \$b \\times x = bx\$ क्षेत्रफल का एक और आयत जोड़ते हैं।\n\nलेकिन ध्यान से देखो! नए बड़े आयत को पूरा करने के लिए, हमें एक छोटे कोने का टुकड़ा भी भरना होगा। इस कोने के टुकड़े का क्षेत्रफल \$a \\times b = ab\$ है।",
          'hudTitle': 'ऊंचाई बढ़ाएँ',
          'hudInstruction':
              "वृद्धि 'b' से ऊंचाई बढ़ाने के लिए स्लाइडर को खींचें।",
        },
        {
          'title': 'चरण 4: ज्यामितीय प्रमाण',
          'theory':
              "पूरी आकृति को देखें! हमने भुजाओं (x) और (x) के साथ शुरुआत की। हमने भुजाओं (x + a) और (x + b) के साथ समाप्त किया।\n\nनए बड़े आयत का कुल क्षेत्रफल हमारे द्वारा बनाए गए सभी चार अलग-अलग पहेली टुकड़ों का योग है।",
          'hudTitle': 'समीकरण की पहचान करें',
          'hudInstruction':
              "इस संपूर्ण क्षेत्र मॉडल का प्रतिनिधित्व करने वाले सही बीजीय समीकरण का चयन करें।",
          'options': [
            '(x+a)(x+b) = x² + a + b',
            '(x+a)(x+b) = x² + ax + bx + ab',
            '(x+a)(x+b) = x² + ab',
          ],
          'correctIdx': 1,
        },
        {
          'title': 'चरण 5: गणितीय अनुप्रयोग',
          'theory':
              "यह ज्यामितीय प्रमाण हमें एक शक्तिशाली बीजीय सर्वसमिका देता है:\n\$(x+a)(x+b) = x^2 + (a+b)x + ab\$।\n\nआइए \$102 \\times 103\$ की गणना करें। हम इसे \$(100+2)(100+3)\$ के रूप में लिख सकते हैं।\nयहाँ, \$x=100\$, \$a=2\$, और \$b=3\$।\n\nक्षेत्रफल = \$100^2 + (2+3)100 + (2 \\times 3)\$",
          'hudTitle': 'गुणनफल हल करें',
          'hudInstruction':
              "सूत्र का उपयोग करके 102 × 103 के अंतिम संख्यात्मक मान की गणना करें।",
          'correctValue': 10506,
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

      // Reset interaction states logically based on step
      if (step == 0) {
        _step1SquareDrawn = false;
        _valA = 0.0;
        _valB = 0.0;
      } else if (step == 1) {
        _step1SquareDrawn = true;
        _valA = 0.0;
        _valB = 0.0;
      } else if (step == 2) {
        _step1SquareDrawn = true;
        _valA = 3.0; // pre-fill a
        _valB = 0.0;
      } else if (step == 3) {
        _step1SquareDrawn = true;
        _valA = 3.0;
        _valB = 4.0; // pre-fill b
        _step4SelectedAnswer = -1;
      } else if (step == 4) {
        _step1SquareDrawn = true;
        _valA = 3.0;
        _valB = 4.0;
        _inputController.clear();
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
    if (_currentStep == 0) {
      if (_step1SquareDrawn) {
        _showFeedback(_getString('toastSuccess'), true);
      } else {
        _showFeedback(_getString('toastError'), false);
      }
    } else if (_currentStep == 1) {
      if (_valA >= 1.0) {
        _showFeedback(_getString('toastSuccess'), true);
      } else {
        _showFeedback(_getString('toastError'), false);
      }
    } else if (_currentStep == 2) {
      if (_valB >= 1.0) {
        _showFeedback(_getString('toastSuccess'), true);
      } else {
        _showFeedback(_getString('toastError'), false);
      }
    } else if (_currentStep == 3) {
      int correctIdx = currentScenario['correctIdx'] ?? -1;
      if (_step4SelectedAnswer == correctIdx) {
        _showFeedback(_getString('toastSuccess'), true);
      } else {
        _showFeedback(_getString('toastError'), false);
        // Clear selection after a delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && !_interactionCompleted) {
            setState(() {
              _feedbackMessage = null;
              _step4SelectedAnswer = -1;
            });
          }
        });
      }
    } else if (_currentStep == 4) {
      int? parsed = int.tryParse(_inputController.text.trim());
      int correctVal = currentScenario['correctValue'] ?? -999;
      if (parsed == correctVal) {
        _showFeedback(_getString('toastSuccess'), true);
      } else {
        _showFeedback(_getString('toastError'), false);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && !_interactionCompleted) {
            setState(() {
              _feedbackMessage = null;
            });
          }
        });
      }
    }
  }

  void _handleStep1Action() {
    if (_interactionCompleted) return;
    _playSound('tap');
    setState(() => _step1SquareDrawn = true);
    _showFeedback(_getString('toastSuccess'), true);
  }

  void _handleMCQChoice(int answerIndex) {
    if (_interactionCompleted) return;
    _playSound('tap');
    setState(() => _step4SelectedAnswer = answerIndex);
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
    if (_currentStep == 0 && !_interactionCompleted) {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: _handleStep1Action,
        icon: const Icon(Icons.crop_square),
        label: Text(
          _getStepString('btnText'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );
    } else if (_currentStep == 1) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              "a = ${_valA.toStringAsFixed(1)}",
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 200,
            child: Slider(
              value: _valA,
              min: 0,
              max: 5,
              divisions: 50,
              activeColor: Colors.amber,
              inactiveColor: borderPanel,
              onChanged: _interactionCompleted
                  ? null
                  : (val) {
                      setState(() => _valA = val);
                      if (val >= 3.0 && !_interactionCompleted) {
                        _playSound('success');
                        _showFeedback(_getString('toastSuccess'), true);
                      }
                    },
            ),
          ),
        ],
      );
    } else if (_currentStep == 2) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              "b = ${_valB.toStringAsFixed(1)}",
              style: const TextStyle(
                color: Colors.purpleAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 200,
            child: Slider(
              value: _valB,
              min: 0,
              max: 5,
              divisions: 50,
              activeColor: Colors.purpleAccent,
              inactiveColor: borderPanel,
              onChanged: _interactionCompleted
                  ? null
                  : (val) {
                      setState(() => _valB = val);
                      if (val >= 4.0 && !_interactionCompleted) {
                        _playSound('success');
                        _showFeedback(_getString('toastSuccess'), true);
                      }
                    },
            ),
          ),
        ],
      );
    } else if (_currentStep == 3) {
      List<String> options = List<String>.from(
        currentScenario['options'] ?? [],
      );
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: List.generate(options.length, (idx) {
          bool isSelected = _step4SelectedAnswer == idx;
          bool isCorrect = idx == (currentScenario['correctIdx'] ?? -1);
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
    } else if (_currentStep == 4) {
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
                hintText: "102 × 103",
                hintStyle: TextStyle(color: textMuted),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (val) {
                _playSound('tap');
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
                    _playSound('tap');
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
              // 2D Geometric Render Area Model
              CustomPaint(
                size: Size.infinite,
                painter: AreaModelPainter(
                  isDark: _isDarkTheme,
                  step: _currentStep,
                  isSquareDrawn: _step1SquareDrawn,
                  valA: _valA,
                  valB: _valB,
                  labels: tLabels,
                ),
              ),

              // Only in Step 4/5 - Floating math summary
              if (_currentStep >= 3)
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
                      _currentStep == 3
                          ? "(x + a)(x + b) = x² + ax + bx + ab"
                          : "100² + (2+3)100 + (2×3)",
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

    // Format Theory to handle MathJax strings natively
    String formattedTheory = currentScenario['theory']
        .toString()
        .replaceAll(r"$", "")
        .replaceAll(r"\times", "×")
        .replaceAll(r"^2", "²");

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
                      const Icon(Icons.add_box, color: Colors.amber, size: 80),
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

// --- Native Area Model Painter ---
class AreaModelPainter extends CustomPainter {
  final bool isDark;
  final int step;
  final bool isSquareDrawn;
  final double valA;
  final double valB;
  final Map<String, dynamic> labels;

  AreaModelPainter({
    required this.isDark,
    required this.step,
    required this.isSquareDrawn,
    required this.valA,
    required this.valB,
    required this.labels,
  });

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

    if (!isSquareDrawn && step == 0) return;

    final center = Offset(size.width / 2, size.height / 2);

    // Mathematical Proportions
    double baseX = 140.0;
    double scaleA = valA * 20.0;
    double scaleB = valB * 20.0;

    // Origins (centering the total combined box)
    double totalW = baseX + scaleA;
    double totalH = baseX + scaleB;
    double startX = center.dx - (totalW / 2);
    double startY =
        center.dy - (totalH / 2) - 20; // shifted slightly up to clear HUD

    // Paints
    final borderPaint = Paint()
      ..color = isDark ? Colors.white54 : Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final pX2 = Paint()..color = Colors.blueAccent.withOpacity(0.8);
    final pAX = Paint()..color = Colors.greenAccent.withOpacity(0.8);
    final pBX = Paint()..color = Colors.purpleAccent.withOpacity(0.8);
    final pAB = Paint()..color = Colors.orangeAccent.withOpacity(0.8);

    // Helpers to draw text
    void drawLabel(String text, Rect rect, {bool small = false}) {
      if (rect.width < 30 || rect.height < 20)
        return; // don't draw if too small to fit
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: small ? 14 : 24,
            shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          rect.center.dx - (textPainter.width / 2),
          rect.center.dy - (textPainter.height / 2),
        ),
      );
    }

    void drawAxisLabel(String text, Offset pos) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            fontSize: 16,
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

    // 1. Draw Base Square (x²)
    Rect rX2 = Rect.fromLTWH(startX, startY, baseX, baseX);
    canvas.drawRect(rX2, pX2);
    canvas.drawRect(rX2, borderPaint);
    drawLabel(labels['x2']?.toString() ?? 'x²', rX2);

    // Axis labels for x
    drawAxisLabel("x", Offset(startX + (baseX / 2), startY - 15));
    drawAxisLabel("x", Offset(startX - 15, startY + (baseX / 2)));

    // 2. Draw Increment A (ax)
    if (valA > 0) {
      Rect rAX = Rect.fromLTWH(startX + baseX, startY, scaleA, baseX);
      canvas.drawRect(rAX, pAX);
      canvas.drawRect(rAX, borderPaint);
      drawLabel(labels['ax']?.toString() ?? 'ax', rAX, small: scaleA < 50);
      drawAxisLabel("+ a", Offset(startX + baseX + (scaleA / 2), startY - 15));
    }

    // 3. Draw Increment B (bx) & (ab)
    if (valB > 0) {
      Rect rBX = Rect.fromLTWH(startX, startY + baseX, baseX, scaleB);
      canvas.drawRect(rBX, pBX);
      canvas.drawRect(rBX, borderPaint);
      drawLabel(labels['bx']?.toString() ?? 'bx', rBX, small: scaleB < 50);
      drawAxisLabel("+ b", Offset(startX - 20, startY + baseX + (scaleB / 2)));

      if (valA > 0) {
        Rect rAB = Rect.fromLTWH(
          startX + baseX,
          startY + baseX,
          scaleA,
          scaleB,
        );
        canvas.drawRect(rAB, pAB);
        canvas.drawRect(rAB, borderPaint);
        drawLabel(labels['ab']?.toString() ?? 'ab', rAB, small: true);
      }
    }
  }

  @override
  bool shouldRepaint(covariant AreaModelPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.step != step ||
        oldDelegate.isSquareDrawn != isSquareDrawn ||
        oldDelegate.valA != valA ||
        oldDelegate.valB != valB;
  }
}
