// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const DecimalPlaceValueSystemApp());
}

// --- Sound Manager ---
class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  // Three separate players so sounds never interrupt each other
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

  // 1. Play a standard click sound (Clean pop)
  Future<void> playClick() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(
      AssetSource(
        'audio/class7/mixkit_2073.mp3',
      ),
    );
  }

  // 2. Play a sound when a new page opens (Swoosh/Chime)
  Future<void> playPageOpen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(
      AssetSource(
        'audio/class7/gotitem.mp3',
      ),
    );
  }

  // 3. Play the Dropdown sound (Using your specific Mixkit sound!)
  Future<void> playDropdown() async {
    await _dropdownPlayer.stop();
    await _dropdownPlayer.play(
      AssetSource(
        'audio/class7/mixkit_1491.mp3',
      ),
    );
  }

  // 4. Play an error sound (Soft thud)
  Future<void> playError() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(
      AssetSource(
        'audio/class7/mixkit_946.mp3',
      ),
    );
  }

  Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(
      AssetSource(
        'audio/class7/mixkit_2574.mp3',
      ),
    );
  }

  void dispose() {
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();
  }
}
// --------------------

class DecimalPlaceValueSystemApp extends StatelessWidget {
  const DecimalPlaceValueSystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Decimal Factory',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: Colors.orangeAccent,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      home: const DecimalPlaceValueSystem(),
    );
  }
}

class BlockData {
  final String type; // 'unit', 'tenth', 'hundredth'
  final String source;
  BlockData(this.type, this.source);
}

class StepLogic {
  final String text;
  final String actionTarget;
  final String actionType;
  final int countReq;
  final int tenthsReq;
  final int hundredthsReq;

  StepLogic({
    required this.text,
    required this.actionTarget,
    required this.actionType,
    this.countReq = 0,
    this.tenthsReq = 0,
    this.hundredthsReq = 0,
  });
}

class Scenario {
  final String title;
  final String objective;
  final List<StepLogic> steps;
  final String conclusion;

  Scenario({
    required this.title,
    required this.objective,
    required this.steps,
    required this.conclusion,
  });
}

class DecimalPlaceValueSystem extends StatefulWidget {
  const DecimalPlaceValueSystem({super.key});

  @override
  State<DecimalPlaceValueSystem> createState() =>
      _DecimalPlaceValueSystemState();
}

class _DecimalPlaceValueSystemState extends State<DecimalPlaceValueSystem>
    with TickerProviderStateMixin {
  bool _isSidebarOpen = true;
  bool _showShutter = true;
  String _currentLang = 'EN';

  // Game State
  int _scenarioIndex = 0;
  int _stepIndex = 0;
  bool _isMachineProcessing = false;

  final List<String> _bin = [];
  final List<String> _machine = [];
  final List<String> _output = [];
  final List<String> _matUnits = [];
  final List<String> _matTenths = [];
  final List<String> _matHundredths = [];

  late List<Scenario> scenarios;

  // I18N Dictionary
  final Map<String, Map<String, String>> _i18n = {
    'EN': {
      'title': "The Decimal Factory: Building Numbers Beyond the Point",
      'subtitle': "Class 7 • A PEEK BEYOND THE POINT",
      'enterLab': "Enter Lab",
      'blocksBin': "BLOCKS BIN",
      'slicerMachine': "SLICER MACHINE",
      'grinderMachine': "GRINDER MACHINE",
      'outputTray': "OUTPUT TRAY",
      'units': "UNITS",
      'tenths': "TENTHS",
      'hundredths': "HUNDREDTHS",
      'start': "START",
      'processing': "PROCESSING...",
      'idle': "IDLE",
      'missionObjective': "Mission Objective",
      'proceduralSteps': "Procedural Steps",
      'currentTask': "Current Task",
      'allCompleted': "All steps completed!",
      'exchange': "EXCHANGE",
      'scenarioCompleted': "Scenario Completed!",
      'continueBtn': "Continue",
    },
    'HI': {
      'title': "दशमलव फ़ैक्टरी: बिंदु के पार संख्याएँ बनाना",
      'subtitle': "कक्षा 7 • बिंदु के पार एक झलक",
      'enterLab': "लैब में प्रवेश करें",
      'blocksBin': "ब्लॉक बिन",
      'slicerMachine': "स्लाइसर मशीन",
      'grinderMachine': "ग्राइंडर मशीन",
      'outputTray': "आउटपुट ट्रे",
      'units': "इकाइयाँ",
      'tenths': "दसवें हिस्से",
      'hundredths': "सौवें हिस्से",
      'start': "प्रारंभ",
      'processing': "प्रसंस्करण...",
      'idle': "निष्क्रिय",
      'missionObjective': "मिशन का उद्देश्य",
      'proceduralSteps': "प्रक्रियात्मक चरण",
      'currentTask': "वर्तमान कार्य",
      'allCompleted': "सभी चरण पूर्ण!",
      'exchange': "बदलें",
      'scenarioCompleted': "परिदृश्य पूर्ण हुआ!",
      'continueBtn': "जारी रखें",
    },
  };

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _initScenarios();
    _loadScenario(0);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SoundManager().dispose(); // Dispose the players
    super.dispose();
  }

  void _toggleLanguage() {
    SoundManager().playClick(); // Audio feedback
    setState(() {
      if (_currentLang == 'EN') {
        _currentLang = 'HI';
      } else {
        _currentLang = 'EN';
      }
      _initScenarios();
    });
  }

  void _resetLab() {
    SoundManager().playClick(); // Audio feedback
    setState(() {
      _showShutter = true;
      _initScenarios();
      _loadScenario(0);
    });
  }

  void _initScenarios() {
    if (_currentLang == 'EN') {
      scenarios = [
        Scenario(
          title: "Scenario 1: The Tenths Slicer",
          objective:
              "Understand that one whole unit can be divided into 10 equal tenths and learn decimal notation.",
          steps: [
            StepLogic(
              text:
                  "DRAG a 'Unit Cube' from the Bin and DROP it onto the Slicer Machine.",
              actionTarget: 'machine',
              actionType: 'drop_cube',
            ),
            StepLogic(
              text:
                  "CLICK the green 'START' button to slice the Unit into 10 Tenths.",
              actionTarget: 'btn_start',
              actionType: 'click',
            ),
            StepLogic(
              text:
                  "DRAG one 'Tenth Slab' onto the 'Tenths' column of the Mat.",
              actionTarget: 'tenths',
              actionType: 'drop_slab',
              countReq: 1,
            ),
            StepLogic(
              text: "DRAG three more 'Tenth Slabs' to stack them (total 4).",
              actionTarget: 'tenths',
              actionType: 'drop_slab',
              countReq: 4,
            ),
            StepLogic(
              text:
                  "Add slabs until you have 10. They will merge back into 1 Unit!",
              actionTarget: 'tenths',
              actionType: 'drop_slab',
              countReq: 10,
            ),
          ],
          conclusion:
              "Awesome! You have successfully divided 1 Unit into 10 equal parts. 10 Tenths = 1 Whole (1.0)!",
        ),
        Scenario(
          title: "Scenario 2: The Hundredths Grinder",
          objective:
              "Understand that a 'tenth' can be divided into 10 'hundredths'.",
          steps: [
            StepLogic(
              text:
                  "DRAG a 'Tenth Slab' from the Bin and DROP it onto the Grinder Machine.",
              actionTarget: 'machine',
              actionType: 'drop_slab',
            ),
            StepLogic(
              text:
                  "CLICK the 'START' button to cut the slab into 10 Hundredth Rods.",
              actionTarget: 'btn_start',
              actionType: 'click',
            ),
            StepLogic(
              text:
                  "DRAG ONE 'Hundredth Rod' to the 'Hundredths' column of the Mat.",
              actionTarget: 'hundredths',
              actionType: 'drop_rod',
              countReq: 1,
            ),
            StepLogic(
              text: "Build 0.25: Place 2 Tenth Slabs and 5 Hundredth Rods.",
              actionTarget: 'mat_multi',
              actionType: 'drop_mixed',
              tenthsReq: 2,
              hundredthsReq: 5,
            ),
            StepLogic(
              text: "CLICK the 'EXCHANGE' button over the Tenths on the mat.",
              actionTarget: 'btn_exchange',
              actionType: 'click',
            ),
          ],
          conclusion:
              "Brilliant! You built the decimal number 0.25. This proves that 0.25 is 2 Tenths and 5 Hundredths!",
        ),
      ];
    } else if (_currentLang == 'HI') {
      scenarios = [
        Scenario(
          title: "परिदृश्य 1: दसवें हिस्से का स्लाइसर",
          objective:
              "समझें कि एक पूर्ण इकाई को 10 समान दसवें हिस्सों में कैसे बांटा जाता है।",
          steps: [
            StepLogic(
              text:
                  "बड़े नीले 'यूनिट क्यूब' को बिन से खींचें और इसे स्लाइसर मशीन पर छोड़ें।",
              actionTarget: 'machine',
              actionType: 'drop_cube',
            ),
            StepLogic(
              text:
                  "हरे 'प्रारंभ' बटन पर क्लिक करें। मशीन 1 यूनिट को 10 दसवें हिस्से में काट देगी।",
              actionTarget: 'btn_start',
              actionType: 'click',
            ),
            StepLogic(
              text:
                  "एक 'दसवें हिस्से के स्लैब' को मैट के 'दसवें हिस्से' कॉलम पर खींचें।",
              actionTarget: 'tenths',
              actionType: 'drop_slab',
              countReq: 1,
            ),
            StepLogic(
              text: "तीन और 'दसवें हिस्से के स्लैब' खींचकर स्टैक करें (कुल 4)।",
              actionTarget: 'tenths',
              actionType: 'drop_slab',
              countReq: 4,
            ),
            StepLogic(
              text:
                  "जब तक 10 स्लैब न हो जाएं तब तक जोड़ें। वे वापस 1 यूनिट बन जाएंगे!",
              actionTarget: 'tenths',
              actionType: 'drop_slab',
              countReq: 10,
            ),
          ],
          conclusion:
              "बहुत बढ़िया! आपने सफलतापूर्वक 1 इकाई को 10 भागों में बांटा है। 10 दसवें हिस्से = 1 पूर्ण (1.0)!",
        ),
        Scenario(
          title: "परिदृश्य 2: सौवें हिस्से का ग्राइंडर",
          objective:
              "समझें कि एक 'दसवें हिस्से' को 10 'सौवें हिस्सों' में विभाजित किया जा सकता है।",
          steps: [
            StepLogic(
              text:
                  "बिन से एक 'दसवें हिस्से के स्लैब' को खींचकर ग्राइंडर मशीन पर छोड़ें।",
              actionTarget: 'machine',
              actionType: 'drop_slab',
            ),
            StepLogic(
              text:
                  "'प्रारंभ' बटन पर क्लिक करें। मशीन स्लैब को 10 सौवें हिस्से में काट देगी।",
              actionTarget: 'btn_start',
              actionType: 'click',
            ),
            StepLogic(
              text:
                  "एक 'सौवें हिस्से' को मैट के 'सौवें हिस्से' कॉलम पर खींचें।",
              actionTarget: 'hundredths',
              actionType: 'drop_rod',
              countReq: 1,
            ),
            StepLogic(
              text: "0.25 बनाएं: 2 दसवें हिस्से और 5 सौवें हिस्से रखें।",
              actionTarget: 'mat_multi',
              actionType: 'drop_mixed',
              tenthsReq: 2,
              hundredthsReq: 5,
            ),
            StepLogic(
              text: "मैट पर दसवें हिस्से के ऊपर 'बदलें' बटन पर क्लिक करें।",
              actionTarget: 'btn_exchange',
              actionType: 'click',
            ),
          ],
          conclusion:
              "अद्भुत! आपने 0.25 दशमलव संख्या बनाई। यह 2 दसवें और 5 सौवें हिस्सों से बनी है!",
        ),
      ];
    }
  }

  void _loadScenario(int index) {
    setState(() {
      _scenarioIndex = index;
      _stepIndex = 0;
      _bin.clear();
      _machine.clear();
      _output.clear();
      _matUnits.clear();
      _matTenths.clear();
      _matHundredths.clear();

      if (index == 0) {
        _bin.addAll(['unit', 'unit', 'unit']);
      } else {
        _bin.addAll(['tenth', 'tenth', 'tenth', 'tenth']);
      }
    });
  }

  void _checkStepCompletion() {
    if (_stepIndex >= scenarios[_scenarioIndex].steps.length) return;

    final step = scenarios[_scenarioIndex].steps[_stepIndex];
    bool completed = false;

    if (step.actionType == 'drop_cube' && _machine.contains('unit')) {
      completed = true;
    } else if (step.actionType == 'drop_slab' &&
        step.actionTarget == 'machine' &&
        _machine.contains('tenth')) {
      completed = true;
    } else if (step.actionType == 'drop_slab' &&
        step.actionTarget == 'tenths' &&
        _matTenths.length >= step.countReq) {
      completed = true;
      if (_matTenths.length == 10) _triggerMergeAnimation();
    } else if (step.actionType == 'drop_rod' &&
        step.actionTarget == 'hundredths' &&
        _matHundredths.length >= step.countReq) {
      completed = true;
    } else if (step.actionType == 'drop_mixed' &&
        _matTenths.length == step.tenthsReq &&
        _matHundredths.length == step.hundredthsReq) {
      completed = true;
    } else if (step.actionType == 'click') {
      completed = true;
    }

    if (completed) {
      setState(() {
        _stepIndex++;
      });
      if (_stepIndex >= scenarios[_scenarioIndex].steps.length) {
        _showSuccessPopup();
      }
    }
  }

  void _processMachine() {
    if (_machine.isEmpty) return;
    
    SoundManager().playClick(); // Audio feedback for starting machine
    setState(() => _isMachineProcessing = true);

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        String input = _machine.removeLast();
        String outputType = input == 'unit' ? 'tenth' : 'hundredth';
        for (int i = 0; i < 10; i++) {
          _output.add(outputType);
        }
        _isMachineProcessing = false;
      });
      if (scenarios[_scenarioIndex].steps[_stepIndex].actionTarget ==
          'btn_start') {
        _checkStepCompletion();
      }
    });
  }

  void _triggerMergeAnimation() {
    setState(() {
      _matTenths.clear();
      _matUnits.add('unit');
    });
    _checkStepCompletion();
  }

  void _handleExchange() {
    if (_matTenths.isEmpty) return;

    SoundManager().playClick(); // Audio feedback for exchange
    setState(() {
      _matTenths.removeLast();
      for (int i = 0; i < 10; i++) {
        _matHundredths.add('hundredth');
      }
    });
    if (scenarios[_scenarioIndex].steps[_stepIndex].actionTarget ==
        'btn_exchange') {
      _checkStepCompletion();
    }
  }

  void _onAcceptDrop(BlockData data, String target) {
    SoundManager().playClick(); // Tactile audio feedback on successful drop
    setState(() {
      // Remove from source
      if (data.source == 'bin') {
        _bin.remove(data.type);
      } else if (data.source == 'output') {
        _output.remove(data.type);
      } else if (data.source == 'mat_units') {
        _matUnits.remove(data.type);
      } else if (data.source == 'mat_tenths') {
        _matTenths.remove(data.type);
      } else if (data.source == 'mat_hundredths') {
        _matHundredths.remove(data.type);
      }

      // Add to target
      if (target == 'machine') {
        _machine.add(data.type);
      } else if (target == 'mat_units') {
        _matUnits.add(data.type);
      } else if (target == 'mat_tenths') {
        _matTenths.add(data.type);
      } else if (target == 'mat_hundredths') {
        _matHundredths.add(data.type);
      } else if (target == 'bin') {
        _bin.add(data.type);
      }
    });
    _checkStepCompletion();
  }

  void _showSuccessPopup() {
    SoundManager().playPageOpen(); // Cheerful chime for scenario completion
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.orangeAccent, width: 2),
        ),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.greenAccent, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _i18n[_currentLang]!['scenarioCompleted'] ?? "Completed!",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            scenarios[_scenarioIndex].conclusion,
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              SoundManager().playClick(); // Audio feedback
              Navigator.pop(context);
              setState(() {
                if (_scenarioIndex < scenarios.length - 1) {
                  _loadScenario(_scenarioIndex + 1);
                } else {
                  _loadScenario(0); // Restart if it's the last
                }
              });
            },
            child: Text(
              _i18n[_currentLang]!['continueBtn'] ?? "Continue",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  double get currentDisplayValue {
    return (_matUnits.length * 1.0) +
        (_matTenths.length * 0.1) +
        (_matHundredths.length * 0.01);
  }

  // Gets the localized string safely
  String _t(String key) => _i18n[_currentLang]?[key] ?? key;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final sidebarWidth = screenWidth * 0.35;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Main Canvas Area
            Positioned.fill(
              child: InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(double.infinity),
                minScale: 0.2,
                maxScale: 4.0,
                constrained: false,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Infinite Background Layer
                    Positioned(
                      top: -10000,
                      left: -10000,
                      right: -10000,
                      bottom: -10000,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: CustomPaint(painter: GridPainter()),
                      ),
                    ),

                    // Interactive Canvas Layer
                    SizedBox(
                      width: 1600,
                      height: 900,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            top: 100,
                            left: 100,
                            child: _buildBinArea(),
                          ),
                          Positioned(
                            top: 100,
                            left: 500,
                            child: _buildMachineArea(),
                          ),
                          Positioned(
                            top: 100,
                            left: 1000,
                            child: _buildOutputArea(),
                          ),
                          Positioned(
                            top: 500,
                            left: 100,
                            child: _buildPlaceValueMat(),
                          ),
                          Positioned(
                            top: 500,
                            left: 1000,
                            child: _buildDigitalDisplay(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Floating Mission Card
            if (!_isSidebarOpen)
              Positioned(
                top: 70,
                left: 16,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 300,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.blueAccent.withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.flag, color: Colors.blueAccent),
                            const SizedBox(width: 8),
                            Text(
                              _t('currentTask'),
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _stepIndex < scenarios[_scenarioIndex].steps.length
                              ? scenarios[_scenarioIndex].steps[_stepIndex].text
                              : _t('allCompleted'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Sidebar Overlay
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              child: Container(
                width: sidebarWidth,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.95),
                  border: const Border(
                    right: BorderSide(color: Colors.white12, width: 2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(5, 0),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: screenHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 64, 16, 24),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.white12),
                              ),
                              color: Color(0xFF0F172A),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 2.0),
                                      child: Icon(
                                        Icons.precision_manufacturing,
                                        color: Colors.orangeAccent,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _t('title'),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _t('subtitle'),
                                            style: TextStyle(
                                              color: Colors.orangeAccent
                                                  .withOpacity(0.8),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    InkWell(
                                      onTap: _toggleLanguage,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.orangeAccent
                                                .withOpacity(0.8),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.language,
                                              color: Colors.orangeAccent,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _currentLang,
                                              style: const TextStyle(
                                                color: Colors.orangeAccent,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    InkWell(
                                      onTap: _resetLab,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.orangeAccent
                                                .withOpacity(0.8),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.refresh,
                                          color: Colors.orangeAccent,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Scrollable Content
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Scenario Selector
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F172A),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        isExpanded: true,
                                        dropdownColor: const Color(0xFF0F172A),
                                        value: _scenarioIndex,
                                        items: List.generate(scenarios.length, (
                                          index,
                                        ) {
                                          return DropdownMenuItem(
                                            value: index,
                                            child: Text(
                                              scenarios[index].title,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          );
                                        }),
                                        onChanged: (val) {
                                          if (val != null) {
                                            SoundManager().playDropdown(); // Audio feedback for changing dropdown
                                            _loadScenario(val);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Objective
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.blue.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.track_changes,
                                              color: Colors.blueAccent,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _t('missionObjective'),
                                              style: const TextStyle(
                                                color: Colors.blueAccent,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          scenarios[_scenarioIndex].objective,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Steps
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.format_list_numbered,
                                        color: Colors.orangeAccent,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _t('proceduralSteps'),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  ...List.generate(
                                    scenarios[_scenarioIndex].steps.length,
                                    (index) {
                                      bool isCompleted = index < _stepIndex;
                                      bool isActive = index == _stepIndex;

                                      return AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? Colors.orange.withOpacity(0.1)
                                              : (isCompleted
                                                    ? Colors.green.withOpacity(
                                                        0.1,
                                                      )
                                                    : Colors.transparent),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: isActive
                                                ? Colors.orangeAccent
                                                : (isCompleted
                                                      ? Colors.greenAccent
                                                            .withOpacity(0.5)
                                                      : Colors.white12),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: isActive
                                                    ? Colors.orangeAccent
                                                    : (isCompleted
                                                          ? Colors.greenAccent
                                                          : Colors.grey
                                                                .withOpacity(
                                                                  0.3,
                                                                )),
                                                shape: BoxShape.circle,
                                              ),
                                              alignment: Alignment.center,
                                              child: isCompleted
                                                  ? const Icon(
                                                      Icons.check,
                                                      color: Colors.black,
                                                      size: 18,
                                                    )
                                                  : Text(
                                                      "${index + 1}",
                                                      style: TextStyle(
                                                        color: isActive
                                                            ? Colors.black
                                                            : Colors.white54,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                scenarios[_scenarioIndex]
                                                    .steps[index]
                                                    .text,
                                                style: TextStyle(
                                                  color: isCompleted
                                                      ? Colors.white54
                                                      : Colors.white,
                                                  decoration: isCompleted
                                                      ? TextDecoration
                                                            .lineThrough
                                                      : null,
                                                  fontWeight: isActive
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Footer
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 8,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0xFF0F172A),
                              border: Border(
                                top: BorderSide(color: Colors.white12),
                              ),
                            ),
                            child: const Text(
                              "© ZeroScienceLab - Fall in love with math and Science",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Fixed Menu Icon Top Left
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.orangeAccent,
                iconSize: 28,
                onPressed: () {
                  SoundManager().playClick(); // Audio feedback
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
            ),

            // Curtain / Shutter Screen (Always Top Most)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutCubic,
              top: _showShutter ? 0 : -screenHeight,
              left: 0,
              right: 0,
              height: screenHeight,
              child: Container(
                color: const Color(0xFF0F172A),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white12),
                          ),
                          child: const Icon(
                            Icons.precision_manufacturing,
                            size: 80,
                            color: Colors.orangeAccent,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            _t('title'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _t('subtitle'),
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 48),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.play_circle_fill, size: 28),
                          label: Text(
                            _t('enterLab'),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 10,
                          ),
                          onPressed: () {
                            SoundManager().curtainScreen(); // Audio feedback for curtain open
                            setState(() {
                              _showShutter = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Canvas Elements Builders ---

  Widget _buildBinArea() {
    return DragTarget<BlockData>(
      onAcceptWithDetails: (details) => _onAcceptDrop(details.data, 'bin'),
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 300,
          height: 250,
          decoration: BoxDecoration(
            color: const Color(0xFF334155),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: candidateData.isNotEmpty
                  ? Colors.orangeAccent
                  : Colors.white24,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _t('blocksBin'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: _bin
                        .map((type) => _buildDraggableBlock(type, 'bin'))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMachineArea() {
    bool isSlicer = _scenarioIndex == 0;
    bool showStartBtn = _machine.isNotEmpty && !_isMachineProcessing;

    return DragTarget<BlockData>(
      onAcceptWithDetails: (details) {
        if ((isSlicer && details.data.type == 'unit') ||
            (!isSlicer && details.data.type == 'tenth')) {
          _onAcceptDrop(details.data, 'machine');
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Column(
          children: [
            Container(
              width: 350,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFF475569),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                border: Border.all(
                  color: candidateData.isNotEmpty
                      ? Colors.greenAccent
                      : Colors.white38,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSlicer
                              ? Icons.vertical_align_center
                              : Icons.cyclone,
                          size: 64,
                          color: _isMachineProcessing
                              ? Colors.orangeAccent
                              : Colors.white54,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isSlicer ? _t('slicerMachine') : _t('grinderMachine'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_machine.isNotEmpty && !_isMachineProcessing)
                    Positioned(
                      top: 20,
                      left: 135,
                      child: _buildStaticBlock(_machine.first),
                    ),
                ],
              ),
            ),
            if (showStartBtn)
              GestureDetector(
                onTap: _processMachine,
                child: Container(
                  width: 350,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _t('start'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 350,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isMachineProcessing
                            ? Colors.orangeAccent
                            : Colors.redAccent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isMachineProcessing ? _t('processing') : _t('idle'),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildOutputArea() {
    return Container(
      width: 400,
      height: 250,
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _t('outputTray'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _output
                    .map((type) => _buildDraggableBlock(type, 'output'))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceValueMat() {
    return Container(
      width: 800,
      height: 350,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blueAccent, width: 6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildMatColumn(
            _t('units'),
            Colors.redAccent,
            _matUnits,
            'mat_units',
            'unit',
          ),
          Container(width: 4, color: Colors.blueAccent),
          _buildMatColumn(
            _t('tenths'),
            Colors.blueAccent,
            _matTenths,
            'mat_tenths',
            'tenth',
            showExchange: _scenarioIndex == 1 && _matTenths.isNotEmpty,
          ),
          Container(width: 4, color: Colors.blueAccent),
          _buildMatColumn(
            _t('hundredths'),
            Colors.orangeAccent,
            _matHundredths,
            'mat_hundredths',
            'hundredth',
          ),
        ],
      ),
    );
  }

  Widget _buildMatColumn(
    String title,
    Color color,
    List<String> blocks,
    String sourceName,
    String expectedType, {
    bool showExchange = false,
  }) {
    return Expanded(
      child: DragTarget<BlockData>(
        onAcceptWithDetails: (details) {
          if (details.data.type == expectedType) {
            _onAcceptDrop(details.data, sourceName);
          }
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            color: candidateData.isNotEmpty
                ? color.withOpacity(0.1)
                : Colors.transparent,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    border: Border(bottom: BorderSide(color: color, width: 2)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                if (showExchange)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      onPressed: _handleExchange,
                      icon: const Icon(Icons.swap_horiz, color: Colors.white),
                      label: Text(
                        _t('exchange'),
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                    ),
                  ),
                Expanded(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Positioned(
                        bottom: 20,
                        child: Wrap(
                          direction: Axis.vertical,
                          verticalDirection: VerticalDirection.up,
                          spacing: -5,
                          children: blocks
                              .map(
                                (type) =>
                                    _buildDraggableBlock(type, sourceName),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDigitalDisplay() {
    return Container(
      width: 350,
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF475569), width: 8),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        currentDisplayValue.toStringAsFixed(2),
        style: const TextStyle(
          fontFamily: 'Courier',
          fontSize: 80,
          fontWeight: FontWeight.bold,
          color: Colors.cyanAccent,
          shadows: [Shadow(color: Colors.cyan, blurRadius: 10)],
        ),
      ),
    );
  }

  // --- Block Builders ---

  Widget _buildDraggableBlock(String type, String source) {
    return Draggable<BlockData>(
      data: BlockData(type, source),
      feedback: Opacity(opacity: 0.8, child: _buildStaticBlock(type)),
      childWhenDragging: Opacity(opacity: 0.3, child: _buildStaticBlock(type)),
      child: _buildStaticBlock(type),
    );
  }

  Widget _buildStaticBlock(String type) {
    switch (type) {
      case 'unit':
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border.all(color: Colors.blue.shade900, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(2, 2),
                blurRadius: 4,
              ),
            ],
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: const Text(
            "1.0",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        );
      case 'tenth':
        return Container(
          width: 80,
          height: 15,
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border.all(color: Colors.blue.shade900, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
            borderRadius: BorderRadius.circular(2),
          ),
        );
      case 'hundredth':
        return Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border.all(color: Colors.blue.shade900, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(1, 1),
                blurRadius: 1,
              ),
            ],
            borderRadius: BorderRadius.circular(2),
          ),
        );
      default:
        return const SizedBox();
    }
  }
}

// Background Grid for Isometric/Canvas feel
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 50) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
