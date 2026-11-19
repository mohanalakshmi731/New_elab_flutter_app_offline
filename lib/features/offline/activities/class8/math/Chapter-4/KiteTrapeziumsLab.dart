// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class KiteTrapeziumsLab extends StatefulWidget {
  const KiteTrapeziumsLab({Key? key}) : super(key: key);

  @override
  State<KiteTrapeziumsLab> createState() => _KiteTrapeziumsLabState();
}

class _KiteTrapeziumsLabState extends State<KiteTrapeziumsLab>
    with TickerProviderStateMixin {
  // --- UI State ---
  bool _showCurtain = true;
  bool _isSidebarOpen = true;
  bool _isDarkTheme = true;
  int _currentStep = 0;
  String _currentLang = 'en';
  double _teacherFontSize = 16.0;

  // --- Interaction State ---
  String? _feedbackMessage;
  bool _feedbackIsSuccess = true;
  bool _interactionCompleted = false;

  // Step 1: Kite Diagonals
  bool _step1DiagonalsDrawn = false;

  // Step 2: Base Angles Trapezium (indices 0: BL, 1: BR)
  List<int> _step2RevealedAngles = [];

  // Step 3: Angle MCQ
  int _step3SelectedAnswer = -1;

  // Step 4: True/False MCQ
  int _step4SelectedAnswer = -1; // 0 for False, 1 for True

  // --- Animations & Audio ---
  late AnimationController _curtainController;
  late Animation<Offset> _curtainAnimation;
  late AudioPlayer _audioPlayer;

  // --- Localization Data ---
  final Map<String, Map<String, dynamic>> _translations = {
    'en': {
      'langCode': 'EN',
      'titleMain': 'Kites & Trapeziums',
      'chapterMain': 'Class 8 • Quadrilaterals',
      'enterBtn': 'Enter Lab',
      'teacherTitle': 'Mission Objective',
      'proceedBtn': 'Proceed to Next Step',
      'validateBtn': 'Validate Model',
      'restartBtn': 'Restart Activity',
      'activeStep': 'Investigation Step',
      'targetOutput': 'Target Output',
      'toastSuccess': 'Excellent! Model Validated.',
      'toastError': 'Incorrect. Review theory and try again.',
      'labels': {
        'quad': 'Quadrilateral',
        'kite': 'Kite',
        'trap': 'Trapezium',
        'para': 'Parallelogram',
        'rhombus': 'Rhombus',
        'rect': 'Rectangle',
        'square': 'Square',
        'trueBtn': 'True',
        'falseBtn': 'False',
      },
      'steps': [
        {
          'title': 'Step 1: The Kite',
          'theory':
              "A Kite is a special quadrilateral that has two distinct consecutive pairs of equal length sides.\n\nUnlike a parallelogram, its opposite sides are NOT equal. But it has a special property regarding its diagonals.\n\nThe longer diagonal acts as an axis of symmetry, bisecting the shorter diagonal perfectly at right angles (90°).",
          'hudTitle': 'Investigate Kite',
          'hudInstruction':
              "Tap the kite to draw its intersecting diagonals and reveal the 90° angle.",
        },
        {
          'title': 'Step 2: Isosceles Trapezium',
          'theory':
              "A Trapezium is a quadrilateral with exactly ONE pair of parallel sides.\n\nIf the non-parallel sides are equal in length, we call it an 'Isosceles Trapezium'. Because of this symmetry, its base angles become perfectly equal to each other.",
          'hudTitle': 'Base Angles',
          'hudInstruction':
              "Tap the two bottom base corners of the trapezium to prove they are identical.",
        },
        {
          'title': 'Step 3: Co-Interior Angles',
          'theory':
              "Let's find unknown angles in a Trapezium. Because the top and bottom sides are parallel, the slanted side acts like a 'transversal' line.\n\nRemember from parallel lines: Co-interior angles (the top and bottom angles on the same side) must add up to exactly 180°.",
          'hudTitle': 'Solve the Angle',
          'hudInstruction':
              "If the bottom-left angle is 60°, what must the top-left angle be?",
        },
        {
          'title': 'Step 4: True or False?',
          'theory':
              "Let's test your understanding of quadrilateral definitions and their strict rules.\n\nA Parallelogram requires BOTH pairs of opposite sides to be equal. A Kite only has CONSECUTIVE pairs of equal sides.",
          'hudTitle': 'Reasoning Challenge',
          'hudInstruction': "True or False: A Kite is always a Parallelogram.",
        },
        {
          'title': 'Step 5: The Family Tree',
          'theory':
              "All these shapes belong to the Quadrilateral family.\n\nA Trapezium branches off with 1 parallel pair. A Parallelogram branches off with 2. A Kite is its own unique branch.\n\nRhombuses and Rectangles are special Parallelograms, and the Square is the perfect ultimate child of both!",
          'hudTitle': 'Synthesis Complete',
          'hudInstruction':
              "Activity finished successfully. You have explored the Quadrilateral Family!",
        },
      ],
    },
    'hi': {
      'langCode': 'HI',
      'titleMain': 'पतंग और समलंब',
      'chapterMain': 'कक्षा 8 • चतुर्भुज',
      'enterBtn': 'लैब में प्रवेश करें',
      'teacherTitle': 'मिशन का उद्देश्य',
      'proceedBtn': 'अगले चरण पर जाएँ',
      'validateBtn': 'मॉडल मान्य करें',
      'restartBtn': 'गतिविधि पुनः आरंभ करें',
      'activeStep': 'अन्वेषण चरण',
      'targetOutput': 'लक्षित आउटपुट',
      'toastSuccess': 'उत्कृष्ट! मॉडल मान्य।',
      'toastError': 'गलत मॉडल। सिद्धांत की समीक्षा करें और पुनः प्रयास करें।',
      'labels': {
        'quad': 'चतुर्भुज',
        'kite': 'पतंग',
        'trap': 'समलंब (Trapezium)',
        'para': 'समांतर चतुर्भुज',
        'rhombus': 'समचतुर्भुज',
        'rect': 'आयत',
        'square': 'वर्ग',
        'trueBtn': 'सही (True)',
        'falseBtn': 'गलत (False)',
      },
      'steps': [
        {
          'title': 'चरण 1: पतंग',
          'theory':
              "पतंग एक विशेष चतुर्भुज है जिसमें समान लंबाई वाली भुजाओं के दो अलग-अलग आसन्न (consecutive) जोड़े होते हैं।\n\nसमांतर चतुर्भुज के विपरीत, इसकी विपरीत भुजाएँ समान नहीं होती हैं। लेकिन इसके विकर्णों के संबंध में एक विशेष गुण है।\n\nलंबा विकर्ण समरूपता की धुरी के रूप में कार्य करता है, छोटे विकर्ण को समकोण (90°) पर पूरी तरह से समद्विभाजित करता है।",
          'hudTitle': 'पतंग की जांच करें',
          'hudInstruction':
              "इसके प्रतिच्छेद करने वाले विकर्णों को खींचने और 90° कोण को प्रकट करने के लिए पतंग पर टैप करें।",
        },
        {
          'title': 'चरण 2: समद्विबाहु समलंब',
          'theory':
              "समलंब (Trapezium) एक ऐसा चतुर्भुज है जिसमें समानांतर भुजाओं का ठीक एक जोड़ा होता है।\n\nयदि गैर-समानांतर भुजाएँ लंबाई में समान हैं, तो हम इसे 'समद्विबाहु समलंब' (Isosceles Trapezium) कहते हैं। इस समरूपता के कारण, इसके आधार कोण एक दूसरे के पूरी तरह से समान हो जाते हैं।",
          'hudTitle': 'आधार कोण',
          'hudInstruction':
              "यह साबित करने के लिए कि वे समान हैं, समलंब के दो निचले आधार कोनों पर टैप करें।",
        },
        {
          'title': 'चरण 3: सह-आंतरिक कोण',
          'theory':
              "आइए समलंब में अज्ञात कोण ज्ञात करें। चूंकि ऊपर और नीचे की भुजाएँ समानांतर हैं, इसलिए तिरछी भुजा एक 'तिर्यक' (transversal) रेखा की तरह कार्य करती है।\n\nसमानांतर रेखाओं से याद रखें: सह-आंतरिक कोणों (एक ही तरफ ऊपर और नीचे के कोण) का योग ठीक 180° होना चाहिए।",
          'hudTitle': 'कोण हल करें',
          'hudInstruction':
              "यदि नीचे-बायां कोण 60° है, तो ऊपर-बायां कोण क्या होना चाहिए?",
        },
        {
          'title': 'चरण 4: सही या गलत?',
          'theory':
              "आइए चतुर्भुज परिभाषाओं और उनके सख्त नियमों की आपकी समझ का परीक्षण करें।\n\nएक समांतर चतुर्भुज को विपरीत भुजाओं के दोनों जोड़े समान होने की आवश्यकता होती है। पतंग में केवल समान भुजाओं के लगातार जोड़े होते हैं।",
          'hudTitle': 'तर्क चुनौती',
          'hudInstruction':
              "सही या गलत: एक पतंग हमेशा एक समांतर चतुर्भुज होती है।",
        },
        {
          'title': 'चरण 5: परिवार का पेड़',
          'theory':
              "ये सभी आकृतियाँ चतुर्भुज परिवार की हैं।\n\nएक समलंब 1 समानांतर जोड़े के साथ शाखाबद्ध होता है। एक समांतर चतुर्भुज 2 के साथ शाखाबद्ध होता है। पतंग की अपनी अनूठी शाखा है।\n\nसमचतुर्भुज और आयत विशेष समांतर चतुर्भुज हैं, और वर्ग दोनों का आदर्श बच्चा है!",
          'hudTitle': 'संश्लेषण पूर्ण',
          'hudInstruction':
              "गतिविधि सफलतापूर्वक समाप्त हो गई। आपने चतुर्भुज परिवार का अन्वेषण किया है!",
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
      _step1DiagonalsDrawn = false;
      _step2RevealedAngles = [];
      _step3SelectedAnswer = -1;
      _step4SelectedAnswer = -1;

      if (_currentStep == 4) {
        _interactionCompleted = true; // Auto-complete the final synthesis step
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

  // --- Interaction Logic ---

  void _handleCanvasTap(TapUpDetails details, Size canvasSize) {
    if (_interactionCompleted) return;

    _playSound('tap');

    Offset local = details.localPosition;
    Offset center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    Offset tapPos = local - center;

    if (_currentStep == 0) {
      if (tapPos.distance < 120) {
        setState(() => _step1DiagonalsDrawn = true);
        _showFeedback(_getString('toastSuccess'), true);
      }
    } else if (_currentStep == 1) {
      if ((tapPos - const Offset(-120, 80)).distance < 50) {
        setState(() {
          if (!_step2RevealedAngles.contains(0)) _step2RevealedAngles.add(0);
        });
      } else if ((tapPos - const Offset(120, 80)).distance < 50) {
        setState(() {
          if (!_step2RevealedAngles.contains(1)) _step2RevealedAngles.add(1);
        });
      }

      if (_step2RevealedAngles.length == 2) {
        _showFeedback(_getString('toastSuccess'), true);
      }
    }
  }

  void _handleStep3Choice(int answer) {
    if (_interactionCompleted) return;
    setState(() => _step3SelectedAnswer = answer);
    if (answer == 120) {
      _showFeedback(_getString('toastSuccess'), true);
    } else {
      _showFeedback(_getString('toastError'), false);
    }
  }

  void _handleStep4Choice(int answer) {
    if (_interactionCompleted) return;
    setState(() => _step4SelectedAnswer = answer);
    if (answer == 0) {
      _showFeedback(_getString('toastSuccess'), true);
    } else {
      _showFeedback(_getString('toastError'), false);
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
        if (_interactionCompleted) {
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
            : Icons.lock,
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
    if (_currentStep == 2) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          _buildMCQBtn(
            60,
            "60°",
            _step3SelectedAnswer,
            120,
            _handleStep3Choice,
          ),
          _buildMCQBtn(
            120,
            "120°",
            _step3SelectedAnswer,
            120,
            _handleStep3Choice,
          ),
          _buildMCQBtn(
            180,
            "180°",
            _step3SelectedAnswer,
            120,
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
          _buildMCQBtn(
            1,
            _getLabel('trueBtn'),
            _step4SelectedAnswer,
            0,
            _handleStep4Choice,
          ),
          _buildMCQBtn(
            0,
            _getLabel('falseBtn'),
            _step4SelectedAnswer,
            0,
            _handleStep4Choice,
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
      onTap: () {
        _playSound('tap');
        onTap(value);
      },
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
            fontSize: 18,
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
          return GestureDetector(
            onTapUp: (details) => _handleCanvasTap(details, canvasSize),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 2D Geometric Render
                CustomPaint(
                  size: Size.infinite,
                  painter: KiteTrapeziumPainter(
                    step: _currentStep,
                    isDark: _isDarkTheme,
                    diagonalsDrawn: _step1DiagonalsDrawn,
                    revealedAngles: _step2RevealedAngles,
                  ),
                ),

                // Absolute HTML-like Overlays for Text Labels
                ..._buildCanvasOverlays(canvasSize),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildCanvasOverlays(Size canvasSize) {
    List<Widget> overlays = [];
    final centerX = canvasSize.width / 2;
    final centerY = canvasSize.height / 2;

    Widget placeText(
      String text,
      double dx,
      double dy, {
      Color color = Colors.white,
      double size = 16,
      bool isBold = true,
      Color bgColor = Colors.black54,
    }) {
      return Positioned(
        left: centerX + dx,
        top: centerY + dy,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white24),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: size,
            ),
          ),
        ),
      );
    }

    if (_currentStep == 0 && _step1DiagonalsDrawn) {
      overlays.add(placeText("90°", 5, 5, color: Colors.greenAccent));
    } else if (_currentStep == 1) {
      if (_step2RevealedAngles.contains(0)) {
        overlays.add(placeText("x°", -120, 90, color: Colors.amber));
      } else {
        overlays.add(placeText("?", -120, 90, color: Colors.white70));
      }
      if (_step2RevealedAngles.contains(1)) {
        overlays.add(placeText("x°", 90, 90, color: Colors.amber));
      } else {
        overlays.add(placeText("?", 90, 90, color: Colors.white70));
      }
    } else if (_currentStep == 2) {
      overlays.add(placeText("60°", -130, 90, color: Colors.amber));
      if (_interactionCompleted) {
        overlays.add(placeText("120°", -130, -110, color: Colors.greenAccent));
        overlays.add(
          Positioned(
            left: centerX + 40,
            top: centerY - 40,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                border: Border.all(color: Colors.amber),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "180° - 60° = 120°\n(Co-interior Angles)",
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      } else {
        overlays.add(
          placeText("?", -100, -110, color: Colors.redAccent, size: 20),
        );
      }
    } else if (_currentStep == 3) {
      overlays.add(
        placeText(_getLabel('kite'), -150, 100, color: Colors.amber),
      );
      overlays.add(
        placeText(_getLabel('para'), 100, 100, color: Colors.blueAccent),
      );
      if (_interactionCompleted) {
        overlays.add(
          Positioned(
            left: centerX - 30,
            top: centerY - 30,
            child: const Icon(Icons.close, color: Colors.redAccent, size: 60),
          ),
        );
      } else {
        overlays.add(
          placeText(
            "?",
            -10,
            -20,
            color: Colors.white,
            size: 30,
            bgColor: Colors.transparent,
          ),
        );
      }
    } else if (_currentStep == 4) {
      overlays.add(
        placeText(_getLabel('quad'), -45, -160, color: Colors.white, size: 18),
      );
      overlays.add(
        placeText(_getLabel('kite'), -180, -40, color: Colors.orangeAccent),
      );
      overlays.add(
        placeText(_getLabel('trap'), 0, -40, color: Colors.lightBlueAccent),
      );
      overlays.add(
        placeText(_getLabel('para'), 120, -40, color: Colors.blueAccent),
      );
      overlays.add(
        placeText(_getLabel('rhombus'), 60, 60, color: Colors.purpleAccent),
      );
      overlays.add(
        placeText(_getLabel('rect'), 180, 60, color: Colors.greenAccent),
      );
      overlays.add(
        placeText(_getLabel('square'), 120, 140, color: Colors.amber, size: 18),
      );
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
                left: 20,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 280,
                    maxHeight: screenHeight * 0.6,
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
              left: _isSidebarOpen ? sideWidth : 0,
              right: 0,
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
                          if (!_interactionCompleted &&
                              (_currentStep == 2 || _currentStep == 3)) ...[
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

                      // Mission Objective
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
                      const Icon(
                        Icons.dashboard_customize,
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

// --- Native Geometric Painter ---
class KiteTrapeziumPainter extends CustomPainter {
  final int step;
  final bool isDark;
  final bool diagonalsDrawn;
  final List<int> revealedAngles;

  KiteTrapeziumPainter({
    required this.step,
    required this.isDark,
    required this.diagonalsDrawn,
    required this.revealedAngles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

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

    final Paint linePaint = Paint()
      ..color = isDark ? Colors.white70 : Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final Paint activePaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    // --- Geometries ---

    Path buildKite(Offset offset) {
      return Path()
        ..moveTo(offset.dx, offset.dy - 120) // Top
        ..lineTo(offset.dx + 80, offset.dy - 20) // Right
        ..lineTo(offset.dx, offset.dy + 120) // Bottom
        ..lineTo(offset.dx - 80, offset.dy - 20) // Left
        ..close();
    }

    Path buildTrapezium(Offset offset) {
      return Path()
        ..moveTo(offset.dx - 60, offset.dy - 80) // TopLeft
        ..lineTo(offset.dx + 60, offset.dy - 80) // TopRight
        ..lineTo(offset.dx + 120, offset.dy + 80) // BottomRight
        ..lineTo(offset.dx - 120, offset.dy + 80) // BottomLeft
        ..close();
    }

    Path buildParallelogram(Offset offset) {
      return Path()
        ..moveTo(offset.dx - 60, offset.dy - 80)
        ..lineTo(offset.dx + 100, offset.dy - 80)
        ..lineTo(offset.dx + 60, offset.dy + 80)
        ..lineTo(offset.dx - 100, offset.dy + 80)
        ..close();
    }

    // Render Steps
    if (step == 0) {
      canvas.drawPath(buildKite(center), linePaint);
      if (diagonalsDrawn) {
        canvas.drawLine(
          center + const Offset(-80, -20),
          center + const Offset(80, -20),
          activePaint,
        );
        canvas.drawLine(
          center + const Offset(0, -120),
          center + const Offset(0, 120),
          activePaint,
        );
        Paint marker = Paint()
          ..color = Colors.amber
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawPath(
          Path()
            ..moveTo(center.dx + 15, center.dy - 20)
            ..lineTo(center.dx + 15, center.dy - 5)
            ..lineTo(center.dx, center.dy - 5),
          marker,
        );
      } else {
        canvas.drawCircle(
          center,
          40,
          Paint()..color = Colors.amber.withOpacity(0.2),
        );
      }
    } else if (step == 1 || step == 2) {
      canvas.drawPath(buildTrapezium(center), linePaint);
      Paint marker = Paint()
        ..color = Colors.blueAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawLine(
        center + const Offset(-10, -80),
        center + const Offset(10, -80),
        marker,
      );
      canvas.drawLine(
        center + const Offset(-10, 80),
        center + const Offset(10, 80),
        marker,
      );

      if (step == 1) {
        if (revealedAngles.contains(0)) {
          canvas.drawArc(
            Rect.fromCircle(
              center: center + const Offset(-120, 80),
              radius: 30,
            ),
            0,
            -math.pi / 4,
            false,
            activePaint,
          );
        } else {
          canvas.drawCircle(
            center + const Offset(-120, 80),
            20,
            Paint()..color = Colors.white24,
          );
        }

        if (revealedAngles.contains(1)) {
          canvas.drawArc(
            Rect.fromCircle(center: center + const Offset(120, 80), radius: 30),
            math.pi,
            math.pi / 4,
            false,
            activePaint,
          );
        } else {
          canvas.drawCircle(
            center + const Offset(120, 80),
            20,
            Paint()..color = Colors.white24,
          );
        }
      } else if (step == 2) {
        canvas.drawArc(
          Rect.fromCircle(center: center + const Offset(-120, 80), radius: 30),
          0,
          -math.pi / 4,
          false,
          activePaint,
        );
        canvas.drawArc(
          Rect.fromCircle(center: center + const Offset(-60, -80), radius: 30),
          math.pi / 2,
          math.pi / 3,
          false,
          Paint()
            ..color = Colors.greenAccent
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4,
        );
      }
    } else if (step == 3) {
      canvas.drawPath(
        buildKite(center + const Offset(-120, 0)),
        Paint()
          ..color = Colors.amber
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      canvas.drawPath(
        buildParallelogram(center + const Offset(120, 0)),
        Paint()
          ..color = Colors.blueAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    } else if (step == 4) {
      Paint treeLine = Paint()
        ..color = Colors.white54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawLine(
        center + const Offset(0, -140),
        center + const Offset(-150, -60),
        treeLine,
      );
      canvas.drawLine(
        center + const Offset(0, -140),
        center + const Offset(30, -60),
        treeLine,
      );
      canvas.drawLine(
        center + const Offset(0, -140),
        center + const Offset(160, -60),
        treeLine,
      );
      canvas.drawLine(
        center + const Offset(160, -20),
        center + const Offset(100, 40),
        treeLine,
      );
      canvas.drawLine(
        center + const Offset(160, -20),
        center + const Offset(210, 40),
        treeLine,
      );
      canvas.drawLine(
        center + const Offset(100, 80),
        center + const Offset(150, 120),
        treeLine,
      );
      canvas.drawLine(
        center + const Offset(210, 80),
        center + const Offset(150, 120),
        treeLine,
      );
    }
  }

  @override
  bool shouldRepaint(covariant KiteTrapeziumPainter oldDelegate) {
    return oldDelegate.step != step ||
        oldDelegate.isDark != isDark ||
        oldDelegate.diagonalsDrawn != diagonalsDrawn ||
        oldDelegate.revealedAngles != revealedAngles;
  }
}
