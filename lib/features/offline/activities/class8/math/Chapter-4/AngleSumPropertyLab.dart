// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class AngleSumPropertyLab extends StatefulWidget {
  const AngleSumPropertyLab({Key? key}) : super(key: key);

  @override
  State<AngleSumPropertyLab> createState() => _AngleSumPropertyLabState();
}

class _AngleSumPropertyLabState extends State<AngleSumPropertyLab>
    with TickerProviderStateMixin {
  // --- UI State ---
  bool _showCurtain = true;
  bool _isSidebarOpen = false; // Start collapsed to highlight floating card
  final bool _isDarkTheme = true;
  int _currentStep = 0;
  String _currentLang = 'en';
  final double _teacherFontSize = 16.0;

  // --- Interaction State ---
  String? _feedbackMessage;
  bool _feedbackIsSuccess = true;
  bool _interactionCompleted = false;

  final TextEditingController _inputController = TextEditingController();
  int _mcqSelectedAnswer = -1;

  // --- Animations & Audio ---
  late AnimationController _curtainController;
  late Animation<Offset> _curtainAnimation;
  late AnimationController _drawAnimController;
  late Animation<double> _drawAnimation;
  late AudioPlayer _audioPlayer;

  // --- Localization Data ---
  final Map<String, Map<String, dynamic>> _translations = {
    'en': {
      'langCode': 'EN',
      'titleMain': 'Angle Sum Property',
      'chapterMain': 'Class 8 • Quadrilaterals',
      'enterBtn': 'Enter Virtual Lab',
      'teacherTitle': 'Mission Objective',
      'targetOutput': 'Target Output',
      'proceedBtn': 'Proceed to Next Step',
      'validateBtn': 'Validate Model',
      'restartBtn': 'Restart Activity',
      'activeStep': 'Current Investigation',
      'toastSuccess': 'Excellent! Correct!',
      'toastError': 'Incorrect. Try again!',
      'selectOptionWarn': 'Please select an option in the HUD.',
      'checkBtn': 'Check Answer',
      'steps': [
        {
          'title': 'Step 1: Intro to Quadrilateral',
          'instruction': 'Welcome! Click below to begin the activity.',
          'theory':
              'Welcome to the interactive Geometry Lab.\n\nLet\'s explore the Angle Sum Property of Quadrilaterals.',
          'interaction': {'type': 'button', 'text': 'Generate Quadrilateral'},
        },
        {
          'title': 'Step 2: The Triangle Split',
          'instruction':
              'Which diagonal should we draw to split this shape into two triangles?',
          'theory':
              'Welcome to Concept 2. We know that the three interior angles of a triangle add up to 180°.\n\nWhat is the rule for a four-sided figure? Let\'s take a general quadrilateral and name its corners S, O, M, and E.',
          'interaction': {
            'type': 'mcq',
            'options': ['Diagonal S-O', 'Diagonal S-M', 'Diagonal O-E'],
            'correctIndex': 1,
            'errorMsg': 'Try again. Look at the vertices on the board!',
          },
        },
        {
          'title': 'Step 3: Triangle Angle Sums',
          'instruction':
              'What is the sum of the interior angles of a single triangle?',
          'theory':
              'We solve unknown problems by breaking them into things we know.\n\nBy drawing a diagonal connecting S to M, we slice the quadrilateral perfectly into two triangles: Triangle SOM and Triangle SME.',
          'interaction': {
            'type': 'mcq',
            'options': ['90°', '180°', '360°'],
            'correctIndex': 1,
            'errorMsg': 'Remember the Triangle Angle Sum property!',
          },
        },
        {
          'title': 'Step 4: Proving 360° Property',
          'instruction':
              'Add the sums of both triangles together (180 + 180) to find the total.',
          'theory':
              'The interior angles of Triangle SOM (blue) must add up to 180°.\n\nThe interior angles of Triangle SME (yellow) must also add up to 180°.',
          'interaction': {
            'type': 'input',
            'placeholder': 'Total sum...',
            'correctValue': 360,
            'errorMsg': 'Incorrect. What is 180 + 180?',
          },
        },
        {
          'title': 'Step 5: Reasoning Challenge Setup',
          'instruction':
              'Now, let\'s test this rule with a Reasoning Challenge.',
          'theory':
              'Since these six smaller angles perfectly combine to form the four original angles of quadrilateral, the total sum is simply 180° + 180°.\n\nThe sum of angles in any quadrilateral is always 360°!',
          'interaction': {'type': 'button', 'text': 'Start Challenge'},
        },
        {
          'title': 'Step 6: Mathematical Equation',
          'instruction':
              'We have three 90° angles. What is their combined sum? (90 + 90 + 90)',
          'theory':
              'Is it possible to draw a quadrilateral that has exactly three 90° (right) angles, but the fourth angle is not 90°?\n\nLet\'s try to sketch it by drawing three perfect 90° corners.',
          'interaction': {
            'type': 'input',
            'placeholder': 'Sum of 3 angles...',
            'correctValue': 270,
            'errorMsg': 'Check your addition! 90 * 3 = ?',
          },
        },
        {
          'title': 'Step 7: Final Conclusion',
          'instruction':
              'Subtract 270 from the total 360 to find the missing 4th angle (X).',
          'theory':
              'Let\'s use our new property. The total sum must be 360°.\n\nWe have three right angles: 90° + 90° + 90° = 270°.',
          'interaction': {
            'type': 'input',
            'placeholder': 'Value of X...',
            'correctValue': 90,
            'errorMsg': 'Try again. 360 - 270 = ?',
          },
        },
        {
          'title': 'Step 8: Synthesis Complete',
          'instruction': 'Proof Complete! The 4th angle MUST be 90°.',
          'theory':
              'The result is exactly 90°. Mathematically, the fourth angle is forced to be a right angle.\n\nThe shape becomes a perfect rectangle. Therefore, having only three 90° angles is impossible!',
          'interaction': {'type': 'button', 'text': 'Finish'},
        },
      ],
    },
    'hi': {
      'langCode': 'HI',
      'titleMain': 'कोण योग गुण',
      'chapterMain': 'कक्षा 8 • चतुर्भुज',
      'enterBtn': 'वर्चुअल लैब में प्रवेश करें',
      'teacherTitle': 'मिशन का उद्देश्य',
      'targetOutput': 'लक्षित आउटपुट',
      'proceedBtn': 'अगले चरण पर जाएँ',
      'validateBtn': 'मॉडल मान्य करें',
      'restartBtn': 'गतिविधि पुनः आरंभ करें',
      'activeStep': 'वर्तमान अन्वेषण',
      'toastSuccess': 'उत्कृष्ट! सही!',
      'toastError': 'गलत। पुनः प्रयास करें!',
      'selectOptionWarn': 'कृपया HUD में एक विकल्प चुनें।',
      'checkBtn': 'उत्तर जांचें',
      'steps': [
        {
          'title': 'चरण 1: चतुर्भुज का परिचय',
          'instruction': 'स्वागत है! गतिविधि शुरू करने के लिए नीचे क्लिक करें।',
          'theory':
              'इंटरैक्टिव ज्योमेट्री लैब में आपका स्वागत है।\n\nआइए चतुर्भुजों के कोण योग गुण का अन्वेषण करें।',
          'interaction': {'type': 'button', 'text': 'चतुर्भुज बनाएँ'},
        },
        {
          'title': 'चरण 2: त्रिभुज विभाजन',
          'instruction':
              'इस आकार को दो त्रिभुजों में विभाजित करने के लिए हमें कौन सा विकर्ण खींचना चाहिए?',
          'theory':
              'अवधारणा 2 में आपका स्वागत है। हम जानते हैं कि एक त्रिभुज के तीन आंतरिक कोणों का योग 180° होता है।\n\nचार भुजाओं वाली आकृति का नियम क्या है? आइए एक सामान्य चतुर्भुज लें और इसके कोनों का नाम S, O, M, और E रखें।',
          'interaction': {
            'type': 'mcq',
            'options': ['विकर्ण S-O', 'विकर्ण S-M', 'विकर्ण O-E'],
            'correctIndex': 1,
            'errorMsg': 'पुनः प्रयास करें। बोर्ड पर शीर्षों को देखें!',
          },
        },
        {
          'title': 'चरण 3: त्रिभुज कोण योग',
          'instruction': 'एकल त्रिभुज के आंतरिक कोणों का योग क्या है?',
          'theory':
              'हम अज्ञात समस्याओं को उन चीजों में तोड़कर हल करते हैं जिन्हें हम जानते हैं।\n\nS को M से जोड़ने वाला एक विकर्ण खींचकर, हम चतुर्भुज को पूरी तरह से दो त्रिभुजों में विभाजित करते हैं: त्रिभुज SOM और त्रिभुज SME।',
          'interaction': {
            'type': 'mcq',
            'options': ['90°', '180°', '360°'],
            'correctIndex': 1,
            'errorMsg': 'त्रिभुज कोण योग गुण याद रखें!',
          },
        },
        {
          'title': 'चरण 4: 360° गुण सिद्ध करना',
          'instruction':
              'कुल ज्ञात करने के लिए दोनों त्रिभुजों का योग (180 + 180) जोड़ें।',
          'theory':
              'त्रिभुज SOM (नीला) के आंतरिक कोणों का योग 180° होना चाहिए।\n\nत्रिभुज SME (पीला) के आंतरिक कोणों का योग भी 180° होना चाहिए।',
          'interaction': {
            'type': 'input',
            'placeholder': 'कुल योग...',
            'correctValue': 360,
            'errorMsg': 'गलत। 180 + 180 क्या है?',
          },
        },
        {
          'title': 'चरण 5: तर्क चुनौती सेटअप',
          'instruction':
              'अब, आइए एक तर्क चुनौती के साथ इस नियम का परीक्षण करें।',
          'theory':
              'चूंकि ये छह छोटे कोण पूरी तरह से चतुर्भुज के चार मूल कोण बनाने के लिए जुड़ते हैं, इसलिए कुल योग केवल 180° + 180° है।\n\nकिसी भी चतुर्भुज में कोणों का योग हमेशा 360° होता है!',
          'interaction': {'type': 'button', 'text': 'चुनौती शुरू करें'},
        },
        {
          'title': 'चरण 6: गणितीय समीकरण',
          'instruction':
              'हमारे पास तीन 90° कोण हैं। उनका संयुक्त योग क्या है? (90 + 90 + 90)',
          'theory':
              'क्या ऐसा चतुर्भुज बनाना संभव है जिसमें ठीक तीन 90° (समकोण) हों, लेकिन चौथा कोण 90° नहीं हो?\n\nआइए तीन पूर्ण 90° कोने खींचकर इसे बनाने का प्रयास करें।',
          'interaction': {
            'type': 'input',
            'placeholder': '3 कोणों का योग...',
            'correctValue': 270,
            'errorMsg': 'अपना जोड़ जांचें! 90 * 3 = ?',
          },
        },
        {
          'title': 'चरण 7: अंतिम निष्कर्ष',
          'instruction':
              'छूटे हुए चौथे कोण (X) को खोजने के लिए कुल 360 में से 270 घटाएं।',
          'theory':
              'आइए अपने नए गुण का उपयोग करें। कुल योग 360° होना चाहिए।\n\nहमारे पास तीन समकोण हैं: 90° + 90° + 90° = 270°.',
          'interaction': {
            'type': 'input',
            'placeholder': 'X का मान...',
            'correctValue': 90,
            'errorMsg': 'पुनः प्रयास करें। 360 - 270 = ?',
          },
        },
        {
          'title': 'चरण 8: संश्लेषण पूर्ण',
          'instruction': 'प्रमाण पूरा हुआ! चौथा कोण 90° होना ही चाहिए।',
          'theory':
              'परिणाम ठीक 90° है। गणितीय रूप से, चौथा कोण समकोण होने के लिए बाध्य है।\n\nआकार एक पूर्ण आयत बन जाता है। इसलिए, केवल तीन 90° कोण होना असंभव है!',
          'interaction': {'type': 'button', 'text': 'समाप्त'},
        },
      ],
    },
  };

  // --- Safe Map Accessors ---
  Map<String, dynamic> get t =>
      _translations[_currentLang] ?? _translations['en']!;
  Map<String, dynamic> get currentScenario {
    final steps = t['steps'] as List?;
    if (steps != null && _currentStep >= 0 && _currentStep < steps.length) {
      return steps[_currentStep] as Map<String, dynamic>;
    }
    return {};
  }

  String _getString(String key) => t[key]?.toString() ?? '';
  String _getStepString(String key) => currentScenario[key]?.toString() ?? '';
  Map<String, dynamic> get _interactionMap =>
      (currentScenario['interaction'] as Map<String, dynamic>?) ?? {};

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

    _drawAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _drawAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _drawAnimController, curve: Curves.easeInOut),
    );

    _startStep(0);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _curtainController.dispose();
    _drawAnimController.dispose();
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

  void _startStep(int step) {
    setState(() {
      _currentStep = step;
      _feedbackMessage = null;
      _interactionCompleted = false;
      _mcqSelectedAnswer = -1;
      _inputController.clear();
    });
    _drawAnimController.reset();
    _drawAnimController.forward();
  }

  void _showFeedback(String msg, bool success) {
    _playSound(success ? 'success' : 'error');
    setState(() {
      _feedbackMessage = msg;
      _feedbackIsSuccess = success;
      if (success) _interactionCompleted = true;
    });
  }

  void _validateInput(dynamic userVal, dynamic correctVal) {
    bool isCorrect = false;
    if (correctVal is int) {
      int parsed = int.tryParse(userVal.toString()) ?? -999;
      isCorrect = (parsed == correctVal);
    } else {
      isCorrect = (userVal == correctVal);
    }

    if (isCorrect) {
      _showFeedback(_getString('toastSuccess'), true);
    } else {
      _showFeedback(
        _interactionMap['errorMsg'] ?? _getString('toastError'),
        false,
      );
    }
  }

  void _validateInteraction() {
    String type = _interactionMap['type'] ?? '';

    if (type == 'button') {
      _showFeedback(_getString('toastSuccess'), true);
    } else if (type == 'mcq') {
      if (_mcqSelectedAnswer == -1) {
        _playSound('error');
        setState(() {
          _feedbackMessage = _getString('selectOptionWarn');
          _feedbackIsSuccess = false;
        });
        return;
      }
      _validateInput(_mcqSelectedAnswer, _interactionMap['correctIndex']);
    } else if (type == 'input') {
      _validateInput(_inputController.text, _interactionMap['correctValue']);
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
    String type = _interactionMap['type'] ?? '';
    String btnLabel = '';

    if (_interactionCompleted) {
      btnLabel = (_currentStep == 7)
          ? _getString('restartBtn')
          : _getString('proceedBtn');
    } else {
      if (type == 'button') {
        btnLabel = _interactionMap['text'] ?? 'Proceed';
      } else {
        btnLabel = _getString('validateBtn');
      }
    }

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: _interactionCompleted ? Colors.green : Colors.amber,
        foregroundColor: _interactionCompleted ? Colors.white : Colors.black,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        _playSound('tap');
        if (_interactionCompleted) {
          if (_currentStep < 7) {
            _startStep(_currentStep + 1);
          } else {
            _startStep(0);
          }
        } else {
          _validateInteraction();
        }
      },
      icon: Icon(
        _interactionCompleted
            ? (_currentStep == 7 ? Icons.refresh : Icons.arrow_forward)
            : Icons.verified,
      ),
      label: Text(
        btnLabel,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildHUDInteraction() {
    String type = _interactionMap['type'] ?? '';

    if (type == 'mcq') {
      List<String> options = List<String>.from(
        _interactionMap['options'] ?? [],
      );
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: List.generate(options.length, (index) {
          bool isSelected = _mcqSelectedAnswer == index;
          return InkWell(
            onTap: _interactionCompleted
                ? null
                : () {
                    _playSound('tap');
                    setState(() => _mcqSelectedAnswer = index);
                  },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.amber.withOpacity(0.8)
                    : (_isDarkTheme ? Colors.white10 : Colors.black12),
                border: Border.all(
                  color: isSelected ? Colors.amber : borderPanel,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                options[index],
                style: TextStyle(
                  color: isSelected ? Colors.black : textBase,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
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
            width: 150,
            child: TextField(
              controller: _inputController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              enabled: !_interactionCompleted,
              style: TextStyle(
                color: textBase,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              decoration: InputDecoration(
                hintText: _interactionMap['placeholder'],
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: _isDarkTheme
                    ? const Color(0xFF0F172A)
                    : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: (val) => _validateInteraction(),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _interactionCompleted ? null : _validateInteraction,
            icon: const Icon(Icons.check_circle, size: 20),
            label: Text(
              _getString('checkBtn'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink(); // Empty for button types (handled by main action)
  }

  Widget _buildInteractiveCanvas() {
    return Container(
      color: _isDarkTheme ? const Color(0xFF0B1120) : const Color(0xFFE2E8F0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // 2D Geometric Render via CustomPaint
              AnimatedBuilder(
                animation: _drawAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size.infinite,
                    painter: GeometryPainter(
                      step: _currentStep,
                      progress: _drawAnimation.value,
                      isDark: _isDarkTheme,
                    ),
                  );
                },
              ),

              // Step 4, 6, 7 Floating Equations
              if (_currentStep == 3 || _currentStep == 5 || _currentStep == 6)
                Positioned(
                  top: 40,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: bgPanel.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      _currentStep == 3
                          ? "180° + 180° = 360°"
                          : _currentStep == 5
                          ? "90° + 90° + 90° + X = 360°\nX = 360° - 270°"
                          : "X = 90°\n(Must be a right angle!)",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
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
                            _getStepString('instruction'),
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
              bottom: 10,
              right: 10,
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
                            _getStepString('title').toUpperCase(),
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _feedbackMessage ?? _getStepString('instruction'),
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
                          if ((_interactionMap['type'] == 'mcq' ||
                              _interactionMap['type'] == 'input')) ...[
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
                      const SizedBox(height: 14),

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
                              _startStep(0);
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
                      Divider(color: borderPanel, height: 32),

                      const SizedBox(height: 14),

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
                            items: List.generate(8, (index) {
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
                                _startStep(val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

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
                          _getStepString('instruction'),
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

            // --- 7. Initial Curtain Raiser ---
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
                      const Icon(Icons.polyline, color: Colors.amber, size: 80),
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

// --- Native Geometric Painter ---
class GeometryPainter extends CustomPainter {
  final int step;
  final double progress; // 0 to 1 for animations
  final bool isDark;

  GeometryPainter({
    required this.step,
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background Grid
    final gridPaint = Paint()
      ..color = isDark
          ? Colors.white.withOpacity(0.05)
          : Colors.black.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    double gridStep = 40;
    for (double i = 0; i < size.width; i += gridStep) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += gridStep) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    canvas.translate(size.width / 2, size.height / 2); // Center

    Paint linePaint = Paint()
      ..color = isDark ? Colors.white70 : Colors.black87
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    Paint fillBlue = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    Paint fillYellow = Paint()
      ..color = Colors.amber.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    TextPainter tp = TextPainter(textDirection: TextDirection.ltr);

    void drawLabel(
      String text,
      Offset pos, [
      Color? color,
      double fontSize = 20,
    ]) {
      tp.text = TextSpan(
        text: text,
        style: TextStyle(
          color: color ?? (isDark ? Colors.white : Colors.black),
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
    }

    if (step >= 0 && step <= 3) {
      // Quad points S, O, M, E
      Offset pS = const Offset(-100, -60);
      Offset pO = const Offset(100, -80);
      Offset pM = const Offset(80, 80);
      Offset pE = const Offset(-70, 70);

      Path quadPath = Path()
        ..moveTo(pS.dx, pS.dy)
        ..lineTo(pO.dx, pO.dy)
        ..lineTo(pM.dx, pM.dy)
        ..lineTo(pE.dx, pE.dy)
        ..close();

      // Animate quad drawing
      if (step == 0) {
        ui.PathMetrics pathMetrics = quadPath.computeMetrics();
        Path animatedPath = Path();
        for (ui.PathMetric metric in pathMetrics) {
          animatedPath.addPath(
            metric.extractPath(0, metric.length * progress),
            Offset.zero,
          );
        }
        canvas.drawPath(animatedPath, linePaint);

        if (progress > 0.8) {
          drawLabel("S", pS + const Offset(-20, -20));
          drawLabel("O", pO + const Offset(20, -20));
          drawLabel("M", pM + const Offset(20, 20));
          drawLabel("E", pE + const Offset(-20, 20));

          drawLabel("?", pS + const Offset(25, 20), Colors.amber);
          drawLabel("?", pO + const Offset(-25, 20), Colors.amber);
          drawLabel("?", pM + const Offset(-25, -20), Colors.amber);
          drawLabel("?", pE + const Offset(20, -20), Colors.amber);
        }
      } else {
        canvas.drawPath(quadPath, linePaint);
        drawLabel("S", pS + const Offset(-20, -20));
        drawLabel("O", pO + const Offset(20, -20));
        drawLabel("M", pM + const Offset(20, 20));
        drawLabel("E", pE + const Offset(-20, 20));
      }

      if (step >= 1) {
        // Draw Diagonal
        Offset dVec = pM - pS;
        canvas.drawLine(
          pS,
          pS +
              Offset(
                dVec.dx * (step == 1 ? progress : 1),
                dVec.dy * (step == 1 ? progress : 1),
              ),
          linePaint,
        );

        // Fills
        Path t1 = Path()
          ..moveTo(pS.dx, pS.dy)
          ..lineTo(pO.dx, pO.dy)
          ..lineTo(pM.dx, pM.dy)
          ..close();
        Path t2 = Path()
          ..moveTo(pS.dx, pS.dy)
          ..lineTo(pM.dx, pM.dy)
          ..lineTo(pE.dx, pE.dy)
          ..close();

        double fillOpacity = (step == 1) ? progress * 0.5 : 0.5;
        fillBlue = Paint()
          ..color = Colors.blue.withOpacity(fillOpacity)
          ..style = PaintingStyle.fill;
        fillYellow = Paint()
          ..color = Colors.amber.withOpacity(fillOpacity)
          ..style = PaintingStyle.fill;

        canvas.drawPath(t1, fillBlue);
        canvas.drawPath(t2, fillYellow);

        if (step >= 2) {
          drawLabel("180°", const Offset(30, -10), Colors.blueAccent, 24);
          drawLabel("180°", const Offset(-30, 20), Colors.amber, 24);
        }
      }
    } else if (step >= 4) {
      // Incomplete Rectangle Challenge
      Offset pA = const Offset(-80, -60);
      Offset pB = const Offset(80, -60);
      Offset pC = const Offset(80, 60);
      Offset pD = const Offset(-80, 60);

      // Bottom, Right, Left lines
      canvas.drawLine(pA, pB, linePaint);
      canvas.drawLine(pB, pC, linePaint);
      canvas.drawLine(pA, pD, linePaint);

      // Draw Right Angles
      double s = 20;
      void drawRA(Offset p, double dx, double dy) {
        Path rp = Path()
          ..moveTo(p.dx + s * dx, p.dy)
          ..lineTo(p.dx + s * dx, p.dy + s * dy)
          ..lineTo(p.dx, p.dy + s * dy);
        canvas.drawPath(rp, linePaint);
        drawLabel(
          "90°",
          p + Offset(s * dx * 1.8, s * dy * 1.8),
          Colors.grey,
          14,
        );
      }

      drawRA(pA, 1, 1);
      drawRA(pB, -1, 1);
      drawRA(pC, -1, -1);

      if (step == 4) {
        drawLabel("X ?", pD + const Offset(20, 20), Colors.amber, 28);
      } else if (step >= 5) {
        // Complete top line
        canvas.drawLine(pD, pC, linePaint);
        if (step == 5) {
          drawLabel("X", pD + const Offset(30, 30), Colors.amber, 28);
        }
        if (step >= 6) {
          Paint raPaint = Paint()
            ..color = Colors.amber
            ..strokeWidth = 3
            ..style = PaintingStyle.stroke;
          Path rp = Path()
            ..moveTo(pD.dx + s * 1, pD.dy)
            ..lineTo(pD.dx + s * 1, pD.dy + s * -1)
            ..lineTo(pD.dx, pD.dy + s * -1);
          canvas.drawPath(rp, raPaint);
          drawLabel("90°", pD + Offset(s * 1.8, s * -1.8), Colors.amber, 20);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant GeometryPainter oldDelegate) {
    return oldDelegate.step != step ||
        oldDelegate.progress != progress ||
        oldDelegate.isDark != isDark;
  }
}
