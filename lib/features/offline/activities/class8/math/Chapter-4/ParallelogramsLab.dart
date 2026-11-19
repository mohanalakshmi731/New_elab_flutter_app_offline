// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class ParallelogramsLab extends StatefulWidget {
  const ParallelogramsLab({Key? key}) : super(key: key);

  @override
  State<ParallelogramsLab> createState() => _ParallelogramsLabState();
}

class _ParallelogramsLabState extends State<ParallelogramsLab>
    with TickerProviderStateMixin {
  // --- UI State ---
  bool _showCurtain = true;
  bool _isSidebarOpen = false; // Start collapsed to highlight floating card
  bool _isDarkTheme = true;
  int _currentStep = 0;
  String _currentLang = 'en';
  final double _teacherFontSize = 16.0;

  // --- Interaction State ---
  String? _feedbackMessage;
  bool _feedbackIsSuccess = true;
  bool _interactionCompleted = false;

  // Step 1: Transversal Angle (30 to 150, target 60)
  double _step1Angle = 90.0;

  // Step 2: Selected Angles (0: BL, 1: BR, 2: TR, 3: TL)
  List<int> _step2SelectedAngles = [];

  // Step 3: Congruence Slide Progress (0.0 to 1.0)
  double _step3Progress = 0.0;

  // Step 4: Diagonal Drag Position
  Offset _step4DiagonalPos = const Offset(-150, 80);

  // Step 5: True/False Choice
  int _step5Choice = -1;

  // --- Animations & Audio ---
  late AnimationController _curtainController;
  late Animation<Offset> _curtainAnimation;
  late AudioPlayer _audioPlayer;

  // --- Localization Data ---
  final Map<String, Map<String, dynamic>> _translations = {
    'en': {
      'langCode': 'EN',
      'titleMain': 'Parallelograms',
      'chapterMain': 'Class 8 • Quadrilaterals',
      'enterBtn': 'Enter Virtual Lab',
      'missionObj': 'Mission Objective',
      'targetOutput': 'Target Output',
      'activeStep': 'Current Investigation',
      'validateBtn': 'Validate Model',
      'proceedBtn': 'Proceed to Next Step',
      'restartBtn': 'Restart Activity',
      'toastSuccess': 'Excellent! Model Validated.',
      'toastError': 'Incorrect. Review theory and try again.',
      'steps': [
        {
          'title': 'Step 1: Construction Analysis',
          'theory':
              "A parallelogram is a quadrilateral where both pairs of opposite sides are parallel.\n\nLet's construct one by crossing two sets of parallel lines. Think of the slanted sides as 'transversals' cutting across horizontal parallel lines.\n\nWe know from earlier geometry that consecutive interior angles on a transversal sum to 180°. If one angle is x, the adjacent angle must be 180° - x.",
          'hudTitle': 'Angle Adjustment',
          'hudInstruction':
              "Drag the slider to adjust the transversal angle. Set it to exactly 60° to continue.",
        },
        {
          'title': 'Step 2: Deducing Opposite Angles',
          'theory':
              "Let's move around the figure. If the bottom-right angle is 180° - x, what is the top-right angle?\n\nSince the side is a transversal between horizontal parallel lines, the top-right angle must be 180° - (180° - x), which simplifies exactly to x.\n\nProperty 1 proved:\nOpposite angles in a parallelogram are perfectly equal!",
          'hudTitle': 'Identify Angles',
          'hudInstruction':
              "Tap on the TWO opposite angles that are mathematically equal (x) to prove the property.",
        },
        {
          'title': 'Step 3: Congruence Proof',
          'theory':
              "We know the lines are parallel, but are they equal in length? Let's prove it algebraically and visually!\n\nWe draw a diagonal to split the parallelogram into two triangles. Because top and bottom lines are parallel, the 'Alternate Interior Angles' are equal.\n\nThe diagonal is a shared side. By the ASA (Angle-Side-Angle) rule, these two triangles are exactly congruent!\n\nProperty 2 proved:\nMatching parts of congruent triangles means Opposite Sides are Equal.",
          'hudTitle': 'Triangle Overlap',
          'hudInstruction':
              "Slide to rotate and translate the top triangle to verify it perfectly overlaps the bottom one.",
        },
        {
          'title': 'Step 4: Figure It Out',
          'theory':
              "Another property of parallelograms is that their diagonals always bisect (cut in half) each other.\n\nChallenge: Construct a parallelogram using ONLY its diagonals (lengths 7 cm and 5 cm).\n\nWe don't need side lengths! We draw a 7 cm line and mark its exact midpoint. Then, we draw a 5 cm line crossing it exactly at its own midpoint.",
          'hudTitle': 'Bisecting Diagonals',
          'hudInstruction':
              "Drag the orange diagonal until it intersects the blue diagonal exactly at both of their midpoints.",
        },
        {
          'title': 'Step 5: True/False Reasoning',
          'theory':
              "Let's test our reverse logic. True or False: \"A quadrilateral in which opposite angles are equal must be a parallelogram.\"\n\nLet's prove it algebraically. Let opposite angles be x, x and y, y.\n\nSum = 360°\n2x + 2y = 360°",
          'hudTitle': 'Equation Logic',
          'hudInstruction':
              "Divide the equation by 2. Select the correct simplified equation below to prove the lines are parallel.",
        },
      ],
    },
    'hi': {
      'langCode': 'HI',
      'titleMain': 'समानांतर चतुर्भुज',
      'chapterMain': 'कक्षा 8 • चतुर्भुज',
      'enterBtn': 'वर्चुअल लैब में प्रवेश करें',
      'missionObj': 'मिशन का उद्देश्य',
      'targetOutput': 'लक्षित आउटपुट',
      'activeStep': 'वर्तमान अन्वेषण',
      'validateBtn': 'मॉडल मान्य करें',
      'proceedBtn': 'अगले चरण पर जाएँ',
      'restartBtn': 'गतिविधि पुनः आरंभ करें',
      'toastSuccess': 'उत्कृष्ट! मॉडल मान्य।',
      'toastError': 'गलत मॉडल। सिद्धांत की समीक्षा करें और पुनः प्रयास करें।',
      'steps': [
        {
          'title': 'चरण 1: निर्माण विश्लेषण',
          'theory':
              "समानांतर चतुर्भुज एक ऐसा चतुर्भुज है जिसके सम्मुख भुजाओं के दोनों युग्म समानांतर होते हैं।\n\nआइए समानांतर रेखाओं के दो सेटों को पार करके एक का निर्माण करें। तिरछी भुजाओं को क्षैतिज समानांतर रेखाओं को काटने वाले 'तिर्यक रेखाओं' के रूप में सोचें।\n\nहम पिछली ज्यामिति से जानते हैं कि एक तिर्यक रेखा पर क्रमागत अंतःकोणों का योग 180° होता है। यदि एक कोण x है, तो आसन्न कोण 180° - x होना चाहिए।",
          'hudTitle': 'कोण समायोजन',
          'hudInstruction':
              "तिर्यक कोण को समायोजित करने के लिए स्लाइडर खींचें। जारी रखने के लिए इसे ठीक 60° पर सेट करें।",
        },
        {
          'title': 'चरण 2: सम्मुख कोणों का अनुमान लगाना',
          'theory':
              "आइए आकृति के चारों ओर घूमें। यदि निचला-दायां कोण 180° - x है, तो शीर्ष-दायां कोण क्या है?\n\nचूंकि भुजा क्षैतिज समानांतर रेखाओं के बीच एक तिर्यक रेखा है, इसलिए शीर्ष-दायां कोण 180° - (180° - x) होना चाहिए, जो ठीक x में सरल हो जाता है।\n\nसंपत्ति 1 सिद्ध:\nसमानांतर चतुर्भुज में सम्मुख कोण पूरी तरह से समान होते हैं!",
          'hudTitle': 'कोणों की पहचान करें',
          'hudInstruction':
              "संपत्ति को साबित करने के लिए गणितीय रूप से समान (x) दो सम्मुख कोणों पर टैप करें।",
        },
        {
          'title': 'चरण 3: सर्वांगसमता प्रमाण',
          'theory':
              "हम जानते हैं कि रेखाएँ समानांतर हैं, लेकिन क्या उनकी लंबाई समान है? आइए इसे बीजगणितीय और दृष्टिगत रूप से सिद्ध करें!\n\nहम समानांतर चतुर्भुज को दो त्रिकोणों में विभाजित करने के लिए एक विकर्ण बनाते हैं। चूंकि ऊपर और नीचे की रेखाएँ समानांतर हैं, 'एकांतर अंतःकोण' समान हैं।\n\nविकर्ण एक साझा भुजा है। ASA (कोण-भुजा-कोण) नियम से, ये दो त्रिकोण बिल्कुल सर्वांगसम हैं!\n\nसंपत्ति 2 सिद्ध:\nसर्वांगसम त्रिभुजों के मेल खाने वाले भागों का अर्थ है कि विपरीत भुजाएँ समान हैं।",
          'hudTitle': 'त्रिभुज ओवरलैप',
          'hudInstruction':
              "शीर्ष त्रिकोण को घुमाने और स्थानांतरित करने के लिए स्लाइड करें ताकि यह सत्यापित हो सके कि यह निचले हिस्से को पूरी तरह से ओवरलैप करता है।",
        },
        {
          'title': 'चरण 4: इसे समझें',
          'theory':
              "समानांतर चतुर्भुजों की एक और संपत्ति यह है कि उनके विकर्ण हमेशा एक दूसरे को द्विभाजित (आधा काटते हैं) करते हैं।\n\nचुनौती: केवल इसके विकर्णों का उपयोग करके एक समानांतर चतुर्भुज का निर्माण करें।\n\nहमें भुजाओं की लंबाई की आवश्यकता नहीं है! हम एक रेखा खींचते हैं और इसके सटीक मध्य बिंदु को चिह्नित करते हैं। फिर, हम एक और रेखा खींचते हैं जो इसे ठीक अपने मध्य बिंदु पर पार करती है।",
          'hudTitle': 'विकर्णों को काटना',
          'hudInstruction':
              "नारंगी विकर्ण को तब तक खींचें जब तक कि यह नीले विकर्ण को उनके दोनों मध्य बिंदुओं पर ठीक से पार न कर ले।",
        },
        {
          'title': 'चरण 5: सत्य/असत्य तर्क',
          'theory':
              "आइए अपने विपरीत तर्क का परीक्षण करें। सत्य या असत्य: \"एक चतुर्भुज जिसमें सम्मुख कोण समान होते हैं, एक समानांतर चतुर्भुज होना चाहिए।\"\n\nआइए इसे बीजगणितीय रूप से सिद्ध करें। मान लें कि सम्मुख कोण x, x और y, y हैं।\n\nयोग = 360°\n2x + 2y = 360°",
          'hudTitle': 'समीकरण तर्क',
          'hudInstruction':
              "समीकरण को 2 से विभाजित करें। यह साबित करने के लिए कि रेखाएँ समानांतर हैं, नीचे दिए गए सही सरलीकृत समीकरण का चयन करें।",
        },
      ],
    },
  };

  // --- Safe Map Accessors (Prevents Null TypeErrors) ---
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

      // Reset scenario states
      _step1Angle = 90.0;
      _step2SelectedAngles = [];
      _step3Progress = 0.0;
      _step4DiagonalPos = const Offset(-150, 80);
      _step5Choice = -1;
    });
  }

  void _showFeedback(String msg, bool success) {
    setState(() {
      _feedbackMessage = msg;
      _feedbackIsSuccess = success;
      if (success) _interactionCompleted = true;
    });
  }

  void _validateInvestigation() {
    bool isCorrect = false;

    if (_currentStep == 0) {
      if (_step1Angle == 60.0) isCorrect = true;
    } else if (_currentStep == 1) {
      if ((_step2SelectedAngles.contains(0) &&
              _step2SelectedAngles.contains(2)) ||
          (_step2SelectedAngles.contains(1) &&
              _step2SelectedAngles.contains(3))) {
        isCorrect = true;
      }
    } else if (_currentStep == 2) {
      if (_step3Progress >= 0.95) isCorrect = true;
    } else if (_currentStep == 3) {
      if (_step4DiagonalPos.distance < 20) {
        setState(() => _step4DiagonalPos = Offset.zero); // Snap
        isCorrect = true;
      }
    } else if (_currentStep == 4) {
      if (_step5Choice == 1) isCorrect = true; // x + y = 180
    }

    if (isCorrect) {
      _playSound('success');
      _showFeedback(_getString('toastSuccess'), true);
    } else {
      _playSound('error');
      _showFeedback(_getString('toastError'), false);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && !_interactionCompleted) {
          setState(() => _feedbackMessage = null);
        }
      });
    }
  }

  // --- UI Building Methods ---
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
    if (_currentStep == 0) {
      return Row(
        children: [
          const Text(
            "30°",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
          ),
          Expanded(
            child: Slider(
              value: _step1Angle,
              min: 30,
              max: 150,
              divisions: 120,
              activeColor: Colors.amber,
              inactiveColor: borderPanel,
              onChanged: _interactionCompleted
                  ? null
                  : (val) => setState(() => _step1Angle = val),
            ),
          ),
          const Text(
            "150°",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
          ),
        ],
      );
    } else if (_currentStep == 1) {
      return Text(
        "Selected: ${_step2SelectedAngles.length} / 2",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.amber,
        ),
      );
    } else if (_currentStep == 2) {
      return Row(
        children: [
          const Text(
            "Split",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          Expanded(
            child: Slider(
              value: _step3Progress,
              min: 0,
              max: 1,
              activeColor: Colors.amber,
              inactiveColor: borderPanel,
              onChanged: _interactionCompleted
                  ? null
                  : (val) => setState(() => _step3Progress = val),
            ),
          ),
          const Text(
            "Overlap",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
          ),
        ],
      );
    } else if (_currentStep == 4) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          _buildMCQBtn(0, "x - y = 90°"),
          _buildMCQBtn(1, "x + y = 180°"),
          _buildMCQBtn(2, "x + 2y = 360°"),
        ],
      );
    }
    return const SizedBox();
  }

  Widget _buildMCQBtn(int index, String text) {
    bool isSelected = _step5Choice == index;
    return InkWell(
      onTap: _interactionCompleted
          ? null
          : () {
              _playSound('tap');
              setState(() => _step5Choice = index);
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.amber.withOpacity(0.8)
              : (_isDarkTheme ? Colors.white10 : Colors.black12),
          border: Border.all(color: isSelected ? Colors.amber : borderPanel),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : textBase,
            fontWeight: FontWeight.bold,
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
              // 2D Geometric Render
              CustomPaint(
                size: Size.infinite,
                painter: ParallelogramPainter(
                  step: _currentStep,
                  angleDeg: _step1Angle,
                  slideProgress: _step3Progress,
                  dragOffset: _step4DiagonalPos,
                  isDark: _isDarkTheme,
                ),
              ),

              // Canvas HTML-like overlays mapped to specific coordinates
              ..._buildCanvasOverlays(canvasSize),

              // Step 4 Draggable Handler
              if (_currentStep == 3)
                Positioned(
                  left: canvasSize.width / 2 + _step4DiagonalPos.dx - 50,
                  top: canvasSize.height / 2 + _step4DiagonalPos.dy - 50,
                  child: GestureDetector(
                    onPanUpdate: _interactionCompleted
                        ? null
                        : (details) {
                            setState(() => _step4DiagonalPos += details.delta);
                          },
                    child: Container(
                      width: 100,
                      height: 100,
                      color: Colors.transparent,
                      child: const Center(
                        child: Icon(
                          Icons.control_camera,
                          color: Colors.white54,
                          size: 40,
                        ),
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
    }) {
      return Positioned(
        left: centerX + dx - 20,
        top: centerY + dy - 15,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(4),
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

    Widget clickZone(int id, double dx, double dy, String label) {
      bool isSelected = _step2SelectedAngles.contains(id);
      return Positioned(
        left: centerX + dx - 30,
        top: centerY + dy - 30,
        child: GestureDetector(
          onTap: _interactionCompleted
              ? null
              : () {
                  _playSound('tap');
                  setState(() {
                    if (isSelected) {
                      _step2SelectedAngles.remove(id);
                    } else if (_step2SelectedAngles.length < 2) {
                      _step2SelectedAngles.add(id);
                    }
                  });
                },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? Colors.amber.withOpacity(0.5)
                  : Colors.white.withOpacity(0.1),
              border: Border.all(
                color: isSelected ? Colors.amber : Colors.white54,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_currentStep == 0) {
      overlays.add(
        placeText(
          "x = ${_step1Angle.toStringAsFixed(0)}°",
          50,
          40,
          color: Colors.amber,
        ),
      );
      overlays.add(
        placeText(
          "180 - x = ${(180 - _step1Angle).toStringAsFixed(0)}°",
          -120,
          40,
          color: Colors.blueAccent,
        ),
      );
    } else if (_currentStep == 1) {
      overlays.add(clickZone(0, -90, 70, "x"));
      overlays.add(clickZone(1, 90, 70, "180-x"));
      overlays.add(clickZone(2, 110, -70, "x"));
      overlays.add(clickZone(3, -70, -70, "180-x"));
    } else if (_currentStep == 2) {
      // Dynamic overlap text
      if (_step3Progress > 0.9) {
        overlays.add(
          placeText(
            "CONGRUENT (ASA)",
            0,
            -100,
            color: Colors.greenAccent,
            size: 20,
          ),
        );
      }
    } else if (_currentStep == 3) {
      if (_interactionCompleted) {
        overlays.add(
          placeText(
            "DIAGONALS BISECT",
            0,
            -120,
            color: Colors.greenAccent,
            size: 20,
          ),
        );
      }
    } else if (_currentStep == 4) {
      overlays.add(placeText("x", -100, 60));
      overlays.add(placeText("y", 100, 60));
      overlays.add(placeText("x", 120, -60));
      overlays.add(placeText("y", -80, -60));

      overlays.add(
        Positioned(
          top: centerY + 60,
          left: centerX - 100,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black87,
              border: Border.all(color: Colors.amber),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Text(
                  "Sum = 360°",
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const Text(
                  "2x + 2y = 360°",
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                if (_interactionCompleted)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      "x + y = 180°\n⟹ Lines are Parallel!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 250,
                    maxHeight: screenHeight * 1,
                  ),
                  child: _buildGlassPanel(
                    padding: EdgeInsets.zero,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
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
              bottom: 10,
              right: 0,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: screenHeight * 0.4,
                    maxWidth: 500,
                  ),
                  child: _buildGlassPanel(
                    padding: EdgeInsets.zero,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 6,
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
                          const SizedBox(height: 4),
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
                          if (!_interactionCompleted && _currentStep != 1) ...[
                            const SizedBox(height: 8),
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
                          const SizedBox(width: 10),
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
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 22),

                      // Mission Objective
                      Text(
                        _getString('missionObj').toUpperCase(),
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
                        padding: const EdgeInsets.all(10),
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
                      const SizedBox(height: 22),

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
                      const Icon(Icons.hexagon, color: Colors.amber, size: 80),
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
class ParallelogramPainter extends CustomPainter {
  final int step;
  final double angleDeg;
  final double slideProgress;
  final Offset dragOffset;
  final bool isDark;

  ParallelogramPainter({
    required this.step,
    required this.angleDeg,
    required this.slideProgress,
    required this.dragOffset,
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

    final center = Offset(size.width / 2, size.height / 2);

    final Paint linePaint = Paint()
      ..color = isDark ? Colors.white70 : Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final Paint accentPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    // Fixed Horizontal Parallel Lines (Used in Step 1, 2)
    void drawParallelLines() {
      canvas.drawLine(
        center + const Offset(-300, -60),
        center + const Offset(300, -60),
        linePaint,
      );
      canvas.drawLine(
        center + const Offset(-300, 60),
        center + const Offset(300, 60),
        linePaint,
      );
    }

    if (step == 0) {
      drawParallelLines();

      // Transversal line pivoted at center
      double rad = angleDeg * math.pi / 180;
      double len = 200;
      Offset p1 = center + Offset(-len * math.cos(rad), -len * math.sin(rad));
      Offset p2 = center + Offset(len * math.cos(rad), len * math.sin(rad));

      canvas.drawLine(p1, p2, accentPaint);
    } else if (step == 1) {
      drawParallelLines();

      // Draw parallelogram
      Path quad = Path()
        ..moveTo(center.dx - 80, center.dy + 60)
        ..lineTo(center.dx + 80, center.dy + 60)
        ..lineTo(center.dx + 120, center.dy - 60)
        ..lineTo(center.dx - 40, center.dy - 60)
        ..close();

      canvas.drawPath(quad, accentPaint);
    } else if (step == 2) {
      // Congruence Proof (Two Triangles)
      final Paint blueFill = Paint()
        ..color = Colors.blueAccent.withOpacity(0.6)
        ..style = PaintingStyle.fill;
      final Paint yellowFill = Paint()
        ..color = Colors.amber.withOpacity(0.6)
        ..style = PaintingStyle.fill;

      // Bottom Triangle (Fixed)
      Path triA = Path()
        ..moveTo(-80, 60)
        ..lineTo(80, 60)
        ..lineTo(-40, -60)
        ..close();

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.drawPath(triA, blueFill);
      canvas.drawPath(triA, linePaint);
      canvas.restore();

      // Top Triangle (Animated)
      // Initial offset apart from the bottom triangle
      double startOffsetX = 120;
      double startOffsetY = -80;

      canvas.save();
      canvas.translate(center.dx, center.dy);

      // Interpolate position to origin
      double currentX = startOffsetX * (1 - slideProgress);
      double currentY = startOffsetY * (1 - slideProgress);
      canvas.translate(currentX, currentY);

      // Interpolate Rotation around the midpoint (20, 0) to exactly overlap TriA
      // TriB naturally forms the top half without rotation.
      // To prove congruence via ASA visually, we rotate it 180 degrees onto Tri A
      canvas.translate(20, 0); // Move to midpoint of the shared diagonal
      canvas.rotate(slideProgress * math.pi); // Rotate
      canvas.translate(-20, 0); // Move back

      // Original Tri B coordinates (forming the top part of the parallelogram)
      Path triB = Path()
        ..moveTo(120, -60)
        ..lineTo(-40, -60)
        ..lineTo(80, 60)
        ..close();

      canvas.drawPath(triB, yellowFill);
      canvas.drawPath(triB, linePaint);
      canvas.restore();
    } else if (step == 3) {
      // Diagonals Bisect
      final Paint blueDiag = Paint()
        ..color = Colors.blueAccent
        ..strokeWidth = 6.0;
      final Paint orangeDiag = Paint()
        ..color = Colors.orangeAccent
        ..strokeWidth = 6.0;

      // Fixed Blue Diagonal (Length 200)
      canvas.drawLine(
        center + const Offset(-80, -100),
        center + const Offset(80, 100),
        blueDiag,
      );
      canvas.drawCircle(center, 6, Paint()..color = Colors.white); // Midpoint

      // Draggable Orange Diagonal (Length 140)
      Offset orangeCenter = center + dragOffset;
      double oRad = -30 * math.pi / 180;
      Offset oP1 =
          orangeCenter + Offset(-70 * math.cos(oRad), -70 * math.sin(oRad));
      Offset oP2 =
          orangeCenter + Offset(70 * math.cos(oRad), 70 * math.sin(oRad));

      canvas.drawLine(oP1, oP2, orangeDiag);
      canvas.drawCircle(
        orangeCenter,
        6,
        Paint()..color = Colors.white,
      ); // Midpoint

      // If close to center, draw perimeter (parallelogram formed)
      if (dragOffset.distance < 20) {
        Path perim = Path()
          ..moveTo(center.dx - 80, center.dy - 100)
          ..lineTo(oP2.dx, oP2.dy)
          ..lineTo(center.dx + 80, center.dy + 100)
          ..lineTo(oP1.dx, oP1.dy)
          ..close();
        canvas.drawPath(
          perim,
          Paint()
            ..color = Colors.white24
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    } else if (step == 4) {
      // Generic Quad for Reasoning
      Path quad = Path()
        ..moveTo(center.dx - 100, center.dy + 80)
        ..lineTo(center.dx + 120, center.dy + 80)
        ..lineTo(center.dx + 140, center.dy - 40)
        ..lineTo(center.dx - 80, center.dy - 40)
        ..close();

      canvas.drawPath(quad, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant ParallelogramPainter oldDelegate) {
    return oldDelegate.step != step ||
        oldDelegate.angleDeg != angleDeg ||
        oldDelegate.slideProgress != slideProgress ||
        oldDelegate.dragOffset != dragOffset ||
        oldDelegate.isDark != isDark;
  }
}
