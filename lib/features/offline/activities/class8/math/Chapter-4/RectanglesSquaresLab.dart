// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class RectanglesSquaresLab extends StatefulWidget {
  const RectanglesSquaresLab({Key? key}) : super(key: key);

  @override
  State<RectanglesSquaresLab> createState() => _RectanglesSquaresLabState();
}

class _RectanglesSquaresLabState extends State<RectanglesSquaresLab>
    with TickerProviderStateMixin {
  // --- UI State ---
  bool _showCurtain = true;
  bool _isSidebarOpen = true;
  final bool _isDarkTheme = true;
  int _currentStep = 0;
  String _currentLang = 'en';
  final double _teacherFontSize = 16.0;

  // --- Interaction State ---
  bool _step1NailPlaced = false;
  double _stripAngleDeg = 45.0; // For steps 2 & 3
  bool _step4SquareSelected = false;
  Offset _step5SquaresSetOffset = const Offset(
    250,
    0,
  ); // Position relative to center

  String? _feedbackMessage;
  bool _feedbackIsSuccess = true;
  bool _interactionCompleted = false;

  // --- Animations & Audio ---
  late AnimationController _curtainController;
  late Animation<Offset> _curtainAnimation;
  late AudioPlayer _audioPlayer;

  // --- Localization Data ---
  final Map<String, Map<String, dynamic>> _translations = {
    'en': {
      'langCode': 'EN',
      'titleMain': 'Rectangles & Squares',
      'chapterMain': 'Class 8 • Quadrilaterals',
      'enterBtn': 'Enter Virtual Lab',
      'hudTitle': 'Interactive Task',
      'teacherTitle': 'Mission Objective',
      'targetOutput': 'Target Output',
      'activeStep': 'Current Investigation',
      'proceedBtn': 'Proceed to Next Step',
      'restartBtn': 'Restart Lab',
      'verifyBtn': 'Validate Model',
      'scenarios': [
        {
          'title': "Step 1: The Carpenter's Problem",
          'theory':
              "We usually define rectangles by their sides and corner angles, but what about their diagonals?\n\nA carpenter has two wooden strips of equal length (8 units). He wants to nail them together to act as the internal framework for a rectangular frame.",
          'instruction':
              "Watch the strips being placed one by one. Once the center point is marked, tap exactly on the center point to place a nail.",
          'hudIndep': 'Nail Point',
          'hudDep': 'Nail Point',
        },
        {
          'title': 'Step 2: Forming a Rectangle',
          'theory':
              "To make a perfect rectangle, the carpenter must nail them exactly at their midpoints. This means the diagonals must bisect each other (cut each other in half).\n\nDrawing strings around their ends will always form a perfect rectangle. A rectangle is a quadrilateral where diagonals are equal and bisect each other.",
          'instruction':
              "Drag the ends of the top strip to rotate it. Adjust the angle to be between 40° and 60°, then verify.",
          'hudIndep': 'Angle',
          'hudDep': 'Rectangle',
        },
        {
          'title': 'Step 3: Modifying to a Square',
          'theory':
              "To turn this rectangular frame into a perfect Square, we just need to change the angle at which they intersect.",
          'instruction':
              "Rotate the strip until it intersects exactly at 90° (Right Angle) to form a Square.",
          'hudIndep': 'Angle',
          'hudDep': 'Square',
        },
        {
          'title': 'Step 4: The Angle Dictates Shape',
          'theory':
              "Observe two sets of diagonals bisecting each other:\n• Left: Crosses at 30°. Forms a long, flat rectangle.\n• Right: Crosses at 90°. Forms a perfect square.",
          'instruction':
              "Observe the results. Tap on the Square (90° diagonals) to proceed.",
          'hudIndep': 'Angle',
          'hudDep': 'Shape Type',
        },
        {
          'title': 'Step 5: Venn Diagram Logic',
          'theory':
              "Every square is a rectangle, but not every rectangle is a square. We can visualize this using a Venn Diagram.",
          'instruction':
              "Drag the set of 'Squares' (Red) into its correct logical position inside the set of 'Rectangles' (Blue).",
          'hudIndep': 'Squares',
          'hudDep': 'Subset',
        },
      ],
      'labels': {
        'rectResult': 'Result: Rectangle',
        'sqResult': 'Result: Square',
        'setRect': 'Set of Rectangles',
        'setSq': 'Set of Squares',
        'awaiting': 'AWAITING INTERACTION...',
      },
      'feedback': {
        'step1Success': 'Excellent! Nailed successfully.',
        'step1Fail': 'Incorrect. Tap the center to nail.',
        'step2Success': 'Excellent! Model Validated.',
        'step2Fail': 'Incorrect. Adjust between 40° and 60°.',
        'step3Success': 'Excellent! Model Validated.',
        'step3Fail': 'Incorrect. Rotate to exactly 90°.',
        'step4Success': 'Excellent! Result: Square selected!',
        'step4Fail': 'Incorrect. SELECT THE SQUARE.',
        'step5Success': 'Excellent! Correct Subset Logic!',
        'step5Fail': 'Incorrect. Move Squares inside Rectangles.',
      },
    },
    'hi': {
      'langCode': 'HI',
      'titleMain': 'आयत और वर्ग',
      'chapterMain': 'कक्षा 8 • चतुर्भुज',
      'enterBtn': 'वर्चुअल लैब में प्रवेश करें',
      'hudTitle': 'इंटरएक्टिव कार्य',
      'teacherTitle': 'मिशन का उद्देश्य',
      'targetOutput': 'लक्षित आउटपुट',
      'activeStep': 'वर्तमान अन्वेषण',
      'proceedBtn': 'अगले चरण पर जाएँ',
      'restartBtn': 'लैब रीस्टार्ट करें',
      'verifyBtn': 'मॉडल मान्य करें',
      'scenarios': [
        {
          'title': 'चरण 1: बढ़ई की समस्या',
          'theory':
              "हम आमतौर पर आयतों को उनके पक्षों और कोनों के कोणों से परिभाषित करते हैं, लेकिन उनके विकर्णों के बारे में क्या?\n\nएक बढ़ई के पास समान लंबाई (8 इकाई) की लकड़ी की दो पट्टियाँ हैं। वह उन्हें एक साथ कील से जोड़ना चाहता है ताकि वे एक आयताकार ढांचे के आंतरिक ढांचे के रूप में कार्य कर सकें।",
          'instruction':
              "पट्टियों को एक-एक करके रखे जाते हुए देखें। एक बार जब मध्य बिंदु चिह्नित हो जाए, तो कील लगाने के लिए ठीक मध्य बिंदु पर टैप करें।",
          'hudIndep': 'कील बिंदु',
          'hudDep': 'कील बिंदु',
        },
        {
          'title': 'चरण 2: आयत बनाना',
          'theory':
              "एक सही आयत बनाने के लिए, बढ़ई को उन्हें ठीक उनके मध्य बिंदुओं पर कील ठोकनी चाहिए। इसका मतलब है कि विकर्णों को एक-दूसरे को समद्विभाजित करना चाहिए।\n\nउनके सिरों के चारों ओर धागे खींचने से हमेशा एक सही आयत बनेगा। आयत एक ऐसा चतुर्भुज है जहाँ विकर्ण बराबर होते हैं और एक-दूसरे को समद्विभाजित करते हैं।",
          'instruction':
              "ऊपरी पट्टी को घुमाने के लिए उसके सिरों को खींचें। कोण को 40° और 60° के बीच समायोजित करें, फिर सत्यापित करें।",
          'hudIndep': 'कोण',
          'hudDep': 'आयत',
        },
        {
          'title': 'चरण 3: वर्ग में बदलना',
          'theory':
              "इस आयताकार ढांचे को एक आदर्श वर्ग में बदलने के लिए, हमें बस उस कोण को बदलने की आवश्यकता है जिस पर वे एक-दूसरे को काटते हैं।",
          'instruction':
              "पट्टी को तब तक घुमाएं जब तक कि वह वर्ग बनाने के लिए ठीक 90° (समकोण) पर न कट जाए।",
          'hudIndep': 'कोण',
          'hudDep': 'वर्ग',
        },
        {
          'title': 'चरण 4: कोण आकार निर्धारित करता है',
          'theory':
              "एक-दूसरे को समद्विभाजित करने वाले विकर्णों के दो समूहों को देखें:\n• बाएँ: 30° पर कटता है। एक लंबा, सपाट आयत बनाता है।\n• दाएँ: 90° पर कटता है। एक आदर्श वर्ग बनाता है।",
          'instruction':
              "परिणामों को देखें। आगे बढ़ने के लिए वर्ग पर टैप करें (90° विकर्ण)।",
          'hudIndep': 'कोण',
          'hudDep': 'आकार प्रकार',
        },
        {
          'title': 'चरण 5: वेन आरेख तर्क',
          'theory':
              "प्रत्येक वर्ग एक आयत है, लेकिन प्रत्येक आयत एक वर्ग नहीं है। हम इसे वेन आरेख का उपयोग करके देख सकते हैं।",
          'instruction':
              "'वर्गों' के समूह (लाल) को 'आयतों' के समूह (नीला) के अंदर उसकी सही तार्किक स्थिति में खींचें।",
          'hudIndep': 'वर्ग',
          'hudDep': 'उपसमुच्चय',
        },
      ],
      'labels': {
        'rectResult': 'परिणाम: आयत',
        'sqResult': 'परिणाम: वर्ग',
        'setRect': 'आयतों का समूह',
        'setSq': 'वर्गों का समूह',
        'awaiting': 'बातचीत की प्रतीक्षा है...',
      },
      'feedback': {
        'step1Success': 'उत्कृष्ट! कील लगा दी गई!',
        'step1Fail': 'गलत। कीला ठोकने के लिए बीच में क्लिक करें।',
        'step2Success': 'उत्कृष्ट! मॉडल मान्य।',
        'step2Fail': 'गलत। 40° और 60° के बीच समायोजित करें।',
        'step3Success': 'उत्कृष्ट! मॉडल मान्य।',
        'step3Fail': 'गलत। ठीक 90° पर घुमाएं।',
        'step4Success': 'उत्कृष्ट! परिणाम: वर्ग चुना गया!',
        'step4Fail': 'गलत। वर्ग चुनें।',
        'step5Success': 'उत्कृष्ट! तार्किक रूप से सही!',
        'step5Fail': 'गलत। वर्गों को आयत के अंदर ले जाएँ।',
      },
    },
  };

  // --- Safe Map Accessors (Prevents Null TypeErrors) ---
  Map<String, dynamic> get t =>
      _translations[_currentLang] ?? _translations['en']!;
  Map<String, dynamic> get tLabels =>
      (t['labels'] as Map?)?.cast<String, dynamic>() ?? {};
  Map<String, dynamic> get tFeedback =>
      (t['feedback'] as Map?)?.cast<String, dynamic>() ?? {};

  Map<String, dynamic> get currentScenario {
    final scenarios = t['scenarios'] as List?;
    if (scenarios != null &&
        _currentStep >= 0 &&
        _currentStep < scenarios.length) {
      return scenarios[_currentStep] as Map<String, dynamic>;
    }
    return {};
  }

  String _getString(String key) => t[key]?.toString() ?? '';
  String _getLabel(String key) => tLabels[key]?.toString() ?? '';
  String _getFeedback(String key) => tFeedback[key]?.toString() ?? '';
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
      setState(() {
        _showCurtain = false;
      });
    });
  }

  void _loadScenario(int step) {
    setState(() {
      _currentStep = step;
      _feedbackMessage = null;
      _interactionCompleted = false;

      // Reset scenario states
      _step1NailPlaced = false;
      _stripAngleDeg = 45.0;
      _step4SquareSelected = false;
      _step5SquaresSetOffset = const Offset(250, 0);
    });
  }

  void _showFeedback(String key, bool success) {
    _playSound(success ? 'success' : 'error');
    setState(() {
      _feedbackMessage = _getFeedback(key);
      _feedbackIsSuccess = success;
      if (success) _interactionCompleted = true;
    });
  }

  // --- Interaction Validation ---
  void _validateInvestigation() {
    if (_currentStep == 0) {
      if (!_step1NailPlaced) {
        _showFeedback('step1Fail', false);
      }
    } else if (_currentStep == 1) {
      double angle = _normalizeAngle(_stripAngleDeg);
      if (angle >= 40 && angle <= 60) {
        _showFeedback('step2Success', true);
      } else {
        _showFeedback('step2Fail', false);
      }
    } else if (_currentStep == 2) {
      double angle = _normalizeAngle(_stripAngleDeg);
      if ((angle - 90).abs() <= 8) {
        setState(() => _stripAngleDeg = 90.0); // snap to 90
        _showFeedback('step3Success', true);
      } else {
        _showFeedback('step3Fail', false);
      }
    } else if (_currentStep == 3) {
      if (!_step4SquareSelected) {
        _showFeedback('step4Fail', false);
      }
    } else if (_currentStep == 4) {
      // Validate distance of Red Box to center of Blue Box
      if (_step5SquaresSetOffset.distance < 120) {
        _showFeedback('step5Success', true);
        setState(
          () => _step5SquaresSetOffset = const Offset(0, 0),
        ); // snap to center
      } else {
        _showFeedback('step5Fail', false);
      }
    }
  }

  double _normalizeAngle(double angle) {
    double a = angle.abs() % 180;
    if (a > 90) a = 180 - a;
    return a;
  }

  void _handleRotation(DragUpdateDetails details, Offset center) {
    if (_interactionCompleted) return;
    Offset delta = details.localPosition - center;
    double angle = math.atan2(delta.dy, delta.dx);
    setState(() {
      _stripAngleDeg = (angle * 180 / math.pi);
    });
  }

  // --- UI Components ---
  Color get bgBase =>
      _isDarkTheme ? const Color(0xFF020617) : const Color(0xFFF8FAFC);
  Color get bgPanel =>
      _isDarkTheme ? const Color(0xD91E293B) : const Color(0xD9FFFFFF);
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
            : _getString('verifyBtn'),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildWoodStrip({double angle = 0, bool isInteractive = false}) {
    return Transform.rotate(
      angle: angle * math.pi / 180,
      child: Container(
        width: 300,
        height: 24,
        decoration: BoxDecoration(
          color: const Color(0xFF9C5A33),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black45, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 6,
              offset: Offset(2, 4),
            ),
          ],
          gradient: const LinearGradient(
            colors: [Color(0xFF8B4513), Color(0xFFA0522D), Color(0xFF8B4513)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isInteractive
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(
                    Icons.drag_indicator,
                    color: Colors.white54,
                    size: 20,
                  ),
                  const Icon(
                    Icons.drag_indicator,
                    color: Colors.white54,
                    size: 20,
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildNail() {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black87, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 2)),
        ],
        gradient: RadialGradient(colors: [Colors.white, Colors.grey[600]!]),
      ),
    );
  }

  Widget _buildInteractiveCanvas() {
    return Container(
      color: Colors.black, // Dark canvas area simulating the 3D space
      child: LayoutBuilder(
        builder: (context, constraints) {
          Size canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
          Offset center = Offset(canvasSize.width / 2, canvasSize.height / 2);

          return Stack(
            alignment: Alignment.center,
            children: [
              // Simulated table grid background
              CustomPaint(size: Size.infinite, painter: GridPainter()),

              // --- STEP SPECIFIC RENDERING ---
              if (_currentStep == 0) ...[
                _buildWoodStrip(angle: 0),
                _buildWoodStrip(angle: 45),
                if (_step1NailPlaced)
                  _buildNail()
                else
                  GestureDetector(
                    onTap: () {
                      setState(() => _step1NailPlaced = true);
                      _showFeedback('step1Success', true);
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.amber, width: 2),
                      ),
                      child: const Center(
                        child: Text(
                          "[ ? ]",
                          style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],

              if (_currentStep == 1 || _currentStep == 2) ...[
                // Boundary Drawing
                CustomPaint(
                  size: const Size(300, 300),
                  painter: QuadPainter(
                    angleDeg: _stripAngleDeg,
                    stripLength: 300,
                  ),
                ),
                _buildWoodStrip(angle: 0), // Fixed horizontal strip
                GestureDetector(
                  onPanUpdate: (details) => _handleRotation(details, center),
                  child: Container(
                    color: Colors.transparent, // expanded hit area
                    child: Center(
                      child: _buildWoodStrip(
                        angle: _stripAngleDeg,
                        isInteractive: !_interactionCompleted,
                      ),
                    ),
                  ),
                ),
                _buildNail(),
              ],

              if (_currentStep == 3) ...[
                // Left Setup (Rectangle)
                Positioned(
                  left: canvasSize.width * 0.15,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(150, 150),
                              painter: QuadPainter(
                                angleDeg: 30,
                                stripLength: 150,
                              ),
                            ),
                            Transform.scale(
                              scale: 0.5,
                              child: _buildWoodStrip(angle: 0),
                            ),
                            Transform.scale(
                              scale: 0.5,
                              child: _buildWoodStrip(angle: 30),
                            ),
                            _buildNail(),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          _getLabel('rectResult'),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                // Right Setup (Square)
                Positioned(
                  right: canvasSize.width * 0.15,
                  child: GestureDetector(
                    onTap: () {
                      _playSound('tap');
                      setState(() => _step4SquareSelected = true);
                      _showFeedback('step4Success', true);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          decoration: _step4SquareSelected
                              ? BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  border: Border.all(
                                    color: Colors.greenAccent,
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                )
                              : null,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: const Size(150, 150),
                                painter: QuadPainter(
                                  angleDeg: 90,
                                  stripLength: 150,
                                ),
                              ),
                              Transform.scale(
                                scale: 0.5,
                                child: _buildWoodStrip(angle: 0),
                              ),
                              Transform.scale(
                                scale: 0.5,
                                child: _buildWoodStrip(angle: 90),
                              ),
                              _buildNail(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Text(
                            _getLabel('sqResult'),
                            style: const TextStyle(color: Colors.amber),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              if (_currentStep == 4) ...[
                // Blue Box (Rectangles)
                Container(
                  width: 350,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    border: Border.all(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _getLabel('setRect'),
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),

                // Draggable Red Box (Squares)
                Positioned(
                  left:
                      center.dx -
                      200 +
                      _step5SquaresSetOffset.dx, // Initial offset adjusted
                  top: center.dy - 100 + _step5SquaresSetOffset.dy,
                  child: GestureDetector(
                    onPanUpdate: _interactionCompleted
                        ? null
                        : (details) {
                            setState(() {
                              _step5SquaresSetOffset += details.delta;
                            });
                          },
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.4),
                        border: Border.all(color: Colors.redAccent, width: 2),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _getLabel('setSq'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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
                top: 70,
                left: 10,
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
                            _getString('hudTitle').toUpperCase(),
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _feedbackMessage ?? _getLabel('awaiting'),
                            style: TextStyle(
                              color: _feedbackMessage == null
                                  ? Colors.amber
                                  : (_feedbackIsSuccess
                                        ? Colors.greenAccent
                                        : Colors.redAccent),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          // Custom Specific Trackers
                          const SizedBox(height: 8),
                          Container(height: 1, width: 200, color: borderPanel),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.category,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "X: ${_getStepString('hudIndep')}",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(
                                Icons.insights,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Y: ${_getStepString('hudDep')}",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          if ((_currentStep == 1 || _currentStep == 2) &&
                              !_interactionCompleted) ...[
                            const SizedBox(height: 8),
                            Text(
                              "Angle: ${_normalizeAngle(_stripAngleDeg).toStringAsFixed(0)}°",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
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
                              final scenariosList = t['scenarios'] as List?;
                              final titleStr =
                                  (scenariosList != null &&
                                      index < scenariosList.length)
                                  ? scenariosList[index]['title']?.toString() ??
                                        ''
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
                          elevation: 10,
                        ),
                        onPressed: _enterLab,
                        icon: const Icon(Icons.science, size: 28),
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

// --- Custom Painters for Simulated 3D Space and Geometry ---

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    double step = 40;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Paints the boundary lines (string) connecting the diagonal strip ends
class QuadPainter extends CustomPainter {
  final double angleDeg;
  final double stripLength;

  QuadPainter({required this.angleDeg, required this.stripLength});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    final l = stripLength / 2;

    // Horizontal strip points
    final p1 = center + Offset(l, 0);
    final p3 = center + Offset(-l, 0);

    // Rotated strip points
    final rad = angleDeg * math.pi / 180;
    final p2 = center + Offset(l * math.cos(rad), l * math.sin(rad));
    final p4 = center + Offset(-l * math.cos(rad), -l * math.sin(rad));

    // Draw connecting "strings"
    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p4.dx, p4.dy)
      ..close();

    canvas.drawPath(path, paint);

    // Draw points at vertices
    final dotPaint = Paint()..color = Colors.amber;
    canvas.drawCircle(p1, 4, dotPaint);
    canvas.drawCircle(p2, 4, dotPaint);
    canvas.drawCircle(p3, 4, dotPaint);
    canvas.drawCircle(p4, 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant QuadPainter oldDelegate) {
    return oldDelegate.angleDeg != angleDeg ||
        oldDelegate.stripLength != stripLength;
  }
}
