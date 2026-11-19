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
      title: 'Virtual Lab | Magical Expression Machine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617),
        primaryColor: Colors.yellow,
        fontFamily: 'Roboto',
      ),
      home: const IntroductiontoAlgebraicExpressionsandVariables(),
    ),
  );
}

class IntroductiontoAlgebraicExpressionsandVariables extends StatefulWidget {
  const IntroductiontoAlgebraicExpressionsandVariables({super.key});

  @override
  State<IntroductiontoAlgebraicExpressionsandVariables> createState() =>
      _IntroductiontoAlgebraicExpressionsandVariablesState();
}

class _IntroductiontoAlgebraicExpressionsandVariablesState
    extends State<IntroductiontoAlgebraicExpressionsandVariables>
    with TickerProviderStateMixin {
  bool _isSidebarOpen = true;
  bool _isCurtainOpen = false;

  // Default language is set to English (en)
  String _currentLang = 'en';
  int _currentScenario = 1;
  int _currentStep = 1;
  bool _scenarioValidated = false;
  bool _showSuccessPopup = false;

  // Audio Player
  late AudioPlayer _audioPlayer;

  // Mixkit Sound URLs
  final String _clickSound =
      'audio/class7/mixkit_2568.mp3';
  final String _successSound =
      'audio/class7/mixkit_2018.mp3';
  final String _startSound =
      'audio/class7/mixkit_2018.mp3';
  final String _dropSound =
      'audio/class7/mixkit_2869.mp3';

  String get _currentLanguage => _currentLang.toUpperCase();

  // Scenario 1 State
  bool _s1BoxXOnBelt = false;
  int _s1ApplesOnBelt = 0;
  bool _s1MachineRunning = false;
  bool _s1BoxOpened = false;
  double _s1ConveyorPosition = 0.0;

  // Scenario 2 State
  bool _s2CrateYInMachine = false;
  int _s2DialValue = 1;
  bool _s2MachineRunning = false;
  bool _s2CratesOpened = false;

  late AnimationController _beltAnimationController;

  final Map<String, Map<String, String>> _dict = {
    'en': {
      'appTitle': 'The Magical Expression Machine',
      'appSubtitle': 'Class 7 • EXPRESSIONS USING LETTER-NUMBERS',
      'enterLab': 'Enter Virtual Lab',
      'scen1Title': '1. The Fruit Sorter',
      'scen2Title': '2. The Toy Car Duplicator',
      'selectScenario': 'Select Scenario',
      'missionObj': 'Mission Objective',
      'procSteps': 'Procedural Steps',
      'step': 'Step',
      'waiting': 'Waiting for task...',
      'proceed': 'Proceed to Next Step',
      'validate': 'Validate Model',
      'scenSummary': 'Scenario Summary',
      'startBtn': 'START',
      'dupBtn': 'DUPLICATE',
      'inHopper': 'INPUT HOPPER',
      'outTray': 'OUTPUT TRAY',
      'convertUnits': 'Convert Units',
      'noConversionNeeded': 'No unit conversion is needed at this step.',
      'closeAndContinue': 'Close and Continue',
      's1Obj':
          'Understand that a variable (a letter) represents an unknown quantity and can be combined with a constant in an expression.',
      's1Sum':
          'An expression like "x + 3" is a rule. We started with an unknown number of apples ("x") and added 3. When we found out "x" was 5, the total became 5 + 3 = 8.',
      's1St1': "DRAG the Mystery Fruit Box 'x' onto the conveyor belt.",
      's1St2':
          "DRAG 3 single apples from the basket and DROP them onto the conveyor belt behind the 'x' box.",
      's1St3': "CLICK the green 'START' button on the machine.",
      's1St4': "CLICK the 'x' box in the output area to open it.",
      's2Obj':
          'Understand that a number in front of a variable (a coefficient) means multiplication.',
      's2Sum':
          'The expression "3y" means "3 times the amount in y". The rule was to make 3 sets. Once we knew "y" was 4, the total became 3 × 4 = 12. The number 3 is a coefficient.',
      's2St1':
          "DRAG the 'y' crate and DROP it into the input slot of the Duplicator Machine.",
      's2St2':
          "CLICK the '+' button on the machine's dial until it shows the number 3.",
      's2St3': "CLICK the large 'DUPLICATE' button to run the machine.",
      's2St4': "CLICK on any one of the 'y' crates to open it.",
      'completedMsg': 'Model validated! Select next scenario.',
      'totalApples': 'Total Apples: ',
      'applesAdded': 'Apples Added:',
      'placingMysteryBox': 'Placing the\nMystery Box',
      'addingApples': 'Adding the Apples\n(The Constant)',
      'systemStatus': 'SYSTEM STATUS',
      'ready': 'READY',
      'wait': 'WAIT',
    },
    'hi': {
      'appTitle': 'जादुई व्यंजक मशीन',
      'appSubtitle': 'कक्षा 7 • अक्षर-संख्याओं का उपयोग करके व्यंजक',
      'enterLab': 'वर्चुअल लैब में प्रवेश करें',
      'scen1Title': '1. फल छांटने वाला',
      'scen2Title': '2. टॉय कार डुप्लिकेटर',
      'selectScenario': 'परिदृश्य चुनें',
      'missionObj': 'मिशन का उद्देश्य',
      'procSteps': 'प्रक्रियात्मक चरण',
      'step': 'चरण',
      'waiting': 'कार्य की प्रतीक्षा है...',
      'proceed': 'अगले चरण पर जाएँ',
      'validate': 'मॉडल को मान्य करें',
      'scenSummary': 'परिदृश्य सारांश',
      'startBtn': 'प्रारंभ',
      'dupBtn': 'प्रतिलिपि',
      'inHopper': 'इनपुट हॉपर',
      'outTray': 'आउटपुट ट्रे',
      'convertUnits': 'इकाइयाँ बदलें',
      'noConversionNeeded': 'इस चरण में इकाइयों को बदलने की आवश्यकता नहीं है।',
      'closeAndContinue': 'बंद करें और जारी रखें',
      's1Obj':
          'समझें कि एक चर (एक अक्षर) एक अज्ञात मात्रा का प्रतिनिधित्व करता है और इसे व्यंजक में स्थिरांक के साथ जोड़ा जा सकता है।',
      's1Sum':
          'व्यंजक "x + 3" एक नियम है। हमने अज्ञात सेब ("x") से शुरुआत की और 3 जोड़े। जब पता चला कि "x" 5 है, तो कुल 5 + 3 = 8 हो गया।',
      's1St1': "रहस्यमयी फल बॉक्स 'x' को कन्वेयर बेल्ट पर खींचें।",
      's1St2':
          "स्टैंड से 3 सेब खींचें और उन्हें 'x' बॉक्स के पीछे कन्वेयर बेल्ट पर छोड़ दें।",
      's1St3': "मशीन पर हरे 'प्रारंभ' बटन पर क्लिक करें।",
      's1St4': "खोलने के लिए आउटपुट क्षेत्र में 'x' बॉक्स पर क्लिक करें।",
      's2Obj': 'समझें कि चर के सामने वाली संख्या (गुणांक) का अर्थ गुणा है।',
      's2Sum':
          'व्यंजक "3y" का अर्थ है "y का 3 गुना"। नियम 3 सेट बनाने का था। जब पता चला कि "y" 4 है, तो कुल 3 × 4 = 12 हो गया। संख्या 3 गुणांक है।',
      's2St1': "'y' क्रेट को मशीन के इनपुट स्लॉट में खींचें और छोड़ें।",
      's2St2': "मशीन के डायल पर '+' बटन पर तब तक क्लिक करें जब तक 3 न दिखे।",
      's2St3': "मशीन चलाने के लिए बड़े 'प्रतिलिपि' बटन पर क्लिक करें।",
      's2St4': "खोलने के लिए किसी भी 'y' क्रेट पर क्लिक करें।",
      'completedMsg': 'मॉडल मान्य हो गया! अगला परिदृश्य चुनें।',
      'totalApples': 'कुल सेब: ',
      'applesAdded': 'जोड़े गए सेब:',
      'placingMysteryBox': 'रहस्यमयी बॉक्स\nरखना',
      'addingApples': 'सेब जोड़ना\n(स्थिरांक)',
      'systemStatus': 'सिस्टम स्थिति',
      'ready': 'तैयार',
      'wait': 'प्रतीक्षा करें',
    },
  };

  String t(String key) => _dict[_currentLang]?[key] ?? key;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _audioPlayer = AudioPlayer();
    _beltAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..addListener(() {
            setState(() {
              _s1ConveyorPosition = _beltAnimationController.value;
            });
          });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _audioPlayer.dispose();
    _beltAnimationController.dispose();
    super.dispose();
  }

  Future<void> _playSound(String url) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio playback error: $e");
    }
  }

  void _toggleLanguage() {
    _playSound(_clickSound);
    setState(() {
      _currentLang = _currentLang == 'en' ? 'hi' : 'en';
    });
  }

  void _resetLab() {
    _playSound(_clickSound);
    setState(() {
      _isCurtainOpen = false; // Returns to the curtain screen
      _currentScenario = 1; // Resets entirely to scenario 1
    });
    _loadScenario(1);
  }

  void _loadScenario(int num) {
    _playSound(_clickSound);
    setState(() {
      _currentScenario = num;
      _currentStep = 1;
      _scenarioValidated = false;
      _showSuccessPopup = false;

      _s1BoxXOnBelt = false;
      _s1ApplesOnBelt = 0;
      _s1MachineRunning = false;
      _s1BoxOpened = false;
      _s1ConveyorPosition = 0.0;
      _beltAnimationController.reset();

      _s2CrateYInMachine = false;
      _s2DialValue = 1;
      _s2MachineRunning = false;
      _s2CratesOpened = false;
    });
  }

  void _completeStep() {
    _playSound(_successSound);
    setState(() {
      if (_currentStep < 4) {
        _currentStep++;
      } else {
        _scenarioValidated = true;
        _showSuccessPopup = true;
      }
    });
  }

  List<Map<String, dynamic>> _getSteps() {
    if (_currentScenario == 1) {
      return [
        {'id': 1, 'inst': t('s1St1'), 'action': 'drag_x'},
        {'id': 2, 'inst': t('s1St2'), 'action': 'drag_apples'},
        {'id': 3, 'inst': t('s1St3'), 'action': 'click_start'},
        {'id': 4, 'inst': t('s1St4'), 'action': 'click_open'},
      ];
    } else {
      return [
        {'id': 1, 'inst': t('s2St1'), 'action': 'drag_y'},
        {'id': 2, 'inst': t('s2St2'), 'action': 'click_plus'},
        {'id': 3, 'inst': t('s2St3'), 'action': 'click_duplicate'},
        {'id': 4, 'inst': t('s2St4'), 'action': 'click_crate'},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = screenWidth > 800 ? screenWidth * 0.3 : 300.0;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // 1. Main Canvas Area
            Positioned.fill(
              child: Container(
                color: const Color(0xFF0F172A),
                padding: EdgeInsets.only(
                  left: _isSidebarOpen ? sidebarWidth : 0,
                ),
                child: InteractiveViewer(
                  panEnabled: true,
                  scaleEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: ClipRect(
                        child: SizedBox(
                          width: 1250,
                          height: 800,
                          child: _currentScenario == 1
                              ? _buildScenario1()
                              : _buildScenario2(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 2. Sidebar (Left Side)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              width: sidebarWidth,
              child: _buildSidebar(sidebarWidth),
            ),

            // 3. Menu Toggle Icon (Always visible)
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.orangeAccent,
                iconSize: 28,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _playSound(_clickSound);
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

            // 4. Floating Mission Card
            if (!_isSidebarOpen && _isCurtainOpen)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(child: _buildFloatingCard()),
              ),

            // 5. Success Popup Overlay
            if (_showSuccessPopup) _buildSuccessPopupOverlay(),

            // 6. Curtain Raiser (Initial Screen)
            if (!_isCurtainOpen) _buildCurtain(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurtain() {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF0F172A),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.blueGrey.shade700),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 20),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.science, size: 80, color: Colors.yellow),
                  const SizedBox(height: 20),
                  Text(
                    t('appTitle'),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    t('appSubtitle'),
                    style: const TextStyle(fontSize: 18, color: Colors.yellow),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: () {
                      _playSound(_startSound);
                      setState(() => _isCurtainOpen = true);
                    },
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.black,
                    ),
                    label: Text(
                      t('enterLab'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(double width) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.95),
        border: const Border(
          right: BorderSide(color: Colors.white24, width: 1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 15,
            offset: Offset(5, 0),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.biotech,
                                  color: Colors.indigoAccent,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t('appTitle'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      t('appSubtitle'),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.yellow,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: _toggleLanguage,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.orangeAccent.withOpacity(
                                          0.8,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.language,
                                          color: Colors.orangeAccent,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _currentLanguage,
                                          style: const TextStyle(
                                            color: Colors.orangeAccent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              InkWell(
                                onTap: _resetLab,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.orangeAccent.withOpacity(
                                        0.8,
                                      ),
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
                          const SizedBox(height: 25),
                          Text(
                            t('selectScenario').toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade400,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _currentScenario,
                                isExpanded: true,
                                dropdownColor: const Color(0xFF0F172A),
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: 1,
                                    child: Text(
                                      t('scen1Title'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 2,
                                    child: Text(
                                      t('scen2Title'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) _loadScenario(val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.white24, height: 40),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.menu_book,
                                color: Colors.blue,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                t('missionObj'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              _currentScenario == 1 ? t('s1Obj') : t('s2Obj'),
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          Row(
                            children: [
                              const Icon(
                                Icons.format_list_numbered,
                                color: Colors.yellow,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                t('procSteps'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ..._getSteps().map((step) {
                            bool isDone =
                                step['id'] < _currentStep || _scenarioValidated;
                            bool isActive =
                                step['id'] == _currentStep &&
                                !_scenarioValidated;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.yellow
                                    : const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isActive
                                      ? Colors.yellow
                                      : Colors.white12,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    isDone
                                        ? Icons.check_circle
                                        : (isActive
                                              ? Icons.play_circle_fill
                                              : Icons.circle_outlined),
                                    color: isActive
                                        ? Colors.black
                                        : (isDone ? Colors.green : Colors.grey),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "${t('step')} ${step['id']}: ${step['inst']}",
                                      style: TextStyle(
                                        color: isActive
                                            ? Colors.black
                                            : (isDone
                                                  ? Colors.grey
                                                  : Colors.white),
                                        fontWeight: isActive
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        decoration: isDone
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    const Spacer(),

                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.white12)),
                        color: Color(0xFF0F172A),
                      ),
                      child: Text(
                        '© ZeroScienceLab - Fall in love with math and Science',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingCard() {
    String currentInst = _scenarioValidated
        ? t('completedMsg')
        : _getSteps()[_currentStep - 1]['inst'];

    return Container(
      width: 500,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.yellow.withOpacity(0.5), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.yellow),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  currentInst,
                  style: TextStyle(
                    color: _scenarioValidated
                        ? Colors.greenAccent
                        : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _playSound(_clickSound);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t('noConversionNeeded')),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                icon: const Icon(Icons.sync_alt, size: 18),
                label: Text(t('convertUnits')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _scenarioValidated
                    ? null
                    : () {
                        _playSound(_clickSound);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(t('waiting')),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                icon: const Icon(Icons.fact_check, size: 18),
                label: Text(t('validate')),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessPopupOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Container(
            width: 550,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.yellow, width: 2),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.yellow,
                    size: 60,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    t('scenSummary'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: Text(
                      _currentScenario == 1 ? t('s1Sum') : t('s2Sum'),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _playSound(_clickSound);
                      setState(() => _showSuccessPopup = false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text(t('closeAndContinue')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // COMMON ASSETS & BACKGROUND
  // ---------------------------------------------------------

  Widget _buildFloorBackground() {
    return Positioned.fill(
      child: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                Container(color: const Color(0xFFCBE3FA)),
                Positioned(
                  top: 50,
                  left: 100,
                  child: Icon(
                    Icons.settings,
                    color: Colors.blueGrey.withOpacity(0.15),
                    size: 120,
                  ),
                ),
                Positioned(
                  top: 100,
                  left: 180,
                  child: Icon(
                    Icons.settings,
                    color: Colors.blueGrey.withOpacity(0.15),
                    size: 80,
                  ),
                ),
                Positioned(
                  top: 150,
                  right: 200,
                  child: Icon(
                    Icons.settings,
                    color: Colors.blueGrey.withOpacity(0.15),
                    size: 150,
                  ),
                ),
                Positioned(
                  top: 80,
                  left: 350,
                  child: Container(
                    width: 60,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB0D0F0),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.blueGrey.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 120,
                  right: 400,
                  child: Container(
                    width: 80,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB0D0F0),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.blueGrey.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFB4D8F8), Color(0xFFE4F0FB)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= SCENARIO 1 UI =================
  Widget _buildScenario1() {
    double animVal = _beltAnimationController.value;

    double startX = 360.0;
    double endX = 950.0;
    double currentBoxX = startX + ((endX - startX) * animVal);
    double currentBoxY = 365.0;

    if (animVal > 0.85) {
      currentBoxY += (animVal - 0.85) * 1200;
      if (currentBoxY > 510) currentBoxY = 510;
    }

    return Stack(
      children: [
        _buildFloorBackground(),
        Positioned(top: 450, left: 260, child: _buildConveyorBeltBase()),
        Positioned(
          top: 250,
          left: 690,
          child: Container(
            width: 200,
            height: 250,
            decoration: BoxDecoration(
              color: const Color(0xFF94A3B8),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        Positioned(
          top: 480,
          left: 900,
          child: Container(
            width: 220,
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF94A3B8), width: 4),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 120,
                color: const Color(0xFF94A3B8).withOpacity(0.5),
              ),
            ),
          ),
        ),
        Positioned(
          top: 350,
          left: 260,
          child: DragTarget<String>(
            builder: (context, candidateData, rejectedData) {
              return Container(
                width: 400,
                height: 150,
                color: candidateData.isNotEmpty
                    ? Colors.greenAccent.withOpacity(0.3)
                    : Colors.transparent,
              );
            },
            onAcceptWithDetails: (details) {
              if (details.data == 'box_x' && _currentStep == 1) {
                _playSound(_dropSound);
                setState(() => _s1BoxXOnBelt = true);
                _completeStep();
              } else if (details.data == 'apple' && _currentStep == 2) {
                _playSound(_dropSound);
                setState(() {
                  _s1ApplesOnBelt++;
                  if (_s1ApplesOnBelt == 3) _completeStep();
                });
              }
            },
          ),
        ),
        if (_s1BoxXOnBelt)
          Positioned(
            left: _s1MachineRunning ? currentBoxX : 560.0,
            top: _s1MachineRunning ? currentBoxY : 365.0,
            child: GestureDetector(
              onTap: () {
                if (_s1MachineRunning && _currentStep == 4 && animVal == 1.0) {
                  _playSound(_successSound);
                  setState(() => _s1BoxOpened = true);
                  _completeStep();
                }
              },
              child: _buildBlockyBoxX(opened: _s1BoxOpened, size: 85),
            ),
          ),
        for (int i = 0; i < _s1ApplesOnBelt; i++) ...[
          Builder(
            builder: (context) {
              double appleStartX = 480.0 - (i * 60);
              double appleEndX = 920.0 + (i * 35);
              double currentAppleX =
                  appleStartX + ((appleEndX - appleStartX) * animVal);
              double currentAppleY = 410.0;

              if (animVal > 0.85) {
                currentAppleY += (animVal - 0.85) * 1200;
                if (currentAppleY > 550) currentAppleY = 550;
              }

              return Positioned(
                left: _s1MachineRunning ? currentAppleX : appleStartX,
                top: _s1MachineRunning ? currentAppleY : 410.0,
                child: _buildApple(size: 40),
              );
            },
          ),
        ],
        Positioned(top: 250, left: 660, child: _buildMachineFront(animVal)),
        Positioned(
          top: 450,
          left: 960,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade400, width: 3),
            ),
            child: Row(
              children: [
                Text(
                  t('totalApples'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _s1BoxOpened ? "8" : "?",
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 16,
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 165,
          left: 945,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade800,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  t('startBtn'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () {
                  if (_currentStep == 3 &&
                      _s1BoxXOnBelt &&
                      _s1ApplesOnBelt == 3) {
                    _playSound(_startSound);
                    setState(() => _s1MachineRunning = true);
                    _beltAnimationController.forward();
                    Future.delayed(const Duration(seconds: 3), _completeStep);
                  }
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF10B981),
                    border: Border.all(
                      color: Colors.greenAccent.shade100,
                      width: 4,
                    ),
                    boxShadow: [
                      if (_currentStep == 3)
                        const BoxShadow(
                          color: Colors.greenAccent,
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 5,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(top: 120, left: 30, child: _buildInventoryPanel()),
        Positioned(
          top: 150,
          left: 280,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade800,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueGrey.shade400, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  t('applesAdded'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$_s1ApplesOnBelt/3",
                  style: TextStyle(
                    color: _s1ApplesOnBelt == 3
                        ? Colors.greenAccent
                        : Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryPanel() {
    return Container(
      width: 180,
      height: 480,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          const SizedBox(height: 15),
          Text(
            t('placingMysteryBox'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: !_s1BoxXOnBelt
                  ? Draggable<String>(
                      data: 'box_x',
                      feedback: _buildBlockyBoxX(opacity: 0.8, size: 80),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: _buildBlockyBoxX(size: 80),
                      ),
                      child: _buildBlockyBoxX(size: 80),
                    )
                  : Opacity(opacity: 0.3, child: _buildBlockyBoxX(size: 80)),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            t('addingApples'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: _s1ApplesOnBelt < 3
                  ? Draggable<String>(
                      data: 'apple',
                      feedback: _buildApple(opacity: 0.9, size: 50),
                      childWhenDragging: _buildAppleBasket(),
                      child: _buildAppleBasket(),
                    )
                  : Opacity(opacity: 0.5, child: _buildAppleBasket()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppleBasket() {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(bottom: 30, left: 10, child: _buildApple(size: 35)),
          Positioned(bottom: 35, right: 10, child: _buildApple(size: 35)),
          Positioned(bottom: 45, left: 25, child: _buildApple(size: 35)),
          Positioned(bottom: 55, left: 40, child: _buildApple(size: 35)),
          Positioned(bottom: 30, left: 45, child: _buildApple(size: 35)),
          Positioned(
            bottom: 0,
            child: Container(
              width: 90,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFD9A05B),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                border: Border.all(color: const Color(0xFF8B5A2B), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: 2,
                    color: const Color(0xFF8B5A2B).withOpacity(0.5),
                  ),
                  Container(
                    height: 2,
                    color: const Color(0xFF8B5A2B).withOpacity(0.5),
                  ),
                  Container(
                    height: 2,
                    color: const Color(0xFF8B5A2B).withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConveyorBeltBase() {
    return Container(
      width: 520,
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF475569),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF334155), width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              border: Border(
                bottom: BorderSide(color: Colors.black54, width: 2),
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                35,
                (index) => Container(
                  width: 2,
                  color: Colors.white12,
                  transform: Matrix4.translationValues(
                    _s1MachineRunning ? -(_s1ConveyorPosition * 60) % 20 : 0,
                    0,
                    0,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFF64748B),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  20,
                  (index) => Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: const Color(0xFF94A3B8),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF475569),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMachineFront(double animVal) {
    bool isInsideScanner = animVal > 0.4 && animVal < 0.6;

    return Column(
      children: [
        Container(
          width: 260,
          height: 90,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF64748B), width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Text(
              !_s1MachineRunning ? "" : (_s1BoxOpened ? "5 + 3 = 8" : "x + 3"),
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 32,
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.greenAccent, blurRadius: 10)],
              ),
            ),
          ),
        ),
        Container(width: 60, height: 30, color: const Color(0xFF94A3B8)),
        Container(
          width: 200,
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFCBD5E1), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(-5, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 20,
                right: 20,
                child: Container(
                  height: 120,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                ),
              ),
              if (isInsideScanner)
                Positioned(
                  top: 70,
                  left: 30,
                  right: 30,
                  child: Container(
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Colors.greenAccent,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.greenAccent,
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBlockyBoxX({
    double opacity = 1.0,
    bool opened = false,
    double size = 90,
  }) {
    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: size + (size * 0.3),
        height: size + (size * 0.3),
        child: opened
            ? Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: -5,
                    top: size + (size * 0.1),
                    child: Transform(
                      transform: Matrix4.skewX(-0.8),
                      child: Container(
                        width: size,
                        height: 15,
                        color: Colors.black.withOpacity(0.4),
                      ),
                    ),
                  ),
                  Positioned(
                    left: size * 0.15,
                    top: size * 0.25,
                    child: Container(
                      width: size * 0.85,
                      height: size * 0.75,
                      color: const Color(0xFF1E1F66),
                    ),
                  ),
                  Positioned(
                    left: size * 0.25,
                    top: -size * 0.1,
                    child: Transform(
                      transform: Matrix4.skewX(-0.8),
                      child: Container(
                        width: size,
                        height: size * 0.35,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6F72FA),
                          border: Border.all(
                            color: const Color(0xFFA1A3FF),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: size * 0.3,
                    left: size * 0.1,
                    child: _buildApple(size: size * 0.4),
                  ),
                  Positioned(
                    top: size * 0.3,
                    left: size * 0.5,
                    child: _buildApple(size: size * 0.4),
                  ),
                  Positioned(
                    top: size * 0.1,
                    left: size * 0.3,
                    child: _buildApple(size: size * 0.4),
                  ),
                  Positioned(
                    top: -size * 0.05,
                    left: size * 0.1,
                    child: _buildApple(size: size * 0.4),
                  ),
                  Positioned(
                    top: -size * 0.05,
                    left: size * 0.5,
                    child: _buildApple(size: size * 0.4),
                  ),
                  Positioned(
                    left: 0,
                    top: size * 0.55,
                    child: Container(
                      width: size,
                      height: size * 0.45,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4C4DF2),
                        border: Border.all(
                          color: const Color(0xFFA1A3FF),
                          width: 3,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "X",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size * 0.3,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: size,
                    top: size * 0.55,
                    child: Transform(
                      transform: Matrix4.skewY(-0.8),
                      child: Container(
                        width: size * 0.25,
                        height: size * 0.45,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3335A6),
                          border: Border.all(
                            color: const Color(0xFF6F72FA),
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Stack(
                children: [
                  Positioned(
                    left: -5,
                    top: size + (size * 0.1),
                    child: Transform(
                      transform: Matrix4.skewX(-0.8),
                      child: Container(
                        width: size,
                        height: 15,
                        color: Colors.black.withOpacity(0.4),
                      ),
                    ),
                  ),
                  Positioned(
                    left: size * 0.25,
                    top: 0,
                    child: Transform(
                      transform: Matrix4.skewX(-0.8),
                      child: Container(
                        width: size,
                        height: size * 0.25,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9A05B),
                          border: Border.all(
                            color: const Color(0xFFF0B27A),
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                  Positioned(
                    left: size,
                    top: size * 0.25,
                    child: Transform(
                      transform: Matrix4.skewY(-0.8),
                      child: Container(
                        width: size * 0.25,
                        height: size,
                        decoration: BoxDecoration(
                          color: const Color(0xFFA9764E),
                          border: Border.all(
                            color: const Color(0xFFC28E60),
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: size * 0.25,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC28E60),
                        border: Border.all(
                          color: const Color(0xFFE5A872),
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "X",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size * 0.4,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildApple({double opacity = 1.0, double size = 40}) {
    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size * 0.85,
              height: size * 0.85,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 5,
                    offset: const Offset(-2, 4),
                  ),
                ],
                gradient: const RadialGradient(
                  colors: [
                    Colors.white70,
                    Color(0xFFF05151),
                    Color(0xFFB91C1C),
                  ],
                  center: Alignment(-0.3, -0.3),
                  radius: 0.9,
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: Container(
                width: size * 0.08,
                height: size * 0.25,
                color: const Color(0xFF3E2723),
              ),
            ),
            Positioned(
              top: size * 0.03,
              right: size * 0.15,
              child: Transform.rotate(
                angle: 0.5,
                child: Container(
                  width: size * 0.35,
                  height: size * 0.18,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(10),
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

  // ================= SCENARIO 2 UI =================
  Widget _buildScenario2() {
    return Stack(
      children: [
        _buildFloorBackground(),
        Positioned(
          bottom: 200,
          left: 530,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: Colors.yellowAccent),
            ),
            child: Text(
              t('outTray'),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 80,
          left: 300,
          child: Container(
            width: 550,
            height: 110,
            decoration: BoxDecoration(
              color: const Color(0xFF475569),
              border: Border.all(color: const Color(0xFF334155), width: 5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Stack(
              children: [
                if (_s2MachineRunning)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      3,
                      (index) => Center(
                        child: GestureDetector(
                          onTap: () {
                            if (_currentStep == 4) {
                              setState(() => _s2CratesOpened = true);
                              _completeStep();
                            }
                          },
                          child: _buildBlockyBoxY(
                            opened: _s2CratesOpened,
                            size: 85,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 480,
          left: 450,
          child: Container(width: 250, height: 35, color: Colors.black),
        ),
        Positioned(
          top: 250,
          left: 460,
          child: Container(
            width: 230,
            height: 230,
            decoration: const BoxDecoration(
              color: Color(0xFFD1D5DB),
              boxShadow: [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 10,
                  offset: Offset(5, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 170,
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            color: Colors.white,
                            alignment: Alignment.center,
                            child: Text(
                              _s2DialValue.toString(),
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              if (_currentStep == 2 && _s2DialValue < 3) {
                                _playSound(_clickSound);
                                setState(() {
                                  _s2DialValue++;
                                  if (_s2DialValue == 3) _completeStep();
                                });
                              }
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6),
                                boxShadow: [
                                  if (_currentStep == 2)
                                    const BoxShadow(
                                      color: Colors.blueAccent,
                                      blurRadius: 10,
                                    ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          if (_currentStep == 3 && _s2DialValue == 3) {
                            _playSound(_startSound);
                            setState(() => _s2MachineRunning = true);
                            Future.delayed(
                              const Duration(milliseconds: 1500),
                              _completeStep,
                            );
                          }
                        },
                        child: Container(
                          width: 140,
                          height: 35,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            boxShadow: [
                              if (_currentStep == 3)
                                const BoxShadow(
                                  color: Colors.redAccent,
                                  blurRadius: 10,
                                ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              t('dupBtn'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 170,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade400, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 180,
          left: 475,
          child: Container(
            width: 200,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(0.3),
              border: Border.all(color: Colors.greenAccent),
              boxShadow: [
                BoxShadow(
                  color: Colors.greenAccent.withOpacity(0.2),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  t('systemStatus'),
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _s2MachineRunning
                      ? "3y=12"
                      : (_s2CrateYInMachine ? t('ready') : t('wait')),
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 28,
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 130,
          left: 520,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: Colors.yellowAccent),
            ),
            child: Text(
              t('inHopper'),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Positioned(
          top: 100,
          left: 500,
          child: DragTarget<String>(
            builder: (context, candidateData, rejectedData) {
              return Container(
                width: 150,
                height: 150,
                color: candidateData.isNotEmpty
                    ? Colors.green.withOpacity(0.2)
                    : Colors.transparent,
                child: _s2CrateYInMachine
                    ? Align(
                        alignment: Alignment.bottomCenter,
                        child: _buildBlockyBoxY(size: 85),
                      )
                    : const SizedBox(),
              );
            },
            onAcceptWithDetails: (details) {
              if (details.data == 'crate_y' && _currentStep == 1) {
                _playSound(_dropSound);
                setState(() => _s2CrateYInMachine = true);
                _completeStep();
              }
            },
          ),
        ),
        if (!_s2CrateYInMachine)
          Positioned(
            top: 380,
            left: 340,
            child: Draggable<String>(
              data: 'crate_y',
              feedback: _buildBlockyBoxY(opacity: 0.8, size: 100),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: _buildBlockyBoxY(size: 100),
              ),
              child: _buildBlockyBoxY(size: 100),
            ),
          ),
      ],
    );
  }

  Widget _buildBlockyBoxY({
    double opacity = 1.0,
    bool opened = false,
    double size = 90,
  }) {
    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: size + (size * 0.3),
        height: size + (size * 0.3),
        child: opened
            ? Wrap(
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                children: List.generate(
                  4,
                  (_) => Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(
                      Icons.directions_car,
                      color: Colors.yellow,
                      size: size * 0.35,
                    ),
                  ),
                ),
              )
            : Stack(
                children: [
                  Positioned(
                    left: -5,
                    top: size + (size * 0.1),
                    child: Transform(
                      transform: Matrix4.skewX(-0.8),
                      child: Container(
                        width: size,
                        height: 15,
                        color: Colors.black.withOpacity(0.4),
                      ),
                    ),
                  ),
                  Positioned(
                    left: size * 0.25,
                    top: 0,
                    child: Transform(
                      transform: Matrix4.skewX(-0.8),
                      child: Container(
                        width: size,
                        height: size * 0.25,
                        decoration: BoxDecoration(
                          color: const Color(0xFF34D399),
                          border: Border.all(
                            color: const Color(0xFF6EE7B7),
                            width: 3,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Transform(
                          transform: Matrix4.skewX(0.8),
                          child: Text(
                            "y",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: size * 0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: size,
                    top: size * 0.25,
                    child: Transform(
                      transform: Matrix4.skewY(-0.8),
                      child: Container(
                        width: size * 0.25,
                        height: size,
                        decoration: BoxDecoration(
                          color: const Color(0xFF047857),
                          border: Border.all(
                            color: const Color(0xFF34D399),
                            width: 3,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Transform(
                          transform: Matrix4.skewY(0.8),
                          child: Text(
                            "y",
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: size * 0.18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: size * 0.25,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        border: Border.all(
                          color: const Color(0xFF6EE7B7),
                          width: 3,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "y",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size * 0.4,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
