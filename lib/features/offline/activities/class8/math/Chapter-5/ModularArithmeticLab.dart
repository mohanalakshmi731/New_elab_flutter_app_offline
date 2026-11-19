// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class ModularArithmeticLab extends StatefulWidget {
  const ModularArithmeticLab({Key? key}) : super(key: key);

  @override
  State<ModularArithmeticLab> createState() => _ModularArithmeticLabState();
}

class _ModularArithmeticLabState extends State<ModularArithmeticLab>
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

  // Track dropped item in steps
  int? _droppedBaseNumber;
  int? _calculatedRemainder;

  // --- Animations & Audio ---
  late AnimationController _curtainController;
  late Animation<Offset> _curtainAnimation;
  late AudioPlayer _audioPlayer;

  // --- Localization Data ---
  final Map<String, Map<String, dynamic>> _translations = {
    'en': {
      'langCode': 'EN',
      'titleMain': 'Modular Arithmetic',
      'chapterMain': 'Class 8 • Playing with Numbers',
      'enterBtn': 'Enter Virtual Lab',
      'teacherTitle': 'Mission Objective',
      'targetOutput': 'Target Output',
      'proceedBtn': 'Proceed to Next Step',
      'validateBtn': 'Verify Math',
      'restartBtn': 'Restart Activity',
      'activeStep': 'Current Investigation',
      'toastSuccess': 'Excellent! Logic Validated.',
      'toastError': 'Incorrect. Remember: Division = Quotient + Remainder.',
      'labels': {
        'dragTarget': 'Drop Number Here',
        'remPrefix': 'Remainder',
        'modPrefix': 'Mod',
      },
      'steps': [
        {
          'title': 'Step 1: The Remainder Box',
          'theory':
              "Welcome to Concept 2: Modular Arithmetic. This sounds complex, but it's just a fancy term for 'Math with Remainders'.\n\nWhen we divide a number by 2, what are the possible remainders? Only 0 or 1. If it divides perfectly, the remainder is 0. If there is 1 left over, the remainder is 1.\n\nIn mathematics, we write this as: a ≡ r (mod m) (where 'r' is the remainder).",
          'hudTitle': 'Mod 2 Machine',
          'hudInstruction':
              "Drag a number into the 'Mod 2' machine to see its remainder.",
          'modValue': 2,
          'availableNumbers': [4, 7, 10],
          'targetRem': 1, // Look for remainder 1 to proceed
        },
        {
          'title': 'Step 2: Modulo 3',
          'theory':
              "Now let's change the divisor to 3. This is called 'Modulo 3' or 'Mod 3'.\n\nWhen you divide ANY number by 3, the only possible remainders are 0, 1, or 2.\n\nFor example, 10 ÷ 3 = 3 with a remainder of 1. So, 10 ≡ 1 (mod 3).",
          'hudTitle': 'Mod 3 Target',
          'hudInstruction':
              "Find a number that leaves a remainder of 2 when divided by 3.",
          'modValue': 3,
          'availableNumbers': [9, 11, 13],
          'targetRem': 2,
        },
        {
          'title': 'Step 3: Modulo 5',
          'theory':
              "Let's increase the modulo to 5.\n\nThe rule is universal: If we are working in 'Mod N', the possible remainders are always strictly less than N (from 0 up to N-1).\n\nFor Mod 5, the remainders can only be 0, 1, 2, 3, or 4.",
          'hudTitle': 'Mod 5 Puzzle',
          'hudInstruction':
              "Drag the number that leaves a remainder of 4 when divided by 5.",
          'modValue': 5,
          'availableNumbers': [15, 18, 24],
          'targetRem': 4,
        },
        {
          'title': 'Step 4: Real-World Modulo',
          'theory':
              "We use modular arithmetic every day! Think about a 12-hour clock. \n\nIf it is 10:00 AM, what time will it be in 5 hours? 10 + 5 = 15. But clocks wrap around after 12. \n\nWe divide 15 by 12, and the remainder is 3. So it is 3:00 PM! Clocks operate entirely on 'Modulo 12'.",
          'hudTitle': 'Clock Math (Mod 12)',
          'hudInstruction':
              "It is 8 o'clock. Add 10 hours. What time is it? (Find remainder modulo 12)",
          'modValue': 12,
          'availableNumbers': [18, 14, 20],
          'targetRem': 6,
        },
      ],
    },
    'hi': {
      'langCode': 'HI',
      'titleMain': 'मॉड्यूलर अंकगणित',
      'chapterMain': 'कक्षा 8 • संख्याओं के साथ खेलना',
      'enterBtn': 'वर्चुअल लैब में प्रवेश करें',
      'teacherTitle': 'मिशन का उद्देश्य',
      'targetOutput': 'लक्षित आउटपुट',
      'proceedBtn': 'अगले चरण पर जाएँ',
      'validateBtn': 'गणित सत्यापित करें',
      'restartBtn': 'गतिविधि पुनः आरंभ करें',
      'activeStep': 'वर्तमान अन्वेषण',
      'toastSuccess': 'उत्कृष्ट! तर्क मान्य।',
      'toastError': 'गलत। याद रखें: विभाजन = भागफल + शेषफल।',
      'labels': {
        'dragTarget': 'यहाँ नंबर छोड़ें',
        'remPrefix': 'शेषफल (Rem)',
        'modPrefix': 'Mod',
      },
      'steps': [
        {
          'title': 'चरण 1: शेषफल बॉक्स',
          'theory':
              "कांसेप्ट 2 में आपका स्वागत है: मॉड्यूलर अंकगणित। यह जटिल लगता है, लेकिन यह 'शेषफल वाले गणित' के लिए एक फैंसी शब्द है।\n\nजब हम किसी संख्या को 2 से विभाजित करते हैं, तो संभावित शेषफल क्या होते हैं? केवल 0 या 1। यदि यह पूरी तरह से विभाजित हो जाता है, तो शेषफल 0 होता है। यदि 1 बचा है, तो शेषफल 1 है।\n\nगणित में, हम इसे इस प्रकार लिखते हैं: a ≡ r (mod m) (जहाँ 'r' शेषफल है)।",
          'hudTitle': 'Mod 2 मशीन',
          'hudInstruction':
              "शेषफल देखने के लिए किसी संख्या को 'Mod 2' मशीन में खींचें।",
          'modValue': 2,
          'availableNumbers': [4, 7, 10],
          'targetRem': 1,
        },
        {
          'title': 'चरण 2: मोडुलो 3',
          'theory':
              "अब भाजक को 3 में बदलते हैं। इसे 'मोडुलो 3' या 'Mod 3' कहा जाता है।\n\nजब आप किसी भी संख्या को 3 से विभाजित करते हैं, तो एकमात्र संभावित शेषफल 0, 1 या 2 होते हैं।\n\nउदाहरण के लिए, 10 ÷ 3 = 3 और 1 शेष है। इसलिए, 10 ≡ 1 (mod 3)।",
          'hudTitle': 'Mod 3 लक्ष्य',
          'hudInstruction':
              "वह संख्या ज्ञात कीजिए जिसे 3 से विभाजित करने पर 2 शेष बचता है।",
          'modValue': 3,
          'availableNumbers': [9, 11, 13],
          'targetRem': 2,
        },
        {
          'title': 'चरण 3: मोडुलो 5',
          'theory':
              "आइए मोडुलो को 5 तक बढ़ाएं।\n\nनियम सार्वभौमिक है: यदि हम 'Mod N' में काम कर रहे हैं, तो संभावित शेष हमेशा N से सख्ती से कम होते हैं (0 से N-1 तक)।\n\nMod 5 के लिए, शेषफल केवल 0, 1, 2, 3 या 4 हो सकते हैं।",
          'hudTitle': 'Mod 5 पहेली',
          'hudInstruction':
              "उस संख्या को खींचें जिसे 5 से विभाजित करने पर 4 शेष बचता है।",
          'modValue': 5,
          'availableNumbers': [15, 18, 24],
          'targetRem': 4,
        },
        {
          'title': 'चरण 4: वास्तविक दुनिया मोडुलो',
          'theory':
              "हम हर दिन मॉड्यूलर अंकगणित का उपयोग करते हैं! 12 घंटे की घड़ी के बारे में सोचें।\n\nअगर सुबह 10:00 बजे हैं, तो 5 घंटे में क्या समय होगा? 10 + 5 = 15। लेकिन घड़ियाँ 12 के बाद फिर से शुरू हो जाती हैं।\n\nहम 15 को 12 से विभाजित करते हैं, और शेषफल 3 होता है। तो दोपहर के 3:00 बजे हैं! घड़ियाँ पूरी तरह से 'मोडुलो 12' पर काम करती हैं।",
          'hudTitle': 'घड़ी गणित (Mod 12)',
          'hudInstruction':
              "8 बज चुके हैं। 10 घंटे जोड़ें। क्या समय हुआ है? (मोडुलो 12 शेषफल ज्ञात करें)",
          'modValue': 12,
          'availableNumbers': [18, 14, 20],
          'targetRem': 6,
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
      _droppedBaseNumber = null;
      _calculatedRemainder = null;
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

  void _handleNumberDrop(int number) {
    if (_interactionCompleted) return;

    int modValue = currentScenario['modValue'] as int? ?? 1;
    int targetRem = currentScenario['targetRem'] as int? ?? 0;

    int remainder = number % modValue;

    setState(() {
      _droppedBaseNumber = number;
      _calculatedRemainder = remainder;
    });

    if (remainder == targetRem) {
      _showFeedback(_getString('toastSuccess'), true);
    } else {
      _showFeedback(
        "${_getString('toastError')} (Got Remainder $remainder)",
        false,
      );
      // Auto-clear error and reset drop after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && !_interactionCompleted) {
          setState(() {
            _feedbackMessage = null;
            _droppedBaseNumber = null;
            _calculatedRemainder = null;
          });
        }
      });
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
            : Icons.lock,
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

  Widget _buildInteractiveCanvas() {
    List<int> availableNumbers = List<int>.from(
      currentScenario['availableNumbers'] ?? [],
    );
    int modValue = currentScenario['modValue'] as int? ?? 1;

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
              // 2D Canvas Background Painter (Grid and Platforms)
              CustomPaint(
                size: Size.infinite,
                painter: ModularPlatformPainter(isDark: _isDarkTheme),
              ),

              // Drag Target (The Modular Machine)
              Positioned(
                left: centerX - 90,
                top: centerY - 20, // Sit nicely on the isometric base
                child: DragTarget<int>(
                  builder: (context, candidateData, rejectedData) {
                    bool isHovered = candidateData.isNotEmpty;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 180,
                      height: 140,
                      decoration: BoxDecoration(
                        color: isHovered
                            ? Colors.greenAccent.withOpacity(0.3)
                            : (_isDarkTheme
                                  ? Colors.blue.withOpacity(0.2)
                                  : Colors.blue.withOpacity(0.1)),
                        border: Border.all(
                          color: isHovered
                              ? Colors.greenAccent
                              : Colors.blueAccent,
                          width: isHovered ? 4 : 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isHovered
                            ? [
                                BoxShadow(
                                  color: Colors.greenAccent.withOpacity(0.4),
                                  blurRadius: 20,
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${_getLabel('modPrefix')} $modValue",
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (_droppedBaseNumber != null) ...[
                            Text(
                              "$_droppedBaseNumber",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${_getLabel('remPrefix')}: $_calculatedRemainder",
                              style: TextStyle(
                                color: _interactionCompleted
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ] else
                            Text(
                              _getLabel('dragTarget'),
                              style: TextStyle(color: textMuted, fontSize: 12),
                            ),
                        ],
                      ),
                    );
                  },
                  onAccept: (data) => _handleNumberDrop(data),
                ),
              ),

              // Draggable Numbers (Floating above)
              if (!_interactionCompleted)
                ...List.generate(availableNumbers.length, (index) {
                  int number = availableNumbers[index];
                  // Distribute horizontally
                  double xOffset = (index - 1) * 120.0;
                  return Positioned(
                    top: centerY - 160,
                    left:
                        centerX +
                        xOffset -
                        40, // Center alignment relative to point
                    child: Draggable<int>(
                      data: number,
                      feedback: _buildDraggableCube(number, isDragging: true),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: _buildDraggableCube(number),
                      ),
                      child: _buildDraggableCube(number),
                    ),
                  );
                }),

              // Equation Overlay on Success
              if (_interactionCompleted && _droppedBaseNumber != null)
                Positioned(
                  top: centerY - 200,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      border: Border.all(color: Colors.greenAccent, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "$_droppedBaseNumber ≡ $_calculatedRemainder (mod $modValue)",
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 28,
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

  Widget _buildDraggableCube(int number, {bool isDragging = false}) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: isDragging
              ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.8),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ]
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
            colors: [Colors.amberAccent, Colors.orange],
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          "$number",
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
                    maxWidth: 500,
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
class ModularPlatformPainter extends CustomPainter {
  final bool isDark;

  ModularPlatformPainter({required this.isDark});

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

    // Draw the "Platform" aesthetic (isometric base illusion)
    Path platform = Path()
      ..moveTo(center.dx - 200, center.dy + 80)
      ..lineTo(center.dx + 200, center.dy + 80)
      ..lineTo(center.dx + 220, center.dy + 150)
      ..lineTo(center.dx - 220, center.dy + 150)
      ..close();

    canvas.drawPath(platform, Paint()..color = Colors.blue.withOpacity(0.05));
    canvas.drawPath(
      platform,
      Paint()
        ..color = Colors.blueAccent.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Aesthetic "Machine Connectors"
    canvas.drawLine(
      center + const Offset(-50, -20),
      center + const Offset(-50, 80),
      Paint()
        ..color = Colors.white24
        ..strokeWidth = 4,
    );
    canvas.drawLine(
      center + const Offset(50, -20),
      center + const Offset(50, 80),
      Paint()
        ..color = Colors.white24
        ..strokeWidth = 4,
    );
  }

  @override
  bool shouldRepaint(covariant ModularPlatformPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
