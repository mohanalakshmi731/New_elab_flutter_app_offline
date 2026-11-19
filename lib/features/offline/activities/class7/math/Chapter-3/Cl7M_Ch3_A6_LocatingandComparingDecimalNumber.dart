// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'ZSL Virtual Lab | The Decimal Magnifier',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617), // slate-950
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFEAB308), // yellow-500
          secondary: Color(0xFF3B82F6), // blue-500
          surface: Color(0xFF0F172A), // slate-900
          background: Color(0xFF020617),
        ),
        fontFamily: 'Roboto',
      ),
      home: const LocatingandComparingDecimalNumber(),
    ),
  );
}

// --- DATA MODELS ---

class StepConfig {
  final String mode; // "click_segment", "drag_pin", "done"
  final double start;
  final double end;
  final double step;
  final double? targetStart;
  final double? targetEnd;
  final double? targetValue;

  StepConfig({
    required this.mode,
    required this.start,
    required this.end,
    required this.step,
    this.targetStart,
    this.targetEnd,
    this.targetValue,
  });
}

class ScenarioConfig {
  final int id;
  final List<StepConfig> steps;
  ScenarioConfig({required this.id, required this.steps});
}

// --- MAIN WIDGET ---

class LocatingandComparingDecimalNumber extends StatefulWidget {
  const LocatingandComparingDecimalNumber({super.key});

  @override
  State<LocatingandComparingDecimalNumber> createState() =>
      _LocatingandComparingDecimalNumberState();
}

class _LocatingandComparingDecimalNumberState
    extends State<LocatingandComparingDecimalNumber>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isSidebarOpen = true;
  String _language = 'en';
  bool _isShutterOpen = true;
  bool _showSummary = false;

  int _activeScenarioId = 0;
  int _currentStep = 0;

  // Interaction states
  double _pinPositionRatio = 0.0; // 0.0 to 1.0 relative to segment
  bool _isDragging = false;
  bool _isValidated = false;

  final double canvasWidth = 1200.0;
  final double canvasHeight = 400.0;

  // Sound URLs (Mixkit)
  final String soundEnter =
      'audio/class7/mixkit_2568.mp3';
  final String soundClick =
      'audio/class7/mixkit_2568.mp3';
  final String soundSnap =
      'audio/class7/mixkit_2570.mp3';
  final String soundSuccess =
      'audio/class7/mixkit_2018.mp3';
  final String soundError =
      'audio/class7/mixkit_2955.mp3';

  // Scenarios Configurations
  late List<ScenarioConfig> scenariosConfig;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    scenariosConfig = [
      ScenarioConfig(
        id: 0,
        steps: [
          StepConfig(
            mode: "click_segment",
            start: 0,
            end: 5,
            step: 1,
            targetStart: 1,
            targetEnd: 2,
          ),
          StepConfig(
            mode: "drag_pin",
            start: 1,
            end: 2,
            step: 0.1,
            targetValue: 1.4,
          ),
          StepConfig(
            mode: "done",
            start: 1,
            end: 2,
            step: 0.1,
            targetStart: 1,
            targetEnd: 1.4,
          ), // Using targetStart/End for highlight
        ],
      ),
      ScenarioConfig(
        id: 1,
        steps: [
          StepConfig(
            mode: "click_segment",
            start: 0,
            end: 10,
            step: 1,
            targetStart: 4,
            targetEnd: 5,
          ),
          StepConfig(
            mode: "click_segment",
            start: 4,
            end: 5,
            step: 0.1,
            targetStart: 4.1,
            targetEnd: 4.2,
          ),
          StepConfig(
            mode: "drag_pin",
            start: 4.1,
            end: 4.2,
            step: 0.01,
            targetValue: 4.18,
          ),
          StepConfig(
            mode: "done",
            start: 4.1,
            end: 4.2,
            step: 0.01,
            targetStart: 4.1,
            targetEnd: 4.18,
          ),
        ],
      ),
    ];
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playSound(String url) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  void _showToast(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 20, left: 50, right: 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _enterLab() {
    _playSound(soundEnter);
    setState(() {
      _isShutterOpen = false;
    });
  }

  void _toggleLanguage() {
    _playSound(soundClick);
    setState(() {
      _language = _language == 'en' ? 'hi' : 'en';
    });
  }

  void _resetActivity() {
    _playSound(soundClick);
    setState(() {
      _isShutterOpen = true;
      _activeScenarioId = 0;
      _currentStep = 0;
      _isValidated = false;
      _pinPositionRatio = 0.0;
      _showSummary = false;
    });
  }

  void _loadScenario(int id) {
    _playSound(soundClick);
    setState(() {
      _activeScenarioId = id;
      _currentStep = 0;
      _isValidated = false;
      _pinPositionRatio = 0.0;
    });
  }

  void _advanceStep(bool isDragSuccess) {
    if (_currentStep < scenariosConfig[_activeScenarioId].steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _validateClick(double tappedValue) {
    final stepConfig = scenariosConfig[_activeScenarioId].steps[_currentStep];
    if (stepConfig.targetStart == null || stepConfig.targetEnd == null) return;

    if (tappedValue >= stepConfig.targetStart! - 0.01 &&
        tappedValue <= stepConfig.targetEnd! + 0.01) {
      _playSound(soundSuccess);
      _showToast(_t('correctSegment'), Colors.green);
      _advanceStep(false);
    } else {
      _playSound(soundError);
      // Find which segment was actually clicked
      double segmentStart =
          (tappedValue / stepConfig.step).floor() * stepConfig.step;
      double segmentEnd = segmentStart + stepConfig.step;
      _showToast(
        _t('lookClosely')
            .replaceAll('{s}', segmentStart.toStringAsFixed(1))
            .replaceAll('{e}', segmentEnd.toStringAsFixed(1)),
        Colors.red,
      );
    }
  }

  void _validateDrag() {
    final stepConfig = scenariosConfig[_activeScenarioId].steps[_currentStep];
    if (stepConfig.targetValue == null) return;

    final double currentVal =
        stepConfig.start +
        (_pinPositionRatio * (stepConfig.end - stepConfig.start));
    final double diff = (currentVal - stepConfig.targetValue!).abs();

    // Tolerance
    if (diff < (stepConfig.step * 0.3)) {
      setState(() {
        // Snap to target
        _pinPositionRatio =
            (stepConfig.targetValue! - stepConfig.start) /
            (stepConfig.end - stepConfig.start);
      });
      _playSound(soundSnap);
      _showToast(_t('targetAcquired'), Colors.green);
      Future.delayed(const Duration(milliseconds: 800), () {
        _advanceStep(true);
      });
    } else {
      _playSound(soundError);
      _showToast(_t('tryAgain'), Colors.red);
    }
  }

  // --- LOCALIZATION ---
  String _t(String key) {
    return _translations[_language]?[key] ?? _translations['en']?[key] ?? key;
  }

  String _getScenarioTitle(int idx) {
    return _translations[_language]?['scenarios'][idx]['title'] ?? '';
  }

  Map<String, dynamic> _getScenarioData() {
    return _translations[_language]?['scenarios'][_activeScenarioId];
  }

  final Map<String, dynamic> _translations = {
    'en': {
      'appTitle': 'The Decimal Magnifier',
      'appSubtitle': 'Class 7 • A PEEK BEYOND THE POINT',
      'enterLab': 'Enter Lab',
      'headerTitle': 'The Decimal Magnifier',
      'selectScenario': 'Select Scenario',
      'theoryHead': 'Theory',
      'proceduralHead': 'Procedural Steps',
      'stepText': 'Step',
      'missionObjective': 'Mission Objective',
      'actionRequired': 'Action Required',
      'scenarioComplete': 'Scenario Complete',
      'validateModel': 'Validate Model',
      'convertUnits': 'Convert Units',
      'hudTaskComplete':
          'Task Complete! Select the next scenario from the sidebar.',
      'hudClickValidate': 'Click "Validate Model" to check your work.',
      'summaryTitle': 'Investigation Summary',
      'correctSegment': 'Correct Segment! Zooming in...',
      'lookClosely': 'Oops! That\'s between {s} and {e}. Look closely!',
      'targetAcquired': 'Target Acquired!',
      'tryAgain': 'Not quite there. Try again.',
      'scenarios': [
        {
          'title': '1. Pinpointing the Tenths',
          'theoryTitle': 'Understanding Tenths:',
          'theory':
              'The space between whole numbers on a number line holds decimals. Moving one step right in a magnified segment equals adding one tenth (0.1).',
          'steps': [
            {
              'text':
                  'A number line from 0 to 5 is displayed. Find 1.4 by CLICKING on the segment where you think 1.4 is located.',
              'hud': 'Click the segment between 1 and 2.',
            },
            {
              'text':
                  'A target has appeared at 1.4 on the tenths line. DRAG the blue pin and DROP it onto the target.',
              'hud': 'Drag the pin to 1.4',
            },
            {
              'text':
                  'Notice how decimals help us represent precise values between whole numbers. This is just like finding 1.4cm on a ruler!',
              'hud': 'Task Complete! Proceed to next scenario.',
              'summaryText':
                  'Well done! 1.4 is located 4 "tenths" of the way from 1 to 2.\n\nThe visual clearly shows the 4 steps (0.1 each) from 1.0.',
            },
          ],
        },
        {
          'title': '2. The Hundredths Deep Dive',
          'theoryTitle': 'Zooming into Hundredths:',
          'theory':
              'We can perform a double zoom to find incredibly precise values. The space between tenths (e.g., 4.1 and 4.2) holds hundredths (0.01).',
          'steps': [
            {
              'text':
                  'Let\'s find 4.18. First, CLICK the segment between the correct whole numbers (4 and 5).',
              'hud': 'Click the segment between 4 and 5.',
            },
            {
              'text':
                  'To find 4.18, look closely at the tenths. CLICK on the segment where 4.18 must be (between 4.1 and 4.2).',
              'hud': 'Click the segment between 4.1 and 4.2',
            },
            {
              'text':
                  'You\'ve reached the "hundredths" place! DRAG the green pin and DROP it onto the target marked 4.18.',
              'hud': 'Drag the pin to 4.18',
            },
            {
              'text':
                  'Excellent! 4.18 is 1 tenth and 8 hundredths past 4. This precision is used in deciding split-second race winners!',
              'hud': 'Investigation Complete!',
              'summaryText':
                  'Excellent! 4.18 is 1 tenth and 8 hundredths past 4.',
            },
          ],
        },
      ],
    },
    'hi': {
      'appTitle': 'दशमलव आवर्धक',
      'appSubtitle': 'कक्षा 7 • बिंदु के पार एक झलक',
      'enterLab': 'प्रयोगशाला में प्रवेश करें',
      'headerTitle': 'दशमलव आवर्धक',
      'selectScenario': 'परिदृश्य चुनें',
      'theoryHead': 'सिद्धांत',
      'proceduralHead': 'प्रक्रियात्मक चरण',
      'stepText': 'चरण',
      'missionObjective': 'मिशन का उद्देश्य',
      'actionRequired': 'कार्रवाई आवश्यक है',
      'scenarioComplete': 'परिदृश्य पूरा हुआ',
      'validateModel': 'मॉडल मान्य करें',
      'convertUnits': 'इकाइयों को बदलें',
      'hudTaskComplete': 'कार्य पूरा हुआ! साइडबार से अगला परिदृश्य चुनें।',
      'hudClickValidate':
          'अपने काम की जांच करने के लिए "मॉडल मान्य करें" पर क्लिक करें।',
      'summaryTitle': 'जांच सारांश',
      'correctSegment': 'सही खंड! ज़ूम इन कर रहा है...',
      'lookClosely': 'ऊप्स! यह {s} और {e} के बीच है। ध्यान से देखें!',
      'targetAcquired': 'लक्ष्य प्राप्त हुआ!',
      'tryAgain': 'वहाँ तक नहीं। पुनः प्रयास करें।',
      'scenarios': [
        {
          'title': '1. दसवें हिस्से को इंगित करना',
          'theoryTitle': 'दसवें हिस्से को समझना:',
          'theory':
              'संख्या रेखा पर पूर्ण संख्याओं के बीच का स्थान दशमलव रखता है। आवर्धित खंड में एक कदम दाएँ जाने का अर्थ है एक दसवाँ (0.1) जोड़ना।',
          'steps': [
            {
              'text':
                  '0 से 5 तक की संख्या रेखा प्रदर्शित है। 1.4 खोजने के लिए उस खंड पर क्लिक करें जहाँ आपको लगता है कि 1.4 स्थित है।',
              'hud': '1 और 2 के बीच के खंड पर क्लिक करें।',
            },
            {
              'text':
                  'दसवें की रेखा पर 1.4 पर एक लक्ष्य प्रकट हुआ है। नीले पिन को खींचें और लक्ष्य पर छोड़ दें।',
              'hud': 'पिन को 1.4 पर खींचें',
            },
            {
              'text':
                  'ध्यान दें कि दशमलव हमें पूर्ण संख्याओं के बीच सटीक मान दर्शाने में कैसे मदद करते हैं।',
              'hud': 'कार्य पूरा हुआ! अगले परिदृश्य पर जाएँ।',
              'summaryText':
                  'बहुत बढ़िया! 1.4, 1 से 2 के बीच 4 "दसवें" हिस्से पर स्थित है।\n\nदृश्य स्पष्ट रूप से 1.0 से 4 कदम (प्रत्येक 0.1) दिखाता है।',
            },
          ],
        },
        {
          'title': '2. सौवें हिस्से में गहराई से जाना',
          'theoryTitle': 'सौवें हिस्से में ज़ूम करना:',
          'theory':
              'हम अविश्वसनीय रूप से सटीक मान खोजने के लिए डबल ज़ूम कर सकते हैं।',
          'steps': [
            {
              'text':
                  'आइए 4.18 खोजें। सबसे पहले, सही पूर्ण संख्याओं (4 और 5) के बीच के खंड पर क्लिक करें।',
              'hud': '4 और 5 के बीच के खंड पर क्लिक करें।',
            },
            {
              'text':
                  '4.18 खोजने के लिए, दसवें हिस्से को ध्यान से देखें। उस खंड पर क्लिक करें जहाँ 4.18 होना चाहिए।',
              'hud': '4.1 और 4.2 के बीच के खंड पर क्लिक करें।',
            },
            {
              'text':
                  'आप "सौवें" स्थान पर पहुँच गए हैं! पिन को खींचें और 4.18 चिह्नित लक्ष्य पर छोड़ दें।',
              'hud': 'पिन को 4.18 पर खींचें',
            },
            {
              'text': 'बहुत बढ़िया! 4.18, 4 से 1 दसवाँ और 8 सौवाँ आगे है।',
              'hud': 'जांच पूरी हुई!',
              'summaryText':
                  'बहुत बढ़िया! 4.18, 4 से 1 दसवाँ और 8 सौवाँ आगे है।',
            },
          ],
        },
      ],
    },
  };

  // --- BUILD METHODS ---

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double sidebarWidth = screenWidth * 0.35; // Responsive sidebar width

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // 1. Adjustable Workspace Area (Canvas + HUD)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: _isSidebarOpen ? sidebarWidth : 0,
              right: 0,
              child: Stack(
                children: [
                  Positioned.fill(child: _buildInteractiveCanvas()),
                  _buildHUD(),
                ],
              ),
            ),

            // 2. Sidebar (Left aligned, 35% width, fully scrollable)
            _buildSidebar(sidebarWidth),

            // 3. Fixed Menu Button
            _buildTopLeftMenuIcon(),

            // 4. Summary Modal
            if (_showSummary) _buildSummaryModal(),

            // 5. Shutter Welcome Screen
            if (_isShutterOpen) _buildShutterScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopLeftMenuIcon() {
    return Positioned(
      top: 16,
      left: 16, // Fixed position, won't slide with sidebar
      child: IconButton(
        icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
        color: Colors.orangeAccent,
        iconSize: 28,
        onPressed: () {
          HapticFeedback.lightImpact();
          _playSound(soundClick);
          setState(() {
            _isSidebarOpen = !_isSidebarOpen;
          });
        },
        style: IconButton.styleFrom(
          backgroundColor: Colors.black.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.orange.withOpacity(0.8)),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(double sidebarWidth) {
    final scenarioData = _getScenarioData();
    final stepsData = scenarioData['steps'] as List;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: 0,
      bottom: 0,
      left: _isSidebarOpen ? 0 : -sidebarWidth,
      width: sidebarWidth,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withOpacity(0.95), // slate-900 glass
          border: const Border(right: BorderSide(color: Colors.white12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(10, 0),
            ),
          ],
        ),
        child: CustomScrollView(
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header space for menu button
                  const SizedBox(height: 60),

                  // Title & Language
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(
                                      top: 2.0,
                                      right: 8.0,
                                    ),
                                    child: Icon(
                                      Icons.science,
                                      color: Color(0xFFEAB308),
                                      size: 24,
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _t('headerTitle'),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _t('appSubtitle'),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.white70,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: _toggleLanguage,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white30),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.language,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _language.toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 98),
                            InkWell(
                              onTap: _resetActivity,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white30),
                                ),
                                child: const Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 30),
                ],
              ),
            ),

            // Scrollable Content Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t('selectScenario').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: _activeScenarioId,
                          dropdownColor: const Color(0xFF1E293B),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white54,
                          ),
                          items: List.generate(scenariosConfig.length, (index) {
                            return DropdownMenuItem<int>(
                              value: index,
                              child: Text(
                                _getScenarioTitle(index),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }),
                          onChanged: (val) {
                            if (val != null) _loadScenario(val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Theory Block
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.menu_book,
                                size: 18,
                                color: Color(0xFFEAB308),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _t('theoryHead'),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFEAB308),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            scenarioData['theoryTitle'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            scenarioData['theory'],
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        const Icon(
                          Icons.format_list_numbered,
                          size: 18,
                          color: Color(0xFFEAB308),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _t('proceduralHead'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEAB308),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Steps
                    ...List.generate(stepsData.length, (index) {
                      bool isPast = index < _currentStep;
                      bool isCurrent = index == _currentStep;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? const Color(0xFFEAB308)
                              : const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCurrent
                                ? Colors.transparent
                                : Colors.white12,
                          ),
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFEAB308,
                                    ).withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : [],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${_t('stepText')} ${index + 1}",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isCurrent
                                    ? Colors.black87
                                    : Colors.white70,
                                decoration: isPast
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              stepsData[index]['text'],
                              style: TextStyle(
                                fontSize: 13,
                                color: isCurrent ? Colors.black : Colors.white,
                                fontWeight: isCurrent
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                decoration: isPast
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Sticky/Scrollable Footer
            SliverFillRemaining(
              hasScrollBody: false,
              fillOverscroll: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.white12)),
                      color: Color(0xFF0F172A),
                    ),
                    child: Text(
                      '© ZeroScienceLab - Fall in love with math and Science',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHUD() {
    final stepConfig = scenariosConfig[_activeScenarioId].steps[_currentStep];
    final scenarioData = _getScenarioData();
    final stepsData = scenarioData['steps'] as List;
    final currentStepData = stepsData[_currentStep];

    bool isDone = stepConfig.mode == 'done';

    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HUD Message Panel
            Container(
              constraints: const BoxConstraints(maxWidth: 600),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.85),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isDone ? Colors.green : Colors.white12,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDone
                          ? Colors.green.withOpacity(0.2)
                          : const Color(0xFFEAB308).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isDone ? Icons.check_circle : Icons.info,
                      color: isDone ? Colors.green : const Color(0xFFEAB308),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isDone
                              ? (_isValidated
                                        ? _t('scenarioComplete')
                                        : _t('actionRequired'))
                                    .toUpperCase()
                              : _t('missionObjective').toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: isDone
                                ? Colors.green
                                : const Color(0xFFEAB308),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isDone
                              ? (_isValidated
                                    ? _t('hudTaskComplete')
                                    : _t('hudClickValidate'))
                              : currentStepData['hud'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Dynamic Action Buttons (Only visible when sidebar closed AND applicable)
            if (!_isSidebarOpen) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Convert Units Button
                  ElevatedButton.icon(
                    onPressed: () {
                      _playSound(soundClick);
                      _showToast(
                        "Unit Conversion is an upcoming feature!",
                        Colors.blue,
                      );
                    },
                    icon: const Icon(Icons.swap_horiz, color: Colors.white),
                    label: Text(
                      _t('convertUnits'),
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),

                  if (isDone && !_isValidated) ...[
                    const SizedBox(width: 16),
                    // Validate Model Button
                    ElevatedButton.icon(
                      onPressed: () {
                        _playSound(soundClick);
                        setState(() {
                          _showSummary = true;
                        });
                      },
                      icon: const Icon(
                        Icons.check_circle,
                        color: Colors.black87,
                      ),
                      label: Text(
                        _t('validateModel'),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEAB308),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        elevation: 8,
                        shadowColor: const Color(0xFFEAB308).withOpacity(0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ] else if (isDone && !_isValidated) ...[
              // Still show validate button if sidebar is open, but place it below HUD
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  _playSound(soundClick);
                  setState(() {
                    _showSummary = true;
                  });
                },
                icon: const Icon(Icons.check_circle, color: Colors.black87),
                label: Text(
                  _t('validateModel'),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEAB308),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  elevation: 8,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveCanvas() {
    final stepConfig = scenariosConfig[_activeScenarioId].steps[_currentStep];

    return Container(
      color: const Color(0xFF020617), // Canvas Background
      child: Center(
        child: InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(double.infinity),
          minScale: 0.2,
          maxScale: 5.0,
          constrained: false,
          child: SizedBox(
            width: canvasWidth,
            height: canvasHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Background grid (optional visual flair)
                Positioned.fill(child: CustomPaint(painter: GridPainter())),

                // 1. Number Line Custom Paint
                Positioned.fill(
                  child: GestureDetector(
                    onTapUp: (details) {
                      if (stepConfig.mode == 'click_segment') {
                        // Calculate value from local X
                        double tapX = details.localPosition.dx;
                        // Line spans from 100 to canvasWidth - 100
                        double lineStartX = 100;
                        double lineEndX = canvasWidth - 100;
                        double width = lineEndX - lineStartX;

                        if (tapX >= lineStartX && tapX <= lineEndX) {
                          double ratio = (tapX - lineStartX) / width;
                          double tappedValue =
                              stepConfig.start +
                              ratio * (stepConfig.end - stepConfig.start);
                          _validateClick(tappedValue);
                        }
                      }
                    },
                    child: CustomPaint(
                      painter: NumberLinePainter(config: stepConfig),
                    ),
                  ),
                ),

                // 2. Drag Pin
                if (stepConfig.mode == 'drag_pin' || stepConfig.mode == 'done')
                  _buildPinWidget(stepConfig),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinWidget(StepConfig config) {
    double lineStartX = 100;
    double lineEndX = canvasWidth - 100;
    double width = lineEndX - lineStartX;

    // In done mode, pin is at target
    double effectiveRatio = _pinPositionRatio;
    if (config.mode == 'done' && config.targetEnd != null) {
      effectiveRatio =
          (config.targetEnd! - config.start) / (config.end - config.start);
    } else if (config.mode == 'done' && config.targetValue != null) {
      effectiveRatio =
          (config.targetValue! - config.start) / (config.end - config.start);
    }

    double pinLeft =
        lineStartX + (effectiveRatio * width) - 30; // 30 is half pin width

    return Positioned(
      left: pinLeft,
      top: canvasHeight / 2 - 110, // Position above the line
      child: GestureDetector(
        onPanStart: (details) {
          if (config.mode == 'drag_pin') {
            setState(() {
              _isDragging = true;
            });
          }
        },
        onPanUpdate: (details) {
          if (config.mode == 'drag_pin' && _isDragging) {
            setState(() {
              // Convert drag delta back to ratio
              double deltaRatio = details.delta.dx / width;
              _pinPositionRatio += deltaRatio;
              _pinPositionRatio = _pinPositionRatio.clamp(0.0, 1.0);
            });
          }
        },
        onPanEnd: (details) {
          if (config.mode == 'drag_pin' && _isDragging) {
            setState(() {
              _isDragging = false;
            });
            _validateDrag();
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pin Body
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: config.mode == 'done' ? Colors.green : Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (config.mode == 'done' ? Colors.green : Colors.blue)
                        .withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.push_pin, color: Colors.white, size: 30),
            ),
            // Pin Stem
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    config.mode == 'done' ? Colors.green : Colors.blue,
                    Colors.white70,
                  ],
                ),
              ),
            ),
            // Pin point
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black54)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryModal() {
    final scenarioData = _getScenarioData();
    final stepsData = scenarioData['steps'] as List;
    final summaryText = stepsData.last['summaryText'] ?? _t('scenarioComplete');

    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          width: 500,
          constraints: const BoxConstraints(maxHeight: 400),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFEAB308).withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 36,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _t('summaryTitle'),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () {
                      _playSound(soundClick);
                      setState(() {
                        _showSummary = false;
                        _isValidated = true;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    summaryText
                        .replaceAll('<br><br>', '\n\n')
                        .replaceAll(
                          RegExp(r'<[^>]*>'),
                          '',
                        ), // strip any residual html tags if present
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _playSound(soundClick);
                    setState(() {
                      _showSummary = false;
                      _isValidated = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEAB308),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShutterScreen() {
    return Container(
      color: const Color(0xFF020617),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.science, size: 80, color: Color(0xFFEAB308)),
            const SizedBox(height: 24),
            Text(
              _t('appTitle'),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _t('appSubtitle'),
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white54,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: _enterLab,
              icon: const Icon(
                Icons.play_circle_fill,
                size: 28,
                color: Colors.black87,
              ),
              label: Text(
                _t('enterLab'),
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEAB308),
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                elevation: 10,
                shadowColor: const Color(0xFFEAB308).withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- CUSTOM PAINTERS ---

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NumberLinePainter extends CustomPainter {
  final StepConfig config;

  NumberLinePainter({required this.config});

  @override
  void paint(Canvas canvas, Size size) {
    double lineStartX = 100;
    double lineEndX = size.width - 100;
    double width = lineEndX - lineStartX;
    double centerY = size.height / 2;

    // Draw main line
    final linePaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(lineStartX, centerY),
      Offset(lineEndX, centerY),
      linePaint,
    );

    // Calculate ticks
    int numTicks = ((config.end - config.start) / config.step).round();

    // Draw Highlight if "done"
    if (config.mode == 'done' &&
        config.targetStart != null &&
        config.targetEnd != null) {
      double hStartX =
          lineStartX +
          ((config.targetStart! - config.start) / (config.end - config.start)) *
              width;
      double hEndX =
          lineStartX +
          ((config.targetEnd! - config.start) / (config.end - config.start)) *
              width;

      final highlightPaint = Paint()
        ..color = Colors.green.withOpacity(0.4)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(hStartX, centerY - 20, hEndX, centerY + 20),
          const Radius.circular(8),
        ),
        highlightPaint,
      );
    }

    // Draw Ticks and Labels
    final tickPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i <= numTicks; i++) {
      double val = config.start + (i * config.step);
      double xPos = lineStartX + (i / numTicks) * width;

      // Determine if major tick
      bool isMajor = false;
      double eps = 0.00001;
      if ((val % (config.step * 10)).abs() < eps ||
          ((val % (config.step * 10)) - (config.step * 10)).abs() < eps) {
        isMajor = true;
      }
      if (i == 0 || i == numTicks) isMajor = true;

      double tickHeight = isMajor ? 30 : 15;

      canvas.drawLine(
        Offset(xPos, centerY - tickHeight),
        Offset(xPos, centerY + tickHeight),
        tickPaint,
      );

      // Label
      int decimals = 0;
      if (config.step < 1) decimals = 1;
      if (config.step < 0.1) decimals = 2;

      final textSpan = TextSpan(
        text: val.toStringAsFixed(decimals),
        style: TextStyle(
          color: Colors.white,
          fontSize: isMajor ? 24 : 16,
          fontWeight: isMajor ? FontWeight.bold : FontWeight.w500,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(xPos - textPainter.width / 2, centerY + tickHeight + 10),
      );
    }

    // Draw Target Marker if drag_pin
    if (config.mode == 'drag_pin' && config.targetValue != null) {
      double targetX =
          lineStartX +
          ((config.targetValue! - config.start) / (config.end - config.start)) *
              width;

      final targetPaint = Paint()
        ..color = Colors.redAccent.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;

      canvas.drawCircle(Offset(targetX, centerY), 20, targetPaint);

      final innerPaint = Paint()
        ..color = Colors.redAccent.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(targetX, centerY), 18, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant NumberLinePainter oldDelegate) {
    return oldDelegate.config != config;
  }
}
