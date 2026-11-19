// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class IrrationalNumbersLabApp extends StatefulWidget {
  const IrrationalNumbersLabApp({Key? key}) : super(key: key);

  @override
  State<IrrationalNumbersLabApp> createState() =>
      _IrrationalNumbersLabAppState();
}

class _IrrationalNumbersLabAppState extends State<IrrationalNumbersLabApp>
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

  // Geoboard State
  final int _gridSize = 7;
  List<math.Point<int>> _currentPath = [];
  int _mcqSelectedAnswer = -1;

  // --- Animations & Audio ---
  late AnimationController _curtainController;
  late Animation<Offset> _curtainAnimation;
  late AudioPlayer _audioPlayer;

  // --- Localization Data ---
  final Map<String, Map<String, dynamic>> _translations = {
    'en': {
      'langCode': 'EN',
      'titleMain': 'Irrational Numbers',
      'chapterMain': 'Class 8 • The Baudhayana-Pythagoras Theorem',
      'enterBtn': 'Enter Virtual Lab',
      'teacherTitle': 'Mission Objective',
      'targetOutput': 'Target Output',
      'proceedBtn': 'Proceed to Next Step',
      'validateBtn': 'Verify Construction',
      'restartBtn': 'Restart Activity',
      'activeStep': 'Current Investigation',
      'toastSuccess': 'Excellent! Area calculated correctly.',
      'toastError': 'Incorrect. Check your construction or calculation.',
      'selectWarn': 'Please make a selection.',
      'labels': {'area': 'Area', 'side': 'Side Length', 'clear': 'Clear Board'},
      'steps': [
        {
          'title': 'Step 1: Rational Sides',
          'theory':
              "Welcome to Concept 8: Irrational Numbers.\n\nLet's start with a square we know. Draw a 1x1 square on the Geoboard.\n\nThe Area is 1. The side length is √1, which is 1 (a rational number).",
          'hudTitle': 'Draw a 1x1 Square',
          'hudInstruction':
              "Tap 4 dots to form a small 1x1 square. Close the loop by tapping the first dot again.",
          'targetArea': 1,
          'type': 'geoboard',
        },
        {
          'title': 'Step 2: The √2 Discovery',
          'theory':
              "Now, let's tilt our thinking. Draw a square by connecting the midpoints of a 2x2 grid (a square sitting on its corners).\n\nThis square is made of 4 half-squares. Its total Area is 2.\n\nIf Area = 2, then Side Length = √2. Can we write √2 as a simple fraction? No! This is an Irrational Number.",
          'hudTitle': 'Area 2 Construction',
          'hudInstruction':
              "Draw a tilted square with Area = 2. (Connect dots diagonally).",
          'targetArea': 2,
          'type': 'geoboard',
        },
        {
          'title': 'Step 3: Finding √5',
          'theory':
              "We can find many irrational lengths on this grid. Try to construct a square with an Area of 5 units.\n\nHint: Use the Baudhayana theorem on a 2x1 rectangle. The diagonal squared is 2² + 1² = 5.",
          'hudTitle': 'Area 5 Construction',
          'hudInstruction': "Draw a tilted square with Area = 5.",
          'targetArea': 5,
          'type': 'geoboard',
        },
        {
          'title': 'Step 4: Reasoning',
          'theory':
              "We have seen that while a grid is made of whole numbers, the distances between dots can be numbers that cannot be expressed as fractions.\n\nThese 'limitless' decimals that never repeat are called Irrational Numbers.",
          'hudTitle': 'Identification',
          'hudInstruction': "Which of these side lengths is a Rational Number?",
          'options': ['√2', '√5', '√9', '√10'],
          'correctIdx': 2,
          'type': 'mcq',
        },
      ],
    },
    'hi': {
      'langCode': 'HI',
      'titleMain': 'अपरिमेय संख्याएं',
      'chapterMain': 'कक्षा 8 • बौधायन-पाइथागोरस प्रमेय',
      'enterBtn': 'वर्चुअल लैब में प्रवेश करें',
      'teacherTitle': 'मिशन का उद्देश्य',
      'targetOutput': 'लक्षित आउटपुट',
      'proceedBtn': 'अगले चरण पर जाएँ',
      'validateBtn': 'निर्माण सत्यापित करें',
      'restartBtn': 'गतिविधि पुनः आरंभ करें',
      'activeStep': 'वर्तमान अन्वेषण',
      'toastSuccess': 'उत्कृष्ट! क्षेत्रफल की गणना सही है।',
      'toastError': 'गलत। अपने निर्माण या गणना की जाँच करें।',
      'selectWarn': 'कृपया एक विकल्प चुनें।',
      'labels': {
        'area': 'क्षेत्रफल',
        'side': 'भुजा की लंबाई',
        'clear': 'बोर्ड साफ करें',
      },
      'steps': [
        {
          'title': 'चरण 1: परिमेय भुजाएं',
          'theory':
              "अपरिमेय संख्याओं में आपका स्वागत है।\n\nआइए एक ज्ञात वर्ग से शुरू करें। जियोबोर्ड पर 1x1 वर्ग बनाएं।\n\nक्षेत्रफल 1 है। भुजा की लंबाई √1 है, जो कि 1 (एक परिमेय संख्या) है।",
          'hudTitle': '1x1 वर्ग बनाएं',
          'hudInstruction':
              "एक छोटा 1x1 वर्ग बनाने के लिए 4 बिंदुओं पर टैप करें। पहले बिंदु पर फिर से टैप करके लूप बंद करें।",
          'targetArea': 1,
          'type': 'geoboard',
        },
        {
          'title': 'चरण 2: √2 की खोज',
          'theory':
              "अब, अपनी सोच बदलिए। 2x2 ग्रिड के मध्य बिंदुओं को जोड़कर एक वर्ग बनाएं।\n\nयह वर्ग 4 आधे-वर्गों से बना है। इसका कुल क्षेत्रफल 2 है।\n\nयदि क्षेत्रफल = 2, तो भुजा की लंबाई = √2 है। क्या हम √2 को एक साधारण भिन्न के रूप में लिख सकते हैं? नहीं! यह एक अपरिमेय संख्या है।",
          'hudTitle': 'क्षेत्रफल 2 का निर्माण',
          'hudInstruction':
              "क्षेत्रफल = 2 वाला एक तिरछा वर्ग बनाएं। (बिंदुओं को तिरछे जोड़ें)।",
          'targetArea': 2,
          'type': 'geoboard',
        },
        {
          'title': 'चरण 3: √5 खोजना',
          'theory':
              "हम इस ग्रिड पर कई अपरिमेय लंबाई पा सकते हैं। 5 इकाइयों के क्षेत्रफल वाले वर्ग का निर्माण करने का प्रयास करें।\n\nसंकेत: 2x1 आयत पर बौधायन प्रमेय का उपयोग करें। विकर्ण का वर्ग 2² + 1² = 5 है।",
          'hudTitle': 'क्षेत्रफल 5 का निर्माण',
          'hudInstruction': "क्षेत्रफल = 5 वाला एक तिरछा वर्ग बनाएं।",
          'targetArea': 5,
          'type': 'geoboard',
        },
        {
          'title': 'चरण 4: तर्क',
          'theory':
              "हमने देखा है कि जबकि एक ग्रिड पूर्ण संख्याओं से बना होता है, बिंदुओं के बीच की दूरी ऐसी संख्याएं हो सकती हैं जिन्हें भिन्नों के रूप में व्यक्त नहीं किया जा सकता है।\n\nये 'असीमित' दशमलव जो कभी नहीं दोहराते, अपरिमेय संख्याएं कहलाते हैं।",
          'hudTitle': 'पहचान',
          'hudInstruction':
              "इनमें से कौन सी भुजा की लंबाई एक परिमेय संख्या है?",
          'options': ['√2', '√5', '√9', '√10'],
          'correctIdx': 2,
          'type': 'mcq',
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
      _currentPath = [];
      _mcqSelectedAnswer = -1;
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

  double _calculateArea(List<math.Point<int>> path) {
    if (path.length < 3) return 0;
    double area = 0;
    for (int i = 0; i < path.length - 1; i++) {
      area += (path[i].x * path[i + 1].y) - (path[i + 1].x * path[i].y);
    }
    return (area / 2.0).abs();
  }

  void _validateInvestigation() {
    String type = currentScenario['type'] ?? '';

    if (type == 'geoboard') {
      if (_currentPath.isEmpty || _currentPath.first != _currentPath.last) {
        _showFeedback("Please close the square loop.", false);
        return;
      }
      double area = _calculateArea(_currentPath);
      int target = currentScenario['targetArea'] ?? 0;
      if (area == target.toDouble()) {
        _showFeedback(_getString('toastSuccess'), true);
      } else {
        _showFeedback("${_getString('toastError')} (Area: $area)", false);
      }
    } else if (type == 'mcq') {
      if (_mcqSelectedAnswer == -1) {
        _showFeedback(_getString('selectWarn'), false);
        return;
      }
      int correctIdx = currentScenario['correctIdx'] as int? ?? -1;
      if (_mcqSelectedAnswer == correctIdx) {
        _showFeedback(_getString('toastSuccess'), true);
      } else {
        _showFeedback(_getString('toastError'), false);
      }
    }
  }

  void _handleDotTap(int x, int y) {
    if (_interactionCompleted) return;
    _playSound('tap');
    setState(() {
      var point = math.Point(x, y);
      if (_currentPath.isNotEmpty &&
          point == _currentPath.first &&
          _currentPath.length > 2) {
        _currentPath.add(point); // Close loop
        _validateInvestigation();
      } else {
        if (_currentPath.contains(point)) {
          _currentPath.remove(point);
        } else {
          _currentPath.add(point);
        }
      }
    });
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
          if (_currentStep < 3) {
            _loadScenario(_currentStep + 1);
          } else {
            _loadScenario(0);
          }
        }
      },
      icon: Icon(
        _interactionCompleted
            ? (_currentStep == 3 ? Icons.refresh : Icons.arrow_forward)
            : Icons.verified,
      ),
      label: Text(
        _interactionCompleted
            ? (_currentStep == 3
                  ? _getString('restartBtn')
                  : _getString('proceedBtn'))
            : _getString('validateBtn'),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildHUDInteraction() {
    String type = currentScenario['type'] ?? '';

    if (type == 'geoboard') {
      return TextButton.icon(
        onPressed: () {
          _playSound('tap');
          setState(() {
            _currentPath = [];
            _feedbackMessage = null;
          });
        },
        icon: const Icon(Icons.refresh, color: Colors.amber),
        label: Text(
          _getLabel('clear'),
          style: const TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (type == 'mcq') {
      List<String> options = List<String>.from(
        currentScenario['options'] ?? [],
      );
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.start,
        children: List.generate(options.length, (idx) {
          bool isSelected = _mcqSelectedAnswer == idx;
          return InkWell(
            onTap: _interactionCompleted
                ? null
                : () {
                    _playSound('tap');
                    setState(() => _mcqSelectedAnswer = idx);
                    _validateInvestigation();
                  },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? (idx == currentScenario['correctIdx']
                          ? Colors.green
                          : Colors.redAccent)
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
    }
    return const SizedBox();
  }

  Widget _buildInteractiveCanvas() {
    return Container(
      color: _isDarkTheme ? const Color(0xFF0B1120) : const Color(0xFFE2E8F0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double geoboardSize =
              math.min(constraints.maxWidth, constraints.maxHeight) * 0.8;
          double padding = 40.0;
          double drawableSize = geoboardSize - (padding * 2);
          double spacing = drawableSize / (_gridSize - 1);

          return Stack(
            alignment: Alignment.center,
            children: [
              // Geoboard Core
              Center(
                child: Container(
                  width: geoboardSize,
                  height: geoboardSize,
                  decoration: BoxDecoration(
                    color: _isDarkTheme
                        ? Colors.white.withOpacity(0.02)
                        : Colors.black.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CustomPaint(
                        size: Size(geoboardSize, geoboardSize),
                        painter: GeoboardPainter(
                          gridSize: _gridSize,
                          spacing: spacing,
                          padding: padding,
                          path: _currentPath,
                          isDark: _isDarkTheme,
                        ),
                      ),
                      // Dot touch targets
                      for (int y = 0; y < _gridSize; y++)
                        for (int x = 0; x < _gridSize; x++)
                          Positioned(
                            left: padding + x * spacing - 25,
                            top: padding + y * spacing - 25,
                            child: GestureDetector(
                              onTap: () => _handleDotTap(x, y),
                              child: Container(
                                width: 50,
                                height: 50,
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ),

              // Measurement Overlay
              if (_currentPath.length > 2 &&
                  _currentPath.first == _currentPath.last)
                Positioned(
                  top: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "${_getLabel('area')}: ${_calculateArea(_currentPath).toStringAsFixed(1)}",
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${_getLabel('side')}: √${_calculateArea(_currentPath).toStringAsFixed(1)}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
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
                left: 20,
                bottom: 10,
                child: SizedBox(
                  width: 250,
                  height: screenHeight * 1.0,
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
                          if (_feedbackMessage != null) ...[
                            Text(
                              _feedbackMessage!,
                              style: TextStyle(
                                color: _feedbackIsSuccess
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          _buildHUDInteraction(),
                          const SizedBox(height: 16),
                          _buildMainActionButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // --- 3. Foreground Sidebar Overlay (z-index front) ---
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
                            items: List.generate(4, (index) {
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

                      // Target Output Visual Box (Integrated With HUD interaction)
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getStepString('hudInstruction'),
                              style: TextStyle(
                                color: textBase,
                                fontSize: 14,
                                height: 1.5,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_feedbackMessage != null) ...[
                              Text(
                                _feedbackMessage!,
                                style: TextStyle(
                                  color: _feedbackIsSuccess
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            _buildHUDInteraction(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Action Button
                      _buildMainActionButton(),
                      const SizedBox(height: 40),

                      // Footer
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

            // --- 4. Floating Menu Button (Top Left) ---
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

            // --- 5. Initial Curtain Raiser ---
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
                      const Icon(Icons.grid_4x4, color: Colors.amber, size: 80),
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
class GeoboardPainter extends CustomPainter {
  final int gridSize;
  final double spacing;
  final double padding;
  final List<math.Point<int>> path;
  final bool isDark;

  GeoboardPainter({
    required this.gridSize,
    required this.spacing,
    required this.padding,
    required this.path,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(padding, padding);

    final dotColor = isDark ? Colors.white30 : Colors.black26;
    final activeColor = Colors.amber;

    // Draw Fill if closed
    if (path.isNotEmpty && path.first == path.last) {
      final fillPath = Path();
      fillPath.moveTo(path[0].x * spacing, path[0].y * spacing);
      for (int i = 1; i < path.length; i++) {
        fillPath.lineTo(path[i].x * spacing, path[i].y * spacing);
      }
      fillPath.close();
      canvas.drawPath(
        fillPath,
        Paint()
          ..color = activeColor.withOpacity(0.2)
          ..style = PaintingStyle.fill,
      );
    }

    // Draw Lines
    final linePaint = Paint()
      ..color = activeColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < path.length - 1; i++) {
      canvas.drawLine(
        Offset(path[i].x * spacing, path[i].y * spacing),
        Offset(path[i + 1].x * spacing, path[i + 1].y * spacing),
        linePaint,
      );
    }

    // Draw Dots
    final dotPaint = Paint()..color = dotColor;
    final activeDotPaint = Paint()..color = activeColor;

    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        bool isActive = path.contains(math.Point(x, y));
        canvas.drawCircle(
          Offset(x * spacing, y * spacing),
          isActive ? 6 : 4,
          isActive ? activeDotPaint : dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant GeoboardPainter oldDelegate) {
    return oldDelegate.path != path || oldDelegate.isDark != isDark;
  }
}
