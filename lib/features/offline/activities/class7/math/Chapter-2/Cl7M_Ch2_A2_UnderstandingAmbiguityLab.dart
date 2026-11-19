// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const UnderstandingAmbiguityApp());
}

class UnderstandingAmbiguityApp extends StatelessWidget {
  const UnderstandingAmbiguityApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Order in Operations',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: const Color(0xFFEAB308),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFEAB308),
          secondary: Color(0xFF3B82F6),
          surface: Color(0xFF1E293B),
        ),
        fontFamily: 'PlusJakartaSans',
      ),
      home: const UnderstandingAmbiguityLab(),
    );
  }
}

class UnderstandingAmbiguityLab extends StatefulWidget {
  const UnderstandingAmbiguityLab({Key? key}) : super(key: key);

  @override
  State<UnderstandingAmbiguityLab> createState() =>
      _UnderstandingAmbiguityLabState();
}

class _UnderstandingAmbiguityLabState extends State<UnderstandingAmbiguityLab>
    with TickerProviderStateMixin {
  // --- Audio Setup ---
  final AudioPlayer _audioPlayer = AudioPlayer();

  final String _clickSound =
      'audio/class7/mixkit_2568.mp3';
  final String _snapSound =
      'audio/class7/mixkit_392.mp3';
  final String _successSound =
      'audio/class7/mixkit_2018.mp3';
  final String _errorSound =
      'audio/class7/mixkit_2954.mp3';

  // --- State Variables ---
  bool _isLabEntered = false;
  bool _isSidebarOpen = true;
  int _currentScenarioId = 1;
  int _currentStepIndex = 0;

  final Map<String, String> _slots = {};

  // --- Translation Setup ---
  final List<String> _languages = ['en', 'hi'];
  int _currentLangIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
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
      await _audioPlayer.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio play failed: $e");
    }
  }

  void _toggleLanguage() {
    _playSound(_clickSound);
    setState(() {
      _currentLangIndex = (_currentLangIndex + 1) % _languages.length;
    });
  }

  void _resetLab() {
    _playSound(_clickSound);
    setState(() {
      _currentLangIndex = 0;
      _isLabEntered = false;
      _currentScenarioId = 1;
      _resetScenario();
    });
  }

  void _resetScenario() {
    setState(() {
      _slots.clear();
      _currentStepIndex = 0;
    });
  }

  void _loadScenario(int id) {
    _playSound(_clickSound);
    setState(() {
      _currentScenarioId = id;
      _resetScenario();
      if (MediaQuery.of(context).size.width <= 768) {
        _isSidebarOpen = false;
      }
    });
  }

  void _validate() {
    _playSound(_clickSound);

    bool success = false;
    String errorMessage = t('err_default');
    String title = t('val_success');
    String mathStr = '';
    String descStr = '';

    switch (_currentScenarioId) {
      case 1:
        if (_currentStepIndex == 0) {
          int apples = _slots.values.where((v) => v.startsWith('a_')).length;
          int boxes = _slots.values.where((v) => v.startsWith('b_')).length;
          if (apples == 2 && boxes == 3) {
            success = true;
            title = t('fsCorrect');
            mathStr = r"2 + (3 × 4) = 14";
          } else {
            errorMessage = t('s1_err2');
          }
        } else if (_currentStepIndex == 1) {
          int apples = _slots.values.where((v) => v.startsWith('a_')).length;
          int emptyBoxes = _slots.values
              .where((v) => v.startsWith('e_'))
              .length;
          if (apples == 2 && emptyBoxes == 3) {
            success = true;
            title = t('fsIncorrect');
            mathStr = r"(2 + 3) × 4 = 20";
          } else {
            errorMessage = "Drag 2 apples and 3 EMPTY boxes.";
          }
        } else {
          success = true;
          title = t('fsSummary');
          mathStr = t('rule_mult_add');
        }
        break;

      case 2:
        if (_currentStepIndex == 0) {
          if (_slots.containsKey('belt_tray')) {
            success = true;
            title = t('fsGrpAdded');
            mathStr = r"Tray added to belt";
          } else {
            errorMessage = "Drag the Grouping Tray to the belt.";
          }
        } else if (_currentStepIndex == 1) {
          int fruitsInTray = _slots.keys
              .where((k) => k.startsWith('tray_in_'))
              .length;
          if (fruitsInTray == 5) {
            success = true;
            title = t('fsGrpSolved');
            mathStr = r"(2 + 3) grouped";
          } else {
            errorMessage = "Drag 2 Apples and 3 Strawberries into the Tray.";
          }
        } else if (_currentStepIndex == 2) {
          if (_slots.containsKey('belt_mult')) {
            success = true;
            title = t('fsCorrCalc');
            mathStr = r"4 × (2 + 3) = 20";
          } else {
            errorMessage = "Drag the Multiplier Machine onto the belt.";
          }
        } else {
          success = true;
          title = t('fsSummary');
          mathStr = t('rule_comp_brac');
        }
        break;

      case 3:
        if (_currentStepIndex == 0) {
          if (_slots.containsValue('juice') &&
              _slots.containsValue('sandwich')) {
            success = true;
            title = t('fsGrpAdded');
            mathStr = r"(15 + 56) = 71";
          } else {
            errorMessage = "Drag both Juice and Sandwich into the Basket.";
          }
        } else if (_currentStepIndex == 1) {
          if (_slots.containsKey('register_zone')) {
            success = true;
            title = t('fsCorrCalc');
            mathStr = r"100 - (15 + 56) = 29";
          } else {
            errorMessage = "Drag the Shopping Basket to the Cash Register.";
          }
        } else if (_currentStepIndex == 2) {
          success = true;
          title = t('fsIncorrCalc');
          mathStr = r"100 - 15 + 56 = 141";
        } else {
          success = true;
          title = t('fsSummary');
          mathStr = t('rule_grp_sub');
        }
        break;

      case 4:
        if (_currentStepIndex == 0) {
          if (_slots.length == 5) {
            success = true;
            title = t('fsActionVal');
            mathStr = r"Tools placed!";
          } else {
            errorMessage = "Drag all 5 tools to their placeholders.";
          }
        } else if (_currentStepIndex == 1) {
          success = true;
          title = t('fsCorrRes');
          mathStr = r"5 × (4 + 2) = 30";
          descStr = t('fs_s4_correct_desc');
        } else if (_currentStepIndex == 2) {
          success = true;
          title = t('fsIncorrRes');
          mathStr = r"5 × 4 + 2 = 22";
          descStr = t('fs_s4_incorrect_desc');
        } else {
          success = true;
          title = t('fsSummary');
          mathStr = t('rule_grp_mult');
          descStr = t('fs_s4_summary_desc');
        }
        break;
    }

    if (success) {
      _playSound(_successSound);
      _showValidationPopup(title, mathStr, descStr);
    } else {
      _playSound(_errorSound);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showValidationPopup(String title, String mathStr, String descStr) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF3B82F6), width: 2),
          ),
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  mathStr, // Note: Use a LaTeX parser like flutter_math_fork if rendering real equations is needed in the UI.
                  style: const TextStyle(
                    fontSize: 24,
                    fontFamily: 'monospace',
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (descStr.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    descStr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                if (_currentStepIndex < _getSteps().length - 1) {
                  setState(() {
                    _currentStepIndex++;
                    _slots.clear();
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Text(
                  t('continueBtn'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String t(String key) {
    final lang = _languages[_currentLangIndex];
    return _translations[lang]?[key] ?? _translations['en']?[key] ?? key;
  }

  final Map<String, Map<String, String>> _translations = {
    'en': {
      'mainTitle': "Order in Operations: Brackets",
      'subTitle': "Class 7 • ARITHMETIC EXPRESSIONS",
      'btn_enter': "Enter Lab",
      'selectScenario': "SELECT SCENARIO",
      'missionObj': "MISSION OBJECTIVE",
      'procSteps': "PROCEDURAL STEPS",
      'valModel': "VALIDATE MODEL",
      'startFac': "START FACTORY",
      'showErr': "SHOW ERROR",
      'testBtn': "TEST",
      'continueBtn': "CONTINUE",
      'nextStep': "NEXT STEP",
      'footer_copy': "© ZeroScienceLab - Fall in love with math and Science",
      'err_default': "Incorrect assembly. Please follow the instructions.",
      'val_success': "Validation Successful",
      'scen1': "1. The Ambiguous Smoothie",
      'scen2': "2. Grouping with Brackets",
      'scen3': "3. The Shopping Voucher",
      'scen4': "4. The Zookeeper's Meal Plan",
      'fsCorrect': "Correct Sequence",
      'fsIncorrect': "Incorrect Sequence",
      'fsSummary': "Summary",
      'fsGrpSolved': "Grouping Solved!",
      'fsGrpAdded': "Group Added",
      'fsCorrCalc': "Correct Calculation",
      'fsIncorrCalc': "Incorrect Calculation",
      'fsCorrRes': "Correct Result",
      'fsIncorrRes': "Incorrect Result",
      'fsActionVal': "Action Validated!",
      'rule_mult_add': r"Rule: Multiply before Add",
      'rule_comp_brac': r"Rule: Compute Brackets First",
      'rule_grp_sub': r"Rule: Group before Subtract",
      'rule_grp_mult': r"Rule: Group Before Multiplying",
      's1_obj':
          "Demonstrate that 2 + 3 × 4 can lead to ambiguity without rules.",
      's1_step1': "Drag 2 Apples and 3 Boxes onto the conveyor belt.",
      's1_step2': "Try incorrect method: Drag 2 Apples and 3 EMPTY Boxes.",
      's1_step3': "Review the mathematical rule.",
      's1_err2': "Please drag exactly 2 Apples and 3 Boxes into the slots.",
      's2_obj': "Introduce brackets as a physical 'Grouping Tray'.",
      's2_step1': "Drag the Grouping Tray onto the belt.",
      's2_step2': "Drag 2 Apples and 3 Strawberries INSIDE the tray.",
      's2_step3': "Drag the Multiplier Machine onto the belt.",
      's2_step4': "Review the conclusion.",
      's3_obj': "Apply brackets in subtraction (shopping example).",
      's3_step1': "Drag Juice (₹15) and Sandwich (₹56) into the Basket.",
      's3_step2': "Drag the Basket to the Cash Register.",
      's3_step3': "Check the Incorrect Method (without grouping).",
      's3_step4': "Review the conclusion.",
      's4_obj': "Construct 5 × (4 + 2) for monkeys.",
      's4_step1':
          "Drag Banana, Apple, Tray, Blender, and Multiplier to placeholders.",
      's4_step2': "Test the CORRECT method (with brackets).",
      's4_step3': "Test the INCORRECT method (no brackets).",
      's4_step4': "Review the conclusion.",
      'fs_s4_correct_desc':
          "By grouping bananas and apples first, all 5 monkeys get 6 fruits.",
      'fs_s4_incorrect_desc':
          "Without the grouping tray, order of operations forces multiplication first (5 × 4). Monkeys get unequal meals!",
      'fs_s4_summary_desc':
          "Always use brackets to group elements that must be processed together.",
    },
    'hi': {
      'mainTitle': "संचालन का क्रम: कोष्ठक की शक्ति",
      'subTitle': "कक्षा 7 • अंकगणितीय व्यंजक",
      'btn_enter': "लैब में प्रवेश करें",
      'selectScenario': "परिदृश्य चुनें",
      'missionObj': "मिशन का उद्देश्य",
      'procSteps': "प्रक्रियात्मक चरण",
      'valModel': "मॉडल मान्य करें",
      'startFac': "फैक्ट्री शुरू करें",
      'showErr': "त्रुटि दिखाएं",
      'testBtn': "परीक्षण",
      'continueBtn': "जारी रखें",
      'nextStep': "अगला कदम",
      'footer_copy': "© ZeroScienceLab - गणित और विज्ञान से प्यार करें",
      'err_default': "गलत संयोजन। कृपया निर्देशों का पालन करें।",
      'val_success': "सत्यापन सफल",
      'scen1': "1. अस्पष्ट स्मूदी",
      'scen2': "2. कोष्ठक के साथ समूहीकरण",
      'scen3': "3. शॉपिंग वाउचर",
      'scen4': "4. चिड़ियाघर भोजन योजना",
      'fsCorrect': "सही क्रम",
      'fsIncorrect': "गलत क्रम",
      'fsSummary': "सारांश",
      'fsGrpSolved': "समूहीकरण हल किया गया!",
      'fsGrpAdded': "समूह जोड़ा गया",
      'fsCorrCalc': "सही गणना",
      'fsIncorrCalc': "गलत गणना",
      'fsCorrRes': "सही परिणाम",
      'fsIncorrRes': "गलत परिणाम",
      'fsActionVal': "कार्रवाई मान्य!",
      'rule_mult_add': r"नियम: जोड़ने से पहले गुणा करें",
      'rule_comp_brac': r"नियम: पहले कोष्ठक हल करें",
      'rule_grp_sub': r"नियम: घटाने से पहले समूह बनाएं",
      'rule_grp_mult': r"नियम: गुणा करने से पहले समूह बनाएं",
      's1_obj':
          "प्रदर्शित करें कि 2 + 3 × 4 नियमों के बिना अस्पष्टता पैदा कर सकता है।",
      's1_step1': "कन्वेयर बेल्ट पर 2 सेब और 3 बॉक्स खींचें।",
      's1_step2': "गलत तरीका: 2 सेब और 3 खाली बॉक्स खींचें।",
      's1_step3': "गणितीय नियम की समीक्षा करें।",
      's1_err2': "कृपया स्लॉट में ठीक 2 सेब और 3 बॉक्स खींचें।",
      's2_obj': "कोष्ठक को भौतिक 'समूहीकरण ट्रे' के रूप में पेश करें।",
      's2_step1': "समूहीकरण ट्रे को बेल्ट पर खींचें।",
      's2_step2': "ट्रे के अंदर 2 सेब और 3 स्ट्रॉबेरी खींचें।",
      's2_step3': "गुणक मशीन को बेल्ट पर खींचें।",
      's2_step4': "निष्कर्ष की समीक्षा करें।",
      's3_obj': "घटाव में कोष्ठक लागू करें (खरीदारी उदाहरण)।",
      's3_step1': "रस (₹15) और सैंडविच (₹56) को टोकरी में खींचें।",
      's3_step2': "टोकरी को कैश रजिस्टर पर खींचें।",
      's3_step3': "गलत विधि की जाँच करें (बिना समूहीकरण)।",
      's3_step4': "निष्कर्ष की समीक्षा करें।",
      's4_obj': "बंदरों के लिए 5 × (4 + 2) का निर्माण करें।",
      's4_step1': "केला, सेब, ट्रे, ब्लेंडर और गुणक को स्थान पर खींचें।",
      's4_step2': "सही विधि का परीक्षण करें (कोष्ठक के साथ)।",
      's4_step3': "गलत विधि का परीक्षण करें (कोई कोष्ठक नहीं)।",
      's4_step4': "निष्कर्ष की समीक्षा करें।",
      'fs_s4_correct_desc':
          "पहले केले और सेब को समूहित करने से, सभी 5 बंदरों को 6 फल मिलते हैं।",
      'fs_s4_incorrect_desc':
          "ट्रे के बिना, संचालन का क्रम पहले गुणा करता है। बंदरों को असमान भोजन मिलता है!",
      'fs_s4_summary_desc':
          "हमेशा उन तत्वों को समूहित करने के लिए कोष्ठक का उपयोग करें जिन्हें एक साथ संसाधित किया जाना चाहिए।",
    },
  };

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sidebarWidth = size.width * 0.35;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        },
        child: Stack(
          children: [
            Positioned.fill(
              left: _isSidebarOpen ? sidebarWidth : 0,
              child: _buildCanvasArea(),
            ),
            if (!_isSidebarOpen && _isLabEntered)
              Positioned(top: 66, left: 16, child: _buildFloatingMissionCard()),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: _buildSidebar(sidebarWidth),
            ),
            if (_isLabEntered)
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                  color: const Color(0xFFEAB308),
                  iconSize: 28,
                  onPressed: () {
                    _playSound(_clickSound);
                    setState(() {
                      _isSidebarOpen = !_isSidebarOpen;
                    });
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A).withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: const Color(0xFFEAB308).withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutCubic,
              top: _isLabEntered ? -size.height : 0,
              left: 0,
              right: 0,
              height: size.height,
              child: IgnorePointer(
                ignoring: _isLabEntered,
                child: _buildCurtainScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurtainScreen() {
    return Container(
      color: const Color(0xFF020617),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.data_object, size: 80, color: Color(0xFFEAB308)),
            const SizedBox(height: 24),
            Text(
              t('mainTitle'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              t('subTitle'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                _playSound(_successSound);
                setState(() {
                  _isLabEntered = true;
                });
              },
              icon: const Icon(Icons.play_circle_fill, size: 28),
              label: Text(
                t('btn_enter'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEAB308),
                foregroundColor: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvasArea() {
    return Container(
      color: const Color(0xFF0F172A),
      child: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(2500),
        minScale: 0.2,
        maxScale: 3.0,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: _buildScenarioContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScenarioContent() {
    switch (_currentScenarioId) {
      case 1:
        return _buildScenario1();
      case 2:
        return _buildScenario2();
      case 3:
        return _buildScenario3();
      case 4:
        return _buildScenario4();
      default:
        return const SizedBox();
    }
  }

  // --- Scenario 1: Redesigned ---
  Widget _buildScenario1() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDraggable(
              'a_1',
              'Apple',
              Colors.redAccent,
              icon: Icons.apple,
            ),
            const SizedBox(width: 10),
            _buildDraggable(
              'a_2',
              'Apple',
              Colors.redAccent,
              icon: Icons.apple,
            ),
            const SizedBox(width: 30),
            _buildDraggable(
              'b_1',
              'Box (4)',
              Colors.orangeAccent,
              icon: Icons.inventory_2,
            ),
            const SizedBox(width: 10),
            _buildDraggable(
              'b_2',
              'Box (4)',
              Colors.orangeAccent,
              icon: Icons.inventory_2,
            ),
            const SizedBox(width: 10),
            _buildDraggable(
              'b_3',
              'Box (4)',
              Colors.orangeAccent,
              icon: Icons.inventory_2,
            ),
            const SizedBox(width: 30),
            if (_currentStepIndex == 1) ...[
              _buildDraggable(
                'e_1',
                'Empty\nBox',
                Colors.grey,
                icon: Icons.inventory_2_outlined,
              ),
              const SizedBox(width: 10),
              _buildDraggable(
                'e_2',
                'Empty\nBox',
                Colors.grey,
                icon: Icons.inventory_2_outlined,
              ),
              const SizedBox(width: 10),
              _buildDraggable(
                'e_3',
                'Empty\nBox',
                Colors.grey,
                icon: Icons.inventory_2_outlined,
              ),
            ],
          ],
        ),
        const SizedBox(height: 60),
        // Stylized Conveyor Belt container
        _buildConveyorBelt([
          _buildDropZone('c_1', 'Slot 1'),
          const SizedBox(width: 15),
          _buildDropZone('c_2', 'Slot 2'),
          const SizedBox(width: 15),
          _buildDropZone('c_3', 'Slot 3'),
          const SizedBox(width: 15),
          _buildDropZone('c_4', 'Slot 4'),
          const SizedBox(width: 15),
          _buildDropZone('c_5', 'Slot 5'),
        ]),
      ],
    );
  }

  // Visual component for Conveyor Belt
  Widget _buildConveyorBelt(List<Widget> dropZones) {
    return Container(
      height: 140,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF334155), // Slate 700
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF475569),
          width: 6,
        ), // Slate 600
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            offset: Offset(0, 10),
            blurRadius: 15,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rollers background details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              20,
              (index) => Container(
                width: 6,
                height: 130,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          // Belt shadow overlay
          Container(height: 140, color: Colors.black.withOpacity(0.2)),
          // Interactive Drop Zones
          Row(mainAxisSize: MainAxisSize.min, children: dropZones),
        ],
      ),
    );
  }

  Widget _buildScenario2() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_currentStepIndex == 0)
              _buildDraggable(
                'tray',
                'Grouping\nTray ( )',
                Colors.purpleAccent,
                width: 120,
              ),
            if (_currentStepIndex == 1) ...[
              _buildDraggable(
                'a_1',
                'Apple',
                Colors.redAccent,
                icon: Icons.apple,
              ),
              const SizedBox(width: 10),
              _buildDraggable(
                'a_2',
                'Apple',
                Colors.redAccent,
                icon: Icons.apple,
              ),
              const SizedBox(width: 20),
              _buildDraggable('s_1', 'Strawb.', Colors.pinkAccent),
              const SizedBox(width: 10),
              _buildDraggable('s_2', 'Strawb.', Colors.pinkAccent),
              const SizedBox(width: 10),
              _buildDraggable('s_3', 'Strawb.', Colors.pinkAccent),
            ],
            if (_currentStepIndex == 2)
              _buildDraggable(
                'mult',
                'Multiplier\nMachine',
                Colors.blueGrey,
                width: 120,
              ),
          ],
        ),
        const SizedBox(height: 60),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_currentStepIndex >= 0)
                _buildDropZone(
                  'belt_tray',
                  'Place Tray',
                  width: 250,
                  height: 100,
                  color: _slots.containsKey('belt_tray')
                      ? Colors.purple.withOpacity(0.3)
                      : null,
                ),
              const SizedBox(width: 30),
              if (_currentStepIndex >= 2)
                _buildDropZone(
                  'belt_mult',
                  'Place Mult.',
                  width: 120,
                  height: 100,
                ),
            ],
          ),
        ),
        if (_slots.containsKey('belt_tray') && _currentStepIndex == 1)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDropZone('tray_in_1', 'In Tray'),
                const SizedBox(width: 5),
                _buildDropZone('tray_in_2', 'In Tray'),
                const SizedBox(width: 5),
                _buildDropZone('tray_in_3', 'In Tray'),
                const SizedBox(width: 5),
                _buildDropZone('tray_in_4', 'In Tray'),
                const SizedBox(width: 5),
                _buildDropZone('tray_in_5', 'In Tray'),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildScenario3() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_currentStepIndex == 0) ...[
              _buildDraggable('juice', 'Juice\n₹15', Colors.orange),
              const SizedBox(width: 20),
              _buildDraggable('sandwich', 'Sandwich\n₹56', Colors.green),
            ],
            if (_currentStepIndex == 1)
              _buildDraggable(
                'basket',
                'Shopping\nBasket',
                Colors.brown,
                width: 100,
              ),
          ],
        ),
        const SizedBox(height: 60),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_currentStepIndex == 0)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.brown.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.brown),
                ),
                child: Row(
                  children: [
                    _buildDropZone('basket_in_1', 'To Basket'),
                    const SizedBox(width: 10),
                    _buildDropZone('basket_in_2', 'To Basket'),
                  ],
                ),
              ),
            const SizedBox(width: 60),
            if (_currentStepIndex == 1)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blueGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Cash Register',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _buildDropZone('register_zone', 'Drop Basket', width: 120),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildScenario4() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_currentStepIndex == 0)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDraggable('banana', 'Banana', Colors.yellow[700]!),
              const SizedBox(width: 10),
              _buildDraggable(
                'apple',
                'Apple',
                Colors.redAccent,
                icon: Icons.apple,
              ),
              const SizedBox(width: 10),
              _buildDraggable('tray', 'Tray ( )', Colors.purpleAccent),
              const SizedBox(width: 10),
              _buildDraggable('blender', 'Blender +', Colors.blue),
              const SizedBox(width: 10),
              _buildDraggable(
                'mult',
                'Multiplier x5',
                Colors.blueGrey,
                width: 100,
              ),
            ],
          ),
        const SizedBox(height: 60),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDropZone('zone_banana', 'Place Banana'),
              const SizedBox(width: 10),
              _buildDropZone('zone_apple', 'Place Apple'),
              const SizedBox(width: 10),
              _buildDropZone('zone_tray', 'Place Tray'),
              const SizedBox(width: 10),
              _buildDropZone('zone_blender', 'Place Blender'),
              const SizedBox(width: 10),
              _buildDropZone('zone_mult', 'Place Mult.', width: 100),
            ],
          ),
        ),
      ],
    );
  }

  // --- Common UI Components ---
  Widget _buildDraggable(
    String id,
    String label,
    Color color, {
    double width = 80,
    double height = 80,
    IconData? icon,
  }) {
    return Draggable<String>(
      data: id,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: width * 1.1,
          height: height * 1.1,
          decoration: BoxDecoration(
            color: color.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black45, blurRadius: 10, spreadRadius: 2),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) Icon(icon, color: Colors.white, size: 28),
                if (icon != null) const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      childWhenDragging: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) Icon(icon, color: Colors.white, size: 28),
              if (icon != null) const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropZone(
    String slotId,
    String label, {
    double width = 80,
    double height = 80,
    Color? color,
  }) {
    bool hasItem = _slots.containsKey(slotId);
    String? currentItem = hasItem ? _slots[slotId] : null;
    IconData? iconToDisplay = currentItem != null
        ? _getIconForData(currentItem)
        : null;

    return DragTarget<String>(
      onWillAccept: (data) => !hasItem,
      onAccept: (data) {
        _playSound(_snapSound);
        setState(() {
          _slots[slotId] = data;
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: hasItem
                ? Colors.grey[700]
                : (color ?? Colors.grey[800]!.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: candidateData.isNotEmpty
                  ? Colors.yellow
                  : Colors.grey[600]!,
              width: 2,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasItem && iconToDisplay != null)
                  Icon(iconToDisplay, color: Colors.white, size: 24),
                if (hasItem && iconToDisplay != null) const SizedBox(height: 4),
                Text(
                  hasItem ? _getLabelForData(currentItem!) : label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: hasItem ? Colors.white : Colors.white38,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData? _getIconForData(String data) {
    if (data.startsWith('a_')) return Icons.apple;
    if (data.startsWith('b_')) return Icons.inventory_2;
    if (data.startsWith('e_')) return Icons.inventory_2_outlined;
    return null;
  }

  String _getLabelForData(String data) {
    if (data.startsWith('a_')) return 'Apple';
    if (data.startsWith('b_')) return 'Box';
    if (data.startsWith('e_')) return 'Empty\nBox';
    if (data.startsWith('s_')) return 'Strawb.';
    if (data == 'tray') return 'Tray';
    if (data == 'mult') return 'Mult.';
    if (data == 'juice') return 'Juice';
    if (data == 'sandwich') return 'Sandwich';
    if (data == 'basket') return 'Basket';
    if (data == 'banana') return 'Banana';
    if (data == 'blender') return 'Blender';
    return data;
  }

  // --- Sidebar & Panels ---
  Widget _buildSidebar(double width) {
    return Material(
      elevation: 16,
      color: const Color(0xFF1E293B),
      child: Container(
        width: width,
        height: double.infinity,
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: Colors.white12)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.only(
                  top: 70,
                  left: 20,
                  right: 16,
                  bottom: 16,
                ),
                color: const Color(0xFF0F172A),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.data_object, color: Color(0xFFEAB308)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t('mainTitle'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t('subTitle'),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _toggleLanguage,
                          icon: const Icon(Icons.language, size: 16),
                          label: Text(
                            _languages[_currentLangIndex].toUpperCase(),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white10,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _resetLab,
                          icon: const Icon(Icons.refresh),
                          color: Colors.white,
                          tooltip: 'Reset Activity',
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('selectScenario'),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: _currentScenarioId,
                          dropdownColor: const Color(0xFF0F172A),
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white54,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          onChanged: (val) {
                            if (val != null) _loadScenario(val);
                          },
                          items: [
                            DropdownMenuItem(value: 1, child: Text(t('scen1'))),
                            DropdownMenuItem(value: 2, child: Text(t('scen2'))),
                            DropdownMenuItem(value: 3, child: Text(t('scen3'))),
                            DropdownMenuItem(value: 4, child: Text(t('scen4'))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Icon(
                          Icons.track_changes,
                          color: Color(0xFFEAB308),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          t('missionObj'),
                          style: const TextStyle(
                            color: Color(0xFFEAB308),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t('s${_currentScenarioId}_obj'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Icon(
                          Icons.list_alt,
                          color: Color(0xFF3B82F6),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          t('procSteps'),
                          style: const TextStyle(
                            color: Color(0xFF3B82F6),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._getSteps().asMap().entries.map((entry) {
                      int idx = entry.key;
                      String step = entry.value;
                      bool isActive = idx == _currentStepIndex;
                      bool isPast = idx < _currentStepIndex;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.blue.withOpacity(0.1)
                                : Colors.transparent,
                            border: Border.all(
                              color: isActive
                                  ? Colors.blue.withOpacity(0.5)
                                  : Colors.white12,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                isPast
                                    ? Icons.check_circle
                                    : (isActive
                                          ? Icons.play_arrow
                                          : Icons.circle_outlined),
                                color: isPast
                                    ? Colors.green
                                    : (isActive ? Colors.blue : Colors.white38),
                                size: 18,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  step,
                                  style: TextStyle(
                                    color: isActive
                                        ? Colors.white
                                        : Colors.white54,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _validate,
                        icon: const Icon(Icons.check_circle),
                        label: Text(
                          t('valModel'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEAB308),
                          foregroundColor: const Color(0xFF0F172A),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  border: Border(top: BorderSide(color: Colors.white12)),
                ),
                child: Text(
                  t('footer_copy'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingMissionCard() {
    final steps = _getSteps();

    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.track_changes,
                color: Color(0xFFEAB308),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                t('missionObj'),
                style: const TextStyle(
                  color: Color(0xFFEAB308),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            t('s${_currentScenarioId}_obj'),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const Divider(color: Colors.white24, height: 24),
          Row(
            children: [
              const Icon(Icons.list_alt, color: Color(0xFF3B82F6), size: 16),
              const SizedBox(width: 8),
              Text(
                'STEP ${_currentStepIndex + 1} OF ${steps.length}',
                style: const TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            steps[_currentStepIndex],
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _currentStepIndex > 0
                    ? () {
                        _playSound(_clickSound);
                        setState(() {
                          _currentStepIndex--;
                          _slots.clear();
                        });
                      }
                    : null,
                icon: const Icon(Icons.arrow_back_ios, size: 14),
                color: Colors.white,
                disabledColor: Colors.white24,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
              ElevatedButton(
                onPressed: _validate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEAB308),
                  foregroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                ),
                child: Text(
                  t('valModel'),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: _currentStepIndex < steps.length - 1
                    ? () {
                        _playSound(_clickSound);
                        setState(() {
                          _currentStepIndex++;
                          _slots.clear();
                        });
                      }
                    : null,
                icon: const Icon(Icons.arrow_forward_ios, size: 14),
                color: Colors.white,
                disabledColor: Colors.white24,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<String> _getSteps() {
    switch (_currentScenarioId) {
      case 1:
        return [t('s1_step1'), t('s1_step2'), t('s1_step3')];
      case 2:
        return [t('s2_step1'), t('s2_step2'), t('s2_step3'), t('s2_step4')];
      case 3:
        return [t('s3_step1'), t('s3_step2'), t('s3_step3'), t('s3_step4')];
      case 4:
        return [t('s4_step1'), t('s4_step2'), t('s4_step3'), t('s4_step4')];
      default:
        return [];
    }
  }
}
