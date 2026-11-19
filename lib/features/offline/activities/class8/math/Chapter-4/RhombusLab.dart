// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class RhombusLab extends StatefulWidget {
  const RhombusLab({Key? key}) : super(key: key);

  @override
  State<RhombusLab> createState() => _RhombusLabState();
}

class _RhombusLabState extends State<RhombusLab> with TickerProviderStateMixin {
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

  // Step 1: Diagonal drawing
  List<int> _step1SelectedNodes = [];
  List<List<int>> _step1DrawnDiagonals = []; // e.g. [[0,2], [1,3]]

  // Step 2: Center Click
  bool _step2CenterClicked = false;

  // Step 3: Angle MCQ
  int _step3SelectedAnswer = -1;

  // Step 4: Venn Diagram Click
  bool _step4IntersectionClicked = false;

  // --- Animations & Audio ---
  late AnimationController _curtainController;
  late Animation<Offset> _curtainAnimation;
  late AudioPlayer _audioPlayer;

  // --- Localization Data ---
  final Map<String, Map<String, dynamic>> _translations = {
    'en': {
      'langCode': 'EN',
      'titleMain': 'Rhombus',
      'chapterMain': 'Class 8 • Quadrilaterals',
      'enterBtn': 'Enter Virtual Lab',
      'teacherTitle': 'Mission Objective',
      'targetOutput': 'Target Output',
      'proceedBtn': 'Proceed to Next Step',
      'validateBtn': 'Validate Model',
      'restartBtn': 'Restart Activity',
      'activeStep': 'Current Investigation',
      'toastSuccess': 'Excellent! Model Validated.',
      'toastError': 'Incorrect. Review theory and try again.',
      'labels': {
        'rectangles': 'Rectangles',
        'rhombuses': 'Rhombuses',
        'square': 'SQUARE',
      },
      'steps': [
        {
          'title': 'Step 1: The Kite Logic',
          'theory':
              "Welcome to Concept 4. Let's draw a quadrilateral where all four sides are exactly equal in length. We will call it GAME.\nBecause all sides are equal, it looks a bit like a kite, but the mathematical name is a Rhombus.\nTo uncover its secret, let's draw its two diagonals connecting the opposite corners.",
          'hudTitle': 'Draw Diagonals',
          'hudInstruction':
              "Tap on opposite glowing nodes (A to C, B to D) to form the diagonals.",
        },
        {
          'title': 'Step 2: Congruence Proof',
          'theory':
              "Notice how the diagonals slice the rhombus into four smaller triangles.\nBecause the outer sides are all equal, and the diagonals bisect each other, we can use Triangle Congruence rules. All four triangles are perfectly identical (congruent)!\n\nIf the four angles at the center are equal and add up to a full 360° circle, what must each angle be? Exactly 90°!\n\nSo, the diagonals of a rhombus always intersect at right angles.",
          'hudTitle': 'Measure Intersection',
          'hudInstruction':
              "Tap the central intersection point to reveal the angle measurement.",
        },
        {
          'title': 'Step 3: Figure It Out',
          'theory':
              "Because its opposite sides are equal, every rhombus is also a special type of parallelogram. It follows all the parallelogram rules!\n'Figure It Out': Let's say one corner angle of a rhombus is 50°. Can we find the other three? Yes!\n\nThe opposite angle must also be 50°. The adjacent angles must add up to 180°. So, 180° - 50° = 130°.",
          'hudTitle': 'Solve for Angle',
          'hudInstruction':
              "If the bottom-left angle is 50°, select the correct value for the top-right (opposite) angle.",
        },
        {
          'title': 'Step 4: The Venn Diagram',
          'theory':
              "Now, let's map out these quadrilaterals logically using a Venn Diagram.\nLet's draw one circle for Rectangles (quadrilaterals with equal 90° angles). Let's draw another intersecting circle for Rhombuses (quadrilaterals with equal sides).\n\nWhat happens in the overlapping section in the middle?",
          'hudTitle': 'Intersection Analysis',
          'hudInstruction':
              "Tap on the overlapping center region of the Venn diagram.",
        },
        {
          'title': 'Step 5: The Perfect Square',
          'theory':
              "What is a shape that is both a Rectangle and a Rhombus? It is a Square!\nA square has 90° corner angles (like a rectangle) and all four equal sides (like a rhombus).\n\nIts diagonals bisect each other, are equal in length, AND intersect at 90°. The square is the ultimate, perfect quadrilateral sitting right in the center of our Venn Diagram.",
          'hudTitle': 'Synthesis Complete',
          'hudInstruction':
              "Activity finished successfully. You have mastered the Rhombus!",
        },
      ],
    },
    'hi': {
      'langCode': 'HI',
      'titleMain': 'समचतुर्भुज',
      'chapterMain': 'कक्षा 8 • चतुर्भुज',
      'enterBtn': 'वर्चुअल लैब में प्रवेश करें',
      'teacherTitle': 'मिशन का उद्देश्य',
      'targetOutput': 'लक्षित आउटपुट',
      'proceedBtn': 'अगले चरण पर जाएँ',
      'validateBtn': 'मॉडल मान्य करें',
      'restartBtn': 'गतिविधि पुनः आरंभ करें',
      'activeStep': 'वर्तमान अन्वेषण',
      'toastSuccess': 'उत्कृष्ट! मॉडल मान्य।',
      'toastError': 'गलत मॉडल। सिद्धांत की समीक्षा करें और पुनः प्रयास करें।',
      'labels': {
        'rectangles': 'आयत',
        'rhombuses': 'समचतुर्भुज',
        'square': 'वर्ग (SQUARE)',
      },
      'steps': [
        {
          'title': 'चरण 1: पतंग का तर्क',
          'theory':
              "अवधारणा 4 में आपका स्वागत है। आइए एक ऐसा चतुर्भुज बनाएं जिसकी चारों भुजाएं लंबाई में बिल्कुल बराबर हों। हम इसे GAME कहेंगे।\nचूंकि सभी भुजाएं बराबर हैं, यह थोड़ा पतंग जैसा दिखता है, लेकिन इसका गणितीय नाम समचतुर्भुज (Rhombus) है।\nइसके रहस्य को उजागर करने के लिए, आइए इसके दो विकर्ण बनाएं जो विपरीत कोनों को जोड़ते हैं।",
          'hudTitle': 'विकर्ण बनाएं',
          'hudInstruction':
              "विकर्ण बनाने के लिए विपरीत चमकते नोड्स (A से C, B से D) पर टैप करें।",
        },
        {
          'title': 'चरण 2: सर्वांगसमता प्रमाण',
          'theory':
              "ध्यान दें कि विकर्ण समचतुर्भुज को चार छोटे त्रिभुजों में कैसे काटते हैं।\n\nचूंकि बाहरी भुजाएं सभी बराबर हैं, और विकर्ण एक-दूसरे को समद्विभाजित करते हैं, हम त्रिभुज सर्वांगसमता नियमों का उपयोग कर सकते हैं। चारों त्रिभुज पूरी तरह से समान (सर्वांगसम) हैं!\nयदि केंद्र पर चार कोण बराबर हैं और उनका योग पूर्ण 360° वृत्त है, तो प्रत्येक कोण क्या होना चाहिए? बिल्कुल 90°!\n\nइसलिए, समचतुर्भुज के विकर्ण हमेशा समकोण पर प्रतिच्छेद करते हैं।",
          'hudTitle': 'प्रतिच्छेदन मापें',
          'hudInstruction':
              "कोण माप देखने के लिए केंद्रीय प्रतिच्छेदन बिंदु पर टैप करें।",
        },
        {
          'title': 'चरण 3: इसे हल करें',
          'theory':
              "चूंकि इसकी विपरीत भुजाएं बराबर हैं, हर समचतुर्भुज एक विशेष प्रकार का समांतर चतुर्भुज भी है। यह समांतर चतुर्भुज के सभी नियमों का पालन करता है!\n'इसे हल करें': मान लें कि एक समचतुर्भुज का एक कोने का कोण 50° है। क्या हम अन्य तीन खोज सकते हैं? हाँ!\nविपरीत कोण भी 50° होना चाहिए। आसन्न कोणों का योग 180° होना चाहिए। इसलिए, 180° - 50° = 130°।",
          'hudTitle': 'कोण के लिए हल करें',
          'hudInstruction':
              "यदि नीचे-बाएं कोण 50° है, तो ऊपर-दाएं (विपरीत) कोण के लिए सही मान चुनें।",
        },
        {
          'title': 'चरण 4: वेन आरेख',
          'theory':
              "अब, आइए वेन आरेख का उपयोग करके इन चतुर्भुजों को तार्किक रूप से मैप करें।\nआइए आयत (समान 90° कोण वाले चतुर्भुज) के लिए एक वृत्त बनाएं। समचतुर्भुज (समान भुजाओं वाले चतुर्भुज) के लिए एक और प्रतिच्छेद करने वाला वृत्त बनाएं।\n\nबीच के अतिव्यापी (overlapping) भाग में क्या होता है?",
          'hudTitle': 'प्रतिच्छेदन विश्लेषण',
          'hudInstruction': "वेन आरेख के मध्य अतिव्यापी क्षेत्र पर टैप करें।",
        },
        {
          'title': 'चरण 5: पूर्ण वर्ग',
          'theory':
              "वह आकृति क्या है जो आयत और समचतुर्भुज दोनों है? यह एक वर्ग (Square) है!\nएक वर्ग में 90° के कोने वाले कोण होते हैं (आयत की तरह) और चारों भुजाएं समान होती हैं (समचतुर्भुज की तरह)।\n\nइसके विकर्ण एक-दूसरे को समद्विभाजित करते हैं, लंबाई में बराबर होते हैं, और 90° पर प्रतिच्छेद करते हैं। वर्ग हमारे वेन आरेख के बिल्कुल केंद्र में बैठा अंतिम, परिपूर्ण चतुर्भुज है।",
          'hudTitle': 'संश्लेषण पूर्ण',
          'hudInstruction':
              "गतिविधि सफलतापूर्वक समाप्त हो गई है। आपने समचतुर्भुज में महारत हासिल कर ली है!",
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
      _step1SelectedNodes = [];
      _step1DrawnDiagonals = [];
      _step2CenterClicked = false;
      _step3SelectedAnswer = -1;
      _step4IntersectionClicked = false;

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

  // Coordinates mapped relative to center (0,0)
  final List<Offset> _rhombusNodes = const [
    Offset(-160, 0), // 0: Left
    Offset(0, -100), // 1: Top
    Offset(160, 0), // 2: Right
    Offset(0, 100), // 3: Bottom
  ];

  void _handleCanvasTap(TapUpDetails details, Size canvasSize) {
    if (_interactionCompleted) return;

    _playSound('tap');

    Offset local = details.localPosition;
    Offset center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    Offset tapPos = local - center;

    if (_currentStep == 0) {
      // Check node taps
      for (int i = 0; i < _rhombusNodes.length; i++) {
        if ((tapPos - _rhombusNodes[i]).distance < 40) {
          setState(() {
            if (_step1SelectedNodes.contains(i)) {
              _step1SelectedNodes.remove(i);
            } else {
              _step1SelectedNodes.add(i);
              if (_step1SelectedNodes.length == 2) {
                int a = _step1SelectedNodes[0];
                int b = _step1SelectedNodes[1];
                // Valid pairs: (0,2) or (1,3)
                if ((a == 0 && b == 2) ||
                    (a == 2 && b == 0) ||
                    (a == 1 && b == 3) ||
                    (a == 3 && b == 1)) {
                  _step1DrawnDiagonals.add([a, b]);
                  _feedbackMessage = "Diagonal Drawn!";
                  _feedbackIsSuccess = true;
                  if (_step1DrawnDiagonals.length == 2) {
                    _showFeedback(_getString('toastSuccess'), true);
                  } else {
                    _playSound('success'); // Soft success for 1st diagonal
                  }
                } else {
                  _showFeedback(_getString('toastError'), false);
                }
                _step1SelectedNodes.clear();
              }
            }
          });
          break;
        }
      }
    } else if (_currentStep == 1) {
      // Check center tap
      if (tapPos.distance < 40) {
        setState(() => _step2CenterClicked = true);
        _showFeedback(_getString('toastSuccess'), true);
      }
    } else if (_currentStep == 3) {
      // Venn diagram center tap
      if (tapPos.distance < 50) {
        setState(() => _step4IntersectionClicked = true);
        _showFeedback(_getString('toastSuccess'), true);
      }
    }
  }

  void _handleStep3Choice(int answer) {
    if (_interactionCompleted) return;
    setState(() => _step3SelectedAnswer = answer);
    if (answer == 50) {
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
          _buildMCQBtn(40, "40°"),
          _buildMCQBtn(50, "50°"),
          _buildMCQBtn(130, "130°"),
        ],
      );
    }
    return const SizedBox();
  }

  Widget _buildMCQBtn(int value, String text) {
    bool isSelected = _step3SelectedAnswer == value;
    return InkWell(
      onTap: () {
        _playSound('tap');
        _handleStep3Choice(value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (value == 50 ? Colors.green : Colors.redAccent)
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
                  painter: RhombusPainter(
                    step: _currentStep,
                    isDark: _isDarkTheme,
                    nodes: _rhombusNodes,
                    selectedNodes: _step1SelectedNodes,
                    drawnDiagonals: _step1DrawnDiagonals,
                    centerClicked: _step2CenterClicked,
                    intersectionClicked: _step4IntersectionClicked,
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
    }) {
      return Positioned(
        left: centerX + dx - (text.length * size * 0.3),
        top: centerY + dy - 15,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black54,
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

    if (_currentStep == 0) {
      overlays.add(
        placeText(
          "A",
          _rhombusNodes[0].dx - 30,
          _rhombusNodes[0].dy,
          color: Colors.amber,
        ),
      );
      overlays.add(
        placeText(
          "B",
          _rhombusNodes[1].dx,
          _rhombusNodes[1].dy - 30,
          color: Colors.amber,
        ),
      );
      overlays.add(
        placeText(
          "C",
          _rhombusNodes[2].dx + 30,
          _rhombusNodes[2].dy,
          color: Colors.amber,
        ),
      );
      overlays.add(
        placeText(
          "D",
          _rhombusNodes[3].dx,
          _rhombusNodes[3].dy + 30,
          color: Colors.amber,
        ),
      );
    } else if (_currentStep == 1 && _step2CenterClicked) {
      overlays.add(placeText("90°", 15, -35, color: Colors.greenAccent));
      overlays.add(placeText("90°", -35, 15, color: Colors.greenAccent));
    } else if (_currentStep == 2) {
      overlays.add(
        placeText(
          "50°",
          _rhombusNodes[0].dx + 40,
          _rhombusNodes[0].dy,
          color: Colors.amber,
        ),
      );
      if (_interactionCompleted) {
        overlays.add(
          placeText(
            "50°",
            _rhombusNodes[2].dx - 40,
            _rhombusNodes[2].dy,
            color: Colors.greenAccent,
          ),
        );
      } else {
        overlays.add(
          placeText(
            "?",
            _rhombusNodes[2].dx - 40,
            _rhombusNodes[2].dy,
            color: Colors.redAccent,
            size: 20,
          ),
        );
      }
    } else if (_currentStep == 3 || _currentStep == 4) {
      overlays.add(
        placeText(
          _getLabel('rectangles'),
          -100,
          -120,
          color: Colors.blueAccent,
        ),
      );
      overlays.add(
        placeText(_getLabel('rhombuses'), 100, -120, color: Colors.redAccent),
      );

      if (_currentStep == 4) {
        // Drop in Square label
        overlays.add(
          Positioned(
            left: centerX - 40,
            top: centerY - 15,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 1),
              curve: Curves.elasticOut,
              builder: (context, val, child) {
                return Transform.scale(
                  scale: val,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      _getLabel('square'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
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
              bottom: 10,
              right: 10,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: screenHeight * 0.45,
                    maxWidth: 400,
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
                          if (!_interactionCompleted && _currentStep == 2) ...[
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
                      Divider(color: Colors.white24),
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
                      const Icon(Icons.diamond, color: Colors.amber, size: 80),
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
class RhombusPainter extends CustomPainter {
  final int step;
  final bool isDark;
  final List<Offset> nodes;
  final List<int> selectedNodes;
  final List<List<int>> drawnDiagonals;
  final bool centerClicked;
  final bool intersectionClicked;

  RhombusPainter({
    required this.step,
    required this.isDark,
    required this.nodes,
    required this.selectedNodes,
    required this.drawnDiagonals,
    required this.centerClicked,
    required this.intersectionClicked,
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

    final Paint nodePaint = Paint()..color = Colors.blueAccent;
    final Paint selectedNodePaint = Paint()..color = Colors.amber;

    // Render Steps 0, 1, 2 (Rhombus shape)
    if (step <= 2) {
      Path rhombusPath = Path()
        ..moveTo(center.dx + nodes[0].dx, center.dy + nodes[0].dy)
        ..lineTo(center.dx + nodes[1].dx, center.dy + nodes[1].dy)
        ..lineTo(center.dx + nodes[2].dx, center.dy + nodes[2].dy)
        ..lineTo(center.dx + nodes[3].dx, center.dy + nodes[3].dy)
        ..close();

      if (step == 0) {
        canvas.drawPath(rhombusPath, linePaint);

        // Draw Diagonals
        for (var pair in drawnDiagonals) {
          canvas.drawLine(
            center + nodes[pair[0]],
            center + nodes[pair[1]],
            activePaint,
          );
        }

        // Draw Nodes
        for (int i = 0; i < nodes.length; i++) {
          canvas.drawCircle(
            center + nodes[i],
            12,
            selectedNodes.contains(i) ? selectedNodePaint : nodePaint,
          );
        }
      } else if (step == 1) {
        // Step 2: Show congruence, 4 triangles filled
        canvas.drawPath(rhombusPath, linePaint);
        canvas.drawLine(center + nodes[0], center + nodes[2], linePaint);
        canvas.drawLine(center + nodes[1], center + nodes[3], linePaint);

        // Fill Triangles
        final fills = [
          Paint()
            ..color = Colors.redAccent.withOpacity(0.3)
            ..style = PaintingStyle.fill,
          Paint()
            ..color = Colors.blueAccent.withOpacity(0.3)
            ..style = PaintingStyle.fill,
          Paint()
            ..color = Colors.green.withOpacity(0.3)
            ..style = PaintingStyle.fill,
          Paint()
            ..color = Colors.purpleAccent.withOpacity(0.3)
            ..style = PaintingStyle.fill,
        ];

        for (int i = 0; i < 4; i++) {
          Path tri = Path()
            ..moveTo(center.dx, center.dy)
            ..lineTo(center.dx + nodes[i].dx, center.dy + nodes[i].dy)
            ..lineTo(
              center.dx + nodes[(i + 1) % 4].dx,
              center.dy + nodes[(i + 1) % 4].dy,
            )
            ..close();
          canvas.drawPath(tri, fills[i]);
        }

        // Center Node
        canvas.drawCircle(
          center,
          12,
          centerClicked ? selectedNodePaint : nodePaint,
        );

        // Draw 90 deg markers if clicked
        if (centerClicked) {
          double s = 20;
          Paint marker = Paint()
            ..color = Colors.amber
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;
          // TR
          canvas.drawPath(
            Path()
              ..moveTo(center.dx + s, center.dy)
              ..lineTo(center.dx + s, center.dy - s)
              ..lineTo(center.dx, center.dy - s),
            marker,
          );
          // TL
          canvas.drawPath(
            Path()
              ..moveTo(center.dx - s, center.dy)
              ..lineTo(center.dx - s, center.dy - s)
              ..lineTo(center.dx, center.dy - s),
            marker,
          );
          // BL
          canvas.drawPath(
            Path()
              ..moveTo(center.dx - s, center.dy)
              ..lineTo(center.dx - s, center.dy + s)
              ..lineTo(center.dx, center.dy + s),
            marker,
          );
          // BR
          canvas.drawPath(
            Path()
              ..moveTo(center.dx + s, center.dy)
              ..lineTo(center.dx + s, center.dy + s)
              ..lineTo(center.dx, center.dy + s),
            marker,
          );
        }
      } else if (step == 2) {
        canvas.drawPath(rhombusPath, linePaint);
        canvas.drawLine(center + nodes[0], center + nodes[2], linePaint);
        canvas.drawLine(center + nodes[1], center + nodes[3], linePaint);
      }
    } else if (step == 3 || step == 4) {
      // Venn Diagram
      final Paint blueCircle = Paint()
        ..color = Colors.blueAccent.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6;
      final Paint redCircle = Paint()
        ..color = Colors.redAccent.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6;

      final Offset leftC = center + const Offset(-70, 0);
      final Offset rightC = center + const Offset(70, 0);
      const double radius = 120;

      if (intersectionClicked || step == 4) {
        // Highlight intersection
        final intersectionPath = Path.combine(
          PathOperation.intersect,
          Path()..addOval(Rect.fromCircle(center: leftC, radius: radius)),
          Path()..addOval(Rect.fromCircle(center: rightC, radius: radius)),
        );
        canvas.drawPath(
          intersectionPath,
          Paint()
            ..color = Colors.purple.withOpacity(0.4)
            ..style = PaintingStyle.fill,
        );
      }

      canvas.drawCircle(leftC, radius, blueCircle);
      canvas.drawCircle(rightC, radius, redCircle);

      if (step == 4) {
        // Draw Square
        Path square = Path()
          ..moveTo(center.dx - 40, center.dy - 40)
          ..lineTo(center.dx + 40, center.dy - 40)
          ..lineTo(center.dx + 40, center.dy + 40)
          ..lineTo(center.dx - 40, center.dy + 40)
          ..close();
        canvas.drawPath(
          square,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
        canvas.drawPath(
          square,
          Paint()
            ..color = Colors.purple
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant RhombusPainter oldDelegate) {
    return oldDelegate.step != step ||
        oldDelegate.isDark != isDark ||
        oldDelegate.selectedNodes != selectedNodes ||
        oldDelegate.drawnDiagonals != drawnDiagonals ||
        oldDelegate.centerClicked != centerClicked ||
        oldDelegate.intersectionClicked != intersectionClicked;
  }
}
