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
      title: 'The Expression Factory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF020617),
        primaryColor: Colors.amber,
        colorScheme: const ColorScheme.dark(
          primary: Colors.amber,
          surface: Color(0xFF0F172A),
        ),
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'Roboto',
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: const EvaluatingAlgebraicExpressions(),
    ),
  );
}

class EvaluatingAlgebraicExpressions extends StatefulWidget {
  const EvaluatingAlgebraicExpressions({super.key});

  @override
  State<EvaluatingAlgebraicExpressions> createState() =>
      _EvaluatingAlgebraicExpressionsState();
}

class _EvaluatingAlgebraicExpressionsState
    extends State<EvaluatingAlgebraicExpressions>
    with TickerProviderStateMixin {
  // --- Core State ---
  bool _isSidebarOpen = true;
  String _language = 'en'; // 'en' or 'hi'
  int _currentScenario = 0; // 0 = Age, 1 = Matchsticks
  int _currentStep = 0; // 0 to 4
  int? _factoryValue; // The value inside the box
  bool _isProcessing = false;
  bool _showCurtain = true;
  bool _showSummary = false;

  // 0: Left (Start), 1: Middle (Machine), 2: Right (End)
  int _boxPosition = 0;

  // --- Controllers ---
  final TransformationController _transformationController =
      TransformationController();
  late AnimationController _gearAnimController;
  late AudioPlayer _audioPlayer;

  // --- Translation Dictionary ---
  final Map<String, Map<String, String>> _i18n = {
    'en': {
      'appTitle': 'The Expression Factory',
      'appSubtitle': 'Class 7 • EXPRESSIONS USING LETTER-NUMBERS',
      'enterLab': 'Enter Lab',
      'theory': 'Theory',
      'missionObj': 'Mission Objective:',
      'procSteps': 'Procedural Steps',
      'stepText': 'STEP',
      'waitInst': 'Wait for instructions',
      'start': 'START',
      'valModel': 'VALIDATE MODEL',
      'sc0_title': 'Scenario 1: The Age Calculator',
      'sc1_title': 'Scenario 2: The Matchstick Multiplier',
      'sc0_mission':
          'To understand how to evaluate a simple addition expression (a + 3) by substituting a value for the variable.',
      'sc0_step0':
          "DRAG the number '10' from the panel and DROP it onto the box 'a'.",
      'sc0_hud0': "DRAG '10' ONTO BOX 'a'",
      'sc0_step1':
          "CLICK the 'Start' button to send the box 'a' onto the conveyor belt.",
      'sc0_hud1': 'START THE FACTORY',
      'sc0_step2':
          "The box enters the machine (+3 Adder). CLICK 'Run Machine' and observe.",
      'sc0_hud2': 'PROCESS THE BOX',
      'sc0_step3': "CLICK 'Send to End' to move the box to the end station.",
      'sc0_hud3': 'MOVE TO END STATION',
      'sc0_step4': "Evaluation is complete. CLICK 'Validate Model'.",
      'sc0_hud4': 'VALIDATE THE FACTORY MODEL',
      'sc0_summary':
          "When Aftab's age (a) is 10, the expression a + 3 evaluates to 13. You substituted the value 10 for the variable 'a' and performed the addition.",
      'sc1_mission':
          'To evaluate a simple multiplication expression (2n) by substituting a value for the variable.',
      'sc1_step0': "DRAG the number '5' and DROP it onto the box 'n'.",
      'sc1_hud0': "DRAG '5' TO BOX 'n'",
      'sc1_step1': "CLICK the 'Start' button to run the factory.",
      'sc1_hud1': 'START THE FACTORY',
      'sc1_step2':
          "The box enters the machine (x2 Multiplier). CLICK 'Run Machine' and observe.",
      'sc1_hud2': 'PROCESS THE BOX',
      'sc1_step3': "CLICK 'Send to End' to move the box to the end station.",
      'sc1_hud3': 'MOVE TO END STATION',
      'sc1_step4': "Evaluation is complete. CLICK 'Validate Model'.",
      'sc1_hud4': 'VALIDATE THE FACTORY MODEL',
      'sc1_summary':
          "For 5 L-shapes (n=5), the expression 2n (which means 2 times n) evaluates to 10. You needed 10 matchsticks.",
      'btnRun': 'Run Machine',
      'btnSend': 'Send to End',
      'correctSub': 'Correct Value Substituted!',
      'incorrectSub': 'Incorrect Value. Try again.',
      'footer': '© ZeroScienceLab - Fall in love with math and Science',
      'completedMsg': 'MODEL VALIDATED AND SCENARIO COMPLETED',
      'summaryTitle': 'Summary',
      'machineAdder': '+3 Adder',
      'machineMultiplier': 'x2 Multiplier',
      'shabnamAge': "Shabnam's Age",
      'totalMatches': "Total Matchsticks",
      'expression': "EXPRESSION: ",
      'reset': "Reset Lab",
      'langToggle': "EN",
    },
    'hi': {
      'appTitle': 'व्यंजक कारखाना',
      'appSubtitle': 'कक्षा 7 • अक्षर-संख्याओं का उपयोग करके व्यंजक',
      'enterLab': 'प्रयोगशाला में प्रवेश करें',
      'theory': 'सिद्धांत',
      'missionObj': 'उद्देश्य:',
      'procSteps': 'प्रक्रियात्मक चरण',
      'stepText': 'चरण',
      'waitInst': 'निर्देशों की प्रतीक्षा करें',
      'start': 'शुरू करें',
      'valModel': 'मॉडल मान्य करें',
      'sc0_title': 'परिदृश्य 1: आयु कैलकुलेटर',
      'sc1_title': 'परिदृश्य 2: माचिस की तीली गुणक',
      'sc0_mission':
          'चर के लिए मान प्रतिस्थापित करके एक साधारण योग व्यंजक (a + 3) का मूल्यांकन करना समझना।',
      'sc0_step0': "पैनल से '10' को खींचें और बॉक्स 'a' पर छोड़ें।",
      'sc0_hud0': "बॉक्स 'a' पर '10' खींचें",
      'sc0_step1':
          "कन्वेयर बेल्ट पर बॉक्स 'a' भेजने के लिए 'शुरू करें' बटन दबाएं।",
      'sc0_hud1': 'कारखाना शुरू करें',
      'sc0_step2':
          "बॉक्स (+3 योजक) मशीन में प्रवेश करता है। 'मशीन चलाएं' पर क्लिक करें।",
      'sc0_hud2': 'बॉक्स को प्रोसेस करें',
      'sc0_step3': "'अंत में भेजें' बटन पर क्लिक करें।",
      'sc0_hud3': 'अंतिम स्टेशन पर जाएं',
      'sc0_step4': "मूल्यांकन पूरा हो गया है। 'मॉडल मान्य करें' पर क्लिक करें।",
      'sc0_hud4': 'फ़ैक्टरी मॉडल मान्य करें',
      'sc0_summary':
          "जब आफताब की आयु (a) 10 है, तो व्यंजक a + 3 का मान 13 होता है। आपने a के लिए 10 मान रखा और जोड़ किया।",
      'sc1_mission':
          'चर के लिए मान प्रतिस्थापित करके एक साधारण गुणा व्यंजक (2n) का मूल्यांकन करना।',
      'sc1_step0': "'5' को खींचें और इसे 'n' बॉक्स पर छोड़ें।",
      'sc1_hud0': "बॉक्स 'n' पर '5' खींचें",
      'sc1_step1': "कारखाना चलाने के लिए 'शुरू करें' बटन पर क्लिक करें।",
      'sc1_hud1': 'कारखाना शुरू करें',
      'sc1_step2':
          "बॉक्स (x2 गुणक) मशीन में प्रवेश करता है। 'मशीन चलाएं' पर क्लिक करें।",
      'sc1_hud2': 'बॉक्स को प्रोसेस करें',
      'sc1_step3': "'अंत में भेजें' बटन पर क्लिक करें।",
      'sc1_hud3': 'अंतिम स्टेशन पर जाएं',
      'sc1_step4': "मूल्यांकन पूरा हो गया है। 'मॉडल मान्य करें' पर क्लिक करें।",
      'sc1_hud4': 'फ़ैक्टरी मॉडल मान्य करें',
      'sc1_summary':
          "5 L-आकृतियों (n=5) के लिए, व्यंजक 2n (जिसका अर्थ n का 2 गुना है) 10 पर मूल्यांकन होता है। आपको 10 तीलियों की आवश्यकता थी।",
      'btnRun': 'मशीन चलाएं',
      'btnSend': 'अंत में भेजें',
      'correctSub': 'सही मान प्रतिस्थापित!',
      'incorrectSub': 'गलत मान। पुन: प्रयास करें।',
      'footer': '© ZeroScienceLab - Fall in love with math and Science',
      'completedMsg': 'मॉडल मान्य और परिदृश्य पूरा हुआ',
      'summaryTitle': 'सारांश',
      'machineAdder': '+3 योजक',
      'machineMultiplier': 'x2 गुणक',
      'shabnamAge': "शबनम की आयु",
      'totalMatches': "कुल तीलियां",
      'expression': "व्यंजक: ",
      'reset': "रीसेट करें",
      'langToggle': "HI",
    },
  };

  String getLoc(String key) => _i18n[_language]![key] ?? key;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _gearAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _gearAnimController.dispose();
    _audioPlayer.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  // --- Audio Methods ---
  void _playSound(String url) async {
    try {
      await _audioPlayer.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio play error: $e");
    }
  }

  void _playClick() => _playSound(
    'audio/class7/mixkit_2568.mp3',
  );
  void _playSuccess() => _playSound(
    'audio/class7/mixkit_2018.mp3',
  );
  void _playError() => _playSound(
    'audio/class7/mixkit_2570.mp3',
  );
  void _playAction() => _playSound(
    'audio/class7/mixkit_270.mp3',
  );
  void _playCurtain() => _playSound(
    'audio/class7/mixkit_2020.mp3',
  );

  // --- Logic Methods ---
  void _loadScenario(int index) {
    _playClick();
    setState(() {
      _currentScenario = index;
      _currentStep = 0;
      _factoryValue = null;
      _isProcessing = false;
      _boxPosition = 0;
      _showSummary = false;
    });
  }

  void _resetLab() {
    _playClick();
    setState(() {
      _currentStep = 0;
      _factoryValue = null;
      _isProcessing = false;
      _boxPosition = 0;
      _showSummary = false;
      _showCurtain = true; // Show the curtain screen again
    });
    // Reset canvas position and zoom
    _transformationController.value = Matrix4.identity();
  }

  void _toggleLanguage() {
    _playClick();
    setState(() {
      _language = _language == 'en' ? 'hi' : 'en';
    });
  }

  void _handleDrop(int value) {
    int target = _currentScenario == 0 ? 10 : 5;
    if (value == target) {
      _playSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getLoc('correctSub')),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() {
        _factoryValue = value;
        _currentStep++;
      });
    } else {
      _playError();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getLoc('incorrectSub')),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _startFactory() {
    _playAction();
    setState(() {
      _isProcessing = true;
      _boxPosition = 1; // Move to middle
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _currentStep++;
        });
      }
    });
  }

  void _runMachine() {
    _playAction();
    setState(() {
      _isProcessing = true;
    });
    _gearAnimController.repeat();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _currentStep++;
        });
        _gearAnimController.stop();
        _playSuccess();
      }
    });
  }

  void _sendToEnd() {
    _playAction();
    setState(() {
      _isProcessing = true;
      _boxPosition = 2; // Move to end
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _currentStep++;
        });
        _playSuccess();
      }
    });
  }

  void _validateModel() {
    _playClick();
    setState(() {
      _showSummary = true;
    });
  }

  // --- UI Builders ---

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
            // 1. Canvas Layer (Interactive Viewer)
            Positioned.fill(child: _buildCanvas()),

            // 3. Floating Mission Card (Visible when sidebar collapsed)
            if (!_isSidebarOpen)
              Positioned(top: 66.0, left: 16, child: _buildFloatingCard()),

            // 4. Sidebar Layer
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              width: sidebarWidth,
              child: _buildSidebar(),
            ),

            // 5. Menu Toggle Button (Fixed Position, won't slide with sidebar)
            Positioned(
              top: 16,
              left: 16,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: IconButton(
                  icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                  color: Colors.amberAccent,
                  iconSize: 28,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _playClick();
                    setState(() {
                      _isSidebarOpen = !_isSidebarOpen;
                    });
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A).withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.amber.withOpacity(0.5)),
                    ),
                  ),
                ),
              ),
            ),

            // 6. Summary Modal Overlay
            if (_showSummary) Positioned.fill(child: _buildSummaryModal()),

            // 7. Curtain Raiser Overlay (Front-most)
            if (_showCurtain)
              Positioned.fill(child: _buildCurtain(screenHeight)),
          ],
        ),
      ),
    );
  }

  // --- Sub-Builders ---

  Widget _buildCurtain(double screenHeight) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      top: _showCurtain ? 0 : -screenHeight,
      bottom: _showCurtain ? 0 : screenHeight,
      left: 0,
      right: 0,
      child: Container(
        color: const Color(0xFF020617),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.factory, size: 80, color: Colors.amber),
            const SizedBox(height: 20),
            Text(
              getLoc('appTitle'),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              getLoc('appSubtitle'),
              style: TextStyle(
                fontSize: 20,
                color: Colors.blueGrey[300],
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                _playCurtain();
                setState(() {
                  _showCurtain = false;
                });
              },
              icon: const Icon(
                Icons.arrow_forward,
                color: Colors.black,
                size: 28,
              ),
              label: Text(
                getLoc('enterLab'),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                elevation: 10,
                shadowColor: Colors.amber.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      // Removed SafeArea here
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 66.0,
          bottom: 20.0,
        ), // Top padding accommodates fixed menu icon
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.biotech,
                    color: Colors.amber,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getLoc('appTitle'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        getLoc('appSubtitle'),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey[300],
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Controls: Language & Reset Row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _toggleLanguage,
                    icon: const Icon(
                      Icons.language,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: Text(
                      getLoc('langToggle'),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _resetLab,
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: Text(
                      getLoc('reset'),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Scenario Dropdown
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: _currentScenario,
                  dropdownColor: const Color(0xFF0F172A),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.amber),
                  items: [
                    DropdownMenuItem(
                      value: 0,
                      child: Text(
                        getLoc('sc0_title'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text(
                        getLoc('sc1_title'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) _loadScenario(val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Theory/Mission
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.menu_book,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        getLoc('theory'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    getLoc('missionObj'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentScenario == 0
                        ? getLoc('sc0_mission')
                        : getLoc('sc1_mission'),
                    style: TextStyle(color: Colors.blueGrey[300], height: 1.4),
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
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  getLoc('procSteps'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStepList(),

            const SizedBox(height: 30),

            // Dynamic Action Area (in Sidebar)
            _buildActionArea(),

            const SizedBox(height: 40),
            // Footer
            Center(
              child: Text(
                getLoc('footer'),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.blueGrey[500]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepList() {
    List<String> stepTexts =
        _currentScenario == 0
            ? [
              getLoc('sc0_step0'),
              getLoc('sc0_step1'),
              getLoc('sc0_step2'),
              getLoc('sc0_step3'),
              getLoc('sc0_step4'),
            ]
            : [
              getLoc('sc1_step0'),
              getLoc('sc1_step1'),
              getLoc('sc1_step2'),
              getLoc('sc1_step3'),
              getLoc('sc1_step4'),
            ];

    return Column(
      children: List.generate(stepTexts.length, (index) {
        bool isPast = index < _currentStep;
        bool isCurrent = index == _currentStep;

        Color bgColor =
            isCurrent
                ? Colors.amber
                : (isPast
                    ? const Color(0xFF1E293B).withOpacity(0.5)
                    : const Color(0xFF1E293B));
        Color textColor =
            isCurrent
                ? Colors.black
                : (isPast ? Colors.white38 : Colors.white70);
        Color titleColor =
            isCurrent
                ? Colors.black87
                : (isPast ? Colors.white38 : Colors.white);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isCurrent
                      ? Colors.amberAccent
                      : Colors.white.withOpacity(0.05),
            ),
            boxShadow:
                isCurrent
                    ? [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.3),
                        blurRadius: 10,
                      ),
                    ]
                    : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${getLoc('stepText')} ${index + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                  decoration: isPast ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stepTexts[index],
                style: TextStyle(
                  fontSize: 14,
                  color: textColor,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                  decoration: isPast ? TextDecoration.lineThrough : null,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildActionArea() {
    if (_currentStep == 0) {
      List<int> draggables = _currentScenario == 0 ? [5, 10, 15] : [2, 5, 8];
      return Column(
        children: [
          Text(
            getLoc('waitInst').toUpperCase(),
            style: const TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            children:
                draggables.map((val) {
                  return Draggable<int>(
                    data: val,
                    feedback: Material(
                      color: Colors.transparent,
                      child: _buildDragItem(val, true),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: _buildDragItem(val, false),
                    ),
                    child: _buildDragItem(val, false),
                    onDragStarted: () => _playClick(),
                  );
                }).toList(),
          ),
        ],
      );
    } else if (_currentStep == 1) {
      return _buildActionButton(
        icon: Icons.play_arrow,
        label: getLoc('start'),
        color: Colors.green,
        onTap: _startFactory,
      );
    } else if (_currentStep == 2) {
      return _buildActionButton(
        icon: Icons.settings_suggest,
        label: getLoc('btnRun'),
        color: Colors.amber,
        textColor: Colors.black,
        onTap: _runMachine,
      );
    } else if (_currentStep == 3) {
      return _buildActionButton(
        icon: Icons.fast_forward,
        label: getLoc('btnSend'),
        color: Colors.blueAccent,
        onTap: _sendToEnd,
      );
    } else if (_currentStep == 4 && !_showSummary) {
      return _buildActionButton(
        icon: Icons.check_circle,
        label: getLoc('valModel'),
        color: Colors.purpleAccent,
        onTap: _validateModel,
      );
    } else {
      return Center(
        child: Text(
          getLoc('completedMsg'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      );
    }
  }

  Widget _buildDragItem(int value, bool isDragging) {
    return Container(
      width: 60,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color:
            isDragging
                ? Colors.amber.withOpacity(0.8)
                : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDragging ? Colors.white : Colors.white.withOpacity(0.2),
          width: 2,
        ),
        boxShadow:
            isDragging
                ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ]
                : [],
      ),
      child: Text(
        value.toString(),
        style: TextStyle(
          color: isDragging ? Colors.black : Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    Color textColor = Colors.white,
  }) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : onTap,
        icon: Icon(icon, color: textColor),
        label: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 8,
          shadowColor: color.withOpacity(0.5),
        ),
      ),
    );
  }

  // Floating Card when sidebar is collapsed
  Widget _buildFloatingCard() {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.amber.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _currentScenario == 0
                ? getLoc('sc0_mission')
                : getLoc('sc1_mission'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildActionArea(),
        ],
      ),
    );
  }

  // --- Factory Canvas Builder ---

  Widget _buildCanvas() {
    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: 0.1,
      maxScale: 5.0,
      boundaryMargin: const EdgeInsets.all(double.infinity),
      constrained: false,
      panEnabled: true,
      scaleEnabled: true,
      child: Container(
        width: 1400,
        height: 800,
        color: const Color(0xFF020617), // Very dark background
        child: Stack(
          children: [
            // 1. Conveyor Belt Background
            Positioned(
              left: 100,
              top: 400,
              right: 100,
              height: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF112240),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      offset: Offset(0, 10),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
            // Conveyor Legs
            for (double x = 150; x < 1300; x += 150)
              Positioned(
                left: x,
                top: 420,
                width: 10,
                height: 80,
                child: Container(color: const Color(0xFF233554)),
              ),

            // Main Expression Sign (Top Center)
            Positioned(
              top: 50,
              left: 500,
              width: 400,
              height: 100,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  border: Border.all(color: Colors.amber, width: 4),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  "${getLoc('expression')} ${_currentScenario == 0 ? 'a + 3' : '2n'}",
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // 2. Input Station (Left)
            Positioned(
              left: 100,
              top: 420,
              width: 150,
              height: 20,
              child: Container(color: Colors.blueGrey[800]),
            ),

            // 3. Middle Machine
            Positioned(
              left: 550,
              top: 250,
              width: 300,
              height: 250,
              child: _buildMachineVisuals(),
            ),

            // 4. End Station (Right)
            Positioned(
              left: 1050,
              top: 200,
              width: 250,
              height: 250,
              child: _buildEndStationVisuals(),
            ),

            // 5. The Moving Box (Variable Box)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeInOut,
              top: 320,
              left: _boxPosition == 0 ? 125 : (_boxPosition == 1 ? 650 : 1125),
              child: _buildVariableBox(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMachineVisuals() {
    bool isAdder = _currentScenario == 0;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border.all(color: Colors.white24, width: 4),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            offset: Offset(0, 20),
            blurRadius: 20,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Glass tube / center area
          Positioned(
            left: 50,
            right: 50,
            top: 20,
            bottom: 50,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child:
                  _isProcessing
                      ? RotationTransition(
                        turns: _gearAnimController,
                        child: Icon(
                          isAdder ? Icons.add_circle_outline : Icons.close,
                          size: 100,
                          color: isAdder ? Colors.green : Colors.purple,
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
          ),
          // Machine Label
          Positioned(
            bottom: 10,
            left: 20,
            right: 20,
            height: 40,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isAdder ? Colors.green : Colors.purple,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isAdder ? getLoc('machineAdder') : getLoc('machineMultiplier'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndStationVisuals() {
    bool isFinal = _currentStep >= 4 && _factoryValue != null;
    String title =
        _currentScenario == 0 ? getLoc('shabnamAge') : getLoc('totalMatches');
    String eq = '';
    if (isFinal) {
      eq =
          _currentScenario == 0
              ? '$_factoryValue + 3 = ${_factoryValue! + 3}'
              : '2 x $_factoryValue = ${_factoryValue! * 2}';
    }

    return Container(
      decoration: BoxDecoration(
        color: isFinal ? const Color(0xFF064E3B) : const Color(0xFF1E293B),
        border: Border.all(
          color: isFinal ? Colors.green : Colors.blueAccent,
          width: 4,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment:
            isFinal ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isFinal ? Colors.greenAccent : Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isFinal) ...[
            const SizedBox(height: 12),
            Text(
              eq,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVariableBox() {
    bool isFilled = _factoryValue != null;
    String label =
        isFilled
            ? _factoryValue.toString()
            : (_currentScenario == 0 ? 'a' : 'n');

    Widget boxContent = Container(
      width: 100,
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color:
            isFilled
                ? Colors.green.withOpacity(0.8)
                : Colors.amber.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            offset: Offset(0, 10),
            blurRadius: 10,
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isFilled ? Colors.white : Colors.black,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    // Only allow drop when at position 0 and empty (Step 0)
    if (_currentStep == 0 && !isFilled && _boxPosition == 0) {
      return DragTarget<int>(
        builder: (context, candidateData, rejectedData) {
          bool isHovered = candidateData.isNotEmpty;
          return Transform.scale(
            scale: isHovered ? 1.1 : 1.0,
            child: Container(
              decoration:
                  isHovered
                      ? BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 10,
                          ),
                        ],
                      )
                      : null,
              child: boxContent,
            ),
          );
        },
        onWillAcceptWithDetails: (details) => true,
        onAcceptWithDetails: (details) => _handleDrop(details.data),
      );
    }

    return boxContent;
  }

  Widget _buildSummaryModal() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 500,
          constraints: const BoxConstraints(maxHeight: 400),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.amber.withOpacity(0.5)),
            boxShadow: const [
              BoxShadow(color: Colors.black54, blurRadius: 30, spreadRadius: 5),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.amber,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          getLoc('summaryTitle'),
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () {
                        _playClick();
                        setState(() {
                          _showSummary = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
              // Body (Scrollable)
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    _currentScenario == 0
                        ? getLoc('sc0_summary')
                        : getLoc('sc1_summary'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      height: 1.5,
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
}
